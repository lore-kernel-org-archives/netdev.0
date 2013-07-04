From: Kyle Manna <kyle@kylemanna.com>
Subject: [PATCH 2/2] bluetooth: Add l2cap sockopt for LE conn params
Date: Thu,  4 Jul 2013 16:25:03 -0700
Message-ID: <1372980303-3007-3-git-send-email-kyle@kylemanna.com>
References: <1372980303-3007-1-git-send-email-kyle@kylemanna.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Kyle Manna <kyle@kylemanna.com>
To: linux-bluetooth@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:39422 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933159Ab3GDX0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 19:26:48 -0400
In-Reply-To: <1372980303-3007-1-git-send-email-kyle@kylemanna.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Userspace can now specify connection parameters to override the
  defaults prior to connecting to the device.
* The intention is that setsockopt() will be called before connect() is
  called in userspace apps and BlueZ libraries.
* It is critical to set these parameters prior to connect() to avoid
  issues with hardware that must arbitrate the antenna access between
  Bluetooth LE and things like WiFi.  Aggressive connect (and scan)
  window and interval values result in significant WiFi degradation.
* Reduces the need to call the hci LE Connection Update Command to
  override the "defaults" when the desired values are known ahead of
  time.
* Add BT_LE_CONN_PARAM socket option.

Signed-off-by: Kyle Manna <kyle@kylemanna.com>
---
 include/net/bluetooth/bluetooth.h |  2 ++
 net/bluetooth/l2cap_sock.c        | 23 +++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 10eb9b3..36e9242 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -82,6 +82,8 @@ struct bt_power {
 
 #define BT_CHANNEL_POLICY	10
 
+#define BT_LE_CONN_PARAM	11
+
 /* BR/EDR only (default policy)
  *   AMP controllers cannot be used.
  *   Channel move requests from the remote device are denied.
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 2c7917e..17b6e2b 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -454,6 +454,15 @@ static int l2cap_sock_getsockopt(struct socket *sock, int level, int optname,
 			err = -EFAULT;
 		break;
 
+	case BT_LE_CONN_PARAM:
+
+		len = min_t(unsigned int, len,
+			    sizeof(struct hci_cp_le_create_conn));
+		if (copy_to_user(optval, (char *) &chan->cp_le, len))
+			err = -EFAULT;
+
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -749,6 +758,20 @@ static int l2cap_sock_setsockopt(struct socket *sock, int level, int optname,
 
 		break;
 
+	case BT_LE_CONN_PARAM:
+
+		if (sizeof(struct hci_cp_le_create_conn) != optlen) {
+			err = -EINVAL;
+			break;
+		}
+
+		if (copy_from_user((char *) &chan->cp_le, optval, optlen)) {
+			err = -EFAULT;
+			break;
+		}
+
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
-- 
1.8.1.2
