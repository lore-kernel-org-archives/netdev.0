From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/2] isdn/gigaset: reset tty->receive_room when attaching ser_gigaset
Date: Tue, 14 Jul 2015 00:37:13 +0200 (CEST)
Message-ID: <ff18ec15ffc6347cd5574a66eb67cc9483361afa.1436826434.git.tilman@imap.cc>
References: <cover.1436826434.git.tilman@imap.cc>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Hansjoerg Lipp <hjlipp@web.de>, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1436826434.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 79901317ce80 ("n_tty: Don't flush buffer when closing ldisc"),
first merged in kernel release 3.10, caused the following regression
in the Gigaset M101 driver:

Before that commit, when closing the N_TTY line discipline in
preparation to switching to N_GIGASET_M101, receive_room would be
reset to a non-zero value by the call to n_tty_flush_buffer() in
n_tty's close method. With the removal of that call, receive_room
might be left at zero, blocking data reception on the serial line.

The present patch fixes that regression by setting receive_room
to an appropriate value in the ldisc open method.

Fixes: 79901317ce80 ("n_tty: Don't flush buffer when closing ldisc")
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ser-gigaset.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 8c91fd5..3ac9c41 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -524,9 +524,18 @@ gigaset_tty_open(struct tty_struct *tty)
 	cs->hw.ser->tty = tty;
 	atomic_set(&cs->hw.ser->refcnt, 1);
 	init_completion(&cs->hw.ser->dead_cmp);
-
 	tty->disc_data = cs;
 
+	/* Set the amount of data we're willing to receive per call
+	 * from the hardware driver to half of the input buffer size
+	 * to leave some reserve.
+	 * Note: We don't do flow control towards the hardware driver.
+	 * If more data is received than will fit into the input buffer,
+	 * it will be dropped and an error will be logged. This should
+	 * never happen as the device is slow and the buffer size ample.
+	 */
+	tty->receive_room = RBUFSIZE/2;
+
 	/* OK.. Initialization of the datastructures and the HW is done.. Now
 	 * startup system and notify the LL that we are ready to run
 	 */
-- 
1.7.1
