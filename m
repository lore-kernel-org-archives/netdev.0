From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] inet: frags: fix a race between inet_evict_bucket and inet_frag_kill
Date: Tue, 28 Oct 2014 10:30:34 +0100
Message-ID: <1414488634-28412-1-git-send-email-nikolay@redhat.com>
References: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McLean <chutzpah@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206AbaJ1JbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2014 05:31:04 -0400
In-Reply-To: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the evictor is running it adds some chosen frags to a local list to
be evicted once the chain lock has been released but at the same time
the *frag_queue can be running for some of the same queues and it
may call inet_frag_kill which will wait on the chain lock and
will then delete the queue from the wrong list since it was added in the
eviction one. The fix is simple - check if the queue has the evict flag
set under the chain lock before deleting it, this is safe because the
evict flag is set only under that lock and having the flag set also means
that the queue has been detached from the chain list, so no need to delete
it again.
An important note to make is that we're safe w.r.t refcnt because
inet_frag_kill and inet_evict_bucket will sync on the del_timer operation
where only one of the two can succeed (or if the timer is executing -
none of them), the cases are:
1. inet_frag_kill succeeds in del_timer
 - then the timer ref is removed, but inet_evict_bucket will not add
   this queue to its expire list but will restart eviction in that chain
2. inet_evict_bucket succeeds in del_timer
 - then the timer ref is kept until the evictor "expires" the queue, but
   inet_frag_kill will remove the initial ref and will set
   INET_FRAG_COMPLETE which will make the frag_expire fn just to remove
   its ref.
In the end all of the queue users will do an inet_frag_put and the one
that reaches 0 will free it. The refcount balance should be okay.

CC: Florian Westphal <fw@strlen.de>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McLean <chutzpah@gentoo.org>

Fixes: b13d3cbfb8e8 ("inet: frag: move eviction of queues to work queue")
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Patrick McLean <chutzpah@gentoo.org>
Tested-by: Patrick McLean <chutzpah@gentoo.org>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
A few more eyes to confirm all of this would be much appreciated.

 net/ipv4/inet_fragment.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 9eb89f3f0ee4..894ec30c5896 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -285,7 +285,8 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	struct inet_frag_bucket *hb;
 
 	hb = get_frag_bucket_locked(fq, f);
-	hlist_del(&fq->list);
+	if (!(fq->flags & INET_FRAG_EVICTED))
+		hlist_del(&fq->list);
 	spin_unlock(&hb->chain_lock);
 }
 
-- 
1.9.3
