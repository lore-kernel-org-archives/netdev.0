From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 8/9] net: nb8800: avoid uninitialized variable warning
Date: Wed, 27 Jan 2016 15:04:58 +0100
Message-ID: <1453903507-3427225-9-git-send-email-arnd@arndb.de>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	=?UTF-8?q?M=C3=A5ns=20Rullg=C3=A5rd?= <mans@mansr.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nb8800_poll() function initializes the 'next' variable in the
loop looking for new input data. We know this will be called at
least once because 'budget' is a guaranteed to be a positive number
when we enter the function, but the compiler doesn't know that
and warns when the variable is used later:

drivers/net/ethernet/aurora/nb8800.c: In function 'nb8800_poll':
drivers/net/ethernet/aurora/nb8800.c:350:21: warning: 'next' may be used uninitialized in this function [-Wmaybe-uninitialized]

Changing the 'while() {}' loop to 'do {} while()' makes it obvious
to the compiler what is going on so it no longer warns.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/aurora/nb8800.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index ecc4a334c507..f71ab2647a3b 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -302,7 +302,7 @@ static int nb8800_poll(struct napi_struct *napi, int budget)
 	nb8800_tx_done(dev);
 
 again:
-	while (work < budget) {
+	do {
 		struct nb8800_rx_buf *rxb;
 		unsigned int len;
 
@@ -330,7 +330,7 @@ again:
 		rxd->report = 0;
 		last = next;
 		work++;
-	}
+	} while (work < budget);
 
 	if (work) {
 		priv->rx_descs[last].desc.config |= DESC_EOC;
-- 
2.7.0
