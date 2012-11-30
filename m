From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 11/17] br2684: fix module_put() race
Date: Fri, 30 Nov 2012 00:35:30 +0000
Message-ID: <1354235736-26833-12-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37531 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

The br2684 code used module_put() during unassignment from vcc with
hope that we have BKL. This assumption is no longer true.

Now owner field in atmvcc is used to move this module_put()
to vcc_destroy_socket().

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/br2684.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index c483021..373d784 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -68,6 +68,7 @@ struct br2684_vcc {
 	/* keep old push, pop functions for chaining */
 	void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb);
 	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
+	struct module *old_owner;
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -385,8 +386,8 @@ static void br2684_close_vcc(struct br2684_vcc *brvcc)
 	write_unlock_irq(&devs_lock);
 	brvcc->atmvcc->user_back = NULL;	/* what about vcc->recvq ??? */
 	brvcc->old_push(brvcc->atmvcc, NULL);	/* pass on the bad news */
+	module_put(brvcc->old_owner);
 	kfree(brvcc);
-	module_put(THIS_MODULE);
 }
 
 /* when AAL5 PDU comes in: */
@@ -560,9 +561,11 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
 	brvcc->old_pop = atmvcc->pop;
+	brvcc->old_owner = atmvcc->owner;
 	barrier();
 	atmvcc->push = br2684_push;
 	atmvcc->pop = br2684_pop;
+	atmvcc->owner = THIS_MODULE;
 
 	/* initialize netdev carrier state */
 	if (atmvcc->dev->signal == ATM_PHY_SIG_LOST)
-- 
1.8.0
