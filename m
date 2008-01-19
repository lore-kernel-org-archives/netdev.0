From: samuel@sortiz.org
Subject: [PATCH 2/4] [IrDA] Frame length validation
Date: Sat, 19 Jan 2008 01:02:07 +0100
Message-ID: <20080119000555.384367284@sortiz.org>
References: <20080119000205.827714764@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Robie Basak <rb-oss-1@justgohome.co.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.48]:23493 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760477AbYARQDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 11:03:52 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2113.orange.fr (SMTP Server) with ESMTP id 9ED911C0009F
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 14:51:54 +0100 (CET)
Content-Disposition: inline; filename=irda_input_validation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robie Basak <rb-oss-1@justgohome.co.uk>

When using a stir4200-based USB adaptor to talk to a device that uses an
mcp2150, the stir4200 sometimes drops an incoming frame causing the
mcp2150 to try and retransmit the lost frame. In this combination, the
next frame received from the mcp2150 is often invalid - either an empty
i:rsp or an IrCOMM i:rsp with an invalid clen. These corner cases are
now checked.

Signed-off-by: Robie Basak <rb-oss-1@justgohome.co.uk>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/ircomm/ircomm_core.c |   12 ++++++++++++
 net/irda/irlap_event.c        |   13 +++++++++++++
 2 files changed, 25 insertions(+)

Index: net-2.6.25/net/irda/ircomm/ircomm_core.c
===================================================================
--- net-2.6.25.orig/net/irda/ircomm/ircomm_core.c	2008-01-14 19:27:06.000000000 +0100
+++ net-2.6.25/net/irda/ircomm/ircomm_core.c	2008-01-17 06:33:07.000000000 +0100
@@ -362,6 +362,18 @@
 
 	clen = skb->data[0];
 
+ 	/*
+	 * Input validation check: a stir4200/mcp2150 combinations sometimes
+ 	 * results in frames with clen > remaining packet size. These are
+ 	 * illegal; if we throw away just this frame then it seems to carry on
+ 	 * fine
+	 */
+ 	if (unlikely(skb->len < (clen + 1))) {
+ 		IRDA_DEBUG(2, "%s() throwing away illegal frame\n",
+			   __FUNCTION__ );
+ 		return;
+ 	}
+
 	/*
 	 * If there are any data hiding in the control channel, we must
 	 * deliver it first. The side effect is that the control channel
Index: net-2.6.25/net/irda/irlap_event.c
===================================================================
--- net-2.6.25.orig/net/irda/irlap_event.c	2008-01-17 06:33:05.000000000 +0100
+++ net-2.6.25/net/irda/irlap_event.c	2008-01-17 06:33:07.000000000 +0100
@@ -1199,6 +1199,19 @@
 
 	switch (event) {
 	case RECV_I_RSP: /* Optimize for the common case */
+		if (unlikely(skb->len <= LAP_ADDR_HEADER + LAP_CTRL_HEADER)) {
+			/*
+			 * Input validation check: a stir4200/mcp2150
+ 			 * combination sometimes results in an empty i:rsp.
+ 			 * This makes no sense; we can just ignore the frame
+ 			 * and send an rr:cmd immediately. This happens before
+ 			 * changing nr or ns so triggers a retransmit
+			 */
+ 			irlap_wait_min_turn_around(self, &self->qos_tx);
+ 			irlap_send_rr_frame(self, CMD_FRAME);
+ 			/* Keep state */
+ 			break;
+ 		}
 		/* FIXME: must check for remote_busy below */
 #ifdef CONFIG_IRDA_FAST_RR
 		/*

-- 

