From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: wan/sdla: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:53:59 -0700
Message-ID: <20171025105359.GA146645@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allen Pais <allen.lkml@gmail.com>,
        Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:44950 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932422AbdJYKyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 06:54:02 -0400
Received: by mail-pg0-f68.google.com with SMTP id j3so17020276pga.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 03:54:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Allen Pais <allen.lkml@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wan/sdla.c  | 12 +++++-------
 include/linux/if_frad.h |  1 +
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 0cc48902dbb9..57ed259c8208 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -927,13 +927,10 @@ static irqreturn_t sdla_isr(int dummy, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void sdla_poll(unsigned long device)
+static void sdla_poll(struct timer_list *t)
 {
-	struct net_device	  *dev;
-	struct frad_local *flp;
-
-	dev = (struct net_device *) device;
-	flp = netdev_priv(dev);
+	struct frad_local *flp = from_timer(flp, t, timer);
+	struct net_device *dev = flp->dev;
 
 	if (sdla_byte(dev, SDLA_502_RCV_BUF))
 		sdla_receive(dev);
@@ -1616,8 +1613,9 @@ static void setup_sdla(struct net_device *dev)
 	flp->assoc		= sdla_assoc;
 	flp->deassoc		= sdla_deassoc;
 	flp->dlci_conf		= sdla_dlci_conf;
+	flp->dev		= dev;
 
-	setup_timer(&flp->timer, sdla_poll, (unsigned long)dev);
+	timer_setup(&flp->timer, sdla_poll, 0);
 	flp->timer.expires	= 1;
 }
 
diff --git a/include/linux/if_frad.h b/include/linux/if_frad.h
index 46df7e565d6f..82a1b4e93570 100644
--- a/include/linux/if_frad.h
+++ b/include/linux/if_frad.h
@@ -83,6 +83,7 @@ struct frad_local
 
    /* fields that are used by the Sangoma SDLA cards */
    struct timer_list timer;
+   struct net_device *dev;
    int               type;		/* adapter type */
    int               state;		/* state of the S502/8 control latch */
    int               buffer;		/* current buffer for S508 firmware */
-- 
2.7.4


-- 
Kees Cook
Pixel Security
