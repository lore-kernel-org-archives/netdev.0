From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v4 5/7] net: pch_gbe: Always reset PHY along with MAC
Date: Mon, 5 Jun 2017 10:31:34 -0700
Message-ID: <20170605173136.10795-6-paul.burton@imgtec.com>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170605173136.10795-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        <linux-mips@linux-mips.org>, Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Paul Burton <paul.burton@imgtec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:28533 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752048AbdFERdo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 13:33:44 -0400
In-Reply-To: <20170605173136.10795-1-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the MIPS Boston development board, the EG20T MAC does not report
receiving the RX clock from the (RGMII) RTL8211E PHY unless the PHY is
reset at the same time as the MAC. Since the pch_gbe driver resets the
MAC a number of times - twice during probe, and when taking down the
network interface - we need to reset the PHY at all the same times. Do
that from pch_gbe_mac_reset_hw which is used to reset the MAC in all
cases.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
---

Changes in v4: None
Changes in v3: None
Changes in v2: None

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b9d8504eb09c..c8554d3adf1c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -380,10 +380,13 @@ static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 {
 	/* Read the MAC address. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
+	pch_gbe_phy_set_reset(hw, 1);
 	iowrite32(PCH_GBE_ALL_RST, &hw->reg->RESET);
 #ifdef PCH_GBE_MAC_IFOP_RGMII
 	iowrite32(PCH_GBE_MODE_GMII_ETHER, &hw->reg->MODE);
 #endif
+	pch_gbe_phy_set_reset(hw, 0);
+	usleep_range(1250, 1500);
 	pch_gbe_wait_clr_bit(&hw->reg->RESET, PCH_GBE_ALL_RST);
 	/* Setup the receive addresses */
 	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
-- 
2.13.0
