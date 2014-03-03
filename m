From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon,  3 Mar 2014 15:05:20 +0100
Message-ID: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754126AbaCCOHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 09:07:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I stumbled upon this very serious bug while hunting for another one,
it's a very subtle race condition between inet_frag_evictor,
inet_frag_intern and the IPv4/6 frag_queue and expire functions (basically
the users of inet_frag_kill/inet_frag_put).
What happens is that after a fragment has been added to the hash chain but
before it's been added to the lru_list (inet_frag_lru_add), it may get
deleted (either by an expired timer if the system load is high or the
timer sufficiently low, or by the fraq_queue function for different
reasons) before it's added to the lru_list, then after it gets added
it's a matter of time for the evictor to get to a piece of memory which
has been freed leading to a number of different bugs depending on what's
left there. I've been able to trigger this on both IPv4 and IPv6 (which
is normal as the frag code is the same), but it's been much more
difficult to trigger on IPv4 due to the protocol differences about how
fragments are treated. The setup I used to reproduce this is:
2 machines with 4 x 10G bonded in a RR bond, so the same flow can be
seen on multiple cards at the same time. Then I used multiple instances
of ping/ping6 to generate fragmented packets and flood the machines with
them while running other processes to load the attacked machine.
*It is very important to have the _same flow_ coming in on multiple CPUs
concurrently. Usually the attacked machine would die in less than 30
minutes, if configured properly to have many evictor calls and timeouts
it could happen in 10 minutes or so.

The fix is simple, just move the lru_add under the hash chain locked
region so when a removing function is called it'll have to wait for the
fragment to be added to the lru_list, and then it'll remove it (it works
because the hash chain removal is done before the lru_list one and
there's no window between the two list adds when the frag can get
dropped). With this fix applied I couldn't kill the same machine in 24
hours with the same setup.

Fixes: 3ef0eb0db4bf ("net: frag, move LRU list maintenance outside of
rwlock")

CC: Jesper Dangaard Brouer <brouer@redhat.com>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
I'm new to this code, so I'm not sure if this is the best approach to fix
the issue and am open to other suggestions, since I consider the issue
quite serious (remotely triggerable) I'll be closely monitoring this thread
to get it fixed asap.

 net/ipv4/inet_fragment.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index bb075fc9a14f..322dcebfc588 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -278,9 +278,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &hb->chain);
+	inet_frag_lru_add(nf, qp);
 	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
-	inet_frag_lru_add(nf, qp);
+
 	return qp;
 }
 
-- 
1.8.4.2
