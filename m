From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] ixgbe: remove extra unused queues in DCB + FCoE case
Date: Sat, 21 Jul 2012 16:08:59 -0700
Message-ID: <1342912142-11130-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22894 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029Ab2GUXJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:12 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

With DCB and FCoE configured extra queues may be allocated and
never used. After this patch we calculate the max correctly.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 84370e7..bc7e79b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7048,6 +7048,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	u8 part_str[IXGBE_PBANUM_LENGTH];
 	unsigned int indices = num_possible_cpus();
+	unsigned int dcb_max = 0;
 #ifdef IXGBE_FCOE
 	u16 device_caps;
 #endif
@@ -7097,15 +7098,16 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	pci_save_state(pdev);
 
 #ifdef CONFIG_IXGBE_DCB
-	indices *= MAX_TRAFFIC_CLASS;
+	if (ii->mac == ixgbe_mac_82598EB)
+		dcb_max = min_t(unsigned int, indices * MAX_TRAFFIC_CLASS,
+				IXGBE_MAX_RSS_INDICES);
+	else
+		dcb_max = min_t(unsigned int, indices * MAX_TRAFFIC_CLASS,
+				IXGBE_MAX_FDIR_INDICES);
 #endif
 
 	if (ii->mac == ixgbe_mac_82598EB)
-#ifdef CONFIG_IXGBE_DCB
-		indices = min_t(unsigned int, indices, MAX_TRAFFIC_CLASS * 4);
-#else
 		indices = min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICES);
-#endif
 	else
 		indices = min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICES);
 
@@ -7113,6 +7115,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	indices += min_t(unsigned int, num_possible_cpus(),
 			 IXGBE_MAX_FCOE_INDICES);
 #endif
+	indices = max_t(unsigned int, dcb_max, indices);
 	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indices);
 	if (!netdev) {
 		err = -ENOMEM;
-- 
1.7.10.4
