From: jamal <hadi@cyberus.ca>
Subject: [IPSEC]: searching  SAD without assumming L3 details
Date: Sat, 02 Sep 2006 09:43:02 -0400
Message-ID: <1157204582.5197.4.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YpGT1/YX+Ske3s6OQ4EA"
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:48263 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751092AbWIBNqR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 09:46:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GJVpD-0001pt-Ah
	for netdev@vger.kernel.org; Sat, 02 Sep 2006 09:46:19 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-YpGT1/YX+Ske3s6OQ4EA
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Against net-2.6.19

signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

--=-YpGT1/YX+Ske3s6OQ4EA
Content-Disposition: attachment; filename=sad-nl3p
Content-Type: text/plain; name=sad-nl3p; charset=UTF-8
Content-Transfer-Encoding: 7bit

Allow for searching the SAD from external data path points without
assumming L3 details. The only customer of this exposure currently
is pktgen.

---
commit 33d3060784e6aa55e30ae7d5efc491180e7f955d
tree 707017ff673d1161f46d69fd818035b6bc50bbdb
parent 0169ac1c2a64f04deeff3dae704f34e22ae59cb7
author Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Sep 2006 09:38:12 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Sat, 02 Sep 2006 09:38:12 -0400

 include/net/xfrm.h    |    4 ++++
 net/xfrm/xfrm_state.c |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bf8e2df..7b0ea47 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -895,6 +895,10 @@ extern struct xfrm_state *xfrm_state_fin
 					  struct flowi *fl, struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
 					  unsigned short family);
+extern struct xfrm_state * xfrm_stateonly_find(xfrm_address_t *daddr, 
+				 	 xfrm_address_t *saddr, 
+					 unsigned short family, 
+					 u32 reqid, u8 mode, u8 proto);
 extern int xfrm_state_check_expire(struct xfrm_state *x);
 extern void xfrm_state_insert(struct xfrm_state *x);
 extern int xfrm_state_add(struct xfrm_state *x);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9f63edd..2bfc04e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -501,6 +501,39 @@ __xfrm_state_locate(struct xfrm_state *x
 }
 
 struct xfrm_state *
+xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
+		unsigned short family, u32 reqid, u8 mode, u8 proto)
+{
+	unsigned int h = xfrm_dst_hash(daddr, saddr, 0, family);
+	struct xfrm_state *rx = NULL, *x = NULL;
+	struct hlist_node *entry;
+	
+	spin_lock(&xfrm_state_lock);
+	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+		if (x->props.family == family &&
+		    x->props.reqid == reqid && 
+		    xfrm_state_addr_check(x, daddr, saddr, family) &&
+		    mode == x->props.mode &&
+		    proto == x->id.proto)  { 
+
+			if (x->km.state != XFRM_STATE_VALID) 
+					continue;
+			else {
+				rx = x;
+				break; 
+			}
+		}
+	}
+	spin_unlock(&xfrm_state_lock);
+
+	if (rx)
+		xfrm_state_hold(rx);
+
+	return rx;
+}
+EXPORT_SYMBOL(xfrm_stateonly_find);
+
+struct xfrm_state *
 xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
 		struct flowi *fl, struct xfrm_tmpl *tmpl,
 		struct xfrm_policy *pol, int *err,

--=-YpGT1/YX+Ske3s6OQ4EA--


-- 
VGER BF report: U 0.499973
