From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.19] [IPV6]: Fix address/interface handling in UDP and
 DCCP, according to the scoping architecture.
Date: Tue, 21 Nov 2006 01:43:06 +0900 (JST)
Message-ID: <20061121.014306.76909112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48256 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S934266AbWKTQnG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 11:43:06 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Fix address/interface handling in UDP and DCCP, according to the scoping architecture.

TCP and RAW do not have this issue.  Closes Bug #7432.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index eb0ff7a..fc4242c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -277,7 +277,7 @@ static void dccp_v6_err(struct sk_buff *
 	__u64 seq;
 
 	sk = inet6_lookup(&dccp_hashinfo, &hdr->daddr, dh->dccph_dport,
-			  &hdr->saddr, dh->dccph_sport, skb->dev->ifindex);
+			  &hdr->saddr, dh->dccph_sport, inet6_iif(skb));
 
 	if (sk == NULL) {
 		ICMP6_INC_STATS_BH(__in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e0c3934..c83f23e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -242,14 +242,13 @@ static void udpv6_err(struct sk_buff *sk
 {
 	struct ipv6_pinfo *np;
 	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
-	struct net_device *dev = skb->dev;
 	struct in6_addr *saddr = &hdr->saddr;
 	struct in6_addr *daddr = &hdr->daddr;
 	struct udphdr *uh = (struct udphdr*)(skb->data+offset);
 	struct sock *sk;
 	int err;
 
-	sk = udp_v6_lookup(daddr, uh->dest, saddr, uh->source, dev->ifindex);
+	sk = udp_v6_lookup(daddr, uh->dest, saddr, uh->source, inet6_iif(skb));
    
 	if (sk == NULL)
 		return;
@@ -348,7 +347,7 @@ static void udpv6_mcast_deliver(struct u
 
 	read_lock(&udp_hash_lock);
 	sk = sk_head(&udp_hash[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
-	dif = skb->dev->ifindex;
+	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
 		kfree_skb(skb);
@@ -429,7 +428,7 @@ static int udpv6_rcv(struct sk_buff **ps
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = udp_v6_lookup(saddr, uh->source, daddr, uh->dest, dev->ifindex);
+	sk = udp_v6_lookup(saddr, uh->source, daddr, uh->dest, inet6_iif(skb));
 
 	if (sk == NULL) {
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))


-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
