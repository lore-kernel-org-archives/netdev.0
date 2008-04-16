From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Discard tcp out-of-order queue if system limit is
 reached
Date: Tue, 15 Apr 2008 20:27:40 -0700 (PDT)
Message-ID: <20080415.202740.114756353.davem@davemloft.net>
References: <200804151854.45021.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: vgusev@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753270AbYDPD1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 23:27:39 -0400
In-Reply-To: <200804151854.45021.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaliy Gusev <vgusev@openvz.org>
Date: Tue, 15 Apr 2008 18:54:44 +0400

> tcp_prune_queue() doesn't prune an out-of-order queue if socket
> is under rcvbuf. However even if socket is under rcvbuf but system-wide limit is
> reached then skb cannot be queued. It can lead to deadlock situation as any skb that
> fills sequence hole is dropped.
> So discard out-of-order queue if system-wide limit is reached.
> 
> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

I applied your original patch already, so I added the following
relative patch.

Please provide relative fixup patches when I say that I've applied
your patch already.

Thank you.

commit 56f367bbfd5a7439961499ca6a2f0822d2074d83
Author: Vitaliy Gusev <vgusev@openvz.org>
Date:   Tue Apr 15 20:26:34 2008 -0700

    [TCP]: Add return value indication to tcp_prune_ofo_queue().
    
    Returns non-zero if tp->out_of_order_queue was seen non-empty.
    This allows tcp_try_rmem_schedule() to return early.
    
    Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 61db7b1..bbb7d88 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3841,7 +3841,7 @@ static void tcp_ofo_queue(struct sock *sk)
 	}
 }
 
-static void tcp_prune_ofo_queue(struct sock *sk);
+static int tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
 static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
@@ -3853,7 +3853,9 @@ static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
 			return -1;
 
 		if (!sk_rmem_schedule(sk, size)) {
-			tcp_prune_ofo_queue(sk);
+			if (!tcp_prune_ofo_queue(sk))
+				return -1;
+
 			if (!sk_rmem_schedule(sk, size))
 				return -1;
 		}
@@ -4211,10 +4213,12 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 
 /*
  * Purge the out-of-order queue.
+ * Return true if queue was pruned.
  */
-static void tcp_prune_ofo_queue(struct sock *sk)
+static int tcp_prune_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	int res = 0;
 
 	if (!skb_queue_empty(&tp->out_of_order_queue)) {
 		NET_INC_STATS_BH(LINUX_MIB_OFOPRUNED);
@@ -4228,7 +4232,9 @@ static void tcp_prune_ofo_queue(struct sock *sk)
 		if (tp->rx_opt.sack_ok)
 			tcp_sack_reset(&tp->rx_opt);
 		sk_mem_reclaim(sk);
+		res = 1;
 	}
+	return res;
 }
 
 /* Reduce allocated memory if we can, trying to get
