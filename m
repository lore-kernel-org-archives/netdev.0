From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 29 Mar 2007 16:10:34 -0400
Message-ID: <20070329201034.GA2177@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51257 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030666AbXC2UKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 16:10:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/atl1/atl1_main.c         |   10 ++++++++++
 drivers/net/netxen/netxen_nic_init.c |    3 ++-
 drivers/net/sis190.c                 |    1 +
 3 files changed, 13 insertions(+), 1 deletions(-)

Chris Snook (1):
      atl1: save mac address on remove

Francois Romieu (1):
      sis190: new PHY support

Linsys Contractor Adhiraj Joshi (1):
      NetXen: Fix hardware access for ppc architecture.

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index dee3638..8606eac 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2320,6 +2320,16 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 		return;
 
 	adapter = netdev_priv(netdev);
+
+	/* Some atl1 boards lack persistent storage for their MAC, and get it
+	 * from the BIOS during POST.  If we've been messing with the MAC
+	 * address, we need to save the permanent one.
+	 */
+	if (memcmp(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN)) {
+		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN);
+		atl1_set_mac_addr(&adapter->hw);
+	}
+
 	iowrite16(0, adapter->hw.hw_addr + REG_GPHY_ENABLE);
 	unregister_netdev(netdev);
 	pci_iounmap(pdev, adapter->hw.hw_addr);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 229aa1c..eff965d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -438,6 +438,7 @@ do_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
 
 	for (addridx = addr; addridx < (addr + size); addridx += 4) {
 		ret = do_rom_fast_read(adapter, addridx, (int *)bytes);
+		*(int *)bytes = cpu_to_le32(*(int *)bytes);
 		if (ret != 0)
 			break;
 		bytes += 4;
@@ -497,7 +498,7 @@ static inline int do_rom_fast_write_words(struct netxen_adapter *adapter,
 		int timeout = 0;
 		int data;
 
-		data = *(u32*)bytes;
+		data = le32_to_cpu((*(u32*)bytes));
 
 		ret = do_rom_fast_write(adapter, addridx, data);
 		if (ret < 0)
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b08508b..34463ce 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -324,6 +324,7 @@ static struct mii_chip_info {
 	u32 feature;
 } mii_chip_table[] = {
 	{ "Broadcom PHY BCM5461", { 0x0020, 0x60c0 }, LAN, F_PHY_BCM5461 },
+	{ "Broadcom PHY AC131",   { 0x0143, 0xbc70 }, LAN, 0 },
 	{ "Agere PHY ET1101B",    { 0x0282, 0xf010 }, LAN, 0 },
 	{ "Marvell PHY 88E1111",  { 0x0141, 0x0cc0 }, LAN, F_PHY_88E1111 },
 	{ "Realtek PHY RTL8201",  { 0x0000, 0x8200 }, LAN, 0 },
