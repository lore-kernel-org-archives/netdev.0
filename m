From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] net: deliver skbs on inactive slaves to exact matches
Date: Thu, 06 May 2010 11:01:04 -0700
Message-ID: <25360.1273168864@death.nxdomain.ibm.com>
References: <20100506172438.26339.93520.stgit@jf-dev2-dcblab>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	christopher.leech@intel.com, andy@greyhouse.net, kaber@trash.net
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54278 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759230Ab0EFSBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 14:01:11 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o46HjOlF001672
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 13:45:24 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o46I19I7103304
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 14:01:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o46I17ew008947
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 14:01:08 -0400
In-reply-to: <20100506172438.26339.93520.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.r.fastabend@intel.com> wrote:

>Currently, the accelerated receive path for VLAN's will
>drop packets if the real device is an inactive slave and
>is not one of the special pkts tested for in
>skb_bond_should_drop().  This behavior is different then
>the non-accelerated path and for pkts over a bonded vlan.
>
>For example,
>
>vlanx -> bond0 -> ethx
>
>will be dropped in the vlan path and not delivered to any
>packet handlers.  However,
>
>bond0 -> vlanx -> ethx
>
>will be delivered to handlers that match the exact dev,
>because the VLAN path checks the real_dev which is not a
>slave and netif_recv_skb() doesn't drop frames but only
>delivers them to exact matches.
>
>This patch adds a pkt_type PACKET_DROP which is now used
>to identify skbs that would previously been dropped and
>allows the skb to continue to skb_netif_recv().  Here we
>add logic to check for PACKET_DROP and if so only deliver
>to handlers that match exactly.  IMHO this is more
>consistent and gives pkt handlers a way to identify skbs
>that come from inactive slaves.

	I was looking at this some yesterday and this morning, trying to
figure out if a packet going up the IP protocol stack with pkt_type ==
PACKET_DROP would break anything.  For example:

net/ipv4/ip_options.c:
int ip_options_rcv_srr(struct sk_buff *skb)
{
[...]
        if (!opt->srr)
                return 0;

        if (skb->pkt_type != PACKET_HOST)
                return -EINVAL;

	or:

net/ipv4/tcp_ipv4.c:
int tcp_v4_rcv(struct sk_buff *skb)
{
        const struct iphdr *iph;
        struct tcphdr *th;
        struct sock *sk;
        int ret;
        struct net *net = dev_net(skb->dev);

        if (skb->pkt_type != PACKET_HOST)
                goto discard_it;

	Is pkt_type == PACKET_DROP instead going to break things for
these, or the other similar cases?

	I think what you're looking for is really the usual PACKET_HOST,
PACKET_OTHERHOST, et al, upper protocol behavior, with the exception
that at the __netif_receive_skb level, wildcard matches in the ptypes
are not done.  Setting the pkt_type to PACKET_DROP loses the _HOST,
_OTHERHOST, etc, information, but sends the packet up the stack anyway,
and I'm not sure that's really the right thing to do.

	-J

>This allows a third case to function which is important for
>doing multipath with FCoE traffic while LAN traffic bonded,
>
>bond0 -> ethx
>          |
>vlanx -> --
>
>Here the vlan is not in bond0 but the FCoE handler can still
>receive the skb.  Previously these skbs were dropped.
>
>I have tested the following 4 configurations in failover modes
>and load balancing modes and have not seen any duplicate packets
>or unexpected bahavior.
>
># bond0 -> ethx
>
># vlanx -> bond0 -> ethx
>
># bond0 -> vlanx -> ethx
>
># bond0 -> ethx
>            |
>  vlanx -> --
>
>Also this removes the PACKET_FASTROUTE define which was not being
>used.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>---
>
> include/linux/if_packet.h |    2 +-
> net/8021q/vlan_core.c     |    4 ++--
> net/core/dev.c            |   25 ++++++++++++++++++-------
> 3 files changed, 21 insertions(+), 10 deletions(-)
>
>diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
>index 6ac23ef..9d079fa 100644
>--- a/include/linux/if_packet.h
>+++ b/include/linux/if_packet.h
>@@ -28,7 +28,7 @@ struct sockaddr_ll {
> #define PACKET_OUTGOING		4		/* Outgoing of any type */
> /* These ones are invisible by user level */
> #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
>-#define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
>+#define PACKET_DROP		6		/* Drop packet 		*/
>
> /* Packet socket options */
>
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index c584a0a..4510e08 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -12,7 +12,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
> 		return NET_RX_DROP;
>
> 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>-		goto drop;
>+		skb->pkt_type = PACKET_DROP;
>
> 	skb->skb_iif = skb->dev->ifindex;
> 	__vlan_hwaccel_put_tag(skb, vlan_tci);
>@@ -84,7 +84,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
> 	struct sk_buff *p;
>
> 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>-		goto drop;
>+		skb->pkt_type = PACKET_DROP;
>
> 	skb->skb_iif = skb->dev->ifindex;
> 	__vlan_hwaccel_put_tag(skb, vlan_tci);
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 36d53be..cefac4f 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -2776,7 +2776,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 	struct net_device *orig_dev;
> 	struct net_device *master;
> 	struct net_device *null_or_orig;
>-	struct net_device *null_or_bond;
>+	struct net_device *dev_or_bond;
> 	int ret = NET_RX_DROP;
> 	__be16 type;
>
>@@ -2793,13 +2793,24 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 	if (!skb->skb_iif)
> 		skb->skb_iif = skb->dev->ifindex;
>
>+	/*
>+	 * bonding note: skbs received on inactive slaves should only
>+	 * be delivered to pkt handlers that are exact matches.  Also
>+	 * the pkt_type field will be marked PACKET_DROP.  If packet
>+	 * handlers are sensitive to duplicate packets these skbs will
>+	 * need to be dropped at the handler.  The vlan accel path may
>+	 * have already set PACKET_DROP.
>+	 */
> 	null_or_orig = NULL;
> 	orig_dev = skb->dev;
> 	master = ACCESS_ONCE(orig_dev->master);
>-	if (master) {
>-		if (skb_bond_should_drop(skb, master))
>+	if (skb->pkt_type == PACKET_DROP)
>+		null_or_orig = orig_dev;
>+	else if (master) {
>+		if (skb_bond_should_drop(skb, master)) {
>+			skb->pkt_type = PACKET_DROP;
> 			null_or_orig = orig_dev; /* deliver only exact match */
>-		else
>+		} else
> 			skb->dev = master;
> 	}
>
>@@ -2849,10 +2860,10 @@ ncls:
> 	 * device that may have registered for a specific ptype.  The
> 	 * handler may have to adjust skb->dev and orig_dev.
> 	 */
>-	null_or_bond = NULL;
>+	dev_or_bond = skb->dev;
> 	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
> 	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
>-		null_or_bond = vlan_dev_real_dev(skb->dev);
>+		dev_or_bond = vlan_dev_real_dev(skb->dev);
> 	}
>
> 	type = skb->protocol;
>@@ -2860,7 +2871,7 @@ ncls:
> 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
> 		if (ptype->type == type && (ptype->dev == null_or_orig ||
> 		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
>-		     ptype->dev == null_or_bond)) {
>+		     ptype->dev == dev_or_bond)) {
> 			if (pt_prev)
> 				ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = ptype;
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
