From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: handle possible memory allocation failure
Date: Tue, 14 Apr 2015 21:51:48 -0700
Message-ID: <1429073511-27664-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34763 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbbDOEwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:12 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The init_interrupt_scheme function had a possible failure
path to allocate memory that was found by smatch.

This adds the correct handling to the function to abort
probe if the memory allocation fails.

Change-ID: I2bf1d826a244209619da4c452d0d58b3eb5e26a3
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 63de3f4..b297294 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7301,7 +7301,7 @@ err_out:
  * i40e_init_interrupt_scheme - Determine proper interrupt scheme
  * @pf: board private structure to initialize
  **/
-static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
+static int i40e_init_interrupt_scheme(struct i40e_pf *pf)
 {
 	int vectors = 0;
 	ssize_t size;
@@ -7343,11 +7343,17 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	/* set up vector assignment tracking */
 	size = sizeof(struct i40e_lump_tracking) + (sizeof(u16) * vectors);
 	pf->irq_pile = kzalloc(size, GFP_KERNEL);
+	if (!pf->irq_pile) {
+		dev_err(&pf->pdev->dev, "error allocating irq_pile memory\n");
+		return -ENOMEM;
+	}
 	pf->irq_pile->num_entries = vectors;
 	pf->irq_pile->search_hint = 0;
 
-	/* track first vector for misc interrupts */
+	/* track first vector for misc interrupts, ignore return */
 	(void)i40e_get_lump(pf, pf->irq_pile, 1, I40E_PILE_VALID_BIT - 1);
+
+	return 0;
 }
 
 /**
@@ -9827,7 +9833,9 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* set up the main switch operations */
 	i40e_determine_queue_usage(pf);
-	i40e_init_interrupt_scheme(pf);
+	err = i40e_init_interrupt_scheme(pf);
+	if (err)
+		goto err_switch_setup;
 
 	/* The number of VSIs reported by the FW is the minimum guaranteed
 	 * to us; HW supports far more and we share the remaining pool with
-- 
1.9.3
