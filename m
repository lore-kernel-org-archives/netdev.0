From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] r8169: fix random mdio_write failures
Date: Sat,  5 Jun 2010 13:21:13 +0300
Message-ID: <1275733273-28321-1-git-send-email-timo.teras@iki.fi>
References: <4C0A1736.9030209@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	=?UTF-8?q?fran=C3=A7ois=20romieu?= <romieu@fr.zoreil.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:59746 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932647Ab0FEKVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 06:21:47 -0400
Received: by ey-out-2122.google.com with SMTP id 25so134216eya.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 03:21:46 -0700 (PDT)
In-Reply-To: <4C0A1736.9030209@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some configurations need delay between the "write completed" indication
and new write to work reliably.

Realtek driver seems to use longer delay when polling the "write comple=
te"
bit, so it waits long enough between writes with high probability (but
could probably break too). This patch adds a new udelay to make sure we
wait unconditionally some time after the write complete indication.

This caused a regression with XID 18000000 boards when the board specif=
ic
phy configuration writing many mdio registers was added in commit
2e955856ff (r8169: phy init for the 8169scd). Some of the configration
mdio writes would almost always fail, and depending on failure might le=
ave
the PHY in non-working state.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: fran=C3=A7ois romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..03a8318 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -559,6 +559,11 @@ static void mdio_write(void __iomem *ioaddr, int r=
eg_addr, int value)
 			break;
 		udelay(25);
 	}
+	/*
+	 * Some configurations require a small delay even after the write
+	 * completed indication or the next write might fail.
+	 */
+	udelay(25);
 }
=20
 static int mdio_read(void __iomem *ioaddr, int reg_addr)
--=20
1.7.0.4

