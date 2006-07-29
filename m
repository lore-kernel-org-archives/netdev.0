From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 15/23] [PATCH] [XFRM] STATE: Allow non IPsec protocol.
Date: Sat, 29 Jul 2006 18:30:40 +0900
Message-ID: <1154165440812-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:26243 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161054AbWG2Jal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:41 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It will be added two more transformation protocols (routing header
and destination options header) by Mobile IPv6.
xfrm_id_proto_match() can be handle zero as all, IPSEC_PROTO_ANY as
all IPsec and otherwise as exact one.

Based on MIPL2 kernel patch.
---
 include/net/xfrm.h   |    7 +++++++
 net/xfrm/xfrm_user.c |    4 ++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 67fe834..0b8edad 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -881,7 +881,14 @@ static inline int xfrm_state_kern(struct
 
 static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
 {
+#ifdef CONFIG_XFRM_ADVANCED
+	return (!userproto || proto == userproto ||
+		(userproto == IPSEC_PROTO_ANY && (proto == IPPROTO_AH ||
+						  proto == IPPROTO_ESP ||
+						  proto == IPPROTO_COMP)));
+#else
 	return (userproto == IPSEC_PROTO_ANY || proto == userproto);
+#endif
 }
 
 /*
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 13fe172..a91367d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -598,7 +598,11 @@ static int xfrm_dump_sa(struct sk_buff *
 	info.nlmsg_flags = NLM_F_MULTI;
 	info.this_idx = 0;
 	info.start_idx = cb->args[0];
+#ifdef CONFIG_XFRM_ADVANCED
+	(void) xfrm_state_walk(0, dump_one_state, &info);
+#else
 	(void) xfrm_state_walk(IPSEC_PROTO_ANY, dump_one_state, &info);
+#endif
 	cb->args[0] = info.this_idx;
 
 	return skb->len;
-- 
1.4.1

