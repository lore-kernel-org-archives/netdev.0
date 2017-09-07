From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 4/6] The common header ksz_priv.h does not contain chip
 specific data
Date: Thu, 7 Sep 2017 21:09:17 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A14@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218E7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411218E7@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

The header ksz_priv.h is used by all KSZ switch drivers so chip specific data are removed and commonly used variables are added.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microchip/ksz_priv.h
index 2a98dbd..343b509 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -25,14 +25,56 @@
 #include <linux/etherdevice.h>
 #include <net/dsa.h>
 
-#include "ksz_9477_reg.h"
-
 struct ksz_io_ops;
 
 struct vlan_table {
 	u32 table[3];
 };
 
+enum {
+	PHY_NO_FLOW_CTRL,
+	PHY_FLOW_CTRL,
+	PHY_TX_ONLY,
+	PHY_RX_ONLY
+};
+
+struct ksz_port_mib {
+	u8 cnt_ptr;
+	u8 ctrl;
+	unsigned long time;
+
+	struct ksz_port_mib_info {
+		u64 counter;
+		u8 read_cnt;
+		u8 read_max;
+	} *info;
+};
+
+struct ksz_port {
+	u16 member;
+	u16 vid_member;
+	int stp_state;
+	u16 speed;
+	u8 duplex;
+	u8 advertised;
+	u8 flow_ctrl;
+	u8 link;
+	u8 partner;
+
+	u32 on:1;			/* port is not disabled by hardware */
+	u32 fiber:1;			/* port is fiber */
+	u32 sgmii:1;			/* port is SGMII */
+	u32 force:1;
+	u32 link_down:1;		/* link just goes down */
+	u32 link_up:1;			/* link is up */
+
+	struct ksz_port_mib mib;
+};
+
+#define USE_FEWER_PORTS			BIT(18)
+
+#define PTP_TAG				BIT(29)
+
 struct ksz_device {
 	struct dsa_switch *ds;
 	struct ksz_platform_data *pdata;
@@ -43,6 +85,7 @@ struct ksz_device {
 	struct mutex alu_mutex;		/* ALU access */
 	struct mutex vlan_mutex;	/* vlan access */
 	const struct ksz_io_ops *ops;
+	const struct ksz_dev_ops *dev_ops;
 
 	struct device *dev;
 
@@ -56,10 +99,32 @@ struct ksz_device {
 	int cpu_port;			/* port connected to CPU */
 	int cpu_ports;			/* port bitmap can be cpu port */
 	int port_cnt;
+	int mib_cnt;
+	int mib_port_cnt;
+	int last_port;			/* ports after that not used */
+	int interface;
 
 	struct vlan_table *vlan_cache;
 
-	u64 mib_value[TOTAL_SWITCH_COUNTER_NUM];
+	u8 *txbuf;
+
+	struct ksz_port *ports;
+	struct timer_list mib_read_timer;
+	struct work_struct mib_read;
+	spinlock_t mib_read_lock;	/* use to update read_cnt */
+	unsigned long MIB_READ_INTERVAL;
+	u32 features;
+	u32 overrides;
+	u16 br_member;
+	u16 member;
+	u16 live_ports;
+	u16 on_ports;			/* ports enabled by DSA */
+	u16 rx_ports;
+	u16 tx_ports;
+	u16 mirror_rx;
+	u16 mirror_tx;
+	u16 HOST_MASK;
+	u16 PORT_MASK;
 };
 
 struct ksz_io_ops {
@@ -75,12 +140,30 @@ struct ksz_io_ops {
 			  u16 *value);
 	int (*phy_write16)(struct ksz_device *dev, int addr, int reg,
 			   u16 value);
+	unsigned int (*get)(struct ksz_device *dev, u32 reg, void *data,
+			    unsigned int len);
+	unsigned int (*set)(struct ksz_device *dev, u32 reg, void *data,
+			    unsigned int len);
+};
+
+struct ksz_dev_ops {
+	u32 (*get_port_addr)(int port, int offset);
+	int (*reset)(struct ksz_device *dev);
+	int (*get_rx_len)(struct ksz_device *dev);
+	int (*get_tx_len)(struct ksz_device *dev);
+	void (*add_tail_tag)(struct ksz_device *dev, struct sk_buff *skb,
+			     int port);
+	int (*get_tail_tag)(struct ksz_device *dev, struct sk_buff *skb,
+			    int *port);
+	int (*detect)(struct ksz_device *dev);
+	int (*init)(struct ksz_device *dev);
+	void (*exit)(struct ksz_device *dev);
 };
 
 struct ksz_device *ksz_switch_alloc(struct device *base,
 				    const struct ksz_io_ops *ops, void *priv); -int ksz_switch_detect(struct ksz_device *dev); -int ksz_switch_register(struct ksz_device *dev);
+int ksz_switch_register(struct ksz_device *dev,
+			const struct ksz_dev_ops *ops);
 void ksz_switch_remove(struct ksz_device *dev);
 
 static inline int ksz_read8(struct ksz_device *dev, u32 reg, u8 *val) @@ -174,37 +257,37 @@ static inline int ksz_write32(struct ksz_device *dev, u32 reg, u32 value)  static inline void ksz_pread8(struct ksz_device *dev, int port, int offset,
 			      u8 *data)
 {
-	ksz_read8(dev, PORT_CTRL_ADDR(port, offset), data);
+	ksz_read8(dev, dev->dev_ops->get_port_addr(port, offset), data);
 }
 
 static inline void ksz_pread16(struct ksz_device *dev, int port, int offset,
 			       u16 *data)
 {
-	ksz_read16(dev, PORT_CTRL_ADDR(port, offset), data);
+	ksz_read16(dev, dev->dev_ops->get_port_addr(port, offset), data);
 }
 
 static inline void ksz_pread32(struct ksz_device *dev, int port, int offset,
 			       u32 *data)
 {
-	ksz_read32(dev, PORT_CTRL_ADDR(port, offset), data);
+	ksz_read32(dev, dev->dev_ops->get_port_addr(port, offset), data);
 }
 
 static inline void ksz_pwrite8(struct ksz_device *dev, int port, int offset,
 			       u8 data)
 {
-	ksz_write8(dev, PORT_CTRL_ADDR(port, offset), data);
+	ksz_write8(dev, dev->dev_ops->get_port_addr(port, offset), data);
 }
 
 static inline void ksz_pwrite16(struct ksz_device *dev, int port, int offset,
 				u16 data)
 {
-	ksz_write16(dev, PORT_CTRL_ADDR(port, offset), data);
+	ksz_write16(dev, dev->dev_ops->get_port_addr(port, offset), data);
 }
 
 static inline void ksz_pwrite32(struct ksz_device *dev, int port, int offset,
 				u32 data)
 {
-	ksz_write32(dev, PORT_CTRL_ADDR(port, offset), data);
+	ksz_write32(dev, dev->dev_ops->get_port_addr(port, offset), data);
 }
 
 #endif
