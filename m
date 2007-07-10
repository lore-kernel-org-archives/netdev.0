From: Olaf Kirch <okir@lst.de>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Tue, 10 Jul 2007 12:44:31 +0200
Message-ID: <200707101244.32753.okir@lst.de>
References: <200707041416.33732.okir@lst.de> <20070709.152746.75758774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:54094 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128AbXGJKpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 06:45:07 -0400
In-Reply-To: <20070709.152746.75758774.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 10 July 2007 00:27, David Miller wrote:
> I'm happy to entertain this kind of solution, but we really
> need to first have an interface to change multiple bits
> at a time in one atomic operation, because by itself this
> patch doubles the number of atomices we do when starting
> a NAPI poll.

Understood. How about the patch below? It takes a similar
approach, but it puts the onus on the netpoll code
path rather than the general NAPI case.

Olaf
--------------
From: Olaf Kirch <olaf.kirch@oracle.com>

Keep netpoll/poll_napi from messing with the poll_list.
Only net_rx_action is allowed to manipulate the list.

Signed-off-by: Olaf Kirch <olaf.kirch@oracle.com>
---
 include/linux/netdevice.h |   10 ++++++++++
 net/core/netpoll.c        |    8 ++++++++
 2 files changed, 18 insertions(+)

Index: iscsi-2.6/include/linux/netdevice.h
===================================================================
--- iscsi-2.6.orig/include/linux/netdevice.h
+++ iscsi-2.6/include/linux/netdevice.h
@@ -248,6 +248,8 @@ enum netdev_state_t
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
 	__LINK_STATE_QDISC_RUNNING,
+	/* Set by the netpoll NAPI code */
+	__LINK_STATE_POLL_LIST_FROZEN,
 };
 
 
@@ -919,6 +921,14 @@ static inline void netif_rx_complete(str
 {
 	unsigned long flags;
 
+#ifdef CONFIG_NETPOLL
+	/* Prevent race with netpoll - yes, this is a kludge.
+	 * But at least it doesn't penalize the non-netpoll
+	 * code path. */
+	if (test_bit(__LINK_STATE_POLL_LIST_FROZEN, &dev->state))
+		return;
+#endif
+
 	local_irq_save(flags);
 	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
 	list_del(&dev->poll_list);
Index: iscsi-2.6/net/core/netpoll.c
===================================================================
--- iscsi-2.6.orig/net/core/netpoll.c
+++ iscsi-2.6/net/core/netpoll.c
@@ -123,6 +123,13 @@ static void poll_napi(struct netpoll *np
 	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
 	    npinfo->poll_owner != smp_processor_id() &&
 	    spin_trylock(&npinfo->poll_lock)) {
+		/* When calling dev->poll from poll_napi, we may end up in
+		 * netif_rx_complete. However, only the CPU to which the
+		 * device was queued is allowed to remove it from poll_list.
+		 * Setting POLL_LIST_FROZEN tells netif_rx_complete
+		 * to leave the NAPI state alone.
+		 */
+		set_bit(__LINK_STATE_POLL_LIST_FROZEN, &np->dev->state);
 		npinfo->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
@@ -130,6 +137,7 @@ static void poll_napi(struct netpoll *np
 
 		atomic_dec(&trapped);
 		npinfo->rx_flags &= ~NETPOLL_RX_DROP;
+		clear_bit(__LINK_STATE_POLL_LIST_FROZEN, &np->dev->state);
 		spin_unlock(&npinfo->poll_lock);
 	}
 }

-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
