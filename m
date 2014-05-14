From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 11/11] net: dsa: bcm_sf2: enable Broadcom tags
Date: Tue, 13 May 2014 22:00:37 -0700
Message-ID: <1400043637-9799-12-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:41845 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015AbaENFBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:38 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so1189393pbb.39
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:37 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Select the Broadcom tag mangler/unmangler and configure the IMP port of
the switch to dispatch the frames to/from the per-port network devices.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/Kconfig        |  1 +
 drivers/net/dsa/bcm_sf2.c      | 19 +++++++++++++++++--
 drivers/net/dsa/bcm_sf2_regs.h | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 9b51960a4227..d1d049682a8c 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -39,6 +39,7 @@ config NET_DSA_MV88E6123_61_65
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
 	select NET_DSA
+	select NET_DSA_TAG_BRCM
 	select FIXED_PHY
 	select BCM7XXX_PHY
 	select MDIO_UNIMAC
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 1f8ac8d45c90..110ea7993c3c 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -164,15 +164,30 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 		break;
 	}
 
-	/* Disable Broadcom tags for IMP port */
+	/* Enable Broadcom tags for IMP port */
 	reg = core_readl(priv, CORE_BRCM_HDR_CTRL);
-	reg &= ~val;
+	reg |= val;
 	core_writel(priv, reg, CORE_BRCM_HDR_CTRL);
 
+	/* Enable reception Broadcom tag for CPU TX (switch RX) to
+	 * allow us to tag outgoing frames
+	 */
+	reg = core_readl(priv, CORE_BRCM_HDR_RX_DIS);
+	reg &= ~(1 << port);
+	core_writel(priv, reg, CORE_BRCM_HDR_RX_DIS);
+
+	/* Enable transmission of Broadcom tags from the switch (CPU RX) to
+	 * allow delivering frames to the per-port net_devices
+	 */
+	reg = core_readl(priv, CORE_BRCM_HDR_TX_DIS);
+	reg &= ~(1 << port);
+	core_writel(priv, reg, CORE_BRCM_HDR_TX_DIS);
+
 	/* Force link status for IMP port */
 	reg = core_readl(priv, CORE_STS_OVERRIDE_IMP);
 	reg |= (MII_SW_OR | LINK_STS);
 	core_writel(priv, reg, CORE_STS_OVERRIDE_IMP);
+
 }
 
 static void bcm_sf2_port_setup(struct dsa_switch *ds, int port)
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index e183cac3d7c8..92a59fb4eec3 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -127,6 +127,19 @@
 #define  GMII_SPEED_UP_2G		(1 << 6)
 #define  MII_SW_OR			(1 << 7)
 
+#define CORE_NEW_CTRL			0x00084
+#define  IP_MC				(1 << 0)
+#define  OUTRANGEERR_DISCARD		(1 << 1)
+#define  INRANGEERR_DISCARD		(1 << 2)
+#define  CABLE_DIAG_LEN			(1 << 3)
+#define  OVERRIDE_AUTO_PD_WAR		(1 << 4)
+#define  EN_AUTO_PD_WAR			(1 << 5)
+#define  UC_FWD_EN			(1 << 6)
+#define  MC_FWD_EN			(1 << 7)
+
+#define CORE_SFT_LRN_CTRL		0x000f8
+#define  SW_LEARN_CNTL(x)		(1 << (x))
+
 #define CORE_STS_OVERRIDE_GMIIP_PORT(x)	(0x160 + (x) * 4)
 #define  LINK_STS			(1 << 0)
 #define  DUPLX_MODE			(1 << 1)
@@ -152,11 +165,38 @@
 #define CORE_PAUSESTS			0x00428
 #define  PAUSESTS_TX_PAUSE_SHIFT	9
 
+#define CORE_GMNCFGCFG			0x0800
+#define  RST_MIB_CNT			(1 << 0)
+#define  RXBPDU_EN			(1 << 1)
+
 #define CORE_BRCM_HDR_CTRL		0x0080c
 #define  BRCM_HDR_EN_P8			(1 << 0)
 #define  BRCM_HDR_EN_P5			(1 << 1)
 #define  BRCM_HDR_EN_P7			(1 << 2)
 
+#define CORE_BRCM_HDR_CTRL2		0x0828
+
+#define CORE_HL_PRTC_CTRL		0x0940
+#define  ARP_EN				(1 << 0)
+#define  RARP_EN			(1 << 1)
+#define  DHCP_EN			(1 << 2)
+#define  ICMPV4_EN			(1 << 3)
+#define  ICMPV6_EN			(1 << 4)
+#define  ICMPV6_FWD_MODE		(1 << 5)
+#define  IGMP_DIP_EN			(1 << 8)
+#define  IGMP_RPTLVE_EN			(1 << 9)
+#define  IGMP_RTPLVE_FWD_MODE		(1 << 10)
+#define  IGMP_QRY_EN			(1 << 11)
+#define  IGMP_QRY_FWD_MODE		(1 << 12)
+#define  IGMP_UKN_EN			(1 << 13)
+#define  IGMP_UKN_FWD_MODE		(1 << 14)
+#define  MLD_RPTDONE_EN			(1 << 15)
+#define  MLD_RPTDONE_FWD_MODE		(1 << 16)
+#define  MLD_QRY_EN			(1 << 17)
+#define  MLD_QRY_FWD_MODE		(1 << 18)
+
+#define CORE_RST_MIB_CNT_EN		0x0950
+
 #define CORE_BRCM_HDR_RX_DIS		0x0980
 #define CORE_BRCM_HDR_TX_DIS		0x0988
 
-- 
1.9.1
