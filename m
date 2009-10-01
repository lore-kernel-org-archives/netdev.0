From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-10-01
Date: Thu, 1 Oct 2009 14:24:51 -0400
Message-ID: <20091001182450.GD2895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52180 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbZJASaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 14:30:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

A small collection of fixes for 2.6.32...

One is a brown paper bag fix for an uninitialized variable, another is a
USB ID.  There is a beaconing fix for the mac80211_hwsim "fake" driver,
and a bug fix for AP mode related to buffering frames for stations in
power save mode.

The b43 fix looks a bit long, but it is more-or-less the same simple
fix applied in multiple places.  It addresses a bug where "the last
bytes of data sent/received to/from PIO FIFOs on SDIO-based cards get
'swizzled' when its length is not multiple of 4 bytes."

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit eb1cf0f8f7a9e5a6d573d5bd72c015686a042db0:
  David S. Miller (1):
        Merge branch 'master' of ssh://master.kernel.org/.../linville/wireless-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      ar9170: fix bug in iq-auto calibration value calculation

Igor Perminov (1):
      mac80211: Fix [re]association power saving issue on AP side

Jouni Malinen (1):
      mac80211_hwsim: Fix initial beacon timer configuration

Michael Buesch (1):
      b43: Always use block-I/O for the PIO data registers

Michal Szalata (1):
      rt2x00: Thrustmaster FunAccess WIFI USB and rt73usb

 drivers/net/wireless/ath/ar9170/phy.c |    6 +--
 drivers/net/wireless/b43/pio.c        |   60 +++++++++++++++++++++------------
 drivers/net/wireless/mac80211_hwsim.c |    3 ++
 drivers/net/wireless/rt2x00/rt73usb.c |    1 +
 net/mac80211/tx.c                     |    5 ++-
 5 files changed, 48 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/ath/ar9170/phy.c b/drivers/net/wireless/ath/ar9170/phy.c
index b3e5cf3..dbd488d 100644
--- a/drivers/net/wireless/ath/ar9170/phy.c
+++ b/drivers/net/wireless/ath/ar9170/phy.c
@@ -1141,7 +1141,8 @@ static int ar9170_set_freq_cal_data(struct ar9170 *ar,
 	u8 vpds[2][AR5416_PD_GAIN_ICEPTS];
 	u8 pwrs[2][AR5416_PD_GAIN_ICEPTS];
 	int chain, idx, i;
-	u8 f;
+	u32 phy_data = 0;
+	u8 f, tmp;
 
 	switch (channel->band) {
 	case IEEE80211_BAND_2GHZ:
@@ -1208,9 +1209,6 @@ static int ar9170_set_freq_cal_data(struct ar9170 *ar,
 		}
 
 		for (i = 0; i < 76; i++) {
-			u32 phy_data;
-			u8 tmp;
-
 			if (i < 25) {
 				tmp = ar9170_interpolate_val(i, &pwrs[0][0],
 							     &vpds[0][0]);
diff --git a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/b43/pio.c
index e96091b..9c13979 100644
--- a/drivers/net/wireless/b43/pio.c
+++ b/drivers/net/wireless/b43/pio.c
@@ -340,10 +340,15 @@ static u16 tx_write_2byte_queue(struct b43_pio_txqueue *q,
 			q->mmio_base + B43_PIO_TXDATA,
 			sizeof(u16));
 	if (data_len & 1) {
+		u8 tail[2] = { 0, };
+
 		/* Write the last byte. */
 		ctl &= ~B43_PIO_TXCTL_WRITEHI;
 		b43_piotx_write16(q, B43_PIO_TXCTL, ctl);
-		b43_piotx_write16(q, B43_PIO_TXDATA, data[data_len - 1]);
+		tail[0] = data[data_len - 1];
+		ssb_block_write(dev->dev, tail, 2,
+				q->mmio_base + B43_PIO_TXDATA,
+				sizeof(u16));
 	}
 
 	return ctl;
@@ -386,26 +391,31 @@ static u32 tx_write_4byte_queue(struct b43_pio_txqueue *q,
 			q->mmio_base + B43_PIO8_TXDATA,
 			sizeof(u32));
 	if (data_len & 3) {
-		u32 value = 0;
+		u8 tail[4] = { 0, };
 
 		/* Write the last few bytes. */
 		ctl &= ~(B43_PIO8_TXCTL_8_15 | B43_PIO8_TXCTL_16_23 |
 			 B43_PIO8_TXCTL_24_31);
-		data = &(data[data_len - 1]);
 		switch (data_len & 3) {
 		case 3:
-			ctl |= B43_PIO8_TXCTL_16_23;
-			value |= (u32)(*data) << 16;
-			data--;
+			ctl |= B43_PIO8_TXCTL_16_23 | B43_PIO8_TXCTL_8_15;
+			tail[0] = data[data_len - 3];
+			tail[1] = data[data_len - 2];
+			tail[2] = data[data_len - 1];
+			break;
 		case 2:
 			ctl |= B43_PIO8_TXCTL_8_15;
-			value |= (u32)(*data) << 8;
-			data--;
+			tail[0] = data[data_len - 2];
+			tail[1] = data[data_len - 1];
+			break;
 		case 1:
-			value |= (u32)(*data);
+			tail[0] = data[data_len - 1];
+			break;
 		}
 		b43_piotx_write32(q, B43_PIO8_TXCTL, ctl);
-		b43_piotx_write32(q, B43_PIO8_TXDATA, value);
+		ssb_block_write(dev->dev, tail, 4,
+				q->mmio_base + B43_PIO8_TXDATA,
+				sizeof(u32));
 	}
 
 	return ctl;
@@ -693,21 +703,25 @@ data_ready:
 			       q->mmio_base + B43_PIO8_RXDATA,
 			       sizeof(u32));
 		if (len & 3) {
-			u32 value;
-			char *data;
+			u8 tail[4] = { 0, };
 
 			/* Read the last few bytes. */
-			value = b43_piorx_read32(q, B43_PIO8_RXDATA);
-			data = &(skb->data[len + padding - 1]);
+			ssb_block_read(dev->dev, tail, 4,
+				       q->mmio_base + B43_PIO8_RXDATA,
+				       sizeof(u32));
 			switch (len & 3) {
 			case 3:
-				*data = (value >> 16);
-				data--;
+				skb->data[len + padding - 3] = tail[0];
+				skb->data[len + padding - 2] = tail[1];
+				skb->data[len + padding - 1] = tail[2];
+				break;
 			case 2:
-				*data = (value >> 8);
-				data--;
+				skb->data[len + padding - 2] = tail[0];
+				skb->data[len + padding - 1] = tail[1];
+				break;
 			case 1:
-				*data = value;
+				skb->data[len + padding - 1] = tail[0];
+				break;
 			}
 		}
 	} else {
@@ -715,11 +729,13 @@ data_ready:
 			       q->mmio_base + B43_PIO_RXDATA,
 			       sizeof(u16));
 		if (len & 1) {
-			u16 value;
+			u8 tail[2] = { 0, };
 
 			/* Read the last byte. */
-			value = b43_piorx_read16(q, B43_PIO_RXDATA);
-			skb->data[len + padding - 1] = value;
+			ssb_block_read(dev->dev, tail, 2,
+				       q->mmio_base + B43_PIO_RXDATA,
+				       sizeof(u16));
+			skb->data[len + padding - 1] = tail[0];
 		}
 	}
 
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 896f532..38cfd79 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -631,6 +631,9 @@ static void mac80211_hwsim_bss_info_changed(struct ieee80211_hw *hw,
 		data->beacon_int = 1024 * info->beacon_int / 1000 * HZ / 1000;
 		if (WARN_ON(!data->beacon_int))
 			data->beacon_int = 1;
+		if (data->started)
+			mod_timer(&data->beacon_timer,
+				  jiffies + data->beacon_int);
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 1cbd9b4..b8f5ee3 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2381,6 +2381,7 @@ static struct usb_device_id rt73usb_device_table[] = {
 	/* Huawei-3Com */
 	{ USB_DEVICE(0x1472, 0x0009), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Hercules */
+	{ USB_DEVICE(0x06f8, 0xe002), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x06f8, 0xe010), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x06f8, 0xe020), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Linksys */
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 5143d20..fd40282 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -367,7 +367,10 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)tx->skb->data;
 	u32 staflags;
 
-	if (unlikely(!sta || ieee80211_is_probe_resp(hdr->frame_control)))
+	if (unlikely(!sta || ieee80211_is_probe_resp(hdr->frame_control)
+			|| ieee80211_is_auth(hdr->frame_control)
+			|| ieee80211_is_assoc_resp(hdr->frame_control)
+			|| ieee80211_is_reassoc_resp(hdr->frame_control)))
 		return TX_CONTINUE;
 
 	staflags = get_sta_flags(sta);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
