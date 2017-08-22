From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 2/2] net: smsc911x: Quiten netif during suspend
Date: Tue, 22 Aug 2017 20:37:26 +0200
Message-ID: <1503427046-17618-3-git-send-email-geert+renesas@glider.be>
References: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Cc: Lukas Wunner <lukas@wunner.de>,
        "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
        netdev@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from laurent.telenet-ops.be ([195.130.137.89]:46976 "EHLO
        laurent.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752349AbdHVShi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:37:38 -0400
In-Reply-To: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the network interface is kept running during suspend, the net core
may call net_device_ops.ndo_start_xmit() while the Ethernet device is
still suspended, which may lead to a system crash.

E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
driven by a PM controlled clock.  If the Ethernet registers are accessed
while the clock is not running, the system will crash with an imprecise
external abort.

As this is a race condition with a small time window, it is not so easy
to trigger at will.  Using pm_test may increase your chances:

    # echo 0 > /sys/module/printk/parameters/console_suspend
    # echo platform > /sys/power/pm_test
    # echo mem > /sys/power/state

To fix this, make sure the network interface is quitened during suspend.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
No stacktrace is provided, as the imprecise external abort is usually
reported from an innocent looking and unrelated function like
__loop_delay(), cpu_idle_poll(), or arch_timer_read_counter_long().
---
 drivers/net/ethernet/smsc/smsc911x.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 0b6a39b003a4e188..012fb66eed8dd618 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2595,6 +2595,11 @@ static int smsc911x_suspend(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct smsc911x_data *pdata = netdev_priv(ndev);
 
+	if (netif_running(ndev)) {
+		netif_stop_queue(ndev);
+		netif_device_detach(ndev);
+	}
+
 	/* enable wake on LAN, energy detection and the external PME
 	 * signal. */
 	smsc911x_reg_write(pdata, PMT_CTRL,
@@ -2628,7 +2633,15 @@ static int smsc911x_resume(struct device *dev)
 	while (!(smsc911x_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && --to)
 		udelay(1000);
 
-	return (to == 0) ? -EIO : 0;
+	if (to == 0)
+		return -EIO;
+
+	if (netif_running(ndev)) {
+		netif_device_attach(ndev);
+		netif_start_queue(ndev);
+	}
+
+	return 0;
 }
 
 static const struct dev_pm_ops smsc911x_pm_ops = {
-- 
2.7.4
