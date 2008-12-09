From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netpoll: fix race on poll_list resulting in garbage entry
Date: Tue, 9 Dec 2008 16:06:44 -0500
Message-ID: <20081209210644.GC3785@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44504 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676AbYLIVIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 16:08:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	A few months back a race was discused between the netpoll napi service
path, and the fast path through net_rx_action:
http://kerneltrap.org/mailarchive/linux-netdev/2007/10/16/345470

A patch was submitted for that bug, but I think we missed a case.

Consider the following scenario:

INITIAL STATE
CPU0 has one napi_struct A on its poll_list
CPU1 is calling netpoll_send_skb and needs to call poll_napi on the same
napi_struct A that CPU0 has on its list



CPU0						CPU1
net_rx_action					poll_napi
!list_empty (returns true)			locks poll_lock for A
						 poll_one_napi
						  napi->poll
						   netif_rx_complete
						    __napi_complete
						    (removes A from poll_list)
list_entry(list->next)


In the above scenario, net_rx_action assumes that the per-cpu poll_list is
exclusive to that cpu.  netpoll of course violates that, and because the netpoll
path can dequeue from the poll list, its possible for CPU0 to detect a non-empty
list at the top of the while loop in net_rx_action, but have it become empty by
the time it calls list_entry.  Since the poll_list isn't surrounded by any other
structure, the returned data from that list_entry call in this situation is
garbage, and any number of crashes can result based on what exactly that garbage
is.

Given that its not fasible for performance reasons to place exclusive locks
arround each cpus poll list to provide that mutal exclusion, I think the best
solution is modify the netpoll path in such a way that we continue to guarantee
that the poll_list for a cpu is in fact exclusive to that cpu.  To do this I've
implemented the patch below.  It adds an additional bit to the state field in
the napi_struct.  When executing napi->poll from the netpoll_path, this bit will
be set. When a driver calls netif_rx_complete, if that bit is set, it will not
remove the napi_struct from the poll_list.  That work will be saved for the next
iteration of net_rx_action.

I've tested this and it seems to work well.  About the biggest drawback I can
see to it is the fact that it might result in an extra loop through
net_rx_action in the event that the device is actually contended for (i.e. the
netpoll path actually preforms all the needed work no the device, and the call
to net_rx_action winds up doing nothing, except removing the napi_struct from
the poll_list.  However I think this is probably a small price to pay, given
that the alternative is a crash.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/netdevice.h |    7 +++++++
 net/core/netpoll.c        |    2 ++
 2 files changed, 9 insertions(+)


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d77b1d..e26f549 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -319,6 +319,7 @@ enum
 {
 	NAPI_STATE_SCHED,	/* Poll is scheduled */
 	NAPI_STATE_DISABLE,	/* Disable pending */
+	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 };
 
 extern void __napi_schedule(struct napi_struct *n);
@@ -1497,6 +1498,12 @@ static inline void netif_rx_complete(struct net_device *dev,
 {
 	unsigned long flags;
 
+	/*
+	 * don't let napi dequeue from the cpu poll list
+	 * just in case its running on a different cpu
+	 */
+	if (unlikely(test_bit(NAPI_STATE_NPSVC, &napi->state)))
+		return;
 	local_irq_save(flags);
 	__netif_rx_complete(dev, napi);
 	local_irq_restore(flags);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 6c7af39..dadac62 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -133,9 +133,11 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 
 	npinfo->rx_flags |= NETPOLL_RX_DROP;
 	atomic_inc(&trapped);
+	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
 	work = napi->poll(napi, budget);
 
+	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 	atomic_dec(&trapped);
 	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
 
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
