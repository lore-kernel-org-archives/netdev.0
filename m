From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 47/58] net/ethernet/sgi: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:31 -0700
Message-ID: <1508200182-104605-48-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/sgi/ioc3-eth.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 9c0488e0f08e..18d533fdf14c 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -764,9 +764,9 @@ static inline void ioc3_setup_duplex(struct ioc3_private *ip)
 	ioc3_w_emcr(ip->emcr);
 }
 
-static void ioc3_timer(unsigned long data)
+static void ioc3_timer(struct timer_list *t)
 {
-	struct ioc3_private *ip = (struct ioc3_private *) data;
+	struct ioc3_private *ip = from_timer(ip, t, ioc3_timer);
 
 	/* Print the link status if it has changed */
 	mii_check_media(&ip->mii, 1, 0);
@@ -818,8 +818,6 @@ static int ioc3_mii_init(struct ioc3_private *ip)
 static void ioc3_mii_start(struct ioc3_private *ip)
 {
 	ip->ioc3_timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
-	ip->ioc3_timer.data = (unsigned long) ip;
-	ip->ioc3_timer.function = ioc3_timer;
 	add_timer(&ip->ioc3_timer);
 }
 
@@ -1291,7 +1289,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 
 	spin_lock_init(&ip->ioc3_lock);
-	init_timer(&ip->ioc3_timer);
+	timer_setup(&ip->ioc3_timer, ioc3_timer, 0);
 
 	ioc3_stop(ip);
 	ioc3_init(dev);
-- 
2.7.4
