From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v5 2/4] net: phy: fixed_phy: handle link-down case
Date: Mon, 20 Jul 2015 17:49:56 -0700
Message-ID: <1437439798-12622-3-git-send-email-f.fainelli@gmail.com>
References: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, mxs@sbrk.org,
	arno@natisbad.org, stsp@users.sourceforge.net,
	devicetree@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	Stas Sergeev <stsp@list.ru>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stas Sergeev <stsp@list.ru>

fixed_phy_register() currently hardcodes the fixed PHY link to 1, and
expects to find a "speed" parameter to provide correct information
towards the fixed PHY consumer.

In a subsequent change, where we allow "managed" (e.g: (RS)GMII in-band
status auto-negotiation) fixed PHYs, none of these parameters can be
provided since they will be auto-negotiated, hence, we just provide a
zero-initialized fixed_phy_status to fixed_phy_register() which makes it
fail when we call fixed_phy_update_regs() since status.speed = 0 which
makes us hit the "default" label and error out.

Without this change, we would also see potentially inconsistent
speed/duplex parameters for fixed PHYs when the link is DOWN.

CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
[florian: add more background to why this is correct and desirable]
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/fixed_phy.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 1960b46add65..479b93f9581c 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -52,6 +52,10 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	u16 lpagb = 0;
 	u16 lpa = 0;
 
+	if (!fp->status.link)
+		goto done;
+	bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
+
 	if (fp->status.duplex) {
 		bmcr |= BMCR_FULLDPLX;
 
@@ -96,15 +100,13 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 		}
 	}
 
-	if (fp->status.link)
-		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
-
 	if (fp->status.pause)
 		lpa |= LPA_PAUSE_CAP;
 
 	if (fp->status.asym_pause)
 		lpa |= LPA_PAUSE_ASYM;
 
+done:
 	fp->regs[MII_PHYSID1] = 0;
 	fp->regs[MII_PHYSID2] = 0;
 
-- 
2.1.0
