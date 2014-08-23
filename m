From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/7] net: phy: fixed: return an error for Clause 45 over 22 reads
Date: Fri, 22 Aug 2014 18:55:42 -0700
Message-ID: <1408758945-18908-5-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:63609 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbaHWB4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:18 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so17518702pac.4
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:18 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fixed PHY driver does not properly emulate Clause 45 over Clause 22
MDIO reads, and as such, will return bogus values when we access such
registers.

Return an error when accessing these registers in order to prevent
advertising bogus capabilities such as EEE support and such.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/fixed.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index d60d875cb445..5b19fbbda6d4 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -124,6 +124,17 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
 	if (reg_num >= MII_REGS_NUM)
 		return -1;
 
+	/* We do not support emulating Clause 45 over Clause 22 register reads
+	 * return an error instead of bogus data.
+	 */
+	switch (reg_num) {
+	case MII_MMD_CTRL:
+	case MII_MMD_DATA:
+		return -1;
+	default:
+		break;
+	}
+
 	list_for_each_entry(fp, &fmb->phys, node) {
 		if (fp->addr == phy_addr) {
 			/* Issue callback if user registered it. */
-- 
1.9.1
