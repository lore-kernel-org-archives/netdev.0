From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Mon, 22 Oct 2012 19:14:51 +0200
Message-ID: <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Krzysztof Mazur <krzysiek@podlesie.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pppoatm gets a reference to atmvcc, but does not increment vcc
usage count. The vcc uses vcc->sk socket for reference counting,
so sock_hold() and sock_put() should be used by pppoatm.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 net/atm/pppoatm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index e3b2d69..a766d96 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -154,6 +154,7 @@ static void pppoatm_unassign_vcc(struct atm_vcc *atmvcc)
 	tasklet_kill(&pvcc->wakeup_tasklet);
 	ppp_unregister_channel(&pvcc->chan);
 	atmvcc->user_back = NULL;
+	sock_put(sk_atm(pvcc->atmvcc));
 	kfree(pvcc);
 	/* Gee, I hope we have the big kernel lock here... */
 	module_put(THIS_MODULE);
@@ -373,6 +374,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	if (pvcc == NULL)
 		return -ENOMEM;
 	pvcc->atmvcc = atmvcc;
+	sock_hold(sk_atm(atmvcc));
 
 	/* Maximum is zero, so that we can use atomic_inc_not_zero() */
 	atomic_set(&pvcc->inflight, NONE_INFLIGHT);
@@ -387,6 +389,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	pvcc->wakeup_tasklet.data = (unsigned long) &pvcc->chan;
 	err = ppp_register_channel(&pvcc->chan);
 	if (err != 0) {
+		sock_put(sk_atm(atmvcc));
 		kfree(pvcc);
 		return err;
 	}
-- 
1.8.0.2.g35080e9
