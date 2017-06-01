From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] cw1200: Fix a sleep-in-atomic bug in cw1200_tx_confirm_cb and cw1200_cqm_bssloss_sm
Date: Thu,  1 Jun 2017 10:36:14 +0800
Message-ID: <1496284574-11056-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: pizza@shaftnet.org, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may sleep under a spin lock, and the function call path is:
cw1200_tx_confirm_cb (acquire the lock by spin_lock)
  __cw1200_cqm_bssloss_sm
    cancel_work_sync --> may sleep

cw1200_cqm_bssloss_sm
  __cw1200_cqm_bssloss_sm
    cancel_work_sync --> may sleep

To fix it, the lock is released before cancel_work_sync, and the lock 
is acquired again after this function.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/st/cw1200/sta.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/st/cw1200/sta.c b/drivers/net/wireless/st/cw1200/sta.c
index a522248..d5f7698 100644
--- a/drivers/net/wireless/st/cw1200/sta.c
+++ b/drivers/net/wireless/st/cw1200/sta.c
@@ -154,7 +154,9 @@ void __cw1200_cqm_bssloss_sm(struct cw1200_common *priv,
 	int tx = 0;
 
 	priv->delayed_link_loss = 0;
+	spin_unlock(&priv->bss_loss_lock);
 	cancel_work_sync(&priv->bss_params_work);
+	spin_lock(&priv->bss_loss_lock);
 
 	pr_debug("[STA] CQM BSSLOSS_SM: state: %d init %d good %d bad: %d txlock: %d uj: %d\n",
 		 priv->bss_loss_state,
-- 
1.7.9.5
