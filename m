From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH] netxen: memory corruption by netxen_p3_get_mac_addr.
Date: Sat,  3 Mar 2012 22:31:27 +0530
Message-ID: <1330794087-19248-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: sony.chacko@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Nayak <santoshprasadnayak@gmail.com>

'mac_hi' and 'mac_lo' are 32 bit unsinged int but we are modifing
64 bit of memory during mac calculation. To fix this issue define
a local variable of 64 bit and do mac calculation.

Remove 'le64_to_cpu' to fix endian issue.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 0f81287..7ea930b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -1069,7 +1069,8 @@ int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 
 int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 {
-	uint32_t crbaddr, mac_hi, mac_lo;
+	uint32_t crbaddr;
+	u64 mac_hi, mac_lo;
 	int pci_func = adapter->ahw.pci_func;
 
 	crbaddr = CRB_MAC_BLOCK_START +
@@ -1079,9 +1080,9 @@ int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 	mac_hi = NXRD32(adapter, crbaddr+4);
 
 	if (pci_func & 1)
-		*mac = le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << 16));
+		*mac = (mac_lo >> 16) | (mac_hi << 16);
 	else
-		*mac = le64_to_cpu((u64)mac_lo | ((u64)mac_hi << 32));
+		*mac = mac_lo | (mac_hi << 32);
 
 	return 0;
 }
-- 
1.7.4.4
