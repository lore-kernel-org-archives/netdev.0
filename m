From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH net-next 3/4] enic: bug fix: tx_timeout reset path fix-ups
Date: Mon, 09 Feb 2009 16:57:22 -0800
Message-ID: <20090210005722.24315.90194.stgit@palito_client100.nuovasystems.com>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:61377 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbZBJA5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 19:57:23 -0500
Received: from sj-core-1.cisco.com (sj-core-1.cisco.com [171.71.177.237])
	by sj-dkim-3.cisco.com (8.12.11/8.12.11) with ESMTP id n1A0vMDY004862
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 16:57:22 -0800
Received: from palito_client100.nuovasystems.com (savbu-palito-client100.cisco.com [10.193.70.13])
	by sj-core-1.cisco.com (8.13.8/8.13.8) with ESMTP id n1A0vM3a010521
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:57:22 GMT
In-Reply-To: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: tx_timeout reset path fix-ups

tx_timeout reset path needs to re-init dev and re-apply nic cfg to enable vlan stripping.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 3ba5f54..4da1e35 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1462,6 +1462,26 @@ static int enic_dev_soft_reset(struct enic *enic)
 	return err;
 }
 
+static int enic_set_niccfg(struct enic *enic)
+{
+	const u8 rss_default_cpu = 0;
+	const u8 rss_hash_type = 0;
+	const u8 rss_hash_bits = 0;
+	const u8 rss_base_cpu = 0;
+	const u8 rss_enable = 0;
+	const u8 tso_ipid_split_en = 0;
+	const u8 ig_vlan_strip_en = 1;
+
+	/* Enable VLAN tag stripping.  RSS not enabled (yet).
+	*/
+
+	return enic_set_nic_cfg(enic,
+		rss_default_cpu, rss_hash_type,
+		rss_hash_bits, rss_base_cpu,
+		rss_enable, tso_ipid_split_en,
+		ig_vlan_strip_en);
+}
+
 static void enic_reset(struct work_struct *work)
 {
 	struct enic *enic = container_of(work, struct enic, reset);
@@ -1477,8 +1497,10 @@ static void enic_reset(struct work_struct *work)
 
 	enic_stop(enic->netdev);
 	enic_dev_soft_reset(enic);
+	vnic_dev_init(enic->vdev, 0);
 	enic_reset_mcaddrs(enic);
 	enic_init_vnic_resources(enic);
+	enic_set_niccfg(enic);
 	enic_open(enic->netdev);
 
 	rtnl_unlock();
@@ -1621,14 +1643,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	unsigned int i;
 	int err;
 
-	const u8 rss_default_cpu = 0;
-	const u8 rss_hash_type = 0;
-	const u8 rss_hash_bits = 0;
-	const u8 rss_base_cpu = 0;
-	const u8 rss_enable = 0;
-	const u8 tso_ipid_split_en = 0;
-	const u8 ig_vlan_strip_en = 1;
-
 	/* Allocate net device structure and initialize.  Private
 	 * instance data is initialized to zero.
 	 */
@@ -1794,14 +1808,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	enic_init_vnic_resources(enic);
 
-	/* Enable VLAN tag stripping.  RSS not enabled (yet).
-	 */
-
-	err = enic_set_nic_cfg(enic,
-		rss_default_cpu, rss_hash_type,
-		rss_hash_bits, rss_base_cpu,
-		rss_enable, tso_ipid_split_en,
-		ig_vlan_strip_en);
+	err = enic_set_niccfg(enic);
 	if (err) {
 		printk(KERN_ERR PFX
 			"Failed to config nic, aborting.\n");

