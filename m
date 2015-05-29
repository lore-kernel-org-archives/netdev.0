From: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH 5/7] net: dsa: ar8xxx: enable QCA header support on AR8xxx
Date: Thu, 28 May 2015 18:42:20 -0700
Message-ID: <1432863742-18427-6-git-send-email-mathieu@codeaurora.org>
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

This change enable support for the QCA headers in QCA83337 driver.
A 2 bytes header will be added by the switch on every incoming packet
to identify the ingress port, and the DSA tagging code will add a
similar 2 bytes header to control which port is used to send a
particular packet.

Signed-off-by: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/dsa/Kconfig  |  1 +
 drivers/net/dsa/ar8xxx.c | 28 ++++++++++++++++++++++++++--
 drivers/net/dsa/ar8xxx.h | 22 ++++++++++++++++++++++
 3 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 17fb296..fa8b484 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -68,6 +68,7 @@ config NET_DSA_BCM_SF2
 config NET_DSA_AR8XXX
 	tristate "Qualcomm Atheros AR8XXX Ethernet switch family support"
 	depends on NET_DSA
+	select NET_DSA_TAG_QCA
 	select REGMAP
 	---help---
 	  This enables support for the Qualcomm Atheros AR8XXX Ethernet
diff --git a/drivers/net/dsa/ar8xxx.c b/drivers/net/dsa/ar8xxx.c
index 327abd4..4044614 100644
--- a/drivers/net/dsa/ar8xxx.c
+++ b/drivers/net/dsa/ar8xxx.c
@@ -292,15 +292,31 @@ static int ar8xxx_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
+	/* Enable CPU Port */
+	ar8xxx_reg_set(ds, AR8327_REG_GLOBAL_FW_CTRL0,
+		       AR8327_GLOBAL_FW_CTRL0_CPU_PORT_EN);
+
 	/* Enable MIB counters */
 	ar8xxx_reg_set(ds, AR8327_REG_MIB, AR8327_MIB_CPU_KEEP);
 	ar8xxx_write(ds, AR8327_REG_MODULE_EN, AR8327_MODULE_EN_MIB);
 
+	/* Enable QCA header mode on Port 0 */
+	ar8xxx_write(ds, AR8327_REG_PORT_HDR_CTRL(0),
+		     AR8327_PORT_HDR_CTRL_ALL << AR8327_PORT_HDR_CTRL_TX_S |
+		     AR8327_PORT_HDR_CTRL_ALL << AR8327_PORT_HDR_CTRL_RX_S);
+
 	/* Disable forwarding by default on all ports */
 	for (i = 0; i < AR8327_NUM_PORTS; i++)
 		ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(i),
 			   AR8327_PORT_LOOKUP_MEMBER, 0);
 
+	/* Forward all unknown frames to CPU port for Linux processing */
+	ar8xxx_write(ds, AR8327_REG_GLOBAL_FW_CTRL1,
+		     BIT(0) << AR8327_GLOBAL_FW_CTRL1_IGMP_DP_S |
+		     BIT(0) << AR8327_GLOBAL_FW_CTRL1_BC_DP_S |
+		     BIT(0) << AR8327_GLOBAL_FW_CTRL1_MC_DP_S |
+		     BIT(0) << AR8327_GLOBAL_FW_CTRL1_UC_DP_S);
+
 	/* Setup connection between CPU ports & PHYs */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
 		/* CPU port gets connected to all PHYs in the switch */
@@ -312,8 +328,16 @@ static int ar8xxx_setup(struct dsa_switch *ds)
 
 		/* Invividual PHYs gets connected to CPU port only */
 		if (ds->phys_port_mask & BIT(i)) {
-			ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(phy_to_port(i)),
+			int phy = phy_to_port(i);
+
+			ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(phy),
 				   AR8327_PORT_LOOKUP_MEMBER, BIT(0));
+
+			/* Disable Auto-learning by default so the switch
+			 * doesn't try to forward the frame to another port
+			 */
+			ar8xxx_reg_clear(ds, AR8327_PORT_LOOKUP_CTRL(phy),
+					 AR8327_PORT_LOOKUP_LEARN);
 		}
 	}
 
@@ -423,7 +447,7 @@ static void ar8xxx_poll_link(struct dsa_switch *ds)
 }
 
 static struct dsa_switch_driver ar8xxx_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_NONE,
+	.tag_protocol		= DSA_TAG_PROTO_QCA,
 	.priv_size		= sizeof(struct ar8xxx_priv),
 	.probe			= ar8xxx_probe,
 	.setup			= ar8xxx_setup,
diff --git a/drivers/net/dsa/ar8xxx.h b/drivers/net/dsa/ar8xxx.h
index 98cc7ed..e68b92a 100644
--- a/drivers/net/dsa/ar8xxx.h
+++ b/drivers/net/dsa/ar8xxx.h
@@ -62,6 +62,28 @@ struct ar8xxx_mib_desc {
 #define   AR8XXX_PORT_STATUS_LINK_AUTO	BIT(9)
 #define   AR8XXX_PORT_STATUS_LINK_PAUSE	BIT(10)
 
+#define AR8327_REG_PORT_HDR_CTRL(_i)		(0x9c + (_i * 4))
+#define   AR8327_PORT_HDR_CTRL_RX_MASK		GENMASK(3, 2)
+#define   AR8327_PORT_HDR_CTRL_RX_S		2
+#define   AR8327_PORT_HDR_CTRL_TX_MASK		GENMASK(1, 0)
+#define   AR8327_PORT_HDR_CTRL_TX_S		0
+#define   AR8327_PORT_HDR_CTRL_ALL		2
+#define   AR8327_PORT_HDR_CTRL_MGMT		1
+#define   AR8327_PORT_HDR_CTRL_NONE		0
+
+#define AR8327_REG_GLOBAL_FW_CTRL0		0x620
+#define   AR8327_GLOBAL_FW_CTRL0_CPU_PORT_EN	BIT(10)
+
+#define AR8327_REG_GLOBAL_FW_CTRL1		0x624
+#define   AR8327_GLOBAL_FW_CTRL1_IGMP_DP_MASK	GENMASK(30, 24)
+#define   AR8327_GLOBAL_FW_CTRL1_IGMP_DP_S	24
+#define   AR8327_GLOBAL_FW_CTRL1_BC_DP_MASK	GENMASK(22, 16)
+#define   AR8327_GLOBAL_FW_CTRL1_BC_DP_S	16
+#define   AR8327_GLOBAL_FW_CTRL1_MC_DP_MASK	GENMASK(14, 8)
+#define   AR8327_GLOBAL_FW_CTRL1_MC_DP_S	8
+#define   AR8327_GLOBAL_FW_CTRL1_UC_DP_MASK	GENMASK(6, 0)
+#define   AR8327_GLOBAL_FW_CTRL1_UC_DP_S	0
+
 #define AR8327_PORT_LOOKUP_CTRL(_i)		(0x660 + (_i) * 0xc)
 #define   AR8327_PORT_LOOKUP_MEMBER		GENMASK(6, 0)
 #define   AR8327_PORT_LOOKUP_IN_MODE		GENMASK(9, 8)
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
