From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Mon, 23 Mar 2015 22:59:43 -0700
Message-ID: <CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
	<20150320.163655.474336751434677390.davem@davemloft.net>
	<550C92F3.50302@cumulusnetworks.com>
	<20150320220946.GB31769@lunn.ch>
	<20150323002215.GA6074@roeck-us.net>
	<550F6D7D.7030403@gmail.com>
	<550F8102.7040701@roeck-us.net>
	<550F8600.2020300@gmail.com>
	<550F8987.5070600@roeck-us.net>
	<5510498D.5010001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guenter Roeck <linux@roeck-us.net>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34831 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbCXF7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 01:59:44 -0400
Received: by qgf74 with SMTP id 74so55453566qgf.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 22:59:43 -0700 (PDT)
In-Reply-To: <5510498D.5010001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:12 AM, roopa <roopa@cumulusnetworks.com> wrote:
> On 3/22/15, 8:33 PM, Guenter Roeck wrote:
>>
>> On 03/22/2015 08:18 PM, John Fastabend wrote:
>> [ ... ]
>>>
>>>
>>> Sorry I probably wasn't being clear. I'm just saying we don't need to
>>> have the driver tell us if the packet has been forwarded. All we have
>>> to do in software is the switch check and assume all packets sent to us
>>> from the driver have already been handled by the hardware. Roopa is
>>> working on this I believe.
>>>
>>
>> Ah, ok. Yes, you are correct. Sorry, I missed that.
>
> yep, so my first RFC listed three ways to do this,
> 1) flag on the bridge port
> 2) check if the port being forwarded to is a switch port, using
>             - the offload flag
>             - the parent id (as john fastabend pointed out)
> 3) A per packet flag which switch driver sets indicating that the packet is
> hw forwarded.
>     This is because we have run into cases where we want to move to software
> forwarding
>     of certain packets like igmp reports.  (I will get some more details on
> the particular igmp problem).
>     In such case, hardware punts the igmp packet to cpu and cpu will do the
> forwarding.
>     I think we may hit more cases like this in the future.
>
> my RFC v1 was based on 1). RFC v2 was based on 3) above.
>
> But, for now, agree that we can just support the more common case using 2).
> And, we can move to 3) in the future if needed.

Roopa, I think it may be possible to do this without any changes to
the bridge code or switchdev code by dropping duplicate pkts in the
swdev driver itself.  The skb is marked with skb_iif set to ifindex of
ingress port, so when the driver goes to egress a pkt on the port, if
the skb_iif is one of the other device ports, we can assume the device
did the fwd already so we can drop the duplicate pkt.  Below is the
change to rocker.  The driver can get as fancy as it wants in its test
to drop or not.  This solution works for mixed offload and
non-offloaded ports in a bridge, or ports from different offload
devices in the same bridge.

Yes, the bridge is spending overhead to clone pkts to flood to its
ports.  IGMP snooping mitigates this for mcast.  BR_FLOOD can be
turned off on the bridge ports to mitigate this for unknown unicast
floods.  So what's left is bcasts.

What do you think?   napi_id looked like another field that could be
used to find the src of the pkt, but skb_iif seemed more straight
forward to use.

diff --git a/drivers/net/ethernet/rocker/rocker.c
b/drivers/net/ethernet/rocker/rocker.c
index aab962c..0f7217f7 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3931,15 +3931,28 @@ unmap_frag:
        return -EMSGSIZE;
 }

+static bool rocker_port_dev_check(struct net_device *dev);
+
 static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct
net_device *dev)
 {
        struct rocker_port *rocker_port = netdev_priv(dev);
        struct rocker *rocker = rocker_port->rocker;
        struct rocker_desc_info *desc_info;
        struct rocker_tlv *frags;
+       struct net_device *in_dev;
        int i;
        int err;

+       if (rocker_port_is_bridged(rocker_port)) {
+               rcu_read_lock();
+               in_dev = dev_get_by_index_rcu(dev_net(dev), skb->skb_iif);
+               if (in_dev && rocker_port_dev_check(in_dev)) {
+                       rcu_read_unlock();
+                       goto skip;
+               }
+               rcu_read_unlock();
+       }
+
        desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
        if (unlikely(!desc_info)) {
                if (net_ratelimit())
@@ -3951,7 +3964,7 @@ static netdev_tx_t rocker_port_xmit(struct
sk_buff *skb, struct net_device *dev)

        frags = rocker_tlv_nest_start(desc_info, ROCKER_TLV_TX_FRAGS);
        if (!frags)
-               goto out;
+               goto drop;
        err = rocker_tx_desc_frag_map_put(rocker_port, desc_info,
                                          skb->data, skb_headlen(skb));
        if (err)
@@ -3983,9 +3996,10 @@ unmap_frags:
        rocker_tx_desc_frags_unmap(rocker_port, desc_info);
 nest_cancel:
        rocker_tlv_nest_cancel(desc_info, frags);
-out:
-       dev_kfree_skb(skb);
+drop:
        dev->stats.tx_dropped++;
+skip:
+       dev_kfree_skb(skb);
