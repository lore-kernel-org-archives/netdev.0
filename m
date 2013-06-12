From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net] tg3: Wait for boot code to finish after power on
Date: Wed, 12 Jun 2013 11:08:59 -0700
Message-ID: <1371060539-27837-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	stable@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some systems that don't need wake-on-lan may choose to power down the
chip on system standby. Upon resume, the power on causes the boot code
to startup and initialize the hardware. On one new platform, this is
causing the device to go into a bad state due to a race between the
driver and boot code, once every several hundred resumes. The same race
exists on open since we come up from a power on.

This patch adds a wait for boot code signature at the beginning of
tg3_init_hw() which is common to both cases. If there has not been a
power-off or the boot code has already completed, the signature will be
present and poll_fw() returns immediately. Also return immediately if
the device does not have firmware.

Cc: stable@vger.kernel.org
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0f493c8..c777b90 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1800,6 +1800,9 @@ static int tg3_poll_fw(struct tg3 *tp)
 	int i;
 	u32 val;
 
+	if (tg3_flag(tp, NO_FWARE_REPORTED))
+		return 0;
+
 	if (tg3_flag(tp, IS_SSB_CORE)) {
 		/* We don't use firmware. */
 		return 0;
@@ -10404,6 +10407,13 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
  */
 static int tg3_init_hw(struct tg3 *tp, bool reset_phy)
 {
+	/* Chip may have been just powered on. If so, the boot code may still
+	 * be running initialization. Wait for it to finish to avoid races in
+	 * accessing the hardware.
+	 */
+	tg3_enable_register_access(tp);
+	tg3_poll_fw(tp);
+
 	tg3_switch_clocks(tp);
 
 	tw32(TG3PCI_MEM_WIN_BASE_ADDR, 0);
-- 
1.8.1.4
