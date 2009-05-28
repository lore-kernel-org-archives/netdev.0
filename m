From: Andy Gospodarek <adgospod@gmail.com>
Subject: Re: [PATCH net-next] bonding: allow bond in mode balance-alb to work properly in bridge -try4.3
Date: Thu, 28 May 2009 08:11:30 -0400
Message-ID: <9DF1DDD3-611B-40E7-9132-038BDCB86CC7@gmail.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090526151717.GB11147@psychotron.englab.brq.redhat.com> <20090527135351.GD1652@psychotron.englab.brq.redhat.com> <20090528110459.GE22391@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0 (iPhone Mail 5G77)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"mschmidt@redhat.com" <mschmidt@redhat.com>,
	"dada1@cosmosbay.com" <dada1@cosmosbay.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"oleg@redhat.com" <oleg@redhat.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f190.google.com ([209.85.221.190]:46607 "EHLO
	mail-qy0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbZE1MLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 08:11:36 -0400
Received: by qyk28 with SMTP id 28so5384317qyk.33
        for <netdev@vger.kernel.org>; Thu, 28 May 2009 05:11:37 -0700 (PDT)
In-Reply-To: <20090528110459.GE22391@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 28, 2009, at 7:05 AM, Jiri Pirko <jpirko@redhat.com> wrote:

> [PATCH net-next] bonding: allow bond in mode balance-alb to work  
> properly in bridge -try4.3
>
> (updated)
> changes v4.2 -> v4.3
> - memcpy the address always, not just in case it differs from master- 
> >dev_addr
> - compare_ether_addr_64bits() is not used so there is no direct need  
> to make new
>  header file (I think it would be good to have bond stuff in  
> separate file
>  anyway).
>
> changes v4.1 -> v4.2
> - use skb->pkt_type == PACKET_HOST compare rather then comparing skb  
> dest addr
>  against skb->dev->dev_addr
>
> Hi all.
>
> The problem is described in following bugzilla:
> https://bugzilla.redhat.com/show_bug.cgi?id=487763
>
> Basically here's what's going on. In every mode, bonding interface  
> uses the same
> mac address for all enslaved devices (except fail_over_mac). Only  
> balance-alb
> will simultaneously use multiple MAC addresses across different  
> slaves. When you
> put this kind of bond device into a bridge it will only add one of  
> mac adresses
> into a hash list of mac addresses, say X. This mac address is marked  
> as local.
> But this bonding interface also has mac address Y. Now then packet  
> arrives with
> destination address Y, this address is not marked as local and the  
> packed looks
> like it needs to be forwarded. This packet is then lost which is  
> wrong.
>
> Notice that interfaces can be added and removed from bond while it  
> is in bridge.
>
> ***
> When the multiple addresses for bridge port approach failed to solve  
> this issue
> due to STP I started to think other way to solve this. I returned to  
> previous
> solution but tweaked one.
>
> This patch solves the situation in the bonding without touching  
> bridge code.
> For every incoming frame to bonding the destination address is  
> compared to
> current address of the slave device from which tha packet came. If  
> these two
> match destination address is replaced by mac address of the master.  
> This address
> is known by bridge so it is delivered properly. Note that the  
> comparsion is not
> made directly, it's used skb->pkt_type == PACKET_HOST instead. This  
> is "set"
> previously in eth_type_trans().
>
> I experimentally tried that this works as good as searching through  
> the slave
> list (v4 of this patch).
>
> Jirka
>
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>

This one is fine too.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 371ece5..9b4db94 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1920,6 +1920,16 @@ static inline void  
> netif_set_gso_max_size(struct net_device *dev,
>    dev->gso_max_size = size;
> }
>
> +static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
> +                          struct net_device *master)
> +{
> +    if (skb->pkt_type == PACKET_HOST) {
> +        u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
> +
> +        memcpy(dest, master->dev_addr, ETH_ALEN);
> +    }
> +}
> +
> /* On bonding slaves other than the currently active slave, suppress
>  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
>  * ARP on active-backup slaves with arp_validate enabled.
> @@ -1933,6 +1943,14 @@ static inline int skb_bond_should_drop(struct  
> sk_buff *skb)
>        if (master->priv_flags & IFF_MASTER_ARPMON)
>            dev->last_rx = jiffies;
>
> +        if ((master->priv_flags & IFF_MASTER_ALB) && master- 
> >br_port) {
> +            /* Do address unmangle. The local destination address
> +             * will be always the one master has. Provides the right
> +             * functionality in a bridge.
> +             */
> +            skb_bond_set_mac_by_master(skb, master);
> +        }
> +
>        if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
>            if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
>                skb->protocol == __cpu_to_be16(ETH_P_ARP))
