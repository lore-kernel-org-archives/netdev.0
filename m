From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 68011] New: spin_unlock is missed in function
 (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c)
Date: Thu, 02 Jan 2014 19:51:16 -0500 (EST)
Message-ID: <20140102.195116.2109511693723200480.davem@davemloft.net>
References: <20140101215231.50ea361e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbaACAvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:51:18 -0500
In-Reply-To: <20140101215231.50ea361e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 1 Jan 2014 21:52:31 -0800

> In function (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c):
> 
> The structure (txq->_xmit_lock) gets successfully locked at line (383) by
> (__netif_tx_trylock(txq)) and unlocked by (__netif_tx_unlock(txq)) at line
> (398).
> 
> The problem occurs when the loop breaks at line (390) and the structure
> (txq->_xmit_lock) still locked. In that case, the structure (txq->_xmit_lock)
> never gets unlocked.
> 
> A possible solution is to call (__netif_tx_unlock(txq)) before the break at
> line (390)

This code path has another problem, if __vlan_put_tag() returns NULL then
the function exit path is going to try and insert that NULL skb back onto
the npinfo->txq, resulting in a crash.

We effectively, therefore, don't have the packet any more and as
things stand the one and only thing we could do is just unlock and
return immediately.  But this means we won't retry sending later, and
will thus lose the frame.

netpoll should try to be as drop free as possible, that's why it has all
of this retry logic.

There really should be a version of __vlan_put_tag() that allows the caller
to unwind and try again somehow.

Here's what I'll apply and queue up for -stable, thanks.

====================
[PATCH] netpoll: Fix missing TXQ unlock and and OOPS.

The VLAN tag handling code in netpoll_send_skb_on_dev() has two problems.

1) It exits without unlocking the TXQ.

2) It then tries to queue a NULL skb to npinfo->txq.

Reported-by: Ahmed Tamrawi <atamrawi@iastate.edu>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/netpoll.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 8f97199..3030978 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -386,8 +386,14 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 					    !vlan_hw_offload_capable(netif_skb_features(skb),
 								     skb->vlan_proto)) {
 						skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-						if (unlikely(!skb))
-							break;
+						if (unlikely(!skb)) {
+							/* This is actually a packet drop, but we
+							 * don't want the code at the end of this
+							 * function to try and re-queue a NULL skb.
+							 */
+							status = NETDEV_TX_OK;
+							goto unlock_txq;
+						}
 						skb->vlan_tci = 0;
 					}
 
@@ -395,6 +401,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
 				}
+			unlock_txq:
 				__netif_tx_unlock(txq);
 
 				if (status == NETDEV_TX_OK)
-- 
1.7.11.7
