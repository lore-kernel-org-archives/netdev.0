From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) baycom/hdlcdrv unregister
Date: Fri, 19 Sep 2003 13:38:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919133804.5ac0fc22.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Sailer <t.sailer@alumni.ethz.ch>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If baycom driver has never been opened, it will attempt to free
an IRQ that it never registered when removed.  The problem is that hdlcdrv
does not keep track of open/close state.

diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	Fri Sep 19 13:16:29 2003
+++ b/drivers/net/hamradio/hdlcdrv.c	Fri Sep 19 13:16:29 2003
@@ -554,6 +554,7 @@
 	/*
 	 * initialise some variables
 	 */
+	s->opened = 1;
 	s->hdlcrx.hbuf.rd = s->hdlcrx.hbuf.wr = 0;
 	s->hdlcrx.in_hdlc_rx = 0;
 	s->hdlcrx.rx_state = 0;
@@ -593,6 +594,7 @@
 	if (s->skb)
 		dev_kfree_skb(s->skb);
 	s->skb = NULL;
+	s->opened = 0;
 	return i;
 }
 
@@ -845,7 +847,7 @@
 
 	BUG_ON(s->magic != HDLCDRV_MAGIC);
 
-	if (s->ops->close)
+	if (s->opened && s->ops->close)
 		s->ops->close(dev);
 	unregister_netdev(dev);
 	
diff -Nru a/include/linux/hdlcdrv.h b/include/linux/hdlcdrv.h
--- a/include/linux/hdlcdrv.h	Fri Sep 19 13:16:29 2003
+++ b/include/linux/hdlcdrv.h	Fri Sep 19 13:16:29 2003
@@ -180,6 +180,7 @@
 
 struct hdlcdrv_state {
 	int magic;
+	int opened;
 
 	const struct hdlcdrv_ops *ops;
 
