From: Alan <gnomes@lxorguk.ukuu.org.uk>
Subject: [PATCH] 6pack: fix free memory scribbles
Date: Tue, 05 Jan 2016 11:51:25 +0000
Message-ID: <20160105115042.8134.4926.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:47673 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbcAELvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 06:51:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit acf673a3187edf72068ee2f92f4dc47d66baed47 fixed a user triggerable free
memory scribble but in doing so replaced it with a different one that allows
the user to control the data and scribble even more.

sixpack_close is called by the tty layer in tty context. The tty context is
protected by sp_get() and sp_put(). However network layer activity via
sp_xmit() is not protected this way. We must therefore stop the queue
otherwise the user gets to dump a buffer mostly of their choice into freed
kernel pages.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---
 drivers/net/hamradio/6pack.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 9f0b1c3..b3ba6a8 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -683,6 +683,12 @@ static void sixpack_close(struct tty_struct *tty)
 	if (!atomic_dec_and_test(&sp->refcnt))
 		down(&sp->dead_sem);
 
+	/* We must stop the queue to avoid potentially scribbling
+	   on the free buffers. The sp->dead_sem is not sufficient
+	   to protect us from sp->xbuff access */
+
+	netif_stop_queue(sp->dev);
+
 	del_timer_sync(&sp->tx_t);
 	del_timer_sync(&sp->resync_t);
 
