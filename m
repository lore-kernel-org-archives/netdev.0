From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] netxen: Fix a sleep-in-atomic bug in netxen_nic_pci_mem_access_direct
Date: Mon, 19 Jun 2017 10:48:53 +0800
Message-ID: <1497840533-4894-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: manish.chopra@cavium.com, rahul.verma@cavium.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:46686 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753298AbdFSCqX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 22:46:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver may sleep under a spin lock, and the function call path is:
netxen_nic_pci_mem_access_direct (acquire the lock by spin_lock)
  ioremap --> may sleep

To fix it, the lock is released before "ioremap", and the lock is 
acquired again after this function.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index a996801..5ea553e 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -1419,7 +1419,9 @@ static u32 netxen_nic_io_read_2M(struct netxen_adapter *adapter,
 
 		mem_base = pci_resource_start(adapter->pdev, 0) +
 					(start & PAGE_MASK);
+		spin_unlock(&adapter->ahw.mem_lock);
 		mem_ptr = ioremap(mem_base, PAGE_SIZE);
+		spin_lock(&adapter->ahw.mem_lock);
 		if (mem_ptr == NULL) {
 			ret = -EIO;
 			goto unlock;
-- 
1.7.9.5
