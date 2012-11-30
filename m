From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 03/17] pppoatm: fix module_put() race
Date: Fri, 30 Nov 2012 00:35:22 +0000
Message-ID: <1354235736-26833-4-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37537 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

The pppoatm used module_put() during unassignment from vcc with
hope that we have BKL. This assumption is no longer true.

Now owner field in atmvcc is used to move this module_put()
to vcc_destroy_socket().

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 net/atm/pppoatm.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index f27a07a..b23c672 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -60,6 +60,7 @@ struct pppoatm_vcc {
 	struct atm_vcc	*atmvcc;	/* VCC descriptor */
 	void (*old_push)(struct atm_vcc *, struct sk_buff *);
 	void (*old_pop)(struct atm_vcc *, struct sk_buff *);
+	struct module *old_owner;
 					/* keep old push/pop for detaching */
 	enum pppoatm_encaps encaps;
 	atomic_t inflight;
@@ -155,8 +156,6 @@ static void pppoatm_unassign_vcc(struct atm_vcc *atmvcc)
 	ppp_unregister_channel(&pvcc->chan);
 	atmvcc->user_back = NULL;
 	kfree(pvcc);
-	/* Gee, I hope we have the big kernel lock here... */
-	module_put(THIS_MODULE);
 }
 
 /* Called when an AAL5 PDU comes in */
@@ -165,9 +164,13 @@ static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
 	pr_debug("\n");
 	if (skb == NULL) {			/* VCC was closed */
+		struct module *module;
+
 		pr_debug("removing ATMPPP VCC %p\n", pvcc);
+		module = pvcc->old_owner;
 		pppoatm_unassign_vcc(atmvcc);
 		atmvcc->push(atmvcc, NULL);	/* Pass along bad news */
+		module_put(module);
 		return;
 	}
 	atm_return(atmvcc, skb->truesize);
@@ -362,6 +365,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	atomic_set(&pvcc->inflight, NONE_INFLIGHT);
 	pvcc->old_push = atmvcc->push;
 	pvcc->old_pop = atmvcc->pop;
+	pvcc->old_owner = atmvcc->owner;
 	pvcc->encaps = (enum pppoatm_encaps) be.encaps;
 	pvcc->chan.private = pvcc;
 	pvcc->chan.ops = &pppoatm_ops;
@@ -378,6 +382,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	atmvcc->push = pppoatm_push;
 	atmvcc->pop = pppoatm_pop;
 	__module_get(THIS_MODULE);
+	atmvcc->owner = THIS_MODULE;
 
 	/* re-process everything received between connection setup and
 	   backend setup */
-- 
1.8.0
