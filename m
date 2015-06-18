From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH] mvneta: add forgotten initialization of autonegotiation bits
Date: Thu, 18 Jun 2015 18:36:03 +0300
Message-ID: <5582E563.3010801@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Linux kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state
signaling")
changed mvneta_adjust_link() so that it does not clear the auto-negotiation
bits in MVNETA_GMAC_AUTONEG_CONFIG register. This was necessary for
auto-negotiation mode to work.
Unfortunately I haven't checked if these bits are ever initialized.
It appears they are not.
This patch adds the missing initialization of the auto-negotiation bits
in the MVNETA_GMAC_AUTONEG_CONFIG register.
It fixes the following regression:
https://www.mail-archive.com/netdev@vger.kernel.org/msg67928.html

Since the patch was tested to fix a regression, it should be applied to
stable tree.

Tested-by: Arnaud Ebalard <arno@natisbad.org>

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: stable@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9..74176ec 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1013,6 +1013,12 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
 		val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;
 		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
+	} else {
+		val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
+		val &= ~(MVNETA_GMAC_INBAND_AN_ENABLE |
+		       MVNETA_GMAC_AN_SPEED_EN |
+		       MVNETA_GMAC_AN_DUPLEX_EN);
+		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
 	}

 	mvneta_set_ucast_table(pp, -1);
-- 
1.9.1
