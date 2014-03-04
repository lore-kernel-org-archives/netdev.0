From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH bluetooth-next] bluetooth: make bluetooth 6lowpan as an option
Date: Tue,  4 Mar 2014 10:23:02 +0100
Message-ID: <1393924982-14001-1-git-send-email-alex.aring@gmail.com>
Cc: gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently you can have bluetooth 6lowpan without ipv6 enabled. This
doesn't make any sense. With this patch you can disable/enable bluetooth
6lowpan support at compile time.

The current bluetooth 6lowpan implementation doesn't check the return
value of 6lowpan function. Nevertheless I added -EOPNOTSUPP as return value
if 6lowpan bluetooth is disabled.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/bluetooth/6lowpan.h | 21 +++++++++++++++++++++
 net/bluetooth/Kconfig   |  8 +++++++-
 net/bluetooth/Makefile  |  3 ++-
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/6lowpan.h b/net/bluetooth/6lowpan.h
index 680eac8..5d281f1 100644
--- a/net/bluetooth/6lowpan.h
+++ b/net/bluetooth/6lowpan.h
@@ -14,13 +14,34 @@
 #ifndef __6LOWPAN_H
 #define __6LOWPAN_H
 
+#include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <net/bluetooth/l2cap.h>
 
+#if IS_ENABLED(CONFIG_BT_6LOWPAN)
 int bt_6lowpan_recv(struct l2cap_conn *conn, struct sk_buff *skb);
 int bt_6lowpan_add_conn(struct l2cap_conn *conn);
 int bt_6lowpan_del_conn(struct l2cap_conn *conn);
 int bt_6lowpan_init(void);
 void bt_6lowpan_cleanup(void);
+#else
+static int bt_6lowpan_recv(struct l2cap_conn *conn, struct sk_buff *skb)
+{
+	return -EOPNOTSUPP;
+}
+static int bt_6lowpan_add_conn(struct l2cap_conn *conn)
+{
+	return -EOPNOTSUPP;
+}
+int bt_6lowpan_del_conn(struct l2cap_conn *conn)
+{
+	return -EOPNOTSUPP;
+}
+static int bt_6lowpan_init(void)
+{
+	return -EOPNOTSUPP;
+}
+static void bt_6lowpan_cleanup(void) { }
+#endif
 
 #endif /* __6LOWPAN_H */
diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index 985b560..10c752f 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -12,7 +12,6 @@ menuconfig BT
 	select CRYPTO_AES
 	select CRYPTO_ECB
 	select CRYPTO_SHA256
-	select 6LOWPAN_IPHC
 	help
 	  Bluetooth is low-cost, low-power, short-range wireless technology.
 	  It was designed as a replacement for cables and other short-range
@@ -40,6 +39,13 @@ menuconfig BT
 	  to Bluetooth kernel modules are provided in the BlueZ packages.  For
 	  more information, see <http://www.bluez.org/>.
 
+config BT_6LOWPAN
+	bool "Bluetooth 6LoWPAN support"
+	depends on BT && IPV6
+	select 6LOWPAN_IPHC
+	help
+	  IPv6 compression over Bluetooth.
+
 source "net/bluetooth/rfcomm/Kconfig"
 
 source "net/bluetooth/bnep/Kconfig"
diff --git a/net/bluetooth/Makefile b/net/bluetooth/Makefile
index 80cb215..ca51246 100644
--- a/net/bluetooth/Makefile
+++ b/net/bluetooth/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_BT_HIDP)	+= hidp/
 
 bluetooth-y := af_bluetooth.o hci_core.o hci_conn.o hci_event.o mgmt.o \
 	hci_sock.o hci_sysfs.o l2cap_core.o l2cap_sock.o smp.o sco.o lib.o \
-	a2mp.o amp.o 6lowpan.o
+	a2mp.o amp.o
+bluetooth-$(CONFIG_BT_6LOWPAN) += 6lowpan.o
 
 subdir-ccflags-y += -D__CHECK_ENDIAN__
-- 
1.9.0
