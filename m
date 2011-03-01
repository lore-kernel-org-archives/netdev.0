From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-03-01
Date: Tue, 1 Mar 2011 13:46:10 -0500
Message-ID: <20110301184609.GA2536@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54908 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380Ab1CATB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 14:01:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another handful of fixes intended for 2.6.38.  Included are a
couple of device IDs, a one-liner to allow iwlagn to load a bug-fixed
firmware for iwl5000, an endian fix for ath9k, another ath9k fix to
correct a regression involving interrupt enabling, and a fix to disable
power save mode for BCM4320b in rndis_wlan.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit e3fa3aff0cb198e7c53d894f52146121d9592872:

  net: fix nla_policy_len to actually _iterate_ over the policy (2011-02-28 12:38:25 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54usb: add Senao NUB-350 usbid

Fry, Donald H (1):
      iwlagn: Support new 5000 microcode.

Jan Puk (1):
      carl9170: add Airlive X.USB a/b/g/n USBID

John W. Linville (1):
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6

Jussi Kivilinna (1):
      rndis_wlan: use power save only for BCM4320b

Stanislaw Gruszka (1):
      ath9k: correct ath9k_hw_set_interrupts

Sujith Manoharan (1):
      ath9k_htc: Fix an endian issue

 drivers/net/wireless/ath/ath9k/hif_usb.c |    9 +++++----
 drivers/net/wireless/ath/ath9k/mac.c     |    5 +++--
 drivers/net/wireless/ath/carl9170/usb.c  |    2 ++
 drivers/net/wireless/iwlwifi/iwl-5000.c  |    2 +-
 drivers/net/wireless/p54/p54usb.c        |    1 +
 drivers/net/wireless/rndis_wlan.c        |    3 +++
 6 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 5ab3084..07b1633 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -219,8 +219,9 @@ static int __hif_usb_tx(struct hif_device_usb *hif_dev)
 	struct tx_buf *tx_buf = NULL;
 	struct sk_buff *nskb = NULL;
 	int ret = 0, i;
-	u16 *hdr, tx_skb_cnt = 0;
+	u16 tx_skb_cnt = 0;
 	u8 *buf;
+	__le16 *hdr;
 
 	if (hif_dev->tx.tx_skb_cnt == 0)
 		return 0;
@@ -245,9 +246,9 @@ static int __hif_usb_tx(struct hif_device_usb *hif_dev)
 
 		buf = tx_buf->buf;
 		buf += tx_buf->offset;
-		hdr = (u16 *)buf;
-		*hdr++ = nskb->len;
-		*hdr++ = ATH_USB_TX_STREAM_MODE_TAG;
+		hdr = (__le16 *)buf;
+		*hdr++ = cpu_to_le16(nskb->len);
+		*hdr++ = cpu_to_le16(ATH_USB_TX_STREAM_MODE_TAG);
 		buf += 4;
 		memcpy(buf, nskb->data, nskb->len);
 		tx_buf->len = nskb->len + 4;
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 180170d..2915b11 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -885,7 +885,7 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah, enum ath9k_int ints)
 	struct ath_common *common = ath9k_hw_common(ah);
 
 	if (!(ints & ATH9K_INT_GLOBAL))
-		ath9k_hw_enable_interrupts(ah);
+		ath9k_hw_disable_interrupts(ah);
 
 	ath_dbg(common, ATH_DBG_INTERRUPT, "0x%x => 0x%x\n", omask, ints);
 
@@ -963,7 +963,8 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah, enum ath9k_int ints)
 			REG_CLR_BIT(ah, AR_IMR_S5, AR_IMR_S5_TIM_TIMER);
 	}
 
-	ath9k_hw_enable_interrupts(ah);
+	if (ints & ATH9K_INT_GLOBAL)
+		ath9k_hw_enable_interrupts(ah);
 
 	return;
 }
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 537732e..f82c400 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -118,6 +118,8 @@ static struct usb_device_id carl9170_usb_ids[] = {
 	{ USB_DEVICE(0x057c, 0x8402) },
 	/* Qwest/Actiontec 802AIN Wireless N USB Network Adapter */
 	{ USB_DEVICE(0x1668, 0x1200) },
+	/* Airlive X.USB a/b/g/n */
+	{ USB_DEVICE(0x1b75, 0x9170) },
 
 	/* terminate */
 	{}
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 79ab0a6..537fb8c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -51,7 +51,7 @@
 #include "iwl-agn-debugfs.h"
 
 /* Highest firmware API version supported */
-#define IWL5000_UCODE_API_MAX 2
+#define IWL5000_UCODE_API_MAX 5
 #define IWL5150_UCODE_API_MAX 2
 
 /* Lowest firmware API version supported */
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 21713a7..9b344a9 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -98,6 +98,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x1413, 0x5400)},   /* Telsey 802.11g USB2.0 Adapter */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
 	{USB_DEVICE(0x1668, 0x1050)},	/* Actiontec 802UIG-1 */
+	{USB_DEVICE(0x1740, 0x1000)},	/* Senao NUB-350 */
 	{USB_DEVICE(0x2001, 0x3704)},	/* DLink DWL-G122 rev A2 */
 	{USB_DEVICE(0x2001, 0x3705)},	/* D-Link DWL-G120 rev C1 */
 	{USB_DEVICE(0x413c, 0x5513)},	/* Dell WLA3310 USB Wireless Adapter */
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 848cc2c..518542b 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2597,6 +2597,9 @@ static int rndis_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
 	__le32 mode;
 	int ret;
 
+	if (priv->device_type != RNDIS_BCM4320B)
+		return -ENOTSUPP;
+
 	netdev_dbg(usbdev->net, "%s(): %s, %d\n", __func__,
 				enabled ? "enabled" : "disabled",
 				timeout);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
