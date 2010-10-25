From: Ben Greear <greearb@candelatech.com>
Subject: Re: Reproducible VLAN/e1000e crash in 2.6.36 vanilla.
Date: Mon, 25 Oct 2010 14:18:05 -0700
Message-ID: <4CC5F40D.8050302@candelatech.com>
References: <4CC5C51F.3000606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53327 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab0JYVSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:18:08 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o9PLI5Vu010457
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 14:18:05 -0700
In-Reply-To: <4CC5C51F.3000606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2010 10:57 AM, Ben Greear wrote:
>
> To re-create, setup 2 802.1q vlans on different physical interfaces on
> the same system,
> set up routing rules such that send-to-self works, and pass traffic
> (UDP/IPv4 in this case,
> but doesn't seem to matter).
> Stop traffic, then attempt to create additional 802.1q vlans on the same
> physical interfaces.
> The crash only appears to happen after having sent traffic on the
> interface.
>
> Likely it will also crash if one system is sending to another, but so
> far we've
> just tested sending-to-self.
>
> This appears very reproducible for us, and appears to be the same
> problem that
> I had reported against our hacked kernel here:
>
> http://www.spinics.net/lists/netdev/msg144748.html

Bleh, I think I see the problem.

If a NIC is in promis mode, it can receive VLAN packets for which there
are no VLAN devices.

static gro_result_t
vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
                 unsigned int vlan_tci, struct sk_buff *skb)
{
         struct sk_buff *p;
         struct net_device *vlan_dev;
         u16 vlan_id;

         if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
                 skb->deliver_no_wcard = 1;

         skb->skb_iif = skb->dev->ifindex;
         __vlan_hwaccel_put_tag(skb, vlan_tci);
         vlan_id = vlan_tci & VLAN_VID_MASK;
         vlan_dev = vlan_group_get_device(grp, vlan_id);

         if (vlan_dev)
                 skb->dev = vlan_dev;
         else if (vlan_id) {
                 if (!(skb->dev->flags & IFF_PROMISC))
                         goto drop;
                 skb->pkt_type = PACKET_OTHERHOST;
         }

You hit that else branch, and then skb->dev remains the physical
device.

Later, it's passed to:

int vlan_hwaccel_do_receive(struct sk_buff *skb)
{
	struct net_device *dev = skb->dev;
	struct vlan_rx_stats     *rx_stats;

	skb->dev = vlan_dev_info(dev)->real_dev;
	netif_nit_deliver(skb);


which does no checking before assuming that skb->dev is a vlan
device.

Things go downhill rapidly after that.


Maybe this code in dev.c should check that skb->dev is
VLAN device before passing to the hwaccel code?

static int __netif_receive_skb(struct sk_buff *skb)
{
	struct packet_type *ptype, *pt_prev;
	rx_handler_func_t *rx_handler;
	struct net_device *orig_dev;
	struct net_device *master;
	struct net_device *null_or_orig;
	struct net_device *orig_or_bond;
	int ret = NET_RX_DROP;
	__be16 type;

	if (!netdev_tstamp_prequeue)
		net_timestamp_check(skb);

	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
		return NET_RX_SUCCESS;


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

