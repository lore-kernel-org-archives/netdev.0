From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 16/58] net: ethernet: stmmac: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:00 -0700
Message-ID: <1508200182-104605-17-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:49739 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757944AbdJQAh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 20:37:27 -0400
Received: by mail-pf0-f174.google.com with SMTP id i5so54553pfe.6
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 17:37:27 -0700 (PDT)
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by:  Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
index 6a9c954492f2..8b50afcdb52d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
@@ -118,10 +118,9 @@ int tse_pcs_init(void __iomem *base, struct tse_pcs *pcs)
 	return ret;
 }
 
-static void pcs_link_timer_callback(unsigned long data)
+static void pcs_link_timer_callback(struct tse_pcs *pcs)
 {
 	u16 val = 0;
-	struct tse_pcs *pcs = (struct tse_pcs *)data;
 	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
 	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
 
@@ -138,12 +137,11 @@ static void pcs_link_timer_callback(unsigned long data)
 	}
 }
 
-static void auto_nego_timer_callback(unsigned long data)
+static void auto_nego_timer_callback(struct tse_pcs *pcs)
 {
 	u16 val = 0;
 	u16 speed = 0;
 	u16 duplex = 0;
-	struct tse_pcs *pcs = (struct tse_pcs *)data;
 	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
 	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
 
@@ -201,14 +199,14 @@ static void auto_nego_timer_callback(unsigned long data)
 	}
 }
 
-static void aneg_link_timer_callback(unsigned long data)
+static void aneg_link_timer_callback(struct timer_list *t)
 {
-	struct tse_pcs *pcs = (struct tse_pcs *)data;
+	struct tse_pcs *pcs = from_timer(pcs, t, aneg_link_timer);
 
 	if (pcs->autoneg == AUTONEG_ENABLE)
-		auto_nego_timer_callback(data);
+		auto_nego_timer_callback(pcs);
 	else if (pcs->autoneg == AUTONEG_DISABLE)
-		pcs_link_timer_callback(data);
+		pcs_link_timer_callback(pcs);
 }
 
 void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
@@ -237,8 +235,8 @@ void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
 
 		tse_pcs_reset(tse_pcs_base, pcs);
 
-		setup_timer(&pcs->aneg_link_timer,
-			    aneg_link_timer_callback, (unsigned long)pcs);
+		timer_setup(&pcs->aneg_link_timer, aneg_link_timer_callback,
+			    0);
 		mod_timer(&pcs->aneg_link_timer, jiffies +
 			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
 	} else if (phy_dev->autoneg == AUTONEG_DISABLE) {
@@ -270,8 +268,8 @@ void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
 
 		tse_pcs_reset(tse_pcs_base, pcs);
 
-		setup_timer(&pcs->aneg_link_timer,
-			    aneg_link_timer_callback, (unsigned long)pcs);
+		timer_setup(&pcs->aneg_link_timer, aneg_link_timer_callback,
+			    0);
 		mod_timer(&pcs->aneg_link_timer, jiffies +
 			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
 	}
-- 
2.7.4
