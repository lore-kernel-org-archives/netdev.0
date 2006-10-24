From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix xfrm_state accounting
Date: Wed, 25 Oct 2006 00:00:58 +0200
Message-ID: <453E8D1A.2040904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020602070703080306060003"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:23437 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422708AbWJXWBV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 18:01:21 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020602070703080306060003
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------020602070703080306060003
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix xfrm_state accounting

xfrm_state_num needs to be increased for XFRM_STATE_ACQ states created
by xfrm_state_find() to prevent the counter from going negative when
the state is destroyed.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d514f03d17b5f7615a549fbe2eb7b57a15aff609
tree 08a95a113236a858dafd3e57afcb959232164cac
parent 5c8ca15198f39a6d346f7573405dcff5c365805e
author Patrick McHardy <kaber@trash.net> Wed, 25 Oct 2006 00:00:03 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 25 Oct 2006 00:00:03 +0200

 net/xfrm/xfrm_state.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 84bbf84..899de9e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -505,6 +505,14 @@ __xfrm_state_locate(struct xfrm_state *x
 						  x->id.proto, family);
 }
 
+static void xfrm_hash_grow_check(int have_hash_collision)
+{
+	if (have_hash_collision &&
+	    (xfrm_state_hmask + 1) < xfrm_state_hashmax &&
+	    xfrm_state_num > xfrm_state_hmask)
+		schedule_work(&xfrm_hash_work);
+}
+
 struct xfrm_state *
 xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
 		struct flowi *fl, struct xfrm_tmpl *tmpl,
@@ -598,6 +606,8 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
 			x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
 			add_timer(&x->timer);
+			xfrm_state_num++;
+			xfrm_hash_grow_check(x->bydst.next != NULL);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
 			xfrm_state_put(x);
@@ -614,14 +624,6 @@ out:
 	return x;
 }
 
-static void xfrm_hash_grow_check(int have_hash_collision)
-{
-	if (have_hash_collision &&
-	    (xfrm_state_hmask + 1) < xfrm_state_hashmax &&
-	    xfrm_state_num > xfrm_state_hmask)
-		schedule_work(&xfrm_hash_work);
-}
-
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
 	unsigned int h;

--------------020602070703080306060003--
