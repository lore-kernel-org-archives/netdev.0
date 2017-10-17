From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 56/58] um: net: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:40 -0700
Message-ID: <1508200182-104605-57-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Jeff Dike <jdike@addtoit.com>,
        Richard Weinberger <richard@nod.at>,
        Jarod Wilson <jarod@redhat.com>,
        user-mode-linux-devel@lists.sourceforge.net,
        user-mode-linux-user@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. (Note that this timer is actually
disabled.)

Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: user-mode-linux-devel@lists.sourceforge.net
Cc: user-mode-linux-user@lists.sourceforge.net
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/um/drivers/net_kern.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 1669240c7a25..b305f8247909 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -168,7 +168,6 @@ static int uml_net_open(struct net_device *dev)
 		goto out_close;
 	}
 
-	lp->tl.data = (unsigned long) &lp->user;
 	netif_start_queue(dev);
 
 	/* clear buffer - it can happen that the host side of the interface
@@ -278,10 +277,11 @@ static const struct ethtool_ops uml_net_ethtool_ops = {
 	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
-static void uml_net_user_timer_expire(unsigned long _conn)
+static void uml_net_user_timer_expire(struct timer_list *t)
 {
 #ifdef undef
-	struct connection *conn = (struct connection *)_conn;
+	struct uml_net_private *lp = from_timer(lp, t, tl);
+	struct connection *conn = &lp->user;
 
 	dprintk(KERN_INFO "uml_net_user_timer_expire [%p]\n", conn);
 	do_connect(conn);
@@ -458,9 +458,8 @@ static void eth_configure(int n, void *init, char *mac,
 		  .add_address 		= transport->user->add_address,
 		  .delete_address  	= transport->user->delete_address });
 
-	init_timer(&lp->tl);
+	timer_setup(&lp->tl, uml_net_user_timer_expire, 0);
 	spin_lock_init(&lp->lock);
-	lp->tl.function = uml_net_user_timer_expire;
 	memcpy(lp->mac, dev->dev_addr, sizeof(lp->mac));
 
 	if ((transport->user->init != NULL) &&
-- 
2.7.4
