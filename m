From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 6/7] tty: r3964: Replace/remove bogus tty lock use
Date: Sat, 10 Oct 2015 16:00:56 -0400
Message-ID: <1444507257-7513-7-git-send-email-peter@hurleysoftware.com>
References: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Alan Cox <alan@linux.intel.com>,
	David Laight <David.Laight@aculab.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tty lock is strictly for serializing tty lifetime events
(open/close/hangup), and not for line discipline serialization.

The tty core already provides serialization of concurrent writes
to the same tty, and line discipline lifetime management (by ldisc
references), so pinning the tty via tty_lock() is unnecessary and
counter-productive; remove tty lock use.

However, the line discipline is responsible for serializing reads
(if required by the line discipline); add read_lock mutex to
serialize calls of r3964_read().

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/tty/n_r3964.c   | 20 +++++++++++++-------
 include/linux/n_r3964.h |  5 +++--
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/tty/n_r3964.c b/drivers/tty/n_r3964.c
index 6fdef92..3451114 100644
--- a/drivers/tty/n_r3964.c
+++ b/drivers/tty/n_r3964.c
@@ -978,6 +978,7 @@ static int r3964_open(struct tty_struct *tty)
 	}
 
 	spin_lock_init(&pInfo->lock);
+	mutex_init(&pInfo->read_lock);
 	pInfo->tty = tty;
 	pInfo->priority = R3964_MASTER;
 	pInfo->rx_first = pInfo->rx_last = NULL;
@@ -1063,7 +1064,16 @@ static ssize_t r3964_read(struct tty_struct *tty, struct file *file,
 
 	TRACE_L("read()");
 
-	tty_lock(tty);
+	/*
+	 *	Internal serialization of reads.
+	 */
+	if (file->f_flags & O_NONBLOCK) {
+		if (!mutex_trylock(&pInfo->read_lock))
+			return -EAGAIN;
+	} else {
+		if (mutex_lock_interruptible(&pInfo->read_lock))
+			return -ERESTARTSYS;
+	}
 
 	pClient = findClient(pInfo, task_pid(current));
 	if (pClient) {
@@ -1075,7 +1085,7 @@ static ssize_t r3964_read(struct tty_struct *tty, struct file *file,
 				goto unlock;
 			}
 			/* block until there is a message: */
-			wait_event_interruptible_tty(tty, tty->read_wait,
+			wait_event_interruptible(tty->read_wait,
 					(pMsg = remove_msg(pInfo, pClient)));
 		}
 
@@ -1105,7 +1115,7 @@ static ssize_t r3964_read(struct tty_struct *tty, struct file *file,
 	}
 	ret = -EPERM;
 unlock:
-	tty_unlock(tty);
+	mutex_unlock(&pInfo->read_lock);
 	return ret;
 }
 
@@ -1154,8 +1164,6 @@ static ssize_t r3964_write(struct tty_struct *tty, struct file *file,
 	pHeader->locks = 0;
 	pHeader->owner = NULL;
 
-	tty_lock(tty);
-
 	pClient = findClient(pInfo, task_pid(current));
 	if (pClient) {
 		pHeader->owner = pClient;
@@ -1173,8 +1181,6 @@ static ssize_t r3964_write(struct tty_struct *tty, struct file *file,
 	add_tx_queue(pInfo, pHeader);
 	trigger_transmit(pInfo);
 
-	tty_unlock(tty);
-
 	return 0;
 }
 
diff --git a/include/linux/n_r3964.h b/include/linux/n_r3964.h
index e9adb42..90a803a 100644
--- a/include/linux/n_r3964.h
+++ b/include/linux/n_r3964.h
@@ -161,8 +161,9 @@ struct r3964_info {
 	unsigned char last_rx;
 	unsigned char bcc;
         unsigned int  blocks_in_rx_queue;
-	  
-	
+
+	struct mutex read_lock;		/* serialize r3964_read */
+
 	struct r3964_client_info *firstClient;
 	unsigned int state;
 	unsigned int flags;
-- 
2.6.1
