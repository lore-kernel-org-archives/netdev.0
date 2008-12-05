From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH 1/2] tty: Flags should be accessed via the foo_bit interfaces
Date: Fri, 05 Dec 2008 17:10:39 +0000
Message-ID: <20081205171036.3528.20768.stgit@localhost.localdomain>
References: <20081205170846.3528.67581.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:46237 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751869AbYLERK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 12:10:27 -0500
In-Reply-To: <20081205170846.3528.67581.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@redhat.com>

We have various drivers that poke around directly and we need to clean this
up before it causes problems.

Signed-off-by: Alan Cox <alan@redhat.com>
---

 drivers/net/irda/irtty-sir.c |    7 +++----
 drivers/net/slip.c           |   11 +++++------
 drivers/net/wan/x25_asy.c    |    8 ++++----
 drivers/net/wireless/strip.c |    8 +++-----
 4 files changed, 15 insertions(+), 19 deletions(-)


diff --git a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
index 6bcee01..d53aa95 100644
--- a/drivers/net/irda/irtty-sir.c
+++ b/drivers/net/irda/irtty-sir.c
@@ -191,7 +191,7 @@ static int irtty_do_write(struct sir_dev *dev, const unsigned char *ptr, size_t
 	tty = priv->tty;
 	if (!tty->ops->write)
 		return 0;
-	tty->flags |= (1 << TTY_DO_WRITE_WAKEUP);
+	set_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 	writelen = tty_write_room(tty);
 	if (writelen > len)
 		writelen = len;
@@ -263,8 +263,7 @@ static void irtty_write_wakeup(struct tty_struct *tty)
 	IRDA_ASSERT(priv != NULL, return;);
 	IRDA_ASSERT(priv->magic == IRTTY_MAGIC, return;);
 
-	tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
-
+	clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 	if (priv->dev)
 		sirdev_write_complete(priv->dev);
 }
@@ -522,7 +521,7 @@ static void irtty_close(struct tty_struct *tty)
 
 	/* Stop tty */
 	irtty_stop_receiver(tty, TRUE);
-	tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+	clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 	if (tty->ops->stop)
 		tty->ops->stop(tty);
 
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 1d58991..11bcbb8 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -402,7 +402,7 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 	 * if we did not request it before write operation.
 	 *       14 Oct 1994  Dmitry Gorodchanin.
 	 */
-	sl->tty->flags |= (1 << TTY_DO_WRITE_WAKEUP);
+	set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 	actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
 #ifdef SL_CHECK_TRANSMIT
 	sl->dev->trans_start = jiffies;
@@ -432,7 +432,7 @@ static void slip_write_wakeup(struct tty_struct *tty)
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
 		sl->tx_packets++;
-		tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		sl_unlock(sl);
 		return;
 	}
@@ -465,7 +465,7 @@ static void sl_tx_timeout(struct net_device *dev)
 			(tty_chars_in_buffer(sl->tty) || sl->xleft) ?
 				"bad line quality" : "driver error");
 		sl->xleft = 0;
-		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 		sl_unlock(sl);
 #endif
 	}
@@ -515,10 +515,9 @@ sl_close(struct net_device *dev)
 	struct slip *sl = netdev_priv(dev);
 
 	spin_lock_bh(&sl->lock);
-	if (sl->tty) {
+	if (sl->tty)
 		/* TTY discipline is running. */
-		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
-	}
+		clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 	netif_stop_queue(dev);
 	sl->rcount   = 0;
 	sl->xleft    = 0;
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 2a6c7a6..e188699 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -243,7 +243,7 @@ static void x25_asy_encaps(struct x25_asy *sl, unsigned char *icp, int len)
 	 * if we did not request it before write operation.
 	 *       14 Oct 1994  Dmitry Gorodchanin.
 	 */
-	sl->tty->flags |= (1 << TTY_DO_WRITE_WAKEUP);
+	set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 	actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
 	sl->xleft = count - actual;
 	sl->xhead = sl->xbuff + actual;
@@ -268,7 +268,7 @@ static void x25_asy_write_wakeup(struct tty_struct *tty)
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
 		sl->stats.tx_packets++;
-		tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		x25_asy_unlock(sl);
 		return;
 	}
@@ -291,7 +291,7 @@ static void x25_asy_timeout(struct net_device *dev)
 		       (tty_chars_in_buffer(sl->tty) || sl->xleft) ?
 		       "bad line quality" : "driver error");
 		sl->xleft = 0;
-		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 		x25_asy_unlock(sl);
 	}
 	spin_unlock(&sl->lock);
@@ -504,7 +504,7 @@ static int x25_asy_close(struct net_device *dev)
 
 	spin_lock(&sl->lock);
 	if (sl->tty)
-		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 
 	netif_stop_queue(dev);
 	sl->rcount = 0;
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 417e9e6..35442b1 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1252,7 +1252,7 @@ static void strip_write_some_more(struct tty_struct *tty)
 #endif
 	} else {		/* Else start transmission of another packet */
 
-		tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		strip_unlock(strip_info);
 	}
 }
@@ -1455,8 +1455,7 @@ static void strip_send(struct strip *strip_info, struct sk_buff *skb)
 	 */
 	strip_info->tx_head = strip_info->tx_buff;
 	strip_info->tx_left = ptr - strip_info->tx_buff;
-	strip_info->tty->flags |= (1 << TTY_DO_WRITE_WAKEUP);
-
+	set_bit(TTY_DO_WRITE_WAKEUP, &strip_info->tty->flags);
 	/*
 	 * 4. Debugging check to make sure we're not overflowing the buffer.
 	 */
@@ -2455,8 +2454,7 @@ static int strip_close_low(struct net_device *dev)
 
 	if (strip_info->tty == NULL)
 		return -EBUSY;
-	strip_info->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
-
+	clear_bit(TTY_DO_WRITE_WAKEUP, &strip_info->tty->flags);
 	netif_stop_queue(dev);
 
 	/*

