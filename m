From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] net: ipconfig: Fix NULL pointer dereference on RARP/BOOTP/DHCP timeout
Date: Mon, 22 Aug 2016 15:01:03 +0200
Message-ID: <1471870863-29687-1-git-send-email-geert+renesas@glider.be>
Cc: Thierry Reding <treding@nvidia.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If no RARP, BOOTP, or DHCP response is received, ic_dev is never set,
causing a NULL pointer dereference in ic_close_devs():

    Sending DHCP requests ...... timed out!
    Unable to handle kernel NULL pointer dereference at virtual address 00000004

To fix this, add a check to avoid dereferencing ic_dev if it is still
NULL.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Fixes: 2647cffb2bc6fbed ("net: ipconfig: Support using "delayed" DHCP replies")
---
 net/ipv4/ipconfig.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ba9cbeafbb2e0817..071a785c65eb7ab5 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -306,7 +306,7 @@ static void __init ic_close_devs(void)
 	while ((d = next)) {
 		next = d->next;
 		dev = d->dev;
-		if (dev != ic_dev->dev && !netdev_uses_dsa(dev)) {
+		if ((!ic_dev || dev != ic_dev->dev) && !netdev_uses_dsa(dev)) {
 			pr_debug("IP-Config: Downing %s\n", dev->name);
 			dev_change_flags(dev, d->flags);
 		}
-- 
1.9.1
