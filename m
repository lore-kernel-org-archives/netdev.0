From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH] sundance: PHY address form 0, only for device ID 0x0200 (IP100A) (20070605)
Date: Wed, 06 Jun 2007 01:46:34 +0200
Message-ID: <m2bqfuufqd.fsf@synack.fr>
References: <1181051441.2487.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jeff@garzik.org
To: Jesse Huang <jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 108.235.97-84.rev.gaoland.net ([84.97.235.108]:48173 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbXFEX4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 19:56:08 -0400
In-Reply-To: <1181051441.2487.1.camel@localhost.localdomain> (Jesse Huang's
	message of "Tue, 05 Jun 2007 09:50:40 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang <jesse@icplus.com.tw> writes:

Hi Jesse,

> -	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
> +	if(sundance_pci_tbl[np->chip_id].device == 0x0200) 
> +		phy = 0;
> +	else 
> +		phy = 1;
> +	for (; phy <= 32 && phy_idx < MII_CNT; phy++) {

I think this value can be put in driver_data.
Attached patch is doing it, but I didn't test it.

tree 602e0c2def631e82635b4f8aad762e69184af143
parent 5ecd3100e695228ac5e0ce0e325e252c0f11806f
author Samir Bellabes <sam@synack.fr> 1181086775 +0200
committer Samir Bellabes <sam@synack.fr> 1181086775 +0200

Search PHY address form 0, only for device ID 0x0200 (IP100A). Other
device are from PHY address 1.

Noticed by Jesse Huang <jesse@icplus.com.tw>

Signed-off-by: Samir Bellabes <sam@synack.fr>

------------------------------------------------------------------------------

 sundance.c |   40 +++++++++++++++++++++++++++++++---------
 1 files changed, 31 insertions(+), 9 deletions(-)

------------------------------------------------------------------------------

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index e1f912d..fb59801 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -205,14 +205,36 @@ #ifndef CONFIG_SUNDANCE_MMIO
 #define USE_IO_OPS 1
 #endif
 
+enum cfg_version {
+	SUNDANCE_CFG_0 = 0x00,	
+	SUNDANCE_CFG_1,
+	SUNDANCE_CFG_2,
+	SUNDANCE_CFG_3,
+	SUNDANCE_CFG_4,
+	SUNDANCE_CFG_5,
+	SUNDANCE_CFG_6
+};
+
+static const struct {
+	unsigned int phy;
+} sundance_cfg_info[] = {
+	[SUNDANCE_CFG_0] = { 1 },
+	[SUNDANCE_CFG_1] = { 1 },
+	[SUNDANCE_CFG_2] = { 1 },
+	[SUNDANCE_CFG_3] = { 1 },
+	[SUNDANCE_CFG_4] = { 1 },
+	[SUNDANCE_CFG_5] = { 1 },
+	[SUNDANCE_CFG_6] = { 0 }
+};
+
 static const struct pci_device_id sundance_pci_tbl[] = {
-	{ 0x1186, 0x1002, 0x1186, 0x1002, 0, 0, 0 },
-	{ 0x1186, 0x1002, 0x1186, 0x1003, 0, 0, 1 },
-	{ 0x1186, 0x1002, 0x1186, 0x1012, 0, 0, 2 },
-	{ 0x1186, 0x1002, 0x1186, 0x1040, 0, 0, 3 },
-	{ 0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
-	{ 0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
-	{ 0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
+	{ 0x1186, 0x1002, 0x1186, 0x1002, 0, 0, SUNDANCE_CFG_0 },
+	{ 0x1186, 0x1002, 0x1186, 0x1003, 0, 0, SUNDANCE_CFG_1 },
+	{ 0x1186, 0x1002, 0x1186, 0x1012, 0, 0, SUNDANCE_CFG_2 },
+	{ 0x1186, 0x1002, 0x1186, 0x1040, 0, 0, SUNDANCE_CFG_3 },
+	{ 0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SUNDANCE_CFG_4 },
+	{ 0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SUNDANCE_CFG_5 },
+	{ 0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SUNDANCE_CFG_6 },
 	{ }
 };
 MODULE_DEVICE_TABLE(pci, sundance_pci_tbl);
@@ -468,7 +490,7 @@ #else
 	int bar = 1;
 #endif
 	int phy, phy_idx = 0;
-
+	const unsigned int phy_start = sundance_cfg_info[ent->driver_data].phy;
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -562,7 +584,7 @@ #endif
 	 * It seems some phys doesn't deal well with address 0 being accessed
 	 * first, so leave address zero to the end of the loop (32 & 31).
 	 */
-	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
+	for (phy = phy_start; phy <= 32 && phy_idx < MII_CNT; phy++) {
 		int phyx = phy & 0x1f;
 		int mii_status = mdio_read(dev, phyx, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
