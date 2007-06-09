From: jamal <hadi@cyberus.ca>
Subject: [XFRM] Introduce standalone SAD lookup
Date: Sat, 09 Jun 2007 10:18:06 -0400
Message-ID: <1181398686.4077.19.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-GRAM++N4aawSW30kcFJD"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:19900 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbXFIOSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 10:18:10 -0400
Received: by py-out-1112.google.com with SMTP id a29so1752178pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 07:18:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GRAM++N4aawSW30kcFJD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

3 of 4.

cheers,
jamal

--=-GRAM++N4aawSW30kcFJD
Content-Disposition: attachment; filename=pg-xfrm
Content-Type: text/plain; name=pg-xfrm; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit 923d6c49f9f513da41e4bfd8188304787a5c8093
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sat Jun 9 09:16:12 2007 -0400

    [XFRM] Introduce standalone SAD lookup
    This allows other in-kernel functions to do SAD lookups.
    The only known user at the moment is pktgen.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 311f25a..79d2c37 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -920,6 +920,10 @@ extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
 					  struct flowi *fl, struct xfrm_tmpl *tmpl,
 					  struct xfrm_policy *pol, int *err,
 					  unsigned short family);
+extern struct xfrm_state * xfrm_stateonly_find(xfrm_address_t *daddr,
+					       xfrm_address_t *saddr,
+					       unsigned short family,
+					       u8 mode, u8 proto, u32 reqid);
 extern int xfrm_state_check_expire(struct xfrm_state *x);
 extern void xfrm_state_insert(struct xfrm_state *x);
 extern int xfrm_state_add(struct xfrm_state *x);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 85f3f43..b8562e4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -686,6 +686,41 @@ out:
 	return x;
 }
 
+struct xfrm_state *
+xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
+		    unsigned short family, u8 mode, u8 proto, u32 reqid)
+{
+	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
+	struct xfrm_state *rx = NULL, *x = NULL;
+	struct hlist_node *entry;
+
+	spin_lock(&xfrm_state_lock);
+	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+		if (x->props.family == family &&
+		    x->props.reqid == reqid &&
+		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
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
+
+	if (rx)
+		xfrm_state_hold(rx);
+	spin_unlock(&xfrm_state_lock);
+
+
+	return rx;
+}
+EXPORT_SYMBOL(xfrm_stateonly_find);
+
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
 	unsigned int h;

--=-GRAM++N4aawSW30kcFJD--

