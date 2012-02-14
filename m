From: Sameer Nanda <snanda@chromium.org>
Subject: [PATCH 2/2] r8169: transition to D0 state at shutdown
Date: Tue, 14 Feb 2012 10:31:15 -0800
Message-ID: <1329244275-28130-1-git-send-email-snanda@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	Sameer Nanda <snanda@chromium.org>
To: omieu@fr.zoreil.com,
	jw@sisk.pl,
	hayeswang@realtek.com
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

With runtime PM, if the ethernet cable is disconnected, the device is
transitioned to D3 state to conserve energy. If the system is shutdown
in this state, any register accesses in rtl_shutdown are dropped on
the floor.

This patch transitions the device back to D0 state in rtl_shutdown if
the device was runtime PM suspended. In addition, since runtiome PM
also mucks around with WOL options, the saved WOL options are also
restored in rtl_shutdown.

Signed-off-by: Sameer Nanda <snanda@chromium.org>
---
 drivers/net/ethernet/realtek/r8169.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index a6921b7..4a894e6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -691,6 +691,7 @@ struct rtl8169_private {
 	u16 intr_event;
 	u16 napi_event;
 	u16 intr_mask;
+	bool runtime_suspended;
 
 	struct mdio_ops {
 		void (*write)(void __iomem *, int, int);
@@ -4308,6 +4309,7 @@ static int rtl8169_open(struct net_device *dev)
 	rtl_hw_start(dev);
 
 	tp->saved_wolopts = 0;
+	tp->runtime_suspended = false;
 	pm_runtime_put_noidle(&pdev->dev);
 
 	rtl8169_check_link_status(dev, tp, ioaddr);
@@ -6106,6 +6108,7 @@ static int rtl8169_runtime_suspend(struct device *device)
 	spin_lock_irq(&tp->lock);
 	tp->saved_wolopts = __rtl8169_get_wol(tp);
 	__rtl8169_set_wol(tp, WAKE_ANY);
+	tp->runtime_suspended = true;
 	spin_unlock_irq(&tp->lock);
 
 	rtl8169_net_suspend(dev);
@@ -6125,6 +6128,7 @@ static int rtl8169_runtime_resume(struct device *device)
 	spin_lock_irq(&tp->lock);
 	__rtl8169_set_wol(tp, tp->saved_wolopts);
 	tp->saved_wolopts = 0;
+	tp->runtime_suspended = false;
 	spin_unlock_irq(&tp->lock);
 
 	rtl8169_init_phy(dev, tp);
@@ -6188,6 +6192,10 @@ static void rtl_shutdown(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	/* Get the device back to D0 state if it was runtime suspended. */
+	if (tp->runtime_suspended)
+		pci_set_power_state(pdev, PCI_D0);
+
 	rtl8169_net_suspend(dev);
 
 	/* Restore original MAC address */
@@ -6195,6 +6203,10 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	spin_lock_irq(&tp->lock);
 
+	/* Restore WOL flags if they were messed around with. */
+	if (tp->saved_wolopts)
+		__rtl8169_set_wol(tp, tp->saved_wolopts);
+
 	rtl8169_hw_reset(tp);
 
 	spin_unlock_irq(&tp->lock);
-- 
1.7.7.3
