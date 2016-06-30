From: Brian Norris <briannorris@chromium.org>
Subject: [PATCH] mwifiex: mask PCIe interrupts before removal
Date: Thu, 30 Jun 2016 15:21:02 -0700
Message-ID: <1467325262-82799-1-git-send-email-briannorris@chromium.org>
Cc: <linux-kernel@vger.kernel.org>,
	Doug Anderson <dianders@chromium.org>,
	Brian Norris <computersforpeace@gmail.com>,
	Stephen Barber <smbarber@chromium.org>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Brian Norris <briannorris@chromium.org>
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCIe driver didn't mask the host interrupts before trying to tear
down. This causes lockups at reboot or rmmod when using MSI-X on 8997,
since the MSI handler gets confused and locks up the system.

Also tested on 8897, which does not support MSI-X (and wasn't
experiencing this same bug). No regressions seen there.

Signed-off-by: Brian Norris <briannorris@chromium.org>
---
 drivers/net/wireless/marvell/mwifiex/pcie.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
index 0c7937eb6b77..af98371dc2af 100644
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -440,6 +440,11 @@ static int mwifiex_pcie_disable_host_int(struct mwifiex_adapter *adapter)
 	return 0;
 }
 
+static void mwifiex_pcie_disable_host_int_noerr(struct mwifiex_adapter *adapter)
+{
+	WARN_ON(mwifiex_pcie_disable_host_int(adapter));
+}
+
 /*
  * This function enables the host interrupt.
  *
@@ -2945,6 +2950,7 @@ static struct mwifiex_if_ops pcie_ops = {
 	.register_dev =			mwifiex_register_dev,
 	.unregister_dev =		mwifiex_unregister_dev,
 	.enable_int =			mwifiex_pcie_enable_host_int,
+	.disable_int =			mwifiex_pcie_disable_host_int_noerr,
 	.process_int_status =		mwifiex_process_int_status,
 	.host_to_card =			mwifiex_pcie_host_to_card,
 	.wakeup =			mwifiex_pm_wakeup_card,
-- 
2.8.0.rc3.226.g39d4020
