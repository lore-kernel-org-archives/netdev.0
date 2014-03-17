From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH v2] ipv6: ip6_append_data_mtu do not handle the mtu of the second fragment properly
Date: Mon, 17 Mar 2014 12:51:01 +0800
Message-ID: <1395031861-19564-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:62143 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbaCQEvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 00:51:14 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so5089294pdi.35
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 21:51:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip6_append_data_mtu(), when the xfrm mode is not tunnel(such as
transport),the ipsec header need to be added in the first fragment, so the mtu
will decrease to reserve space for it, then the second fragment come, the mtu
should be turn back, as the commit 0c1833797a5a6ec23ea9261d979aa18078720b74
said.  however, in the commit a493e60ac4bbe2e977e7129d6d8cbb0dd236be, it use
*mtu = min(*mtu, ...) to change the mtu, which lead to the new mtu is alway
equal with the first fragment's. and cannot turn back.

when I test through  ping6 -c1 -s5000 $ip (mtu=1280):
...frag (0|1232) ESP(spi=0x00002000,seq=0xb), length 1232
...frag (1232|1216)
...frag (2448|1216)
...frag (3664|1216)
...frag (4880|164)

which should be:
...frag (0|1232) ESP(spi=0x00001000,seq=0x1), length 1232
...frag (1232|1232)
...frag (2464|1232)
...frag (3696|1232)
...frag (4928|116)

so delete the min() when change back the mtu.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6_output.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 90dd551..6184dfa 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1101,21 +1101,19 @@ static void ip6_append_data_mtu(unsigned int *mtu,
 				unsigned int fragheaderlen,
 				struct sk_buff *skb,
 				struct rt6_info *rt,
-				bool pmtuprobe)
+				unsigned int orig_mtu)
 {
 	if (!(rt->dst.flags & DST_XFRM_TUNNEL)) {
 		if (skb == NULL) {
 			/* first fragment, reserve header_len */
-			*mtu = *mtu - rt->dst.header_len;
+			*mtu = orig_mtu - rt->dst.header_len;
 
 		} else {
 			/*
 			 * this fragment is not first, the headers
 			 * space is regarded as data space.
 			 */
-			*mtu = min(*mtu, pmtuprobe ?
-				   rt->dst.dev->mtu :
-				   dst_mtu(rt->dst.path));
+			*mtu = orig_mtu;
 		}
 		*maxfraglen = ((*mtu - fragheaderlen) & ~7)
 			      + fragheaderlen - sizeof(struct frag_hdr);
@@ -1132,7 +1130,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_cork *cork;
 	struct sk_buff *skb, *skb_prev = NULL;
-	unsigned int maxfraglen, fragheaderlen, mtu;
+	unsigned int maxfraglen, fragheaderlen, mtu, orig_mtu;
 	int exthdrlen;
 	int dst_exthdrlen;
 	int hh_len;
@@ -1214,6 +1212,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		dst_exthdrlen = 0;
 		mtu = cork->fragsize;
 	}
+	orig_mtu = mtu;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
 
@@ -1313,8 +1312,7 @@ alloc_new_skb:
 			if (skb == NULL || skb_prev == NULL)
 				ip6_append_data_mtu(&mtu, &maxfraglen,
 						    fragheaderlen, skb, rt,
-						    np->pmtudisc >=
-						    IPV6_PMTUDISC_PROBE);
+						    orig_mtu);
 
 			skb_prev = skb;
 
-- 
1.8.3.1
