From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Subject: [2/3] IRDA stack should call irda_get_skb_cb (tx_extra implementation)
Date: Mon, 10 Nov 2008 11:11:48 -0500
Message-ID: <49185D44.8080809@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020308090802010407000006"
To: irda-users@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-200-93-199-98.telconet.net ([200.93.199.98]:58408 "EHLO
	elastix.palosanto.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752837AbYKJQMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 11:12:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020308090802010407000006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

A rewrite of the original patch by Samuel Ortiz, for the tx_extra 
implementation. Does away with irda_alloc_skb which is irrelevant for 
this implementation.

Based on a patch by Samuel Ortiz <samuel@sortiz.org>

Signed-off-by: Alex Villacís Lasso <a_villacis@palosanto.com>

-- 
perl -e '$x=2.4;print sprintf("%.0f + %.0f = %.0f\n",$x,$x,$x+$x);'


--------------020308090802010407000006
Content-Type: text/x-patch;
 name="0002-irda-stack-should-call-irda_get_skb_cp-tx_extra.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-irda-stack-should-call-irda_get_skb_cp-tx_extra.patch"

diff -ur linux-2.6.28-rc3-git-orig/include/net/irda/irda_device.h linux-2.6.28-rc3-git/include/net/irda/irda_device.h
--- linux-2.6.28-rc3-git-orig/include/net/irda/irda_device.h	2008-11-08 12:05:58.000000000 -0500
+++ linux-2.6.28-rc3-git/include/net/irda/irda_device.h	2008-11-08 12:07:35.000000000 -0500
@@ -244,7 +244,7 @@
  */
 static inline __u16 irda_get_mtt(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->tx_extra;
 	return (cb->magic == LAP_MAGIC) ? cb->mtt : 10000;
 }
 
@@ -257,7 +257,7 @@
  */
 static inline __u32 irda_get_next_speed(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->tx_extra;
 	return (cb->magic == LAP_MAGIC) ? cb->next_speed : -1;
 }
 
@@ -270,7 +270,7 @@
  */
 static inline __u16 irda_get_xbofs(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->tx_extra;
 	return (cb->magic == LAP_MAGIC) ? cb->xbofs : 10;
 }
 
@@ -283,7 +283,7 @@
  */
 static inline __u16 irda_get_next_xbofs(const struct sk_buff *skb)
 {
-	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->cb;
+	const struct irda_skb_cb *cb = (const struct irda_skb_cb *) skb->tx_extra;
 	return (cb->magic == LAP_MAGIC) ? cb->next_xbofs : -1;
 }
 #endif /* IRDA_DEVICE_H */
diff -ur linux-2.6.28-rc3-git-orig/net/irda/ircomm/ircomm_lmp.c linux-2.6.28-rc3-git/net/irda/ircomm/ircomm_lmp.c
--- linux-2.6.28-rc3-git-orig/net/irda/ircomm/ircomm_lmp.c	2008-11-06 19:44:23.000000000 -0500
+++ linux-2.6.28-rc3-git/net/irda/ircomm/ircomm_lmp.c	2008-11-08 12:09:49.000000000 -0500
@@ -146,7 +146,7 @@
 
 	IRDA_ASSERT(skb != NULL, return;);
 
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
@@ -187,7 +187,7 @@
 
 	IRDA_ASSERT(skb != NULL, return -1;);
 
-	cb = (struct irda_skb_cb *) skb->cb;
+	cb = irda_get_skb_cb(skb);
 
 	cb->line = self->line;
 
diff -ur linux-2.6.28-rc3-git-orig/net/irda/irlap_frame.c linux-2.6.28-rc3-git/net/irda/irlap_frame.c
--- linux-2.6.28-rc3-git-orig/net/irda/irlap_frame.c	2008-11-06 19:44:23.000000000 -0500
+++ linux-2.6.28-rc3-git/net/irda/irlap_frame.c	2008-11-08 12:09:49.000000000 -0500
@@ -56,7 +56,9 @@
 static inline void irlap_insert_info(struct irlap_cb *self,
 				     struct sk_buff *skb)
 {
-	struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
+	struct irda_skb_cb *cb;
+
+	cb = irda_get_skb_cb(skb);
 
 	/*
 	 * Insert MTT (min. turn time) and speed into skb, so that the
diff -ur linux-2.6.28-rc3-git-orig/net/irda/wrapper.c linux-2.6.28-rc3-git/net/irda/wrapper.c
--- linux-2.6.28-rc3-git-orig/net/irda/wrapper.c	2008-11-06 19:44:23.000000000 -0500
+++ linux-2.6.28-rc3-git/net/irda/wrapper.c	2008-11-08 12:09:49.000000000 -0500
@@ -82,7 +82,7 @@
  */
 int async_wrap_skb(struct sk_buff *skb, __u8 *tx_buff, int buffsize)
 {
-	struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
+	struct irda_skb_cb *cb;
 	int xbofs;
 	int i;
 	int n;
@@ -91,6 +91,8 @@
 		__u8 bytes[2];
 	} fcs;
 
+	cb = irda_get_skb_cb(skb);
+
 	/* Initialize variables */
 	fcs.value = INIT_FCS;
 	n = 0;

--------------020308090802010407000006--
