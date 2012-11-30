From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH]realtek:r8169: Bugfix or workaround for missing extended
 GigaMAC registers settings
Date: Fri, 30 Nov 2012 13:06:19 +0800
Message-ID: <20121130050619.GA12862@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get a board with 8168e-vl(10ec:8168 with RTL_GIGA_MAC_VER_34),
everything looks well first, I can use ifconfig to set ip, netmask,
etc. And the rx/tx statistics show by ifconfig looks good when I
ping another host or ping it from another host. But it don't work,
I can't get ICMP REPLAY from both sides, although the RX/TX statistics
seem good.

After add some debug code, I found this NIC only accept ethernet
broadcast package, it can't filter out the package send to its
MAC address, but it works good for sending.So ifconfig show the
RX/TX status means it can receive ARP package.(It don't its MAC
address, so below)

I have try the driver provided by realtek's website, it have the
same problem at the first time. BUT IT WORK AFTER I REBOOT with
CRTL-ALT-DEL, the reason is that realtek's driver call rtl8168_rar_set
in the .shutdown function register with pci_register_driver. Yes,
the really reason to make it work is rtl8689_rar_set, this function
set extended GigaMAC registers, so after reboot without lost the power,
NIC keep the status before reboot.

I haven't see any code to set GigaMAC registers in kernel when boot,
so I guess BIOS or NIC's circuit make it, but of course one miss
the extended GigaMAC registers  in this problem. The probe code can
get MAC address right, so MAC{0,4} must had been setted, but some
guys forget the extended GigaMAC registers.

This patch fix it.
[ I don't known whether others' realtek's NIC with extended GigaMAC
reigisters have the same problem, I meet it in 8168e-vl with
RTL_GIGA_MAC_VER_34, so I make this patch just for it.]

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 927aa33..e49c08d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3095,7 +3095,30 @@ static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x0e, 0x0000);
 	rtl_writephy(tp, 0x0d, 0x0000);
 }
+static void rtl8168e_2_workaround(struct rtl8169_private *tp, u8 *addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 high;
+	u32 low;
+
+	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
+	high = addr[4] | (addr[5] << 8);
+
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		const struct exgmac_reg e[] = {
+			{ .addr = 0xe0, ERIAR_MASK_1111, .val = low },
+			{ .addr = 0xe4, ERIAR_MASK_1111, .val = high },
+			{ .addr = 0xf0, ERIAR_MASK_1111, .val = low << 16 },
+			{ .addr = 0xf4, ERIAR_MASK_1111, .val = high << 16 |
+								low  >> 16 },
+		};
 
+		rtl_write_exgmac_batch(tp, e, ARRAY_SIZE(e));
+	}
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
 static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3178,6 +3201,7 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x19, 0x0000, 0x0001);
 	rtl_w1w0_phy(tp, 0x10, 0x0000, 0x0400);
 	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl8168e_2_workaround(tp, tp->dev->dev_addr);
 }
 
 static void rtl8168f_hw_phy_config(struct rtl8169_private *tp)
-- 
1.7.11.1.116.g8228a23
