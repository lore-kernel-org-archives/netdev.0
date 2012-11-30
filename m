From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH v3]realtek:r8169: Bugfix or workaround for missing extended
 GigaMAC registers settings
Date: Sat, 1 Dec 2012 07:21:52 +0800
Message-ID: <20121130232152.GA10960@udknight>
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
RX/TX status means it can receive ARP package.(It don't know its
MAC address, so below)

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

Changes:
V1-V2:
I follow Francois Romieu 's below opinion to make this patch oneline:

I'd rather see the GigaMAC registers written through a call to
rtl_rar_set when the mac address is read in rtl_init_one instead of
duplicating most of rtl_rar_set in a quite different place.

V2-V3:
1:Add conditon code to around this fix, because it make no sense for
most NIC
2:Add comment in code

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 927aa33..5d98296 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6903,6 +6903,14 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
+	/*
+	 *This is a fix for BIOS forget to set
+	 *extend GigaMAC registers
+	 *Wang YanQing 12/1/2012
+	 */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+	    rtl_rar_set(tp, dev->dev_addr);
+	}
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 
-- 
1.7.11.1.116.g8228a23
