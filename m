From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: Do route updating for redirect in ndisc layer
Date: Mon, 09 Sep 2013 15:09:56 +0800
Message-ID: <522D7444.20505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:22573 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751329Ab3IIHKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 03:10:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

In rfc2473, we can know that the tunnel ICMP redirect
message should not be reported to the source of the
original packet, so after calling ip6_tnl_err(), the
rel_msg is set to 0 in function ip4ip6_err(), and the
redirect will never be handled.

In order to deal with this, we have to choices:
  1.move the call to ->redirect to ip6_tnl_err
    and afterwards set rel_msg to 0
  2.factor out the calls to ->redirect into the
    ndisc layer

In this patch , i choose the second one, because i found
the ip6_redirect() could be replaced with
ip6_redirect_no_header(), we could always use ip6_redirect()
for route updating in ndisc layer and use the data of the
redirected header option just for finding the socket to be
notified and then notify user in protocols' err_handler.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 include/net/ip6_route.h |  3 ---
 net/dccp/ipv6.c         |  7 -------
 net/ipv6/ah6.c          |  4 +---
 net/ipv6/esp6.c         |  4 +---
 net/ipv6/icmp.c         |  2 --
 net/ipv6/ip6_tunnel.c   |  5 -----
 net/ipv6/ipcomp6.c      |  4 +---
 net/ipv6/ndisc.c        |  6 ++----
 net/ipv6/raw.c          |  2 --
 net/ipv6/route.c        | 29 ++---------------------------
 net/ipv6/tcp_ipv6.c     |  8 --------
 net/ipv6/udp.c          |  2 --
 net/sctp/input.c        | 12 ------------
 net/sctp/ipv6.c         |  3 ---
 14 files changed, 7 insertions(+), 84 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f525e70..5db259e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -133,9 +133,6 @@ extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
 			       __be32 mtu);
 extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
-extern void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
-				   u32 mark);
-extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
 struct netlink_callback;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c61f9c..ed124f7 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -130,13 +130,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
-	if (type == NDISC_REDIRECT) {
-		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst)
-			dst->ops->redirect(dst, sk, skb);
-	}
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 73784c3..084c1e7 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -627,9 +627,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
-	else
+	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d3618a7..b65f9c3 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -446,9 +446,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
-	else
+	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index eef8d94..4bde43c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -91,8 +91,6 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_update_pmtu(skb, net, info, 0, 0);
-	else if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 
 	if (!(type & ICMPV6_INFOMSG_MASK))
 		if (icmp6->icmp6_type == ICMPV6_ECHO_REQUEST)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61355f7..3ea834b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -576,9 +576,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rel_type = ICMP_DEST_UNREACH;
 		rel_code = ICMP_FRAG_NEEDED;
 		break;
-	case NDISC_REDIRECT:
-		rel_type = ICMP_REDIRECT;
-		rel_code = ICMP_REDIR_HOST;
 	default:
 		return 0;
 	}
@@ -637,8 +634,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_info);
 	}
-	if (rel_type == ICMP_REDIRECT)
-		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 5636a91..9624058 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -75,9 +75,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	if (type == NDISC_REDIRECT)
-		ip6_redirect(skb, net, skb->dev->ifindex, 0);
-	else
+	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1217945..e990f09 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1368,11 +1368,9 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
 		return;
 
-	if (!ndopts.nd_opts_rh) {
-		ip6_redirect_no_header(skb, dev_net(skb->dev),
-					skb->dev->ifindex, 0);
+	ip6_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0);
+	if (!ndopts.nd_opts_rh)
 		return;
-	}
 
 	hdr = (u8 *)ndopts.nd_opts_rh;
 	hdr += 8;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 58916bb..ea62e1f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -335,8 +335,6 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		ip6_sk_update_pmtu(skb, sk, info);
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
 	}
-	if (type == NDISC_REDIRECT)
-		ip6_sk_redirect(skb, sk);
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c979dd9..151bd6c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1227,27 +1227,7 @@ static struct dst_entry *ip6_route_redirect(struct net *net,
 				flags, __ip6_route_redirect);
 }
 
-void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
-{
-	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
-	struct dst_entry *dst;
-	struct flowi6 fl6;
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_oif = oif;
-	fl6.flowi6_mark = mark;
-	fl6.flowi6_flags = 0;
-	fl6.daddr = iph->daddr;
-	fl6.saddr = iph->saddr;
-	fl6.flowlabel = ip6_flowinfo(iph);
-
-	dst = ip6_route_redirect(net, &fl6, &ipv6_hdr(skb)->saddr);
-	rt6_do_redirect(dst, NULL, skb);
-	dst_release(dst);
-}
-EXPORT_SYMBOL_GPL(ip6_redirect);
-
-void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
+void ip6_redirect(struct sk_buff *skb, struct net *net, int oif,
 			    u32 mark)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -1266,12 +1246,7 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 	rt6_do_redirect(dst, NULL, skb);
 	dst_release(dst);
 }
-
-void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
-{
-	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
-}
-EXPORT_SYMBOL_GPL(ip6_sk_redirect);
+EXPORT_SYMBOL_GPL(ip6_redirect);
 
 static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5c71501..61fe8e5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -382,14 +382,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
-	if (type == NDISC_REDIRECT) {
-		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst)
-			dst->ops->redirect(dst, sk, skb);
-		goto out;
-	}
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		/* We are not interested in TCP_LISTEN and open_requests
 		 * (SYN-ACKs send out by Linux are always <576bytes so
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f405815..a40b392 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -525,8 +525,6 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type == ICMPV6_PKT_TOOBIG)
 		ip6_sk_update_pmtu(skb, sk, info);
-	if (type == NDISC_REDIRECT)
-		ip6_sk_redirect(skb, sk);
 
 	np = inet6_sk(sk);
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5f20686..0d2d4b7 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -413,18 +413,6 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 	sctp_retransmit(&asoc->outqueue, t, SCTP_RTXR_PMTUD);
 }
 
-void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
-			struct sk_buff *skb)
-{
-	struct dst_entry *dst;
-
-	if (!t)
-		return;
-	dst = sctp_transport_dst_check(t);
-	if (dst)
-		dst->ops->redirect(dst, sk, skb);
-}
-
 /*
  * SCTP Implementer's Guide, 2.37 ICMP handling procedures
  *
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index da613ce..1d143d1 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -181,9 +181,6 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			goto out_unlock;
 		}
 		break;
-	case NDISC_REDIRECT:
-		sctp_icmp_redirect(sk, transport, skb);
-		break;
 	default:
 		break;
 	}
-- 
1.8.3.1
