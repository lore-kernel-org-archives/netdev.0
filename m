From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] smc91x: avoid self-comparison warning
Date: Mon, 14 Mar 2016 23:45:12 +0100
Message-ID: <1457995535-1398186-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Jarzmik <robert.jarzmik@free.fr>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The smc91x driver defines a macro that compares its argument to
itself, apparently to get a true result while using its argument
to avoid a warning about unused local variables.

Unfortunately, this triggers a warning with gcc-6, as the comparison
is obviously useless:

drivers/net/ethernet/smsc/smc91x.c: In function 'smc_hardware_send_pkt':
drivers/net/ethernet/smsc/smc91x.c:563:14: error: self-comparison always evaluates to true [-Werror=tautological-compare]
  if (!smc_special_trylock(&lp->lock, flags)) {

This replaces the macro with another one that behaves similarly,
with a cast to (void) to ensure the argument is used, and using
a literal 'true' as its value.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/smsc/smc91x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index db7db8ac4ca3..c5ed27c54724 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -540,7 +540,7 @@ static inline void  smc_rcv(struct net_device *dev)
 #define smc_special_lock(lock, flags)		spin_lock_irqsave(lock, flags)
 #define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
 #else
-#define smc_special_trylock(lock, flags)	(flags == flags)
+#define smc_special_trylock(lock, flags)	((void)flags, true)
 #define smc_special_lock(lock, flags)   	do { flags = 0; } while (0)
 #define smc_special_unlock(lock, flags)	do { flags = 0; } while (0)
 #endif
-- 
2.7.0
