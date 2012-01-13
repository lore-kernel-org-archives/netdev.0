From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 4/5] brcmsmac: remove PCI suspend/resume from bcma driver
Date: Fri, 13 Jan 2012 00:01:58 -0800 (PST)
Message-ID: <alpine.LNX.2.00.1201130001320.5860@air.linux-foundation.org>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com> <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:46425 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751196Ab2AMIBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 03:01:24 -0500
Received: by obcva7 with SMTP id va7so1848087obc.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 00:01:23 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jan 2012 23:36:52 -0800

The brcmsmac driver isn't a PCI driver any more, it's a bcma one.  The
PCI device has been resumed by the PCI driver (the generic PCI layer,
really), we should be resuming just our own driver state.

Also add pr_debug() calls to show that we now actually get the
suspend/resume events.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   38 ++------------------
 1 files changed, 3 insertions(+), 35 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 213130afdaf7..448ab9c4eb47 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1128,13 +1128,6 @@ static int __devinit brcms_bcma_probe(struct bcma_device *pdev)
 	return 0;
 }
 
-static int brcms_pci_suspend(struct pci_dev *pdev)
-{
-	pci_save_state(pdev);
-	pci_disable_device(pdev);
-	return pci_set_power_state(pdev, PCI_D3hot);
-}
-
 static int brcms_suspend(struct bcma_device *pdev)
 {
 	struct brcms_info *wl;
@@ -1153,40 +1146,15 @@ static int brcms_suspend(struct bcma_device *pdev)
 	wl->pub->hw_up = false;
 	spin_unlock_bh(&wl->lock);
 
-	/* temporarily do suspend ourselves */
-	return brcms_pci_suspend(pdev->bus->host_pci);
-}
-
-static int brcms_pci_resume(struct pci_dev *pdev)
-{
-	int err = 0;
-	uint val;
-
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		return err;
-
-	pci_restore_state(pdev);
-
-	err = pci_enable_device(pdev);
-	if (err)
-		return err;
-
-	pci_set_master(pdev);
-
-	pci_read_config_dword(pdev, 0x40, &val);
-	if ((val & 0x0000ff00) != 0)
-		pci_write_config_dword(pdev, 0x40, val & 0xffff00ff);
+	pr_debug("brcms_suspend ok\n");
 
 	return 0;
 }
 
 static int brcms_resume(struct bcma_device *pdev)
 {
-	/*
-	*  just do pci resume for now until bcma supports it.
-	*/
-	return brcms_pci_resume(pdev->bus->host_pci);
+	pr_debug("brcms_resume ok\n");
+	return 0;
 }
 
 static struct bcma_driver brcms_bcma_driver = {
-- 
1.7.8.rc2.3.g0911
