From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 5/5] r8169: spinlock redux.
Date: Tue, 31 Jan 2012 14:58:09 +0100
Message-ID: <20120131135809.GE18167@electric-eye.fr.zoreil.com>
References: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52451 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab2AaOJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:09:29 -0500
Content-Disposition: inline
In-Reply-To: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8169_get_regs operates under RTNL and rtl task mutex whereas
rtl_set_rx_mode is either called under RTNL or rtl task mutex protection.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0377ffa..7077422 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -680,7 +680,6 @@ struct rtl8169_private {
 	struct pci_dev *pci_dev;
 	struct net_device *dev;
 	struct napi_struct napi;
-	spinlock_t lock;
 	u32 msg_enable;
 	u16 txd_version;
 	u16 mac_version;
@@ -1723,9 +1722,7 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	spin_lock_bh(&tp->lock);
 	memcpy_fromio(p, tp->mmio_addr, regs->len);
-	spin_unlock_bh(&tp->lock);
 	rtl_unlock_work(tp);
 }
 
@@ -4151,7 +4148,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->do_ioctl = rtl_xmii_ioctl;
 	}
 
-	spin_lock_init(&tp->lock);
 	mutex_init(&tp->wk.mutex);
 
 	/* Get MAC address */
@@ -6031,8 +6027,6 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		}
 	}
 
-	spin_lock_bh(&tp->lock);
-
 	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
@@ -6046,8 +6040,6 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 
 	RTL_W32(RxConfig, tmp);
-
-	spin_unlock_bh(&tp->lock);
 }
 
 /**
-- 
1.7.6.5
