From: Dominic Curran <dominic.curran@citrix.com>
Subject: [PATCH net v2] tuntap: Fix for a race in accessing numqueues
Date: Mon, 20 Jan 2014 21:59:18 +0000
Message-ID: <1390255158-9058-1-git-send-email-dominic.curran@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dominic Curran <dominic.curran@citrix.com>,
	Jason Wang <jasowang@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:5880 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380AbaATV7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 16:59:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A patch for fixing a race between queue selection and changing queues
was introduced in commit 92bb73ea2("tuntap: fix a possible race between
queue selection and changing queues").

The fix was to prevent the driver from re-reading the tun->numqueues
more than once within tun_select_queue() using ACCESS_ONCE().

We have been experiancing 'Divide-by-zero' errors in tun_net_xmit() 
since we moved from 3.6 to 3.10, and believe that they come from a 
simular source where the value of tun->numqueues changes to zero 
between the first and a subsequent read of tun->numqueues.

The fix is a simular use of ACCESS_ONCE(), as well as a multiply
instead of a divide in the if statement.

Signed-off-by: Dominic Curran <dominic.curran@citrix.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>
---
V2: Use multiply instead of divide. Suggested by Eric Dumazet.
    Fixed email address for maxk. Rebase against net tree.
---
 drivers/net/tun.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: net/drivers/net/tun.c
===================================================================
--- net.orig/drivers/net/tun.c	2014-01-20 20:22:06.000000000 +0000
+++ net/drivers/net/tun.c	2014-01-20 20:54:54.000000000 +0000
@@ -721,12 +721,14 @@ static netdev_tx_t tun_net_xmit(struct s
 	struct tun_struct *tun = netdev_priv(dev);
 	int txq = skb->queue_mapping;
 	struct tun_file *tfile;
+	u32 numqueues = 0;
 
 	rcu_read_lock();
 	tfile = rcu_dereference(tun->tfiles[txq]);
+	numqueues = ACCESS_ONCE(tun->numqueues);
 
 	/* Drop packet if interface is not attached */
-	if (txq >= tun->numqueues)
+	if (txq >= numqueues)
 		goto drop;
 
 	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
@@ -746,8 +748,8 @@ static netdev_tx_t tun_net_xmit(struct s
 	/* Limit the number of packets queued by dividing txq length with the
 	 * number of queues.
 	 */
-	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
-			  >= dev->tx_queue_len / tun->numqueues)
+	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
+			  >= dev->tx_queue_len)
 		goto drop;
 
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
