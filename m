From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: runtime resume before shutdown.
Date: Tue, 6 Mar 2012 12:14:12 +0100
Message-ID: <20120306111412.GA1805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Sameer Nanda <snanda@chromium.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57122 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754964Ab2CFLPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 06:15:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With runtime PM, if the ethernet cable is disconnected, the device is
transitioned to D3 state to conserve energy. If the system is shutdown
in this state, any register accesses in rtl_shutdown are dropped on
the floor. As the device was programmed by .runtime_suspend() to wake
on link changes, it is thus brought back up as soon as the link recovers.

Resuming every suspended device through the driver core would slow things
down and it is not clear how many devices really need it now.

Original report and D0 transition patch by Sameer Nanda. Patch has been
changed to comply with advices by Rafael J. Wysocki and the PM folks.

Reported-by: Sameer Nanda <snanda@chromium.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Hayes Wang <hayeswang@realtek.com>
Cc: Alan Stern <stern@rowland.harvard.edu>
---

 This sucker turned my silent wake-on-alarm workstation into an early
 sunday morning testbed takeoff. Please consider before 3.3 goes out.

 drivers/net/ethernet/realtek/r8169.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1adf177..bbacb37 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6194,6 +6194,9 @@ static void rtl_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct device *d = &pdev->dev;
+
+	pm_runtime_get_sync(d);
 
 	rtl8169_net_suspend(dev);
 
@@ -6215,6 +6218,8 @@ static void rtl_shutdown(struct pci_dev *pdev)
 		pci_wake_from_d3(pdev, true);
 		pci_set_power_state(pdev, PCI_D3hot);
 	}
+
+	pm_runtime_put_noidle(d);
 }
 
 static struct pci_driver rtl8169_pci_driver = {
-- 
1.7.7.6
