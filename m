From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 05/05] r8169: prevent bit sign expansion error in mdio_write
Date: Fri, 9 Nov 2007 00:12:22 +0100
Message-ID: <20071108231222.GF15968@electric-eye.fr.zoreil.com>
References: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Mark Lord <mlord@pobox.com>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>,
	Josh Logan <joshtlogan@gmail.com>,
	cecco <f.cecco77@tiscali.it>,
	Hans-Jurgen Koch <hjk@linutronix.de>,
	David Gundersen <gundy@iinet.net.au>,
	Will Trives <will@trivescon.com.au>,
	"Alexander Y. Fomichev" <gluk@php4.ru>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38793 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753686AbXKHXQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 18:16:25 -0500
Content-Disposition: inline
In-Reply-To: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oops.

The current code does not like being given an u16 with the highest
bit set as an argument to mdio_write. Let's enforce a correct range of
values for both the register address and value (resp. 5 and 16 bits).

The callers are currently left as-is.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f9ba2e4..1f647b9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -470,7 +470,7 @@ static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
 
-	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0xFF) << 16 | value);
+	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -487,7 +487,7 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 {
 	int i, value = -1;
 
-	RTL_W32(PHYAR, 0x0 | (reg_addr & 0xFF) << 16);
+	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -495,7 +495,7 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 		 * the specified MII register.
 		 */
 		if (RTL_R32(PHYAR) & 0x80000000) {
-			value = (int) (RTL_R32(PHYAR) & 0xFFFF);
+			value = RTL_R32(PHYAR) & 0xffff;
 			break;
 		}
 		udelay(25);
-- 
1.5.3.3

