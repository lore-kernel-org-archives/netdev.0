From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 14/17] pppoatm: optimise PPP channel wakeups after sock_owned_by_user()
Date: Fri, 30 Nov 2012 00:35:33 +0000
Message-ID: <1354235736-26833-15-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47051
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754887Ab2K3Agm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:42 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

We don't need to schedule the wakeup tasklet on *every* unlock; only if we
actually blocked the channel in the first place.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/pppoatm.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 9fcda8c..8c93267 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -113,7 +113,17 @@ static void pppoatm_release_cb(struct atm_vcc *atmvcc)
 {
 	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
 
-	tasklet_schedule(&pvcc->wakeup_tasklet);
+	/*
+	 * As in pppoatm_pop(), it's safe to clear the BLOCKED bit here because
+	 * the wakeup *can't* race with pppoatm_send(). They both hold the PPP
+	 * channel's ->downl lock. And the potential race with *setting* it,
+	 * which leads to the double-check dance in pppoatm_may_send(), doesn't
+	 * exist here. In the sock_owned_by_user() case in pppoatm_send(), we
+	 * set the BLOCKED bit while the socket is still locked. We know that
+	 * ->release_cb() can't be called until that's done.
+	 */
+	if (test_and_clear_bit(BLOCKED, &pvcc->blocked))
+		tasklet_schedule(&pvcc->wakeup_tasklet);
 	if (pvcc->old_release_cb)
 		pvcc->old_release_cb(atmvcc);
 }
@@ -292,8 +302,15 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 
 	vcc = ATM_SKB(skb)->vcc;
 	bh_lock_sock(sk_atm(vcc));
-	if (sock_owned_by_user(sk_atm(vcc)))
+	if (sock_owned_by_user(sk_atm(vcc))) {
+		/*
+		 * Needs to happen (and be flushed, hence test_and_) before we unlock
+		 * the socket. It needs to be seen by the time our ->release_cb gets
+		 * called.
+		 */
+		test_and_set_bit(BLOCKED, &pvcc->blocked);
 		goto nospace;
+	}
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
 	    !test_bit(ATM_VF_READY, &vcc->flags)) {
-- 
1.8.0
