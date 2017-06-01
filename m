From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] qlcnic: Fix a sleep-in-atomic bug in qlcnic_82xx_hw_write_wx_2M and qlcnic_82xx_hw_read_wx_2M
Date: Thu,  1 Jun 2017 16:18:10 +0800
Message-ID: <1496305090-17814-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may sleep under a write spin lock, and the function 
call path is:
qlcnic_82xx_hw_write_wx_2M (acquire the lock by write_lock_irqsave)
  crb_win_lock
    qlcnic_pcie_sem_lock
      usleep_range
qlcnic_82xx_hw_read_wx_2M (acquire the lock by write_lock_irqsave)
  crb_win_lock
    qlcnic_pcie_sem_lock
      usleep_range

To fix it, the usleep_range is replaced with udelay.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 838cc0c..7848cf0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -341,7 +341,7 @@ static void qlcnic_write_window_reg(u32 addr, void __iomem *bar0, u32 data)
 			}
 			return -EIO;
 		}
-		usleep_range(1000, 1500);
+		udelay(1200);
 	}
 
 	if (id_reg)
-- 
1.7.9.5
