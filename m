From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 15/19] ndisc: Use ndisc_send_skb() for redirect.
Date: Tue, 22 Jan 2013 01:49:03 +0900
Message-ID: <50FD717F.8090101@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50374 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753053Ab3AUQtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:49:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reuse dst if one is attached with skb.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   37 ++++++++++++++-----------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f0c436b..437781c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -467,10 +467,8 @@ static void ndisc_send_skb(struct sk_buff *skb,
 			   const struct in6_addr *daddr,
 			   const struct in6_addr *saddr)
 {
-	struct flowi6 fl6;
-	struct dst_entry *dst;
+	struct dst_entry *dst = skb_dst(skb);
 	struct net *net = dev_net(skb->dev);
-	struct sock *sk = net->ipv6.ndisc_sk;
 	struct inet6_dev *idev;
 	int err;
 	struct icmp6hdr *icmp6h = icmp6_hdr(skb);
@@ -478,14 +476,19 @@ static void ndisc_send_skb(struct sk_buff *skb,
 
 	type = icmp6h->icmp6_type;
 
-	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
-	dst = icmp6_dst_alloc(skb->dev, &fl6);
-	if (IS_ERR(dst)) {
-		kfree_skb(skb);
-		return;
-	}
+	if (!dst) {
+		struct sock *sk = net->ipv6.ndisc_sk;
+		struct flowi6 fl6;
 
-	skb_dst_set(skb, dst);
+		icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
+		dst = icmp6_dst_alloc(skb->dev, &fl6);
+		if (IS_ERR(dst)) {
+			kfree_skb(skb);
+			return;
+		}
+
+		skb_dst_set(skb, dst);
+	}
 
 	rcu_read_lock();
 	idev = __in6_dev_get(dst->dev);
@@ -1404,10 +1407,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct in6_addr saddr_buf;
 	struct rt6_info *rt;
 	struct dst_entry *dst;
-	struct inet6_dev *idev;
 	struct flowi6 fl6;
 	int rd_len;
-	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 	bool ret;
 
@@ -1515,17 +1516,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		   inet6_sk(sk)->hop_limit, buff->len);
 
 	skb_dst_set(buff, dst);
-	rcu_read_lock();
-	idev = __in6_dev_get(dst->dev);
-	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
-		      dst_output);
-	if (!err) {
-		ICMP6MSGOUT_INC_STATS(net, idev, NDISC_REDIRECT);
-		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
-	}
-
-	rcu_read_unlock();
+	ndisc_send_skb(buff, &ipv6_hdr(skb)->saddr, &saddr_buf);
 	return;
 
 release:
-- 
1.7.9.5
