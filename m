From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-06-17
Date: Fri, 17 Jun 2011 13:36:14 -0400
Message-ID: <20110617173613.GC6820@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a batch of fixes intended for 3.0.  Included are a regression
for mwl8k which caused CCMP encryption to fail on that device, and an
mwifiex fix for a null pointer dereference.  Also included is a batch
of Bluetooth fixes from Gustavo, including a regression fix for BT 1.1
devices, a fix for shutdown of SCO devices, a fix for an information
leak, and a silly error-checking fix that I thought was worth including
to prevent misinterpreting bad data as device command options.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 118133e6580a0c912cda86109b6468b5ffe73f1c:

  netdev: bfin_mac: fix memory leak when freeing dma descriptors (2011-06-17 00:19:09 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git for-davem

David Miller (1):
      Bluetooth: Do not ignore errors returned from strict_strtol()

Filip Palian (1):
      Bluetooth: l2cap and rfcomm: fix 1 byte infoleak to userspace.

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Luiz Augusto von Dentz (1):
      Bluetooth: fix shutdown on SCO sockets

Nishant Sarmukadam (1):
      mwl8k: Tell firmware to generate CCMP header

Ville Tervo (1):
      Bluetooth: Do not send SET_EVENT_MASK for 1.1 and earlier devices

Yogesh Ashok Powar (1):
      mwifiex: Fixing NULL pointer dereference

 drivers/bluetooth/btmrvl_debugfs.c      |   12 ++++++++++++
 drivers/net/wireless/mwifiex/cfg80211.c |    2 ++
 drivers/net/wireless/mwl8k.c            |    4 +++-
 net/bluetooth/hci_event.c               |   18 ++++++++++--------
 net/bluetooth/l2cap_sock.c              |    1 +
 net/bluetooth/rfcomm/sock.c             |    1 +
 net/bluetooth/sco.c                     |   13 ++++++++++++-
 7 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
index fd6305b..8ecf4c6 100644
--- a/drivers/bluetooth/btmrvl_debugfs.c
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -64,6 +64,8 @@ static ssize_t btmrvl_hscfgcmd_write(struct file *file,
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
+	if (ret)
+		return ret;
 
 	priv->btmrvl_dev.hscfgcmd = result;
 
@@ -108,6 +110,8 @@ static ssize_t btmrvl_psmode_write(struct file *file, const char __user *ubuf,
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
+	if (ret)
+		return ret;
 
 	priv->btmrvl_dev.psmode = result;
 
@@ -147,6 +151,8 @@ static ssize_t btmrvl_pscmd_write(struct file *file, const char __user *ubuf,
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
+	if (ret)
+		return ret;
 
 	priv->btmrvl_dev.pscmd = result;
 
@@ -191,6 +197,8 @@ static ssize_t btmrvl_gpiogap_write(struct file *file, const char __user *ubuf,
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 16, &result);
+	if (ret)
+		return ret;
 
 	priv->btmrvl_dev.gpio_gap = result;
 
@@ -230,6 +238,8 @@ static ssize_t btmrvl_hscmd_write(struct file *file, const char __user *ubuf,
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
+	if (ret)
+		return ret;
 
 	priv->btmrvl_dev.hscmd = result;
 	if (priv->btmrvl_dev.hscmd) {
@@ -272,6 +282,8 @@ static ssize_t btmrvl_hsmode_write(struct file *file, const char __user *ubuf,
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
+	if (ret)
+		return ret;
 
 	priv->btmrvl_dev.hsmode = result;
 
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 660831c..687c1f2 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1288,6 +1288,8 @@ int mwifiex_register_cfg80211(struct net_device *dev, u8 *mac,
 
 	*(unsigned long *) wdev_priv = (unsigned long) priv;
 
+	set_wiphy_dev(wdev->wiphy, (struct device *) priv->adapter->dev);
+
 	ret = wiphy_register(wdev->wiphy);
 	if (ret < 0) {
 		dev_err(priv->adapter->dev, "%s: registering cfg80211 device\n",
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 3226118..aeac3cc 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -2474,6 +2474,7 @@ struct mwl8k_cmd_set_hw_spec {
  * faster client.
  */
 #define MWL8K_SET_HW_SPEC_FLAG_ENABLE_LIFE_TIME_EXPIRY	0x00000400
+#define MWL8K_SET_HW_SPEC_FLAG_GENERATE_CCMP_HDR	0x00000200
 #define MWL8K_SET_HW_SPEC_FLAG_HOST_DECR_MGMT		0x00000080
 #define MWL8K_SET_HW_SPEC_FLAG_HOSTFORM_PROBERESP	0x00000020
 #define MWL8K_SET_HW_SPEC_FLAG_HOSTFORM_BEACON		0x00000010
@@ -2510,7 +2511,8 @@ static int mwl8k_cmd_set_hw_spec(struct ieee80211_hw *hw)
 	cmd->flags = cpu_to_le32(MWL8K_SET_HW_SPEC_FLAG_HOST_DECR_MGMT |
 				 MWL8K_SET_HW_SPEC_FLAG_HOSTFORM_PROBERESP |
 				 MWL8K_SET_HW_SPEC_FLAG_HOSTFORM_BEACON |
-				 MWL8K_SET_HW_SPEC_FLAG_ENABLE_LIFE_TIME_EXPIRY);
+				 MWL8K_SET_HW_SPEC_FLAG_ENABLE_LIFE_TIME_EXPIRY |
+				 MWL8K_SET_HW_SPEC_FLAG_GENERATE_CCMP_HDR);
 	cmd->num_tx_desc_per_queue = cpu_to_le32(MWL8K_TX_DESCS);
 	cmd->total_rxd = cpu_to_le32(MWL8K_RX_DESCS);
 
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index f13ddbf..77930aa 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -477,14 +477,16 @@ static void hci_setup_event_mask(struct hci_dev *hdev)
 	 * command otherwise */
 	u8 events[8] = { 0xff, 0xff, 0xfb, 0xff, 0x00, 0x00, 0x00, 0x00 };
 
-	/* Events for 1.2 and newer controllers */
-	if (hdev->lmp_ver > 1) {
-		events[4] |= 0x01; /* Flow Specification Complete */
-		events[4] |= 0x02; /* Inquiry Result with RSSI */
-		events[4] |= 0x04; /* Read Remote Extended Features Complete */
-		events[5] |= 0x08; /* Synchronous Connection Complete */
-		events[5] |= 0x10; /* Synchronous Connection Changed */
-	}
+	/* CSR 1.1 dongles does not accept any bitfield so don't try to set
+	 * any event mask for pre 1.2 devices */
+	if (hdev->lmp_ver <= 1)
+		return;
+
+	events[4] |= 0x01; /* Flow Specification Complete */
+	events[4] |= 0x02; /* Inquiry Result with RSSI */
+	events[4] |= 0x04; /* Read Remote Extended Features Complete */
+	events[5] |= 0x08; /* Synchronous Connection Complete */
+	events[5] |= 0x10; /* Synchronous Connection Changed */
 
 	if (hdev->features[3] & LMP_RSSI_INQ)
 		events[4] |= 0x04; /* Inquiry Result with RSSI */
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 18dc988..8248303 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -413,6 +413,7 @@ static int l2cap_sock_getsockopt_old(struct socket *sock, int optname, char __us
 			break;
 		}
 
+		memset(&cinfo, 0, sizeof(cinfo));
 		cinfo.hci_handle = chan->conn->hcon->handle;
 		memcpy(cinfo.dev_class, chan->conn->hcon->dev_class, 3);
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 386cfaf..1b10727 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -788,6 +788,7 @@ static int rfcomm_sock_getsockopt_old(struct socket *sock, int optname, char __u
 
 		l2cap_sk = rfcomm_pi(sk)->dlc->session->sock->sk;
 
+		memset(&cinfo, 0, sizeof(cinfo));
 		cinfo.hci_handle = conn->hcon->handle;
 		memcpy(cinfo.dev_class, conn->hcon->dev_class, 3);
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 42fdffd..cb4fb78 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -369,6 +369,15 @@ static void __sco_sock_close(struct sock *sk)
 
 	case BT_CONNECTED:
 	case BT_CONFIG:
+		if (sco_pi(sk)->conn) {
+			sk->sk_state = BT_DISCONN;
+			sco_sock_set_timer(sk, SCO_DISCONN_TIMEOUT);
+			hci_conn_put(sco_pi(sk)->conn->hcon);
+			sco_pi(sk)->conn->hcon = NULL;
+		} else
+			sco_chan_del(sk, ECONNRESET);
+		break;
+
 	case BT_CONNECT:
 	case BT_DISCONN:
 		sco_chan_del(sk, ECONNRESET);
@@ -819,7 +828,9 @@ static void sco_chan_del(struct sock *sk, int err)
 		conn->sk = NULL;
 		sco_pi(sk)->conn = NULL;
 		sco_conn_unlock(conn);
-		hci_conn_put(conn->hcon);
+
+		if (conn->hcon)
+			hci_conn_put(conn->hcon);
 	}
 
 	sk->sk_state = BT_CLOSED;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
