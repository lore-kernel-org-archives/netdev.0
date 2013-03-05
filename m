From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 2/4] net/irda: Hold port lock while bumping blocked_open
Date: Tue,  5 Mar 2013 11:09:05 -0500
Message-ID: <1362499747-4262-3-git-send-email-peter@hurleysoftware.com>
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

Although tty_lock() already protects concurrent update to
blocked_open, that fails to meet the separation-of-concerns between
tty_port and tty.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 net/irda/ircomm/ircomm_tty.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 1721dc7..d282bbe 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -317,8 +317,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	spin_lock_irqsave(&port->lock, flags);
 	if (!tty_hung_up_p(filp))
 		port->count--;
-	spin_unlock_irqrestore(&port->lock, flags);
 	port->blocked_open++;
+	spin_unlock_irqrestore(&port->lock, flags);
 
 	while (1) {
 		if (tty->termios.c_cflag & CBAUD)
@@ -362,8 +362,8 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 	spin_lock_irqsave(&port->lock, flags);
 	if (!tty_hung_up_p(filp))
 		port->count++;
-	spin_unlock_irqrestore(&port->lock, flags);
 	port->blocked_open--;
+	spin_unlock_irqrestore(&port->lock, flags);
 
 	IRDA_DEBUG(1, "%s(%d):block_til_ready after blocking on %s open_count=%d\n",
 	      __FILE__, __LINE__, tty->driver->name, port->count);
-- 
1.8.1.2
