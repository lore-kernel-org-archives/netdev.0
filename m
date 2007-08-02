From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Thu, 02 Aug 2007 12:10:29 -0700
Message-ID: <1186081829.18322.20.camel@dell>
References: <1186002023.18322.7.camel@dell>
 <200708021005.45773.joachim.deguara@amd.com>
 <200708021115.10812.joachim.deguara@amd.com>
 <20070802.022317.66176729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joachim.deguara@amd.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3744 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752875AbXHBSQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 14:16:31 -0400
In-Reply-To: <20070802.022317.66176729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-02 at 02:23 -0700, David Miller wrote:
> From: "Joachim Deguara" <joachim.deguara@amd.com>
> Date: Thu, 2 Aug 2007 11:15:05 +0200
> 
> > Seams like even if powersave shuts down the network that the device should 
> > still work after a suspend to ram, so who is at fault here?
> 
> It's a good question.
> 
> The pci_enable() is done on the PCI device at probe time, at least in
> the tg3 driver, and with such a model restoring and saving of PCI
> config space should not be dependant upon whether the netdev is
> running or not.
> 

Alternatively, we can also fix it by calling pci_enable_device() again
in tg3_open().  But I think it is better to just always save and restore
in suspend/resume.  bnx2.c will also require the same fix.

Thanks Joachim for helping to debug this problem.  Please try this
patch:

[TG3]: Fix suspend/resume problem.

Joachim Deguara <joachim.deguara@amd.com> reported that tg3 devices
would not resume properly if the device was shutdown before the system
was suspended.  In such scenario where the netif_running state is 0,
tg3_suspend() would not save the PCI state and so the memory enable bit
and bus master enable bit would be lost.

We fix this by always saving and restoring the PCI state in
tg3_suspend() and tg3_resume() regardless of netif_running() state.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dc41c05..5874042 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.79"
-#define DRV_MODULE_RELDATE	"July 18, 2007"
+#define DRV_MODULE_VERSION	"3.80"
+#define DRV_MODULE_RELDATE	"August 2, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -12111,6 +12111,12 @@ static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
+	/* PCI register 4 needs to be saved whether netif_running() or not.
+	 * MSI address and data need to be saved if using MSI and
+	 * netif_running().
+	 */
+	pci_save_state(pdev);
+
 	if (!netif_running(dev))
 		return 0;
 
@@ -12130,9 +12136,6 @@ static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 	tg3_full_unlock(tp);
 
-	/* Save MSI address and data for resume.  */
-	pci_save_state(pdev);
-
 	err = tg3_set_power_state(tp, pci_choose_state(pdev, state));
 	if (err) {
 		tg3_full_lock(tp, 0);
@@ -12160,11 +12163,11 @@ static int tg3_resume(struct pci_dev *pdev)
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
+	pci_restore_state(tp->pdev);
+
 	if (!netif_running(dev))
 		return 0;
 
-	pci_restore_state(tp->pdev);
-
 	err = tg3_set_power_state(tp, PCI_D0);
 	if (err)
 		return err;


