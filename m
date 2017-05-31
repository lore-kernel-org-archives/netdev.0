From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] qed: Fix a sleep-in-interrupt bug in qed_int_sp_dpc
Date: Wed, 31 May 2017 22:23:28 +0800
Message-ID: <1496240608-17453-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may sleep in interrupt handling, and the function call path is:
qed_int_sp_dpc (tasklet_init indicates it handles interrupt)
  qed_int_attentions
    qed_mcp_handle_events
      qed_mcp_handle_link_change
        qed_link_update
          qed_fill_link
            qed_mcp_get_media_type
              qed_ptt_acquire
                usleep_range --> may sleep

To fix it, the "usleep_range" is replaced with "udelay".

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/qlogic/qed/qed_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index a05feb3..3250cc4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -131,7 +131,7 @@ struct qed_ptt *qed_ptt_acquire(struct qed_hwfn *p_hwfn)
 		}
 
 		spin_unlock_bh(&p_hwfn->p_ptt_pool->lock);
-		usleep_range(1000, 2000);
+		udelay(1500);
 	}
 
 	DP_NOTICE(p_hwfn, "PTT acquire timeout - failed to allocate PTT\n");
-- 
1.7.9.5
