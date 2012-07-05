From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 4 1/4] OMAP: add cpu id register to MAC address helper
Date: Thu, 05 Jul 2012 10:44:41 +0800
Message-ID: <20120705024439.26317.84637.stgit@build.warmcat.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, linux-arm-kernel@lists.infradead.org
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20120705024259.26317.16000.stgit@build.warmcat.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Green <andy@warmcat.com>

Introduce a generic helper function that can generate a valid MAC
address using data from the OMAP unique CPU ID register.

For comparison purposes this produces a MAC address of

  2e:20:3c:ea:46:01

for the ethernet device on my PandaBoard ES.

The MAC address space has space set aside for these kind of "locally
administered" MAC addresses, analogous to IPv4 10.x.x.x range, and this
patch marks the generated MAC addresses as such.

The patch leaves two bits allowing elaborating 4 different MACs from the
generated data.

Signed-off-by: Andy Green <andy.green@linaro.org>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Nicolas Pitre <nicolas.pitre@linaro.org>
Tested-by: Steven Rostedt <rostedt@goodmis.org>
---
 arch/arm/mach-omap2/id.c              |   39 +++++++++++++++++++++++++++++++++
 arch/arm/mach-omap2/include/mach/id.h |    1 +
 2 files changed, 40 insertions(+)

diff --git a/arch/arm/mach-omap2/id.c b/arch/arm/mach-omap2/id.c
index 37eb95a..3ab5d4d 100644
--- a/arch/arm/mach-omap2/id.c
+++ b/arch/arm/mach-omap2/id.c
@@ -530,3 +530,42 @@ void __init omap2_set_globals_tap(struct omap_globals *omap2_globals)
 	else
 		tap_prod_id = 0x0208;
 }
+
+/*
+ * this uses the unique per-cpu info from the cpu fuses set at factory to
+ * generate a 6-byte MAC address.  Two bits in the generated code are used
+ * to elaborate the generated address into four, so it can be used on multiple
+ * network interfaces.
+ */
+
+void omap_die_id_to_ethernet_mac(u8 *mac, int subtype)
+{
+	struct omap_die_id odi;
+	u32 tap = read_tap_reg(OMAP_TAP_IDCODE);
+
+	omap_get_die_id(&odi);
+
+	mac[0] = odi.id_2;
+	mac[1] = odi.id_2 >> 8;
+	mac[2] = odi.id_1;
+	mac[3] = odi.id_1 >> 8;
+	mac[4] = odi.id_1 >> 16;
+	mac[5] = odi.id_1 >> 24;
+
+	/* XOR other chip-specific data with ID */
+
+	tap ^= odi.id_3;
+
+	mac[0] ^= tap;
+	mac[1] ^= tap >> 8;
+	mac[2] ^= tap >> 16;
+	mac[3] ^= tap >> 24;
+
+	/* allow four MACs from this same basic data */
+
+	mac[1] = (mac[1] & ~0xc0) | ((subtype & 3) << 6);
+
+	/* mark it as not multicast, and outside official 80211 MAC namespace */
+
+	mac[0] = (mac[0] & ~1) | 2;
+}
diff --git a/arch/arm/mach-omap2/include/mach/id.h b/arch/arm/mach-omap2/include/mach/id.h
index 02ed3aa..d6c8d63 100644
--- a/arch/arm/mach-omap2/include/mach/id.h
+++ b/arch/arm/mach-omap2/include/mach/id.h
@@ -18,5 +18,6 @@ struct omap_die_id {
 };
 
 void omap_get_die_id(struct omap_die_id *odi);
+void omap_die_id_to_ethernet_mac(u8 *mac, int subtype);
 
 #endif

