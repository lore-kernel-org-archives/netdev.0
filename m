From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 32/37] drivers/net/wireless/p54: Use kmemdup
Date: Sat, 15 May 2010 23:22:55 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152322390.21345@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitor
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/p54/eeprom.c |    4 ++--
 drivers/net/wireless/p54/p54usb.c |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff -u -p a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -433,10 +433,9 @@ static int p54u_firmware_reset_3887(stru
 	u8 *buf;
 	int ret;
 
-	buf = kmalloc(4, GFP_KERNEL);
+	buf = kmemdup(p54u_romboot_3887, 4, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
-	memcpy(buf, p54u_romboot_3887, 4);
 	ret = p54u_bulk_msg(priv, P54U_PIPE_DATA,
 			    buf, 4);
 	kfree(buf);
diff -u -p a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -599,13 +599,13 @@ int p54_parse_eeprom(struct ieee80211_hw
 			}
 			break;
 		case PDR_PRISM_ZIF_TX_IQ_CALIBRATION:
-			priv->iq_autocal = kmalloc(data_len, GFP_KERNEL);
+			priv->iq_autocal = kmemdup(entry->data, data_len,
+						   GFP_KERNEL);
 			if (!priv->iq_autocal) {
 				err = -ENOMEM;
 				goto err;
 			}
 
-			memcpy(priv->iq_autocal, entry->data, data_len);
 			priv->iq_autocal_len = data_len / sizeof(struct pda_iq_autocal_entry);
 			break;
 		case PDR_DEFAULT_COUNTRY:
