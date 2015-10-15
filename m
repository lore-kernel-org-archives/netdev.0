From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/15] mlxsw: pci: Use MLXSW_PCI_CQS_MAX instead of MLXSW_PCI_CQS_COUNT
Date: Thu, 15 Oct 2015 17:43:17 +0200
Message-ID: <1444923809-20785-4-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36566 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbbJOPnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:37 -0400
Received: by lbcao8 with SMTP id ao8so73578032lbc.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:35 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The count of CQs can be different for various ASICs, so just define
maximal value and check for that.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 8 ++++----
 drivers/net/ethernet/mellanox/mlxsw/pci.h | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 462cea3..5ba740a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -830,7 +830,8 @@ static void mlxsw_pci_eq_tasklet(unsigned long data)
 {
 	struct mlxsw_pci_queue *q = (struct mlxsw_pci_queue *) data;
 	struct mlxsw_pci *mlxsw_pci = q->pci;
-	unsigned long active_cqns[BITS_TO_LONGS(MLXSW_PCI_CQS_COUNT)];
+	u8 cq_count = mlxsw_pci_cq_count(mlxsw_pci);
+	unsigned long active_cqns[BITS_TO_LONGS(MLXSW_PCI_CQS_MAX)];
 	char *eqe;
 	u8 cqn;
 	bool cq_handle = false;
@@ -866,7 +867,7 @@ static void mlxsw_pci_eq_tasklet(unsigned long data)
 
 	if (!cq_handle)
 		return;
-	for_each_set_bit(cqn, active_cqns, MLXSW_PCI_CQS_COUNT) {
+	for_each_set_bit(cqn, active_cqns, cq_count) {
 		q = mlxsw_pci_cq_get(mlxsw_pci, cqn);
 		mlxsw_pci_queue_tasklet_schedule(q);
 	}
@@ -1069,8 +1070,7 @@ static int mlxsw_pci_aqs_init(struct mlxsw_pci *mlxsw_pci, char *mbox)
 
 	if ((num_sdqs != MLXSW_PCI_SDQS_COUNT) ||
 	    (num_rdqs != MLXSW_PCI_RDQS_COUNT) ||
-	    (num_cqs != MLXSW_PCI_CQS_COUNT) ||
-	    (num_eqs != MLXSW_PCI_EQS_COUNT)) {
+	    num_cqs > MLXSW_PCI_CQS_MAX || num_eqs != MLXSW_PCI_EQS_COUNT) {
 		dev_err(&pdev->dev, "Unsupported number of queues\n");
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index 1ef9664..efe1b4b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -73,7 +73,7 @@
 
 #define MLXSW_PCI_RDQS_COUNT	24
 #define MLXSW_PCI_SDQS_COUNT	24
-#define MLXSW_PCI_CQS_COUNT	(MLXSW_PCI_RDQS_COUNT + MLXSW_PCI_SDQS_COUNT)
+#define MLXSW_PCI_CQS_MAX	96
 #define MLXSW_PCI_EQS_COUNT	2
 #define MLXSW_PCI_EQ_ASYNC_NUM	0
 #define MLXSW_PCI_EQ_COMP_NUM	1
-- 
1.9.3
