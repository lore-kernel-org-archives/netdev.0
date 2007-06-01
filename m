From: jamal <hadi@cyberus.ca>
Subject: [RFC] [XFRM] SAD only lookup
Date: Fri, 01 Jun 2007 11:00:25 -0400
Message-ID: <1180710026.4097.27.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DozyQjDb7oIF0O7cE3v+"
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au, James Morris <jmorris@namei.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:62969 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758694AbXFAPAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 11:00:30 -0400
Received: by wr-out-0506.google.com with SMTP id i21so521267wra
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2007 08:00:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DozyQjDb7oIF0O7cE3v+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Folks, 
shit happened and my old hard-drive was whipped containing my old
ipsec pktgen patches. I am now trying to recover them.
Luckily, this one patch i sent on email - so it was an easy recovery.

I know James and Herbert had both commented in the past on this patch.
Please look at it again and see if i am missing something we agreed on.
Herbert, I cant see any easier way to do the SAD lookup. If you have
suggestions please shoot. I am shooting for this to go in when 2.6.23
opens up.


cheers,
jamal


--=-DozyQjDb7oIF0O7cE3v+
Content-Disposition: attachment; filename=pg-xfrm
Content-Type: text/plain; name=pg-xfrm; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit 707411e190af516cefdc3315183d023fde54d53e
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Fri Jun 1 10:49:43 2007 -0400

    [XFRM] Introduce standalone SAD lookup
    This allows other in-kernel functions to do SAD lookups.
    The only known user at the moment is pktgen.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 39ef925..e89cf7e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -921,6 +921,10 @@ extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
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
index 9955ff4..a2d8f64 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -643,6 +643,40 @@ out:
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
+	spin_unlock(&xfrm_state_lock);
+
+	if (rx)
+		xfrm_state_hold(rx);
+
+	return rx;
+}
+EXPORT_SYMBOL(xfrm_stateonly_find);
+
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
 	unsigned int h;

--=-DozyQjDb7oIF0O7cE3v+--

