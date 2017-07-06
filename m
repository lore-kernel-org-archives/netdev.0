From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [PATCH v2] mwifiex: uninit wakeup info in the error handling
Date: Thu,  6 Jul 2017 15:55:28 +0800
Message-ID: <1499327728-25388-1-git-send-email-jeffy.chen@rock-chips.com>
Cc: briannorris@google.com, Jeffy Chen <jeffy.chen@rock-chips.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org, akarwar@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We inited wakeup info at the beginning of mwifiex_add_card, so we need
to uninit it in the error handling.

It's much the same as what we did in:
36908c4 mwifiex: uninit wakeup info when removing device

Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>

---

Changes in v2:
Uninit wakeup when _mwifiex_fw_dpc failed too.

 drivers/net/wireless/marvell/mwifiex/main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index f2600b8..097a899 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -665,8 +665,11 @@ static int _mwifiex_fw_dpc(const struct firmware *firmware, void *context)
 		release_firmware(adapter->firmware);
 		adapter->firmware = NULL;
 	}
-	if (init_failed)
+	if (init_failed) {
+		if (adapter->irq_wakeup >= 0)
+			device_init_wakeup(adapter->dev, false);
 		mwifiex_free_adapter(adapter);
+	}
 	/* Tell all current and future waiters we're finished */
 	complete_all(fw_done);
 
@@ -1655,6 +1658,8 @@ mwifiex_add_card(void *card, struct completion *fw_done,
 		mwifiex_shutdown_drv(adapter);
 	}
 err_kmalloc:
+	if (adapter->irq_wakeup >= 0)
+		device_init_wakeup(adapter->dev, false);
 	mwifiex_free_adapter(adapter);
 
 err_init_sw:
-- 
2.1.4
