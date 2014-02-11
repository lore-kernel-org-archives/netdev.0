From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Tue, 11 Feb 2014 03:11:50 +0100
Message-ID: <20140211021150.GB11150@order.stressinduktion.org>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com> <20140207222840.GD16198@order.stressinduktion.org> <CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com> <20140208005843.GE16198@order.stressinduktion.org> <CALnjE+qiRbLWBJyhig7DFETRLRgAZHqJqUEYGVuJ6nXc7cPguw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45026 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbaBKCLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 21:11:52 -0500
Content-Disposition: inline
In-Reply-To: <CALnjE+qiRbLWBJyhig7DFETRLRgAZHqJqUEYGVuJ6nXc7cPguw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 01:00:14PM -0800, Pravin Shelar wrote:
> On Fri, Feb 7, 2014 at 4:58 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > May I know because of wich vport, vxlan or gre, you did this change?
> >
> It affects both gre and vxlan.

Ok, thanks.

> > I am feeling a bit uncomfortable handling remote and local packets that
> > differently on lower tunnel output (local_df is mostly set on locally
> > originating packets).
> 
> For ip traffic it make sense to turn on local_df only for local
> traffic, since for remote case we can send icmp (frag-needed) back to
> source. No such thing exist for OVS tunnels. ICMP packet are not
> returned to source for the tunnels. That is why to be on safe side,
> local_df is turned on for tunnels in OVS.

I have a proposal:

I don't like it that much because of the many arguments. But I currently
don't see another easy solution. Maybe we should make bool xnet an enum and
test with bitops?

I left the clearing of local_df in skb_scrub_packet as we need it for the
dev_forward_skb case and it should be done that in any case.

This diff is slightly compile tested. ;)

I can test and make proper submit if you agree.

What do you think?

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 026a313..630e72f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1657,7 +1657,7 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		return err;
 
 	return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df,
-			     false);
+			     false, false);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 48ed75c..8863002 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -154,7 +154,8 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
 int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
-		  __u8 tos, __u8 ttl, __be16 df, bool xnet);
+		  __u8 tos, __u8 ttl, __be16 df, bool xnet,
+		  bool clear_local_df);
 
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
 					 int gso_type_mask);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8f519db..5773681 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3903,12 +3903,13 @@ EXPORT_SYMBOL(skb_try_coalesce);
  */
 void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 {
-	if (xnet)
+	if (xnet) {
 		skb_orphan(skb);
+		skb->local_df = 0;
+	}
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->skb_iif = 0;
-	skb->local_df = 0;
 	skb_dst_drop(skb);
 	skb->mark = 0;
 	secpath_reset(skb);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index c0e3cb7..2922ec9 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -721,7 +721,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
-			    tos, ttl, df, !net_eq(tunnel->net, dev_net(dev)));
+			    tos, ttl, df, !net_eq(tunnel->net, dev_net(dev)),
+			    true);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
 	return;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6156f4e..93beb04 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -48,13 +48,16 @@
 
 int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
-		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
+		  __u8 tos, __u8 ttl, __be16 df, bool xnet, 
+		  bool clear_df)
 {
 	int pkt_len = skb->len;
 	struct iphdr *iph;
 	int err;
 
 	skb_scrub_packet(skb, xnet);
+	if (clear_df)
+		skb->local_df = 0;
 
 	skb_clear_hash(skb);
 	skb_dst_set(skb, &rt->dst);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3dfbcf1..cc0be0e 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -974,7 +974,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
-			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));
+			    ttl, df, !net_eq(tunnel->net, dev_net(dev)), true);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
 
