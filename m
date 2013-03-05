From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 1/4] net/irda: Fix port open counts
Date: Tue,  5 Mar 2013 11:09:04 -0500
Message-ID: <1362499747-4262-2-git-send-email-peter@hurleysoftware.com>
References: <1362371063.3221.185.camel@thor.lan>
 <1362499747-4262-1-git-send-email-peter@hurleysoftware.com>
Cc: Sasha Levin <sasha.levin@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	linux-kernel@vger.kernel.org,
	Peter Hurley <peter@hurleysoftware.com>
To: David Miller <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362499747-4262-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Saving the port count bump is unsafe. If the tty is hung up while
this open was blocking, the port count is zeroed.

Explicitly check if the tty was hung up while blocking, and correct
the port count if not.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 net/irda/ircomm/ircomm_tty.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 9a5fd3c..1721dc7 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -280,7 +280,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	struct tty_port *port = &self->port;
 	DECLARE_WAITQUEUE(wait, current);
 	int		retval;
-	int		do_clocal = 0, extra_count = 0;
+	int		do_clocal = 0;
 	unsigned long	flags;
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
@@ -315,10 +315,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	      __FILE__, __LINE__, tty->driver->name, port->count);
 
 	spin_lock_irqsave(&port->lock, flags);
-	if (!tty_hung_up_p(filp)) {
-		extra_count = 1;
+	if (!tty_hung_up_p(filp))
 		port->count--;
-	}
 	spin_unlock_irqrestore(&port->lock, flags);
 	port->blocked_open++;
 
@@ -361,12 +359,10 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(&port->open_wait, &wait);
 
-	if (extra_count) {
-		/* ++ is not atomic, so this should be protected - Jean II */
-		spin_lock_irqsave(&port->lock, flags);
+	spin_lock_irqsave(&port->lock, flags);
+	if (!tty_hung_up_p(filp))
 		port->count++;
-		spin_unlock_irqrestore(&port->lock, flags);
-	}
+	spin_unlock_irqrestore(&port->lock, flags);
 	port->blocked_open--;
 
 	IRDA_DEBUG(1, "%s(%d):block_til_ready after blocking on %s open_count=%d\n",
-- 
1.8.1.2
