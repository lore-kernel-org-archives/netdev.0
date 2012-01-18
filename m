From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/4] enic: rearrange some of the port profile code
Date: Wed, 18 Jan 2012 06:24:07 -0800
Message-ID: <20120118142407.7877.28496.stgit@rhel6.1>
References: <20120118142336.7877.67031.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:6546 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab2ARGkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:40:24 -0500
In-Reply-To: <20120118142336.7877.67031.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch rearranges some of the port profile code in enic_probe.
It moves out some lines of port profile related code currently
inside CONFIG_PCI_IOV. This is only done to move all port profile
related code together so that it can help isolate the port profile
handling code under a separate #ifdef in our internal build scripts.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9f37d92..03b0577 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2270,10 +2270,10 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	int using_dac = 0;
 	unsigned int i;
 	int err;
-	int num_pps = 1;
 #ifdef CONFIG_PCI_IOV
 	int pos = 0;
 #endif
+	int num_pps;
 
 	/* Allocate net device structure and initialize.  Private
 	 * instance data is initialized to zero.
@@ -2380,17 +2380,17 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 				goto err_out_vnic_unregister;
 			}
 			enic->priv_flags |= ENIC_SRIOV_ENABLED;
-			num_pps = enic->num_vfs;
 		}
 	}
-
 #endif
+
+	num_pps = enic->num_vfs ? enic->num_vfs : 1;
 	/* Allocate structure for port profiles */
 	enic->pp = kcalloc(num_pps, sizeof(*enic->pp), GFP_KERNEL);
 	if (!enic->pp) {
 		pr_err("port profile alloc failed, aborting\n");
 		err = -ENOMEM;
-		goto err_out_disable_sriov;
+		goto err_out_disable_sriov_pp;
 	}
 
 	/* Issue device open to get device in known state
@@ -2399,7 +2399,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	err = enic_dev_open(enic);
 	if (err) {
 		dev_err(dev, "vNIC dev open failed, aborting\n");
-		goto err_out_free_pp;
+		goto err_out_disable_sriov;
 	}
 
 	/* Setup devcmd lock
@@ -2522,9 +2522,9 @@ err_out_dev_deinit:
 	enic_dev_deinit(enic);
 err_out_dev_close:
 	vnic_dev_close(enic->vdev);
-err_out_free_pp:
-	kfree(enic->pp);
 err_out_disable_sriov:
+	kfree(enic->pp);
+err_out_disable_sriov_pp:
 #ifdef CONFIG_PCI_IOV
 	if (enic_sriov_enabled(enic)) {
 		pci_disable_sriov(pdev);
