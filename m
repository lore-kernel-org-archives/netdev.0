From: Arthur Kepner <akepner@sgi.com>
Subject: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Thu, 26 Aug 2010 10:06:46 -0700
Message-ID: <20100826170646.GB27157@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:43296 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751536Ab0HZRGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 13:06:47 -0400
Received: from localhost (sshcf.sgi.com [198.149.20.12])
	by relay3.corp.sgi.com (Postfix) with ESMTP id B5FF3AC011
	for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 10:06:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(Resending to netdev. Previously sent to linux-rdma)

The mlx4_core driver allocates 'nreq' msix vectors (and irqs), 
where:

  nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
               num_possible_cpus() + 1);

ConnectX HCAs support 512 event queues (4 reserved). On a system 
with enough processors, we get:

  mlx4_core 0006:01:00.0: Requested 508 vectors, but only 256 MSI-X vectors available, trying again

Further attempts (by other drivers) to allocate interrupts fail, 
because mlx4_core got 'em all.

Use a module parameter to limit the number of MSI-X vectors that 
the mlx4_core driver will attempt to allocate.

Signed-off-by: Arthur Kepner <akepner@sgi.com>

---

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 5102ab1..3eba2f3 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -68,6 +68,10 @@ static int msi_x = 1;
 module_param(msi_x, int, 0444);
 MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
+static int max_msi_x_vec = 64;
+module_param(max_msi_x_vec, int, 0444);
+MODULE_PARM_DESC(max_msi_x_vec, "max MSI-X vectors we'll attempt to allocate");
+
 #else /* CONFIG_PCI_MSI */
 
 #define msi_x (0)
@@ -968,8 +972,10 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	int i;
 
 	if (msi_x) {
+		nreq = min_t(int, num_possible_cpus() + 1, max_msi_x_vec);
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
-			     num_possible_cpus() + 1);
+			     nreq);
+
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
 			goto no_msi;
