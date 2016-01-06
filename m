From: Alan <gnomes@lxorguk.ukuu.org.uk>
Subject: [PATCH] mkiss: fix scribble on freed memory
Date: Wed, 06 Jan 2016 14:55:02 +0000
Message-ID: <20160106145449.28695.13562.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:53492 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbcAFOzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 09:55:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d79f16c046086f4fe0d42184a458e187464eb83e fixed a user triggerable
scribble on free memory but added a new one which allows the user to
scribble even more and user controlled data into freed space.

As with 6pack we need to halt the queue before we free the buffers, because
the transmit logic is not protected by the semaphore.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---
 drivers/net/hamradio/mkiss.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 0b72b9d..85828f1 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -797,6 +797,11 @@ static void mkiss_close(struct tty_struct *tty)
 	 */
 	if (!atomic_dec_and_test(&ax->refcnt))
 		down(&ax->dead_sem);
+	/*
+	 * Halt the transmit queue so that a new transmit cannot scribble
+	 * on our buffers
+	 */
+	netif_stop_queue(ax->dev);
 
 	/* Free all AX25 frame buffers. */
 	kfree(ax->rbuff);
