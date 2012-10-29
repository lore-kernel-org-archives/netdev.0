From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 08/10] cpsw: add a DT field for the active time stamping port
Date: Mon, 29 Oct 2012 19:45:18 +0100
Message-ID: <496c255aeb2c696cbb62ac0319c97cf5fadda55b.1351535540.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:37510 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760461Ab2J2Spw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:45:52 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1826941eaa.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 11:45:52 -0700 (PDT)
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because time stamping on both external ports of the switch simultaneously
is positively useless from the application's point of view, this patch
provides a DT configuration method to choose the active port.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
 drivers/net/ethernet/ti/cpsw.c                 |    7 +++++++
 include/linux/platform_data/cpsw.h             |    1 +
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index dba014f..9f61f2b 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -23,6 +23,7 @@ Required properties:
 - mac_control		: Specifies Default MAC control register content
 			  for the specific platform
 - slaves		: Specifies number for slaves
+- cpts_active_slave	: Specifies the slave to use for time stamping
 - slave_reg_ofs		: Specifies slave register offset
 - sliver_reg_ofs	: Specifies slave sliver register offset
 - phy_id		: Specifies slave phy id
@@ -60,6 +61,7 @@ Examples:
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
+		cpts_active_slave = <0>;
 		cpsw_emac0: slave@0 {
 			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
@@ -95,6 +97,7 @@ Examples:
 		rx_descs = <64>;
 		mac_control = <0x20>;
 		slaves = <2>;
+		cpts_active_slave = <0>;
 		cpsw_emac0: slave@0 {
 			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f1af5e0..f165791 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -847,6 +847,13 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->slaves = prop;
 
+	if (of_property_read_u32(node, "cpts_active_slave", &prop)) {
+		pr_err("Missing cpts_active_slave property in the DT.\n");
+		ret = -EINVAL;
+		goto error_ret;
+	}
+	data->cpts_active_slave = prop;
+
 	data->slave_data = kzalloc(sizeof(struct cpsw_slave_data) *
 				   data->slaves, GFP_KERNEL);
 	if (!data->slave_data) {
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index a052b1d..15a077e 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -33,6 +33,7 @@ struct cpsw_platform_data {
 
 	u32	slaves;		/* number of slave cpgmac ports */
 	struct cpsw_slave_data	*slave_data;
+	u32	cpts_active_slave; /* time stamping slave */
 
 	u32	ale_reg_ofs;	/* address lookup engine reg offset */
 	u32	ale_entries;	/* ale table size */
-- 
1.7.2.5
