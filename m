From: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH 2/7] net: dsa: ar8xxx: add ethtool hw statistics support
Date: Thu, 28 May 2015 18:42:17 -0700
Message-ID: <1432863742-18427-3-git-send-email-mathieu@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

MIB counters can now be reported through each switch port by using
"ethtool -S".

Signed-off-by: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/dsa/ar8xxx.c | 106 +++++++++++++++++++++++++++++++++++++++++++----
 drivers/net/dsa/ar8xxx.h |  47 +++++++++++++++++++++
 2 files changed, 146 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/ar8xxx.c b/drivers/net/dsa/ar8xxx.c
index 4ce3ffc..2f0fa4d 100644
--- a/drivers/net/dsa/ar8xxx.c
+++ b/drivers/net/dsa/ar8xxx.c
@@ -22,6 +22,55 @@
 
 #include "ar8xxx.h"
 
+#define MIB_DESC(_s, _o, _n)	\
+	{			\
+		.size = (_s),	\
+		.offset = (_o),	\
+		.name = (_n),	\
+	}
+
+static const struct ar8xxx_mib_desc ar8327_mib[] = {
+	MIB_DESC(1, 0x00, "RxBroad"),
+	MIB_DESC(1, 0x04, "RxPause"),
+	MIB_DESC(1, 0x08, "RxMulti"),
+	MIB_DESC(1, 0x0c, "RxFcsErr"),
+	MIB_DESC(1, 0x10, "RxAlignErr"),
+	MIB_DESC(1, 0x14, "RxRunt"),
+	MIB_DESC(1, 0x18, "RxFragment"),
+	MIB_DESC(1, 0x1c, "Rx64Byte"),
+	MIB_DESC(1, 0x20, "Rx128Byte"),
+	MIB_DESC(1, 0x24, "Rx256Byte"),
+	MIB_DESC(1, 0x28, "Rx512Byte"),
+	MIB_DESC(1, 0x2c, "Rx1024Byte"),
+	MIB_DESC(1, 0x30, "Rx1518Byte"),
+	MIB_DESC(1, 0x34, "RxMaxByte"),
+	MIB_DESC(1, 0x38, "RxTooLong"),
+	MIB_DESC(2, 0x3c, "RxGoodByte"),
+	MIB_DESC(2, 0x44, "RxBadByte"),
+	MIB_DESC(1, 0x4c, "RxOverFlow"),
+	MIB_DESC(1, 0x50, "Filtered"),
+	MIB_DESC(1, 0x54, "TxBroad"),
+	MIB_DESC(1, 0x58, "TxPause"),
+	MIB_DESC(1, 0x5c, "TxMulti"),
+	MIB_DESC(1, 0x60, "TxUnderRun"),
+	MIB_DESC(1, 0x64, "Tx64Byte"),
+	MIB_DESC(1, 0x68, "Tx128Byte"),
+	MIB_DESC(1, 0x6c, "Tx256Byte"),
+	MIB_DESC(1, 0x70, "Tx512Byte"),
+	MIB_DESC(1, 0x74, "Tx1024Byte"),
+	MIB_DESC(1, 0x78, "Tx1518Byte"),
+	MIB_DESC(1, 0x7c, "TxMaxByte"),
+	MIB_DESC(1, 0x80, "TxOverSize"),
+	MIB_DESC(2, 0x84, "TxByte"),
+	MIB_DESC(1, 0x8c, "TxCollision"),
+	MIB_DESC(1, 0x90, "TxAbortCol"),
+	MIB_DESC(1, 0x94, "TxMultiCol"),
+	MIB_DESC(1, 0x98, "TxSingleCol"),
+	MIB_DESC(1, 0x9c, "TxExcDefer"),
+	MIB_DESC(1, 0xa0, "TxDefer"),
+	MIB_DESC(1, 0xa4, "TxLateCol"),
+};
+
 u32
 ar8xxx_mii_read32(struct mii_bus *bus, int phy_id, int regnum)
 {
@@ -184,6 +233,10 @@ static int ar8xxx_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
+	/* Enable MIB counters */
+	ar8xxx_reg_set(ds, AR8327_REG_MIB, AR8327_MIB_CPU_KEEP);
+	ar8xxx_write(ds, AR8327_REG_MODULE_EN, AR8327_MODULE_EN_MIB);
+
 	/* Disable forwarding by default on all ports */
 	for (i = 0; i < AR8327_NUM_PORTS; i++)
 		ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(i),
@@ -228,6 +281,42 @@ ar8xxx_phy_write(struct dsa_switch *ds, int phy, int regnum, u16 val)
 	return mdiobus_write(bus, phy, regnum, val);
 }
 
+static void ar8xxx_get_strings(struct dsa_switch *ds, int phy, uint8_t *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ar8327_mib); i++) {
+		strncpy(data + i * ETH_GSTRING_LEN, ar8327_mib[i].name,
+			ETH_GSTRING_LEN);
+	}
+}
+
+static void ar8xxx_get_ethtool_stats(struct dsa_switch *ds, int phy,
+				     uint64_t *data)
+{
+	const struct ar8xxx_mib_desc *mib;
+	uint32_t reg, i, port;
+	u64 hi;
+
+	port = phy_to_port(phy);
+
+	for (i = 0; i < ARRAY_SIZE(ar8327_mib); i++) {
+		mib = &ar8327_mib[i];
+		reg = AR8327_PORT_MIB_COUNTER(port) + mib->offset;
+
+		data[i] = ar8xxx_read(ds, reg);
+		if (mib->size == 2) {
+			hi = ar8xxx_read(ds, reg + 4);
+			data[i] |= hi << 32;
+		}
+	}
+}
+
+static int ar8xxx_get_sset_count(struct dsa_switch *ds)
+{
+	return ARRAY_SIZE(ar8327_mib);
+}
+
 static void ar8xxx_poll_link(struct dsa_switch *ds)
 {
 	int i = 0;
@@ -275,13 +364,16 @@ static void ar8xxx_poll_link(struct dsa_switch *ds)
 }
 
 static struct dsa_switch_driver ar8xxx_switch_driver = {
-	.tag_protocol	= DSA_TAG_PROTO_NONE,
-	.probe		= ar8xxx_probe,
-	.setup		= ar8xxx_setup,
-	.set_addr	= ar8xxx_set_addr,
-	.poll_link	= ar8xxx_poll_link,
-	.phy_read	= ar8xxx_phy_read,
-	.phy_write	= ar8xxx_phy_write,
+	.tag_protocol		= DSA_TAG_PROTO_NONE,
+	.probe			= ar8xxx_probe,
+	.setup			= ar8xxx_setup,
+	.set_addr		= ar8xxx_set_addr,
+	.poll_link		= ar8xxx_poll_link,
+	.phy_read		= ar8xxx_phy_read,
+	.phy_write		= ar8xxx_phy_write,
+	.get_strings		= ar8xxx_get_strings,
+	.get_ethtool_stats	= ar8xxx_get_ethtool_stats,
+	.get_sset_count		= ar8xxx_get_sset_count,
 };
 
 static int __init ar8xxx_init(void)
diff --git a/drivers/net/dsa/ar8xxx.h b/drivers/net/dsa/ar8xxx.h
index a29b6d3..7c7a125 100644
--- a/drivers/net/dsa/ar8xxx.h
+++ b/drivers/net/dsa/ar8xxx.h
@@ -18,6 +18,12 @@
 
 #include <linux/delay.h>
 
+struct ar8xxx_mib_desc {
+	unsigned int size;
+	unsigned int offset;
+	const char *name;
+};
+
 #define AR8327_NUM_PORTS		7
 
 #define PHY_ID_QCA8337			0x004dd036
@@ -31,6 +37,14 @@
 #define   AR8327_PORT_PAD_RGMII_RX_DELAY_EN	BIT(24)
 #define   AR8327_PORT_PAD_SGMII_EN		BIT(7)
 
+#define AR8327_REG_MODULE_EN			0x030
+#define   AR8327_MODULE_EN_MIB			BIT(0)
+#define	  AR8327_MODULE_EN_ACL			BIT(1)
+#define	  AR8327_MODULE_EN_L3			BIT(2)
+
+#define AR8327_REG_MIB				0x034
+#define   AR8327_MIB_CPU_KEEP			BIT(20)
+
 #define AR8327_REG_PORT_STATUS(_i)		(0x07c + (_i) * 4)
 #define   AR8XXX_PORT_STATUS_SPEED	GENMASK(2, 0)
 #define   AR8XXX_PORT_STATUS_SPEED_S	0
@@ -52,6 +66,8 @@
 #define   AR8327_PORT_LOOKUP_LEARN		BIT(20)
 #define   AR8327_PORT_LOOKUP_ING_MIRROR_EN	BIT(25)
 
+#define AR8327_PORT_MIB_COUNTER(_i)		(0x1000 + (_i) * 0x100)
+
 /* port speed */
 enum {
 	AR8XXX_PORT_SPEED_10M = 0,
@@ -60,6 +76,25 @@ enum {
 	AR8XXX_PORT_SPEED_ERR = 3,
 };
 
+static inline int port_to_phy(int port)
+{
+	if (port >= 1 && port <= 6)
+		return port - 1;
+
+	return -1;
+}
+
+static inline int phy_to_port(int phy)
+{
+	if (phy < 5)
+		return phy + 1;
+
+	return -1;
+}
+
+u32
+ar8xxx_rmw(struct dsa_switch *ds, int reg, u32 mask, u32 val);
+
 static inline void
 split_addr(u32 regaddr, u16 *r1, u16 *r2, u16 *page)
 {
@@ -79,4 +114,16 @@ wait_for_page_switch(void)
 	udelay(5);
 }
 
+static inline void
+ar8xxx_reg_set(struct dsa_switch *ds, int reg, u32 val)
+{
+	ar8xxx_rmw(ds, reg, 0, val);
+}
+
+static inline void
+ar8xxx_reg_clear(struct dsa_switch *ds, int reg, u32 val)
+{
+	ar8xxx_rmw(ds, reg, val, 0);
+}
+
 #endif /* __AR8XXX_H */
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
