From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mwifiex: fix uninitialized variable access in pcie_remove
Date: Fri, 13 Jan 2017 16:35:03 +0100
Message-ID: <20170113153534.2617372-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Brian Norris <briannorris@chromium.org>,
        Xinming Hu <huxm@marvell.com>, Cathy Luo <cluo@marvell.com>,
        Shengzhen Li <szli@marvell.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Checking the firmware status from PCIe register only works
if the register is available, otherwise we end up with
random behavior:

drivers/net/wireless/marvell/mwifiex/pcie.c: In function 'mwifiex_pcie_remove':
drivers/net/wireless/marvell/mwifiex/pcie.c:585:5: error: 'fw_status' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This makes sure we treat the absence of the register as a failure.

Fixes: 045f0c1b5e26 ("mwifiex: get rid of global user_rmmod flag")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/marvell/mwifiex/pcie.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
index 031141663fc0..eebc68caecdd 100644
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -581,6 +581,8 @@ static void mwifiex_pcie_remove(struct pci_dev *pdev)
 	reg = card->pcie.reg;
 	if (reg)
 		ret = mwifiex_read_reg(adapter, reg->fw_status, &fw_status);
+	else
+		fw_status = -1;
 
 	if (fw_status == FIRMWARE_READY_PCIE && !adapter->mfg_mode) {
 		mwifiex_deauthenticate_all(adapter);
-- 
2.9.0
