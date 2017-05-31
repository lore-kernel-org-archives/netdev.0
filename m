From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] netxen: Fix a sleep-in-atomic bug in netxen_nic_hw_read_wx_2M and netxen_nic_hw_write_wx_2M
Date: Wed, 31 May 2017 17:15:12 +0800
Message-ID: <1496222112-4402-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may sleep under a write spin lock, and function call path is:
netxen_nic_hw_read_wx_2M (acquire the lock by write_lock_irqsave)
  crb_win_lock
    netxen_pcie_sem_lock
      msleep --> may sleep
netxen_nic_hw_write_wx_2M (acquire the lock by write_lock_irqsave)
  crb_win_lock
    netxen_pcie_sem_lock
      msleep --> may sleep

To fix it, the "msleep" is replaced with "mdelay" in netxen_pcie_sem_lock.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index a996801..0a9da42 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -329,7 +329,7 @@ static void __iomem *pci_base_offset(struct netxen_adapter *adapter,
 			break;
 		if (++timeout >= NETXEN_PCIE_SEM_TIMEOUT)
 			return -EIO;
-		msleep(1);
+		mdelay(1);
 	}
 
 	if (id_reg)
-- 
1.7.9.5
