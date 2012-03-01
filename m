From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] enic: fix an endian bug in enic_probe()
Date: Thu, 1 Mar 2012 10:19:54 +0300
Message-ID: <20120301071954.GA7152@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Benvenuti <benve@cisco.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:31185 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376Ab2CAJBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 04:01:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"num_vfs" is a u32 but we only use the high 16 bits and the low 16bits
are left as zero.  That isn't a problem for little endian systems but it
will break on big endian ones.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 99998c6..cf1fb4b 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -94,7 +94,7 @@ struct enic {
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
 #ifdef CONFIG_PCI_IOV
-	u32 num_vfs;
+	u16 num_vfs;
 #endif
 	struct enic_port_profile *pp;
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index e27ec1d..9080ed6 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2390,7 +2390,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
 	if (pos) {
 		pci_read_config_word(pdev, pos + PCI_SRIOV_TOTAL_VF,
-			(u16 *)&enic->num_vfs);
+			&enic->num_vfs);
 		if (enic->num_vfs) {
 			err = pci_enable_sriov(pdev, enic->num_vfs);
 			if (err) {
