From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: dsa: b53: Utilize common helpers for u64/MAC
Date: Thu,  5 Jan 2017 11:08:58 -0800
Message-ID: <20170105190858.12623-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, volodymyr.bendiuga@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35129 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030743AbdAETJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 14:09:05 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so28764214pfk.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 11:09:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the two functions recently introduced: u64_to_ether() and
ether_to_u64() instead of our own versions.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- include etherdevice.h in b53_priv.h to fix Kbuild reported
  errors

 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/b53/b53_priv.h   | 24 +++---------------------
 2 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 947adda3397d..d5370c227043 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1137,7 +1137,7 @@ static int b53_arl_op(struct b53_device *dev, int op, int port,
 	int ret;
 
 	/* Convert the array into a 64-bit MAC */
-	mac = b53_mac_to_u64(addr);
+	mac = ether_addr_to_u64(addr);
 
 	/* Perform a read for the given MAC and VID */
 	b53_write48(dev, B53_ARLIO_PAGE, B53_MAC_ADDR_IDX, mac);
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index f192a673caba..1f4b07b77de2 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -22,6 +22,7 @@
 #include <linux/kernel.h>
 #include <linux/mutex.h>
 #include <linux/phy.h>
+#include <linux/etherdevice.h>
 #include <net/dsa.h>
 
 #include "b53_regs.h"
@@ -325,25 +326,6 @@ struct b53_arl_entry {
 	u8 is_static:1;
 };
 
-static inline void b53_mac_from_u64(u64 src, u8 *dst)
-{
-	unsigned int i;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		dst[ETH_ALEN - 1 - i] = (src >> (8 * i)) & 0xff;
-}
-
-static inline u64 b53_mac_to_u64(const u8 *src)
-{
-	unsigned int i;
-	u64 dst = 0;
-
-	for (i = 0; i < ETH_ALEN; i++)
-		dst |= (u64)src[ETH_ALEN - 1 - i] << (8 * i);
-
-	return dst;
-}
-
 static inline void b53_arl_to_entry(struct b53_arl_entry *ent,
 				    u64 mac_vid, u32 fwd_entry)
 {
@@ -352,14 +334,14 @@ static inline void b53_arl_to_entry(struct b53_arl_entry *ent,
 	ent->is_valid = !!(fwd_entry & ARLTBL_VALID);
 	ent->is_age = !!(fwd_entry & ARLTBL_AGE);
 	ent->is_static = !!(fwd_entry & ARLTBL_STATIC);
-	b53_mac_from_u64(mac_vid, ent->mac);
+	u64_to_ether_addr(mac_vid, ent->mac);
 	ent->vid = mac_vid >> ARLTBL_VID_S;
 }
 
 static inline void b53_arl_from_entry(u64 *mac_vid, u32 *fwd_entry,
 				      const struct b53_arl_entry *ent)
 {
-	*mac_vid = b53_mac_to_u64(ent->mac);
+	*mac_vid = ether_addr_to_u64(ent->mac);
 	*mac_vid |= (u64)(ent->vid & ARLTBL_VID_MASK) << ARLTBL_VID_S;
 	*fwd_entry = ent->port & ARLTBL_DATA_PORT_ID_MASK;
 	if (ent->is_valid)
-- 
2.9.3
