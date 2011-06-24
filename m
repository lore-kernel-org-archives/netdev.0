From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-06-24
Date: Fri, 24 Jun 2011 14:49:49 -0400
Message-ID: <20110624184949.GC4793@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53384 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170Ab1FXTBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 15:01:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another batch of fixes intended for 3.0.  Included are too
rtlwifi fixes from Larry:  a regression that broke firmware loading for
rtl8292cu; and a fix to arbitrate between two devices that share the
same PCI ID but are handled by different drivers...yeah.

The rest are Bluetooth fixes -- quoth Gustavo:

	Three regressions fix intended for 3.0. Two of them fix a
	change made in our HCI security process for 3.0. The third
	one fixes an issue with non-SSP devices.  All of them are
	critical fixes. They should be in 3.0. Please pull!  Thanks.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5c18e80be9ff362f6523b097d495bb2e2f939946:

  net/usb/kalmia: signedness bug in kalmia_bind() (2011-06-23 03:15:39 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git for-davem

Ilia Kolomisnky (1):
      Bluetooth: Fix L2CAP connection establishment

Johan Hedberg (1):
      Bluetooth: Fix accepting connect requests for defer_setup

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Larry Finger (2):
      rtlwifi: rtl8192se: Handle duplicate PCI ID 0x10ec:0x8192 conflict with r8192e_pci
      rtl8192cu: Fix missing firmware load

Luiz Augusto von Dentz (1):
      Bluetooth: Fix L2CAP security check

 drivers/net/wireless/rtlwifi/pci.c          |   13 ++++++++++++-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c |   20 ++++++++++++++++++++
 net/bluetooth/hci_conn.c                    |    6 +++---
 net/bluetooth/l2cap_core.c                  |   21 +++++++++++++++------
 4 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 9f8ccae..254b64b 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1624,6 +1624,16 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	pci_read_config_byte(pdev, 0x8, &revisionid);
 	pci_read_config_word(pdev, 0x3C, &irqline);
 
+	/* PCI ID 0x10ec:0x8192 occurs for both RTL8192E, which uses
+	 * r8192e_pci, and RTL8192SE, which uses this driver. If the
+	 * revision ID is RTL_PCI_REVISION_ID_8192PCIE (0x01), then
+	 * the correct driver is r8192e_pci, thus this routine should
+	 * return false.
+	 */
+	if (deviceid == RTL_PCI_8192SE_DID &&
+	    revisionid == RTL_PCI_REVISION_ID_8192PCIE)
+		return false;
+
 	if (deviceid == RTL_PCI_8192_DID ||
 	    deviceid == RTL_PCI_0044_DID ||
 	    deviceid == RTL_PCI_0047_DID ||
@@ -1856,7 +1866,8 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	pci_write_config_byte(pdev, 0x04, 0x07);
 
 	/* find adapter */
-	_rtl_pci_find_adapter(pdev, hw);
+	if (!_rtl_pci_find_adapter(pdev, hw))
+		goto fail3;
 
 	/* Init IO handler */
 	_rtl_pci_io_handler_init(&pdev->dev, hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index bee7c14..092e342 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -53,6 +53,8 @@ MODULE_FIRMWARE("rtlwifi/rtl8192cufw.bin");
 static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	const struct firmware *firmware;
+	int err;
 
 	rtlpriv->dm.dm_initialgain_enable = 1;
 	rtlpriv->dm.dm_flag = 0;
@@ -64,6 +66,24 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 			 ("Can't alloc buffer for fw.\n"));
 		return 1;
 	}
+	/* request fw */
+	err = request_firmware(&firmware, rtlpriv->cfg->fw_name,
+			rtlpriv->io.dev);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 ("Failed to request firmware!\n"));
+		return 1;
+	}
+	if (firmware->size > 0x4000) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 ("Firmware is too big!\n"));
+		release_firmware(firmware);
+		return 1;
+	}
+	memcpy(rtlpriv->rtlhal.pfirmware, firmware->data, firmware->size);
+	rtlpriv->rtlhal.fwsize = firmware->size;
+	release_firmware(firmware);
+
 	return 0;
 }
 
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 3163330..d3a05b9 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -608,11 +608,11 @@ int hci_conn_security(struct hci_conn *conn, __u8 sec_level, __u8 auth_type)
 		goto encrypt;
 
 auth:
-	if (test_and_set_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend))
+	if (test_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend))
 		return 0;
 
-	hci_conn_auth(conn, sec_level, auth_type);
-	return 0;
+	if (!hci_conn_auth(conn, sec_level, auth_type))
+		return 0;
 
 encrypt:
 	if (conn->link_mode & HCI_LM_ENCRYPT)
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index e64a1c2..56fdd91 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -4002,21 +4002,30 @@ static int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt)
 			}
 		} else if (sk->sk_state == BT_CONNECT2) {
 			struct l2cap_conn_rsp rsp;
-			__u16 result;
+			__u16 res, stat;
 
 			if (!status) {
-				sk->sk_state = BT_CONFIG;
-				result = L2CAP_CR_SUCCESS;
+				if (bt_sk(sk)->defer_setup) {
+					struct sock *parent = bt_sk(sk)->parent;
+					res = L2CAP_CR_PEND;
+					stat = L2CAP_CS_AUTHOR_PEND;
+					parent->sk_data_ready(parent, 0);
+				} else {
+					sk->sk_state = BT_CONFIG;
+					res = L2CAP_CR_SUCCESS;
+					stat = L2CAP_CS_NO_INFO;
+				}
 			} else {
 				sk->sk_state = BT_DISCONN;
 				l2cap_sock_set_timer(sk, HZ / 10);
-				result = L2CAP_CR_SEC_BLOCK;
+				res = L2CAP_CR_SEC_BLOCK;
+				stat = L2CAP_CS_NO_INFO;
 			}
 
 			rsp.scid   = cpu_to_le16(chan->dcid);
 			rsp.dcid   = cpu_to_le16(chan->scid);
-			rsp.result = cpu_to_le16(result);
-			rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
+			rsp.result = cpu_to_le16(res);
+			rsp.status = cpu_to_le16(stat);
 			l2cap_send_cmd(conn, chan->ident, L2CAP_CONN_RSP,
 							sizeof(rsp), &rsp);
 		}
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
