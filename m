From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 3/4] net/irda: Use barrier to set task state
Date: Tue,  5 Mar 2013 11:09:06 -0500
Message-ID: <1362499747-4262-4-git-send-email-peter@hurleysoftware.com>
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

Without a memory and compiler barrier, the task state change
can migrate relative to the condition testing in a blocking loop.
However, the task state change must be visible across all cpus
prior to testing those conditions. Failing to do this can result
in the familiar 'lost wakeup' and this task will hang until killed.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 net/irda/ircomm/ircomm_tty.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index d282bbe..522543d 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -324,7 +324,7 @@ static int ircomm_tty_block_til_ready(struct ircomm_tty_cb *self,
 		if (tty->termios.c_cflag & CBAUD)
 			tty_port_raise_dtr_rts(port);
 
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 
 		if (tty_hung_up_p(filp) ||
 		    !test_bit(ASYNCB_INITIALIZED, &port->flags)) {
-- 
1.8.1.2
