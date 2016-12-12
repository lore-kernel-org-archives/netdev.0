From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store multicast entries
Date: Mon, 12 Dec 2016 14:39:18 +0100
Message-ID: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36131 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbcLLNjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:39:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so11309446wma.3
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 05:39:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hashtable will make it extremely faster when inserting fdb entries
into the forwarding database.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 431e954..407e6db 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -15,6 +15,8 @@
 #include <linux/if_vlan.h>
 #include <linux/irq.h>
 #include <linux/gpio/consumer.h>
+#include <linux/crc32.h>
+#include <linux/hashtable.h>
 
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
@@ -672,6 +674,16 @@ struct mv88e6xxx_info {
 	const struct mv88e6xxx_ops *ops;
 };
 
+struct pvec_tbl_entry {
+        struct hlist_node entry;
+        u32 key_crc32; /* key */
+        u16 pvec;
+        struct pvec_tbl_key {
+                u8 addr[ETH_ALEN];
+                u16 fid;
+        } key;
+};
+
 struct mv88e6xxx_atu_entry {
 	u16	fid;
 	u8	state;
@@ -736,6 +748,9 @@ struct mv88e6xxx_chip {
 
 	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
 
+	/* This table hold a port vector for each multicast address */
+	DECLARE_HASHTABLE(pvec_tbl, 12);
+
 	/* A switch may have a GPIO line tied to its reset pin. Parse
 	 * this from the device tree, and use it before performing
 	 * switch soft reset.
-- 
2.7.4
