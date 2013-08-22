From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH V4] ipv6: handle Redirect ICMP Message with no Redirected
 Header option
Date: Thu, 22 Aug 2013 12:07:35 +0800
Message-ID: <52158E87.7060305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:25244 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752663Ab3HVEH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 00:07:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

rfc 4861 says the Redirected Header option is optional, so
the kernel should not drop the Redirect Message that has no
Redirected Header option. In this patch, the function
ip6_redirect_no_header() is introduced to deal with that
condition.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 Changes for v4:
 1. Remove symbol export

 include/net/ip6_route.h |    2 ++
 net/ipv6/ndisc.c        |    4 +++-
 net/ipv6/route.c        |   21 +++++++++++++++++++++
 3 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 260f83f..f667248 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -135,6 +135,8 @@ extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
 			       __be32 mtu);
 extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
+extern void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
+				   u32 mark);
 extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
 struct netlink_callback;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 79aa965..04d31c2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1369,8 +1369,10 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
 		return;
 
-	if (!ndopts.nd_opts_rh)
+	if (!ndopts.nd_opts_rh) {
+		ip6_redirect_no_header(skb, dev_net(skb->dev), 0, 0);
 		return;
+	}
 
 	hdr = (u8 *)ndopts.nd_opts_rh;
 	hdr += 8;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b70f897..8d9a93e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1178,6 +1178,27 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 }
 EXPORT_SYMBOL_GPL(ip6_redirect);
 
+void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
+			    u32 mark)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct rd_msg *msg = (struct rd_msg *)icmp6_hdr(skb);
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_oif = oif;
+	fl6.flowi6_mark = mark;
+	fl6.flowi6_flags = 0;
+	fl6.daddr = msg->dest;
+	fl6.saddr = iph->daddr;
+
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (!dst->error)
+		rt6_do_redirect(dst, NULL, skb);
+	dst_release(dst);
+}
+
 void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
 {
 	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
-- 
1.7.3.1
