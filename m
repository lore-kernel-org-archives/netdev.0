From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] Bluetooth: avoid rebuilding hci_sock all the time
Date: Wed,  6 Jan 2016 11:59:57 +0100
Message-ID: <1452077997-13596-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42492 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844AbcAFLAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 06:00:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Instead, allow using string formatting with send_monitor_note()
and access init_utsname().

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/bluetooth/hci_sock.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 41f579ba447b..c7026e8f0af1 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -25,9 +25,8 @@
 /* Bluetooth HCI sockets. */
 
 #include <linux/export.h>
+#include <linux/utsname.h>
 #include <asm/unaligned.h>
-#include <generated/compile.h>
-#include <generated/utsrelease.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
@@ -385,18 +384,26 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 	return skb;
 }
 
-static void send_monitor_note(struct sock *sk, const char *text)
+static void __printf(2, 3)
+send_monitor_note(struct sock *sk, const char *fmt, ...)
 {
-	size_t len = strlen(text);
+	size_t len;
 	struct hci_mon_hdr *hdr;
 	struct sk_buff *skb;
+	va_list args;
 
+	va_start(args, fmt);
+	len = vsnprintf(NULL, 0, fmt, args);
 	skb = bt_skb_alloc(len + 1, GFP_ATOMIC);
+	if (skb) {
+		*skb_put(skb, 1) = 0;
+		vsprintf(skb_put(skb, len), fmt, args);
+	}
+	va_end(args);
+
 	if (!skb)
 		return;
 
-	strcpy(skb_put(skb, len + 1), text);
-
 	__net_timestamp(skb);
 
 	hdr = (void *)skb_push(skb, HCI_MON_HDR_SIZE);
@@ -897,10 +904,11 @@ static int hci_sock_bind(struct socket *sock, struct sockaddr *addr,
 		 */
 		hci_sock_set_flag(sk, HCI_SOCK_TRUSTED);
 
-		send_monitor_note(sk, "Linux version " UTS_RELEASE
-				      " (" UTS_MACHINE ")");
-		send_monitor_note(sk, "Bluetooth subsystem version "
-				      BT_SUBSYS_VERSION);
+		send_monitor_note(sk, "Linux version %s (%s)",
+				  init_utsname()->release,
+				  init_utsname()->machine);
+		send_monitor_note(sk, "Bluetooth subsystem version %s",
+				  BT_SUBSYS_VERSION);
 		send_monitor_replay(sk);
 
 		atomic_inc(&monitor_promisc);
-- 
2.6.2
