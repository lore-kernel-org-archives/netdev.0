From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [Bug, PATCH and another Bug] Was: Fix refcounting problem with netif_rx_reschedule()
Date: Wed, 19 Sep 2007 17:24:03 +0530
Message-ID: <20070919115403.19455.65941.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44687 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012AbXISLvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 07:51:50 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8JBpn31021647
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 07:51:49 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8JBpnMr603936
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 07:51:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8JBpmYQ005670
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 07:51:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

After applying Roland's NAPI patch, system panics when I run multiple
thread iperf (no stack trace at this time, it shows that the panic is in
net_tx_action).

I think the problem is:

In the "done < budget" case, ipoib_poll calls netif_rx_complete()
netif_rx_complete()
	__netif_rx_complete()
		__napi_complete()
			list_del()
				__list_del()
				entry->next = LIST_POISON1;
				entry->prev = LIST_POISON2;

Due to race with another completion (explained at end of the patch),
net_rx_action finds quota==0 (even though done < budget earlier):
net_rx_action()
	if (unlikely(!n->quota)) {
		n->quota = n->weight;
		list_move_tail()
			__list_del(POISON, POISON)
			<PANIC>
	}

while IPoIB calling netif_rx_reschedule() works fine due to:
netif_rx_reschedule
        __netif_rx_schedule
                __napi_schedule
                        list_add_tail (this is OK)

Patch that fixes this:

diff -ruNp a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2007-09-19 16:50:35.000000000 +0530
+++ b/include/linux/netdevice.h	2007-09-19 16:51:28.000000000 +0530
@@ -346,7 +346,7 @@ static inline void napi_schedule(struct 
 static inline void __napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
-	list_del(&n->poll_list);
+	__list_del(&n->poll_list);
 	smp_mb__before_clear_bit();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }

When I apply this patch, things work fine but I get napi_check_quota_bug()
warning. This race seems to happen as follows:

CPU#1: ipoib_poll(budget=100)
{
	A. process 100 skbs
	B. netif_rx_complete()
	<Process unrelated interrupts; executes slower than steps C, D, E on
	 CPU#2>
	F. ib_req_notify_cq() (no missed completions, do nothing)
	G. return 100
	H. return to net_rx_action, quota=99, subtract 100, quota=-1, BUG.
}

CPU#2: ipoib_ib_completion() : (starts and finishes entire line of execution
				*after* step B and *before* H executes).
{
	C. New skb comes, call netif_rx_schedule; set quota=100
	D. do ipoib_poll(), process one skb, return work=1 to net_rx_action
	E. net_rx_action: set quota=99
}

The reason why both cpu's can execute poll simultaneously is because
netpoll_poll_lock() returns NULL (dev->npinfo == NULL). This results in
negative napi refcount and the warning. I verified this is the reason by
saving the original quota before calling poll (in net_tx_action) and
comparing with final after poll (before it gets updated), and it gets
changed very often in multiple thread testing (atleast 4 threads, haven't
seen with 2). In most cases, the quota becomes -1, and I have seen upto
-9 but those are rarer.

Note: during steps F-H and C-E, priv/napi is read/modified by both cpu's
	which is another bug relating to the same race.

I guess the above patch is not required if this bug (in IPoIB) is fixed?

Roland, why cannot we get rid of "poll_more" ? We will get called again
after netif_rx_reschedule, and it is cleaner to let the new execution handle
fresh completions. Is there a reason why this goto is required?

Thanks,

- KK
