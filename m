From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/23] [PATCH] [XFRM]: Introduce a helper to compare id protocol.
Date: Sat, 29 Jul 2006 18:29:56 +0900
Message-ID: <11541653961483-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:12419 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1750962AbWG2J37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:29:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Put the helper to header for future use.
---
 include/net/xfrm.h    |    6 ++++++
 net/xfrm/xfrm_state.c |    6 +++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ddb153d..ca537b5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -10,6 +10,7 @@ #include <linux/skbuff.h>
 #include <linux/socket.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
+#include <linux/ipsec.h>
 #include <linux/in6.h>
 #include <linux/mutex.h>
 
@@ -826,6 +827,11 @@ static inline int xfrm_state_kern(struct
 	return atomic_read(&x->tunnel_users);
 }
 
+static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
+{
+	return (userproto == IPSEC_PROTO_ANY || proto == userproto);
+}
+
 /*
  * xfrm algorithm information
  */
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 93a2f36..6cf080f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -293,7 +293,7 @@ void xfrm_state_flush(u8 proto)
 restart:
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
-			    (proto == IPSEC_PROTO_ANY || x->id.proto == proto)) {
+			    xfrm_id_proto_match(x->id.proto, proto)) {
 				xfrm_state_hold(x);
 				spin_unlock_bh(&xfrm_state_lock);
 
@@ -763,7 +763,7 @@ int xfrm_state_walk(u8 proto, int (*func
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
-			if (proto == IPSEC_PROTO_ANY || x->id.proto == proto)
+			if (xfrm_id_proto_match(x->id.proto, proto))
 				count++;
 		}
 	}
@@ -774,7 +774,7 @@ int xfrm_state_walk(u8 proto, int (*func
 
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
-			if (proto != IPSEC_PROTO_ANY && x->id.proto != proto)
+			if (!xfrm_id_proto_match(x->id.proto, proto))
 				continue;
 			err = func(x, --count, data);
 			if (err)
-- 
1.4.1

