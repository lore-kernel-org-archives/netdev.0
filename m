From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 9/9] x86: OLPC: move s/r-related EC cmds to EC driver
Date: Wed, 18 Jul 2012 21:29:20 -0700
Message-ID: <20120718212920.237566cb@dev.queued.net>
References: <20120718182144.2d7b0b50@dev.queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Fox <pgf@laptop.org>, Daniel Drake <dsd@laptop.org>,
	"Richard A. Smith" <richard@laptop.org>,
	linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Matthew Garrett <mjg@redhat.com>,
	Anton Vorontsov <cbou@mail.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Chris Ball <cjb@laptop.org>,
	Jon Nettleton <jon.nettleton@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lunge.queued.net ([173.255.254.236]:50927 "EHLO
	lunge.queued.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2GSE3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 00:29:33 -0400
In-Reply-To: <20120718182144.2d7b0b50@dev.queued.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new EC driver calls platform-specific suspend and resume hooks; run
XO-1-specific EC commands from there, rather than deep in s/r code.  If
we attempt to run EC commands after the new EC driver has suspended, it
is refused by the ec->suspended checks.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 arch/x86/platform/olpc/olpc-xo1-pm.c |   15 ------------
 arch/x86/platform/olpc/olpc.c        |   43
++++++++++++++++++++++++++++----- 2 files changed, 36 insertions(+), 22
deletions(-)

diff --git a/arch/x86/platform/olpc/olpc-xo1-pm.c
b/arch/x86/platform/olpc/olpc-xo1-pm.c index 8054b64..d75582d 100644
--- a/arch/x86/platform/olpc/olpc-xo1-pm.c
+++ b/arch/x86/platform/olpc/olpc-xo1-pm.c
@@ -52,16 +52,11 @@ EXPORT_SYMBOL_GPL(olpc_xo1_pm_wakeup_clear);
 static int xo1_power_state_enter(suspend_state_t pm_state)
 {
 	unsigned long saved_sci_mask;
-	int r;
 
 	/* Only STR is supported */
 	if (pm_state != PM_SUSPEND_MEM)
 		return -EINVAL;
 
-	r = olpc_ec_cmd(EC_SET_SCI_INHIBIT, NULL, 0, NULL, 0);
-	if (r)
-		return r;
-
 	/*
 	 * Save SCI mask (this gets lost since PM1_EN is used as a
mask for
 	 * wakeup events, which is not necessarily the same event set)
@@ -77,16 +72,6 @@ static int xo1_power_state_enter(suspend_state_t
pm_state) /* Restore SCI mask (using dword access to CS5536_PM1_EN) */
 	outl(saved_sci_mask, acpi_base + CS5536_PM1_STS);
 
-	/* Tell the EC to stop inhibiting SCIs */
-	olpc_ec_cmd(EC_SET_SCI_INHIBIT_RELEASE, NULL, 0, NULL, 0);
-
-	/*
-	 * Tell the wireless module to restart USB communication.
-	 * Must be done twice.
-	 */
-	olpc_ec_cmd(EC_WAKE_UP_WLAN, NULL, 0, NULL, 0);
-	olpc_ec_cmd(EC_WAKE_UP_WLAN, NULL, 0, NULL, 0);
-
 	return 0;
 }
 
diff --git a/arch/x86/platform/olpc/olpc.c
b/arch/x86/platform/olpc/olpc.c index ed41b43..2737608 100644
--- a/arch/x86/platform/olpc/olpc.c
+++ b/arch/x86/platform/olpc/olpc.c
@@ -263,11 +263,6 @@ int olpc_ec_sci_query(u16 *sci_value)
 }
 EXPORT_SYMBOL_GPL(olpc_ec_sci_query);
 
-static int olpc_ec_suspend(struct platform_device *pdev)
-{
-	return olpc_ec_mask_write(ec_wakeup_mask);
-}
-
 static bool __init check_ofw_architecture(struct device_node *root)
 {
 	const char *olpc_arch;
@@ -339,9 +334,40 @@ static int olpc_xo1_ec_probe(struct
platform_device *pdev) 
 	return 0;
 }
+static int olpc_xo1_ec_suspend(struct platform_device *pdev)
+{
+	olpc_ec_mask_write(ec_wakeup_mask);
+
+	/*
+	 * Squelch SCIs while suspended.  This is a fix for
+	 * <http://dev.laptop.org/ticket/1835>.
+	 */
+	return olpc_ec_cmd(EC_SET_SCI_INHIBIT, NULL, 0, NULL, 0);
+}
+
+static int olpc_xo1_ec_resume(struct platform_device *pdev)
+{
+	/* Tell the EC to stop inhibiting SCIs */
+	olpc_ec_cmd(EC_SET_SCI_INHIBIT_RELEASE, NULL, 0, NULL, 0);
+
+	/*
+	 * Tell the wireless module to restart USB communication.
+	 * Must be done twice.
+	 */
+	olpc_ec_cmd(EC_WAKE_UP_WLAN, NULL, 0, NULL, 0);
+	olpc_ec_cmd(EC_WAKE_UP_WLAN, NULL, 0, NULL, 0);
+
+	return 0;
+}
 
 static struct olpc_ec_driver ec_xo1_driver = {
-	.suspend = olpc_ec_suspend,
+	.probe = olpc_xo1_ec_probe,
+	.suspend = olpc_xo1_ec_suspend,
+	.resume = olpc_xo1_ec_resume,
+	.ec_cmd = olpc_xo1_ec_cmd,
+};
+
+static struct olpc_ec_driver ec_xo1_5_driver = {
 	.probe = olpc_xo1_ec_probe,
 	.ec_cmd = olpc_xo1_ec_cmd,
 };
@@ -354,7 +380,10 @@ static int __init olpc_init(void)
 		return 0;
 
 	/* register the XO-1 and 1.5-specific EC handler */
-	olpc_ec_driver_register(&ec_xo1_driver, NULL);
+	if (olpc_platform_info.boardrev <
olpc_board_pre(0xd0))	/* XO-1 */
+		olpc_ec_driver_register(&ec_xo1_driver, NULL);
+	else
+		olpc_ec_driver_register(&ec_xo1_5_driver, NULL);
 	platform_device_register_simple("olpc-ec", -1, NULL, 0);
 
 	/* assume B1 and above models always have a DCON */
-- 
1.7.2.5
