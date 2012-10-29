From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 09/10] cpts: specify the input clock frequency via DT
Date: Mon, 29 Oct 2012 19:45:19 +0100
Message-ID: <8766deebbaeb9015babdc20a194aa8b683a61ec6.1351535541.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44513 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760461Ab2J2Spy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:45:54 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2256783eek.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 11:45:54 -0700 (PDT)
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a way to configure the CPTS input clock scaling factors
via the device tree.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    6 ++++++
 drivers/net/ethernet/ti/cpsw.c                 |   14 ++++++++++++++
 include/linux/platform_data/cpsw.h             |    2 ++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 9f61f2b..2214607 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -24,6 +24,8 @@ Required properties:
 			  for the specific platform
 - slaves		: Specifies number for slaves
 - cpts_active_slave	: Specifies the slave to use for time stamping
+- cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
+- cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
 - slave_reg_ofs		: Specifies slave register offset
 - sliver_reg_ofs	: Specifies slave sliver register offset
 - phy_id		: Specifies slave phy id
@@ -62,6 +64,8 @@ Examples:
 		mac_control = <0x20>;
 		slaves = <2>;
 		cpts_active_slave = <0>;
+		cpts_clock_mult = <0x80000000>;
+		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
 			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
@@ -98,6 +102,8 @@ Examples:
 		mac_control = <0x20>;
 		slaves = <2>;
 		cpts_active_slave = <0>;
+		cpts_clock_mult = <0x80000000>;
+		cpts_clock_shift = <29>;
 		cpsw_emac0: slave@0 {
 			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f165791..c04627c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -854,6 +854,20 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->cpts_active_slave = prop;
 
+	if (of_property_read_u32(node, "cpts_clock_mult", &prop)) {
+		pr_err("Missing cpts_clock_mult property in the DT.\n");
+		ret = -EINVAL;
+		goto error_ret;
+	}
+	data->cpts_clock_mult = prop;
+
+	if (of_property_read_u32(node, "cpts_clock_shift", &prop)) {
+		pr_err("Missing cpts_clock_shift property in the DT.\n");
+		ret = -EINVAL;
+		goto error_ret;
+	}
+	data->cpts_clock_shift = prop;
+
 	data->slave_data = kzalloc(sizeof(struct cpsw_slave_data) *
 				   data->slaves, GFP_KERNEL);
 	if (!data->slave_data) {
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index 15a077e..b5c16c3 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -34,6 +34,8 @@ struct cpsw_platform_data {
 	u32	slaves;		/* number of slave cpgmac ports */
 	struct cpsw_slave_data	*slave_data;
 	u32	cpts_active_slave; /* time stamping slave */
+	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
+	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
 
 	u32	ale_reg_ofs;	/* address lookup engine reg offset */
 	u32	ale_entries;	/* ale table size */
-- 
1.7.2.5
