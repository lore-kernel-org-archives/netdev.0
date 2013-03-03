From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] ircomm: release tty before sleeping potentially indefintely
Date: Sun,  3 Mar 2013 17:35:53 -0500
Message-ID: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com>
Cc: davem@davemloft.net, gregkh@linuxfoundation.org, jslaby@suse.cz,
	peter@hurleysoftware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ircomm_tty_block_til_ready would hold tty lock while blocking. Since the sleep
might take a long time we can prevent other processes from accessing the tty,
causing hung tasks and a dead tty.

Diagnosed-by: Peter Hurley <peter@hurleysoftware.com>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/irda/ircomm/ircomm_tty.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 9a5fd3c..7844cb3 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -355,7 +355,9 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		IRDA_DEBUG(1, "%s(%d):block_til_ready blocking on %s open_count=%d\n",
 		      __FILE__, __LINE__, tty->driver->name, port->count);
 
+		tty_unlock(tty);
 		schedule();
+		tty_lock(tty);
 	}
 
 	__set_current_state(TASK_RUNNING);
-- 
1.8.1.4
