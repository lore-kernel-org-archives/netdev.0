From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 6/7] net: nb8800: avoid uninitialized variable warning
Date: Fri, 29 Jan 2016 12:39:14 +0100
Message-ID: <1454067557-3546883-7-git-send-email-arnd@arndb.de>
References: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	=?UTF-8?q?M=C3=A5ns=20Rullg=C3=A5rd?= <mans@mansr.com>,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:54047 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358AbcA2LlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 06:41:17 -0500
In-Reply-To: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Acked-by: Mans Rullgard <mans@mansr.com>
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
