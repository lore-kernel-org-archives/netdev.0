From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next 2/3] net:dsa:mv88e6xxx: add helper functions to operate on hashtable
Date: Mon, 12 Dec 2016 14:40:31 +0100
Message-ID: <1481550031-3227-1-git-send-email-volodymyr.bendiuga@gmail.com>
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33586 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbcLLNko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:40:44 -0500
Received: by mail-wm0-f66.google.com with SMTP id u144so11349938wmu.0
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 05:40:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implementation is similar to rocker driver: drivers/net/ethernet/rocker_ofdpa.c

mv88e6xxx_pvec_tbl_find - iterates through entries in the hashtable
and looks for a match.

mv88e6xxx_pvec_tbl_get - returns en entry if it is found in the
hashtable

mv88e6xxx_pvec_tbl_update - updates the hashtable: inserts new entry,
deletes/modifies existing one.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 61 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 173ea97..6597f3f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2008,6 +2008,67 @@ static int _mv88e6xxx_atu_load(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_atu_cmd(chip, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
+static struct pvec_tbl_entry *
+mv88e6xxx_pvec_tbl_find(struct mv88e6xxx_chip *chip, struct pvec_tbl_entry *match)
+{
+        struct pvec_tbl_entry *found;
+
+        hash_for_each_possible(chip->pvec_tbl, found, entry, match->key_crc32)
+                if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
+                        return found;
+        return NULL;
+}
+
+static int mv88e6xxx_pvec_tbl_update(struct mv88e6xxx_chip *chip, u16 fid,
+			      const unsigned char *addr, u16 pvec)
+{
+        struct pvec_tbl_entry *obj;
+        struct pvec_tbl_entry *found;
+        bool remove = pvec ? false : true;
+
+        obj = kzalloc(sizeof(*obj), GFP_KERNEL);
+        if (!obj)
+                return -ENOMEM;
+
+	obj->pvec = pvec;
+        ether_addr_copy(obj->key.addr, addr);
+        obj->key.fid = fid;
+        obj->key_crc32 = crc32(~0, &obj->key, sizeof(obj->key));
+
+        found = mv88e6xxx_pvec_tbl_find(chip, obj);
+
+        if (remove && found) {
+                kfree(obj);
+                hash_del(&found->entry);
+        } else if (!remove && !found) {
+                hash_add(chip->pvec_tbl, &obj->entry, obj->key_crc32);
+        } else if (!remove && found) {
+                kfree(obj);
+                found->pvec = pvec; /* update */
+        } else {
+                kfree(obj);
+        }
+
+        return 0;
+}
+
+static u16 mv88e6xxx_pvec_tbl_get(struct mv88e6xxx_chip *chip,
+			   u16 fid, const unsigned char *addr)
+{
+        struct pvec_tbl_entry obj;
+        struct pvec_tbl_entry *found;
+
+        ether_addr_copy(obj.key.addr, addr);
+        obj.key.fid = fid;
+        obj.key_crc32 = crc32(~0, &obj.key, sizeof(obj.key));
+
+        found = mv88e6xxx_pvec_tbl_find(chip, &obj);
+        if (found)
+                return found->pvec;
+
+        return 0;
+}
+
 static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry);
 
-- 
2.7.4
