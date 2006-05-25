From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: e1000: add WoL fix for 2.6.17rc
Date: Thu, 25 May 2006 14:12:18 -0700
Message-ID: <44761DB2.8050806@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080807070305030504050206"
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:34529 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1030418AbWEYVNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 17:13:16 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080807070305030504050206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Jeff,

Please queue the 'e1000: add shutdown handler back for WoL' for 2.6.17rc's. 
Since this fix is already committed to jgarzik/netdev-2.6#upstream, you can 
cherrypick it into #upstream-fixes:

$ git-cherry-pick c653e6351e371b33b29871e5eedf610ffb3be037


Cheers,

Auke

--------------080807070305030504050206
Content-Type: text/x-patch;
 name="e1000_01_add_shutdown_back.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_01_add_shutdown_back.patch"

e1000: add shutdown handler back to fix WOL

Someone was waaay too aggressive and removed e1000's reboot notifier
instead of porting it to the new way of the shutdown handler.  This change
broke wake on lan.  Add the shutdown handler back in using the same method
as e100 uses.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>


diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index fb8cef6..b224e40 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -221,6 +221,7 @@ static void e1000_restore_vlan(struct e1
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 static int e1000_resume(struct pci_dev *pdev);
 #endif
+static void e1000_shutdown(struct pci_dev *pdev);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
@@ -236,8 +237,9 @@ static struct pci_driver e1000_driver = 
 	/* Power Managment Hooks */
 #ifdef CONFIG_PM
 	.suspend  = e1000_suspend,
-	.resume   = e1000_resume
+	.resume   = e1000_resume,
 #endif
+	.shutdown = e1000_shutdown
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -4605,6 +4607,12 @@ e1000_resume(struct pci_dev *pdev)
 	return 0;
 }
 #endif
+
+static void e1000_shutdown(struct pci_dev *pdev)
+{
+	e1000_suspend(pdev, PMSG_SUSPEND);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs

--------------080807070305030504050206--
