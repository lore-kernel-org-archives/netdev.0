From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - drivers/net/hamradio remove local random function,
	use random32()
Date: Fri, 16 Feb 2007 09:42:31 -0800
Message-ID: <1171647751.1405.23.camel@localhost>
References: <1171596978.29021.64.camel@localhost>
	 <1171623031.3139.56.camel@playstation2.hb9jnx.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org, jpr@f6fbb.org
To: Thomas Sailer <t.sailer@alumni.ethz.ch>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1171623031.3139.56.camel@playstation2.hb9jnx.ampr.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-16 at 11:50 +0100, Thomas Sailer wrote:
> On Thu, 2007-02-15 at 19:36 -0800, Joe Perches wrote:
> > remove local random function, use random32() instead
> > > Signed-off-by: Joe Perches <joe@perches.com>
> Acked-By: Thomas Sailer <t.sailer@alumni.ethz.ch>
> 
> There are a bunch of other drivers with their homegrown random number
> function, namely 6pack.c dmascc.c hdlcdrv.c yam.c.
> 
> Can you do a patch for those too?

hamradio files with random functions converted to random32()

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 760d04a..01c5e1d 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -24,6 +24,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/timer.h>
+#include <linux/random.h>
 #include <net/ax25.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -142,11 +143,9 @@ static void sp_xmit_on_air(unsigned long channel)
 {
 	struct sixpack *sp = (struct sixpack *) channel;
 	int actual, when = sp->slottime;
-	static unsigned char random;
 
-	random = random * 17 + 41;
-
-	if (((sp->status1 & SIXP_DCD_MASK) == 0) && (random < sp->persistence)) {
+	if (((sp->status1 & SIXP_DCD_MASK) == 0)
+	    && ((unsigned char)random32() < sp->persistence)) {
 		sp->led_state = 0x70;
 		sp->tty->driver->write(sp->tty, &sp->led_state, 1);
 		sp->tx_enable = 1;
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 153b6dc..84aa211 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -52,6 +52,7 @@
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
 #include <linux/jiffies.h>
+#include <linux/random.h>
 #include <net/ax25.h> 
 #include <asm/uaccess.h>
 
@@ -433,16 +434,6 @@ static void encode_hdlc(struct baycom_state *bc)
 
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
 static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 {
 	struct parport *pp = bc->pdev->port;
@@ -464,7 +455,7 @@ static int transmit(struct baycom_state *bc, int cnt, unsigned char stat)
 			if ((--bc->hdlctx.slotcnt) > 0)
 				return 0;
 			bc->hdlctx.slotcnt = bc->ch_params.slottime;
-			if ((random_num() % 256) > bc->ch_params.ppersist)
+			if ((random32() % 256) > bc->ch_params.ppersist)
 				return 0;
 		}
 	}
diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index 0fbb414..0526a22 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -34,6 +34,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/sockios.h>
 #include <linux/workqueue.h>
+#include <linux/random.h>
 #include <asm/atomic.h>
 #include <asm/bitops.h>
 #include <asm/dma.h>
@@ -246,7 +247,6 @@ static inline void tx_on(struct scc_priv *priv);
 static inline void rx_on(struct scc_priv *priv);
 static inline void rx_off(struct scc_priv *priv);
 static void start_timer(struct scc_priv *priv, int t, int r15);
-static inline unsigned char random(void);
 
 static inline void z8530_isr(struct scc_info *info);
 static irqreturn_t scc_isr(int irq, void *dev_id);
@@ -269,7 +269,6 @@ static struct scc_hardware hw[NUM_TYPES] __initdata_or_module = HARDWARE;
 /* Global variables */
 
 static struct scc_info *first;
-static unsigned long rand;
 
 
 MODULE_AUTHOR("Klaus Kudielka");
@@ -314,8 +313,6 @@ static int __init dmascc_init(void)
 	unsigned long time, start[MAX_NUM_DEVS], delay[MAX_NUM_DEVS],
 	    counting[MAX_NUM_DEVS];
 
-	/* Initialize random number generator */
-	rand = jiffies;
 	/* Cards found = 0 */
 	n = 0;
 	/* Warning message */
@@ -1099,13 +1096,6 @@ static void start_timer(struct scc_priv *priv, int t, int r15)
 }
 
 
-static inline unsigned char random(void)
-{
-	/* See "Numerical Recipes in C", second edition, p. 284 */
-	rand = rand * 1664525L + 1013904223L;
-	return (unsigned char) (rand >> 24);
-}
-
 static inline void z8530_isr(struct scc_info *info)
 {
 	int is, i = 100;
@@ -1466,7 +1456,8 @@ static void tm_isr(struct scc_priv *priv)
 		} else {
 			priv->state = WAIT;
 			start_timer(priv,
-				    random() / priv->param.persist *
+				    (unsigned char)random32() /
+				    priv->param.persist *
 				    priv->param.slottime, DCDIE);
 		}
 		break;
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index 452873e..f5a17ad 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -56,6 +56,7 @@
 #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <linux/hdlcdrv.h>
+#include <linux/random.h>
 #include <net/ax25.h> 
 #include <asm/uaccess.h>
 
@@ -371,16 +372,6 @@ static void start_tx(struct net_device *dev, struct hdlcdrv_state *s)
 
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
 	if (!s || s->magic != HDLCDRV_MAGIC || s->hdlctx.ptt || !s->skb) 
@@ -396,7 +387,7 @@ void hdlcdrv_arbitrate(struct net_device *dev, struct hdlcdrv_state *s)
 	if ((--s->hdlctx.slotcnt) > 0)
 		return;
 	s->hdlctx.slotcnt = s->ch_params.slottime;
-	if ((random_num() % 256) > s->ch_params.ppersist)
+	if ((random32() % 256) > s->ch_params.ppersist)
 		return;
 	start_tx(dev, s);
 }
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 6d74f08..efc0bcd 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -50,6 +50,7 @@
 #include <linux/slab.h>
 #include <linux/errno.h>
 #include <linux/bitops.h>
+#include <linux/random.h>
 #include <asm/io.h>
 #include <asm/system.h>
 #include <linux/interrupt.h>
@@ -566,14 +567,6 @@ static void yam_start_tx(struct net_device *dev, struct yam_port *yp)
 	ptt_on(dev);
 }
 
-static unsigned short random_seed;
-
-static inline unsigned short random_num(void)
-{
-	random_seed = 28629 * random_seed + 157;
-	return random_seed;
-}
-
 static void yam_arbitrate(struct net_device *dev)
 {
 	struct yam_port *yp = netdev_priv(dev);
@@ -600,7 +593,7 @@ static void yam_arbitrate(struct net_device *dev)
 	yp->slotcnt = yp->slot / 10;
 
 	/* is random > persist ? */
-	if ((random_num() % 256) > yp->pers)
+	if ((random32() % 256) > yp->pers)
 		return;
 
 	yam_start_tx(dev, yp);



