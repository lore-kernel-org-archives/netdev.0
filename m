From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) use system get_random_bytes in hdlcdrv
Date: Fri, 19 Sep 2003 13:38:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919133809.5390e8cb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Sailer <t.sailer@alumni.ethz.ch>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Real random numbers aren't important here, but having custom
random number generate seems silly when linux kernel has good
way to get random data.

diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	Fri Sep 19 13:18:58 2003
+++ b/drivers/net/hamradio/hdlcdrv.c	Fri Sep 19 13:18:58 2003
@@ -52,6 +52,7 @@
 #include <linux/slab.h>
 #include <linux/errno.h>
 #include <linux/init.h>
+#include <linux/random.h>
 #include <asm/bitops.h>
 #include <asm/uaccess.h>
 
@@ -434,18 +435,10 @@
 
 /* ---------------------------------------------------------------------- */
 
-static unsigned short random_seed;
-
-static inline unsigned short random_num(void)
-{
-	random_seed = 28629 * random_seed + 157;
-	return random_seed;
-}
-
-/* ---------------------------------------------------------------------- */
-
 void hdlcdrv_arbitrate(struct net_device *dev, struct hdlcdrv_state *s)
 {
+	u8 prand;
+
 	if (!s || s->magic != HDLCDRV_MAGIC || s->hdlctx.ptt || !s->skb) 
 		return;
 	if (s->ch_params.fulldup) {
@@ -459,7 +452,9 @@
 	if ((--s->hdlctx.slotcnt) > 0)
 		return;
 	s->hdlctx.slotcnt = s->ch_params.slottime;
-	if ((random_num() % 256) > s->ch_params.ppersist)
+
+	get_random_bytes(&prand, sizeof(prand));
+	if (prand > s->ch_params.ppersist)
 		return;
 	start_tx(dev, s);
 }
