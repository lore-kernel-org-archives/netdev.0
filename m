From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: simplify napi_synchronize() to avoid warnings
Date: Fri, 22 Jan 2016 11:43:44 +0100
Message-ID: <2817787.9jKELuxj8h@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:54598 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbcAVKoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 05:44:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The napi_synchronize() function is defined twice: The definition
for SMP builds waits for other CPUs to be done, while the uniprocessor
variant just contains a barrier and ignores its argument.

In the mvneta driver, this leads to a warning about an unused variable
when we lookup the NAPI struct of another CPU and then don't use it:

ethernet/marvell/mvneta.c: In function 'mvneta_percpu_notifier':
ethernet/marvell/mvneta.c:2910:30: error: unused variable 'other_port' [-Werror=unused-variable]

There are no other CPUs on a UP build, so that code never runs, but
gcc does not know this.

The nicest solution seems to be to turn the napi_synchronize() helper
into an inline function for the UP case as well, as that leads gcc to
not complain about the argument being unused. Once we do that, we can
also combine the two cases into a single function definition and use
if(IS_ENABLED()) rather than #ifdef to make it look a bit nicer.

The warning first came up in linux-4.4, but I failed to catch it
earlier.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f86428854480 ("net: mvneta: Statically assign queues to CPUs")

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5ac140dcb789..289c2314d766 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -512,7 +512,6 @@ static inline void napi_enable(struct napi_struct *n)
 	clear_bit(NAPI_STATE_NPSVC, &n->state);
 }
 
-#ifdef CONFIG_SMP
 /**
  *	napi_synchronize - wait until NAPI is not running
  *	@n: napi context
@@ -523,12 +522,12 @@ static inline void napi_enable(struct napi_struct *n)
  */
 static inline void napi_synchronize(const struct napi_struct *n)
 {
-	while (test_bit(NAPI_STATE_SCHED, &n->state))
-		msleep(1);
+	if (IS_ENABLED(CONFIG_SMP))
+		while (test_bit(NAPI_STATE_SCHED, &n->state))
+			msleep(1);
+	else
+		barrier();
 }
-#else
-# define napi_synchronize(n)	barrier()
-#endif
 
 enum netdev_queue_state_t {
 	__QUEUE_STATE_DRV_XOFF,
