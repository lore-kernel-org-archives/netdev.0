From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 01/10] bus: mvebu-mbus: provide api for obtaining IO and DRAM window information
Date: Tue, 12 Jan 2016 20:10:25 +0100
Message-ID: <1452625834-22166-2-git-send-email-gregory.clement@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>,
	Evan Wang <xswang@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>

This commit enables finding appropriate mbus window and obtaining its
target id and attribute for given physical address in two separate
routines, both for IO and DRAM windows. This functionality
is needed for Armada XP/38x Network Controller's Buffer Manager and
PnC configuration.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>

[DRAM window information reference in LKv3.10]
Signed-off-by: Evan Wang <xswang@marvell.com>
---
 drivers/bus/mvebu-mbus.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mbus.h     |  3 +++
 2 files changed, 54 insertions(+)

diff --git a/drivers/bus/mvebu-mbus.c b/drivers/bus/mvebu-mbus.c
index c43c3d2baf73..3d1c0c3880ec 100644
--- a/drivers/bus/mvebu-mbus.c
+++ b/drivers/bus/mvebu-mbus.c
@@ -948,6 +948,57 @@ void mvebu_mbus_get_pcie_io_aperture(struct resource *res)
 	*res = mbus_state.pcie_io_aperture;
 }
 
+int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target, u8 *attr)
+{
+	const struct mbus_dram_target_info *dram;
+	int i;
+
+	/* Get dram info */
+	dram = mv_mbus_dram_info();
+	if (!dram) {
+		pr_err("missing DRAM information\n");
+		return -ENODEV;
+	}
+
+	/* Try to find matching DRAM window for phyaddr */
+	for (i = 0; i < dram->num_cs; i++) {
+		const struct mbus_dram_window *cs = dram->cs + i;
+
+		if (cs->base <= phyaddr && phyaddr <= (cs->base + cs->size)) {
+			*target = dram->mbus_dram_target_id;
+			*attr = cs->mbus_attr;
+			return 0;
+		}
+	}
+
+	pr_err("invalid dram address 0x%x\n", phyaddr);
+	return -EINVAL;
+}
+EXPORT_SYMBOL_GPL(mvebu_mbus_get_dram_win_info);
+
+int mvebu_mbus_get_io_win_info(phys_addr_t phyaddr, u32 *size, u8 *target,
+			       u8 *attr)
+{
+	int win;
+
+	for (win = 0; win < mbus_state.soc->num_wins; win++) {
+		u64 wbase;
+		int enabled;
+
+		mvebu_mbus_read_window(&mbus_state, win, &enabled, &wbase,
+				       size, target, attr, NULL);
+
+		if (!enabled)
+			continue;
+
+		if (wbase <= phyaddr && phyaddr <= wbase + *size)
+			return win;
+	}
+
+	return -EINVAL;
+}
+EXPORT_SYMBOL_GPL(mvebu_mbus_get_io_win_info);
+
 static __init int mvebu_mbus_debugfs_init(void)
 {
 	struct mvebu_mbus_state *s = &mbus_state;
diff --git a/include/linux/mbus.h b/include/linux/mbus.h
index 1f7bc630d225..ea34a867caa0 100644
--- a/include/linux/mbus.h
+++ b/include/linux/mbus.h
@@ -69,6 +69,9 @@ static inline const struct mbus_dram_target_info *mv_mbus_dram_info_nooverlap(vo
 int mvebu_mbus_save_cpu_target(u32 *store_addr);
 void mvebu_mbus_get_pcie_mem_aperture(struct resource *res);
 void mvebu_mbus_get_pcie_io_aperture(struct resource *res);
+int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target, u8 *attr);
+int mvebu_mbus_get_io_win_info(phys_addr_t phyaddr, u32 *size, u8 *target,
+			       u8 *attr);
 int mvebu_mbus_add_window_remap_by_id(unsigned int target,
 				      unsigned int attribute,
 				      phys_addr_t base, size_t size,
-- 
2.5.0
