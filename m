From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 10/17] pppoatm: fix missing wakeup in pppoatm_send()
Date: Fri, 30 Nov 2012 00:35:29 +0000
Message-ID: <1354235736-26833-11-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37535 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

Now that we can return zero from pppoatm_send() for reasons *other* than
the queue being full, that means we can't depend on a subsequent call to
pppoatm_pop() waking the queue, and we might leave it stalled
indefinitely.

Use the ->release_cb() callback to wake the queue after the sock is
unlocked.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 3dce84a..9fcda8c 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -60,6 +60,7 @@ struct pppoatm_vcc {
 	struct atm_vcc	*atmvcc;	/* VCC descriptor */
 	void (*old_push)(struct atm_vcc *, struct sk_buff *);
 	void (*old_pop)(struct atm_vcc *, struct sk_buff *);
+	void (*old_release_cb)(struct atm_vcc *);
 	struct module *old_owner;
 					/* keep old push/pop for detaching */
 	enum pppoatm_encaps encaps;
@@ -108,6 +109,14 @@ static void pppoatm_wakeup_sender(unsigned long arg)
 	ppp_output_wakeup((struct ppp_channel *) arg);
 }
 
+static void pppoatm_release_cb(struct atm_vcc *atmvcc)
+{
+	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
+
+	tasklet_schedule(&pvcc->wakeup_tasklet);
+	if (pvcc->old_release_cb)
+		pvcc->old_release_cb(atmvcc);
+}
 /*
  * This gets called every time the ATM card has finished sending our
  * skb.  The ->old_pop will take care up normal atm flow control,
@@ -152,6 +161,7 @@ static void pppoatm_unassign_vcc(struct atm_vcc *atmvcc)
 	pvcc = atmvcc_to_pvcc(atmvcc);
 	atmvcc->push = pvcc->old_push;
 	atmvcc->pop = pvcc->old_pop;
+	atmvcc->release_cb = pvcc->old_release_cb;
 	tasklet_kill(&pvcc->wakeup_tasklet);
 	ppp_unregister_channel(&pvcc->chan);
 	atmvcc->user_back = NULL;
@@ -388,6 +398,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	pvcc->old_push = atmvcc->push;
 	pvcc->old_pop = atmvcc->pop;
 	pvcc->old_owner = atmvcc->owner;
+	pvcc->old_release_cb = atmvcc->release_cb;
 	pvcc->encaps = (enum pppoatm_encaps) be.encaps;
 	pvcc->chan.private = pvcc;
 	pvcc->chan.ops = &pppoatm_ops;
@@ -403,6 +414,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	atmvcc->user_back = pvcc;
 	atmvcc->push = pppoatm_push;
 	atmvcc->pop = pppoatm_pop;
+	atmvcc->release_cb = pppoatm_release_cb;
 	__module_get(THIS_MODULE);
 	atmvcc->owner = THIS_MODULE;
 
-- 
1.8.0
