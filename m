From: akpm@osdl.org
Subject: [patch 5/9] bnep endianness bug: filtering by packet type
Date: Wed, 08 Nov 2006 19:51:07 -0800
Message-ID: <200611090351.kA93p7gO003690@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, viro@ftp.linux.org.uk,
	marcel@holtmann.org, viro@zeniv.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21935 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161318AbWKIDvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:51:23 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>

<= and => don't work well on net-endian...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/bluetooth/bnep/core.c   |   16 ++++++++--------
 net/bluetooth/bnep/netdev.c |   11 ++++++-----
 2 files changed, 14 insertions(+), 13 deletions(-)

diff -puN net/bluetooth/bnep/core.c~bnep-endianness-bug-filtering-by-packet-type net/bluetooth/bnep/core.c
--- a/net/bluetooth/bnep/core.c~bnep-endianness-bug-filtering-by-packet-type
+++ a/net/bluetooth/bnep/core.c
@@ -117,14 +117,14 @@ static int bnep_send_rsp(struct bnep_ses
 static inline void bnep_set_default_proto_filter(struct bnep_session *s)
 {
 	/* (IPv4, ARP)  */
-	s->proto_filter[0].start = htons(0x0800);
-	s->proto_filter[0].end   = htons(0x0806);
+	s->proto_filter[0].start = ETH_P_IP;
+	s->proto_filter[0].end   = ETH_P_ARP;
 	/* (RARP, AppleTalk) */
-	s->proto_filter[1].start = htons(0x8035);
-	s->proto_filter[1].end   = htons(0x80F3);
+	s->proto_filter[1].start = ETH_P_RARP;
+	s->proto_filter[1].end   = ETH_P_AARP;
 	/* (IPX, IPv6) */
-	s->proto_filter[2].start = htons(0x8137);
-	s->proto_filter[2].end   = htons(0x86DD);
+	s->proto_filter[2].start = ETH_P_IPX;
+	s->proto_filter[2].end   = ETH_P_IPV6;
 }
 #endif
 
@@ -150,8 +150,8 @@ static int bnep_ctrl_set_netfilter(struc
 		int i;
 
 		for (i = 0; i < n; i++) {
-			f[i].start = get_unaligned(data++);
-			f[i].end   = get_unaligned(data++);
+			f[i].start = ntohs(get_unaligned(data++));
+			f[i].end   = ntohs(get_unaligned(data++));
 
 			BT_DBG("proto filter start %d end %d",
 				f[i].start, f[i].end);
diff -puN net/bluetooth/bnep/netdev.c~bnep-endianness-bug-filtering-by-packet-type net/bluetooth/bnep/netdev.c
--- a/net/bluetooth/bnep/netdev.c~bnep-endianness-bug-filtering-by-packet-type
+++ a/net/bluetooth/bnep/netdev.c
@@ -158,14 +158,15 @@ static inline int bnep_net_mc_filter(str
 static inline u16 bnep_net_eth_proto(struct sk_buff *skb)
 {
 	struct ethhdr *eh = (void *) skb->data;
+	u16 proto = ntohs(eh->h_proto);
 	
-	if (ntohs(eh->h_proto) >= 1536)
-		return eh->h_proto;
+	if (proto >= 1536)
+		return proto;
 		
-	if (get_unaligned((u16 *) skb->data) == 0xFFFF)
-		return htons(ETH_P_802_3);
+	if (get_unaligned((__be16 *) skb->data) == htons(0xFFFF))
+		return ETH_P_802_3;
 		
-	return htons(ETH_P_802_2);
+	return ETH_P_802_2;
 }
 
 static inline int bnep_net_proto_filter(struct sk_buff *skb, struct bnep_session *s)
_
