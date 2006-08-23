From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/44] [XFRM]: Introduce a helper to compare id protocol.
Date: Thu, 24 Aug 2006 00:02:03 +0900
Message-ID: <11563453653169-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:56968 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964914AbWHWPCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:49 -0400
To: davem@davemloft.net
In-Reply-To: <11563453651533-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Put the helper to header for future use.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h    |    6 ++++++
 net/xfrm/xfrm_state.c |    6 +++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f47965b..6f29529 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -10,6 +10,7 @@ #include <linux/skbuff.h>
 #include <linux/socket.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
+#include <linux/ipsec.h>
 #include <linux/in6.h>
 #include <linux/mutex.h>
 
@@ -836,6 +837,11 @@ static inline int xfrm_state_kern(struct
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
index 1c79608..34c038c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -294,7 +294,7 @@ void xfrm_state_flush(u8 proto)
 restart:
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
 			if (!xfrm_state_kern(x) &&
-			    (proto == IPSEC_PROTO_ANY || x->id.proto == proto)) {
+			    xfrm_id_proto_match(x->id.proto, proto)) {
 				xfrm_state_hold(x);
 				spin_unlock_bh(&xfrm_state_lock);
 
@@ -772,7 +772,7 @@ int xfrm_state_walk(u8 proto, int (*func
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
-			if (proto == IPSEC_PROTO_ANY || x->id.proto == proto)
+			if (xfrm_id_proto_match(x->id.proto, proto))
 				count++;
 		}
 	}
@@ -783,7 +783,7 @@ int xfrm_state_walk(u8 proto, int (*func
 
 	for (i = 0; i < XFRM_DST_HSIZE; i++) {
 		list_for_each_entry(x, xfrm_state_bydst+i, bydst) {
-			if (proto != IPSEC_PROTO_ANY && x->id.proto != proto)
+			if (!xfrm_id_proto_match(x->id.proto, proto))
 				continue;
 			err = func(x, --count, data);
 			if (err)
-- 
1.4.0

