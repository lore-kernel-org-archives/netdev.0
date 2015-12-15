From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 2/4] ser_gigaset: turn nonsense checks into WARN_ON
Date: Tue, 15 Dec 2015 18:11:29 +0100
Message-ID: <1450199491-30471-3-git-send-email-pebolle@tiscali.nl>
References: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Cc: Tilman Schmidt <tilman@imap.cc>, Alan Cox <alan@linux.intel.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Peter Hurley <peter@hurleysoftware.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@linux.intel.com>

These checks do nothing useful to protect the code from races. On the
other hand if the old code has been masking a real bug we would like to
know about it.

The check for tiocmset is kept because it is valid for a tty driver to
have a NULL tiocmset method. That in itself is probably a mistake given
modern coding practices - but needs fixing in the tty layer.

Signed-off-by: Alan Cox <alan@linux.intel.com>
Acked-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/isdn/gigaset/ser-gigaset.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index d8771b5d6904..8e21f6afa832 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -67,8 +67,7 @@ static int write_modem(struct cardstate *cs)
 	struct sk_buff *skb = bcs->tx_skb;
 	int sent = -EOPNOTSUPP;
 
-	if (!tty || !tty->ops || !skb)
-		return -EINVAL;
+	WARN_ON(!tty || !tty->ops || !skb);
 
 	if (!skb->len) {
 		dev_kfree_skb_any(skb);
@@ -109,8 +108,7 @@ static int send_cb(struct cardstate *cs)
 	unsigned long flags;
 	int sent = 0;
 
-	if (!tty || !tty->ops)
-		return -EFAULT;
+	WARN_ON(!tty || !tty->ops);
 
 	cb = cs->cmdbuf;
 	if (!cb)
@@ -432,7 +430,9 @@ static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
 	struct tty_struct *tty = cs->hw.ser->tty;
 	unsigned int set, clear;
 
-	if (!tty || !tty->ops || !tty->ops->tiocmset)
+	WARN_ON(!tty || !tty->ops);
+	/* tiocmset is an optional tty driver method */
+	if (!tty->ops->tiocmset)
 		return -EINVAL;
 	set = new_state & ~old_state;
 	clear = old_state & ~new_state;
-- 
2.4.3
