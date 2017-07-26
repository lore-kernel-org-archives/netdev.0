From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] hamradio: dmascc: avoid -Wformat-overflow warning
Date: Wed, 26 Jul 2017 09:55:33 +0200
Message-ID: <20170726075548.2736340-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, David Howells <dhowells@redhat.com>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joerg Reuter <jreuter@yaina.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc warns that the device name might overflow:

drivers/net/hamradio/dmascc.c: In function 'dmascc_init':
drivers/net/hamradio/dmascc.c:584:22: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
   sprintf(dev->name, "dmascc%i", 2 * n + i);
drivers/net/hamradio/dmascc.c:584:3: note: 'sprintf' output between 8 and 17 bytes into a destination of size 16
   sprintf(dev->name, "dmascc%i", 2 * n + i);

>From the static data in this file, I can tell that the index is
strictly limited to 16, so it won't overflow. This simply changes
the sprintf() to snprintf(), which is a good idea in general,
and shuts up this warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I ran into this for the first time today on linux-next randconfig
builds, but couldn't find an obvious commit that introduced it.

I guess it's just a very rare randconfig warning, so this can go
into net-next rather than net fixes.
---
 drivers/net/hamradio/dmascc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index dec6b76bc0fb..cde41200f40a 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -581,7 +581,7 @@ static int __init setup_adapter(int card_base, int type, int n)
 		priv->param.dma = -1;
 		INIT_WORK(&priv->rx_work, rx_bh);
 		dev->ml_priv = priv;
-		sprintf(dev->name, "dmascc%i", 2 * n + i);
+		snprintf(dev->name, sizeof(dev->name), "dmascc%i", 2 * n + i);
 		dev->base_addr = card_base;
 		dev->irq = irq;
 		dev->netdev_ops = &scc_netdev_ops;
-- 
2.9.0
