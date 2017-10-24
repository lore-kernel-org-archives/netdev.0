From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: wan/sbni: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:47:00 -0700
Message-ID: <20171024084700.GA24005@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:47585 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932396AbdJXIrD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:47:03 -0400
Received: by mail-pf0-f194.google.com with SMTP id z11so19169740pfk.4
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 01:47:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wan/sbni.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index bde8c0339831..8e8c4c0e1b64 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -71,6 +71,7 @@
 
 struct net_local {
 	struct timer_list	watchdog;
+	struct net_device	*watchdog_dev;
 
 	spinlock_t	lock;
 	struct sk_buff  *rx_buf_p;		/* receive buffer ptr */
@@ -128,7 +129,7 @@ static void  send_frame( struct net_device * );
 static int   upload_data( struct net_device *,
 			  unsigned, unsigned, unsigned, u32 );
 static void  download_data( struct net_device *, u32 * );
-static void  sbni_watchdog( unsigned long );
+static void  sbni_watchdog(struct timer_list *);
 static void  interpret_ack( struct net_device *, unsigned );
 static int   append_frame_to_pkt( struct net_device *, unsigned, u32 );
 static void  indicate_pkt( struct net_device * );
@@ -1029,11 +1030,10 @@ indicate_pkt( struct net_device  *dev )
  */
 
 static void
-sbni_watchdog( unsigned long  arg )
+sbni_watchdog(struct timer_list *t)
 {
-	struct net_device  *dev = (struct net_device *) arg;
-	struct net_local   *nl  = netdev_priv(dev);
-	struct timer_list  *w   = &nl->watchdog; 
+	struct net_local   *nl  = from_timer(nl, t, watchdog);
+	struct net_device  *dev = nl->watchdog_dev;
 	unsigned long	   flags;
 	unsigned char	   csr0;
 
@@ -1060,11 +1060,7 @@ sbni_watchdog( unsigned long  arg )
 
 	outb( csr0 | RC_CHK, dev->base_addr + CSR0 ); 
 
-	init_timer( w );
-	w->expires	= jiffies + SBNI_TIMEOUT;
-	w->data		= arg;
-	w->function	= sbni_watchdog;
-	add_timer( w );
+	mod_timer(t, jiffies + SBNI_TIMEOUT);
 
 	spin_unlock_irqrestore( &nl->lock, flags );
 }
@@ -1195,10 +1191,9 @@ sbni_open( struct net_device  *dev )
 	netif_start_queue( dev );
 
 	/* set timer watchdog */
-	init_timer( w );
+	nl->watchdog_dev = dev;
+	timer_setup(w, sbni_watchdog, 0);
 	w->expires	= jiffies + SBNI_TIMEOUT;
-	w->data		= (unsigned long) dev;
-	w->function	= sbni_watchdog;
 	add_timer( w );
    
 	spin_unlock( &nl->lock );
-- 
2.7.4


-- 
Kees Cook
Pixel Security
