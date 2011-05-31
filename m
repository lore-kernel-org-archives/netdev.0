From: David Miller <davem@davemloft.net>
Subject: Re: Section conflict compile failures in net
Date: Tue, 31 May 2011 15:45:31 -0700 (PDT)
Message-ID: <20110531.154531.493226762.davem@davemloft.net>
References: <1306445993.4048.58.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: James.Bottomley@HansenPartnership.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932725Ab1EaWpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 18:45:36 -0400
In-Reply-To: <1306445993.4048.58.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 26 May 2011 16:39:53 -0500

BTW, linux-netdev doesn't exist, it's just plain netdev.

> Simply reverting 
> 
> commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4
> Author: Micha<C5><82> Miros<C5><82>aw <mirq-linux@rere.qmqm.pl>
> Date:   Mon Apr 18 13:31:20 2011 +0000
> 
>     net: fix section mismatches
>     
> Fixes the problem.
> 
> If I look at the first problem in hp100.c, the addition of
> __devinitconst to the device tables is fine, but there's no
> corresponding sectional tag on their use, so when compiled as a module,
> things like hp100_eisa_driver is now in the main data section but refers
> to something in the init data section ... I assume all the others are
> the same type of problem.

Yeah I think the device ID table __devinitconst bits have to be
reverted.

I'll apply something like the following:

net: Revert adding __devinitconst to driver ID tables.

If the table is hooked up to foo_driver->id_table we can't
mark it __devinitconst otherwise we end up with section
mismatches.

Reported-by: James Bottomley <James.Bottomley@HansenPartnership.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 5f25889..f6eaf6f 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -395,7 +395,7 @@ static struct isa_driver el3_isa_driver = {
 static int isa_registered;
 
 #ifdef CONFIG_PNP
-static const struct pnp_device_id el3_pnp_ids[] __devinitconst = {
+static const struct pnp_device_id el3_pnp_ids[] = {
 	{ .id = "TCM5090" }, /* 3Com Etherlink III (TP) */
 	{ .id = "TCM5091" }, /* 3Com Etherlink III */
 	{ .id = "TCM5094" }, /* 3Com Etherlink III (combo) */
@@ -478,7 +478,7 @@ static int pnp_registered;
 #endif /* CONFIG_PNP */
 
 #ifdef CONFIG_EISA
-static const struct eisa_device_id el3_eisa_ids[] __devinitconst = {
+static const struct eisa_device_id el3_eisa_ids[] = {
 		{ "TCM5090" },
 		{ "TCM5091" },
 		{ "TCM5092" },
@@ -508,7 +508,7 @@ static int eisa_registered;
 #ifdef CONFIG_MCA
 static int el3_mca_probe(struct device *dev);
 
-static const short el3_mca_adapter_ids[] __devinitconst = {
+static const short el3_mca_adapter_ids[] = {
 		0x627c,
 		0x627d,
 		0x62db,
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 99f43d2..9ff7f37 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -901,7 +901,7 @@ static const struct dev_pm_ops vortex_pm_ops = {
 #endif /* !CONFIG_PM */
 
 #ifdef CONFIG_EISA
-static const struct eisa_device_id vortex_eisa_ids[] __devinitconst = {
+static const struct eisa_device_id vortex_eisa_ids[] = {
 	{ "TCM5920", CH_3C592 },
 	{ "TCM5970", CH_3C597 },
 	{ "" }
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 1765405..645182b 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -342,7 +342,7 @@ static const char depca_string[] = "depca";
 static int depca_device_remove (struct device *device);
 
 #ifdef CONFIG_EISA
-static const struct eisa_device_id depca_eisa_ids[] __devinitconst = {
+static const struct eisa_device_id depca_eisa_ids[] = {
 	{ "DEC4220", de422 },
 	{ "" }
 };
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index c52a1df..ea8d345 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -195,7 +195,7 @@ static const char *const hp100_isa_tbl[] __devinitconst = {
 #endif
 
 #ifdef CONFIG_EISA
-static const struct eisa_device_id hp100_eisa_tbl[] __devinitconst = {
+static const struct eisa_device_id hp100_eisa_tbl[] = {
 	{ "HWPF180" }, /* HP J2577 rev A */
 	{ "HWP1920" }, /* HP 27248B */
 	{ "HWP1940" }, /* HP J2577 */
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index 136d754..00b1a2c 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -895,7 +895,7 @@ static int ibmlana_irq;
 static int ibmlana_io;
 static int startslot;		/* counts through slots when probing multiple devices */
 
-static const short ibmlana_adapter_ids[] __devinitconst = {
+static const short ibmlana_adapter_ids[] = {
 	IBM_LANA_ID,
 	0x0000
 };
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 69b5707..76929e4 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -366,7 +366,7 @@ static inline void register_bank(int iobase, int bank)
 }
 
 /* PNP hotplug support */
-static const struct pnp_device_id smsc_ircc_pnp_table[] __devinitconst = {
+static const struct pnp_device_id smsc_ircc_pnp_table[] = {
 	{ .id = "SMCf010", .driver_data = 0 },
 	/* and presumably others */
 	{ }
diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index e8984b0..3e7fb5b 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -316,7 +316,7 @@ static void ne3210_block_output(struct net_device *dev, int count,
 	memcpy_toio(shmem, buf, count);
 }
 
-static const struct eisa_device_id ne3210_ids[] __devinitconst = {
+static const struct eisa_device_id ne3210_ids[] = {
 	{ "EGL0101" },
 	{ "NVL1801" },
 	{ "" },
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index 0f29f26..76abd94 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -156,7 +156,7 @@ static const struct {
    { 14, 15 }
 };
 
-static const short smc_mca_adapter_ids[] __devinitconst = {
+static const short smc_mca_adapter_ids[] = {
 	0x61c8,
 	0x61c9,
 	0x6fc0,
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 1313aa1..44b96f2 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -727,7 +727,7 @@ static int __devexit madgemc_remove(struct device *device)
 	return 0;
 }
 
-static const short madgemc_adapter_ids[] __devinitconst = {
+static const short madgemc_adapter_ids[] = {
 	0x002d,
 	0x0000
 };
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 45144d5..40c0aa2 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -2097,7 +2097,7 @@ static int __devexit de4x5_eisa_remove (struct device *device)
 	return 0;
 }
 
-static const struct eisa_device_id de4x5_eisa_ids[] __devinitconst = {
+static const struct eisa_device_id de4x5_eisa_ids[] = {
         { "DEC4250", 0 },	/* 0 is the board name index... */
         { "" }
 };
