From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 05/12] net: dsa: b53: Use a macro to define I/O operations
Date: Mon, 18 Sep 2017 19:19:40 -0700
Message-ID: <20170919021947.8971-6-f.fainelli@gmail.com>
References: <20170919021947.8971-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38008 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdISC0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 22:26:09 -0400
Received: by mail-wr0-f194.google.com with SMTP id p37so1359911wrb.5
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 19:26:09 -0700 (PDT)
In-Reply-To: <20170919021947.8971-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of repeating the same pattern: acquire mutex, read/write,
release mutex, define a macro: b53_build_op() which takes the type
(read|write), I/O size, and value (scalar or pointer). This helps with
fixing bugs that could exist (e.g: missing barrier, lock etc.).

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_priv.h | 133 +++++++----------------------------------
 1 file changed, 22 insertions(+), 111 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 7528b22aeb03..f1136619e0e4 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -199,119 +199,30 @@ static inline void b53_switch_remove(struct b53_device *dev)
 	dsa_unregister_switch(dev->ds);
 }
 
-static inline int b53_read8(struct b53_device *dev, u8 page, u8 reg, u8 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read8(dev, page, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_read16(struct b53_device *dev, u8 page, u8 reg, u16 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read16(dev, page, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_read32(struct b53_device *dev, u8 page, u8 reg, u32 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read32(dev, page, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_read48(struct b53_device *dev, u8 page, u8 reg, u64 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read48(dev, page, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
+#define b53_build_op(type, op_size, val_type)	\
+static inline int b53_##type##op_size(struct b53_device *dev, u8 page,		\
+				      u8 reg, val_type val)			\
+{										\
+	int ret;								\
+										\
+	mutex_lock(&dev->reg_mutex);						\
+	ret = dev->ops->type##op_size(dev, page, reg, val);			\
+	mutex_unlock(&dev->reg_mutex);						\
+										\
+	return ret;								\
 }
 
-static inline int b53_read64(struct b53_device *dev, u8 page, u8 reg, u64 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read64(dev, page, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_write8(struct b53_device *dev, u8 page, u8 reg, u8 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write8(dev, page, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_write16(struct b53_device *dev, u8 page, u8 reg,
-			      u16 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write16(dev, page, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_write32(struct b53_device *dev, u8 page, u8 reg,
-			      u32 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write32(dev, page, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_write48(struct b53_device *dev, u8 page, u8 reg,
-			      u64 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write48(dev, page, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int b53_write64(struct b53_device *dev, u8 page, u8 reg,
-			       u64 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write64(dev, page, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
+b53_build_op(read, 8, u8 *);
+b53_build_op(read, 16, u16 *);
+b53_build_op(read, 32, u32 *);
+b53_build_op(read, 48, u64 *);
+b53_build_op(read, 64, u64 *);
+
+b53_build_op(write, 8, u8);
+b53_build_op(write, 16, u16);
+b53_build_op(write, 32, u32);
+b53_build_op(write, 48, u64);
+b53_build_op(write, 64, u64);
 
 struct b53_arl_entry {
 	u8 port;
-- 
2.9.3
