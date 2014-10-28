From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] inet: frags: remove the WARN_ON from inet_evict_bucket
Date: Tue, 28 Oct 2014 10:44:01 +0100
Message-ID: <1414489441-28578-1-git-send-email-nikolay@redhat.com>
References: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McLean <chutzpah@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503AbaJ1Jov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2014 05:44:51 -0400
In-Reply-To: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The WARN_ON in inet_evict_bucket can be triggered by a valid case:
inet_frag_kill and inet_evict_bucket can be running in parallel on the
same queue which means that there has been at least one more ref added
by a previous inet_frag_find call, but inet_frag_kill can delete the
timer before inet_evict_bucket which will cause the WARN_ON() there to
trigger since we'll have refcnt!=1. Now, this case is valid because the
queue is being "killed" for some reason (removed from the chain list and
its timer deleted) so it will get destroyed in the end by one of the
inet_frag_put() calls which reaches 0 i.e. refcnt is still valid.

CC: Florian Westphal <fw@strlen.de>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McLean <chutzpah@gentoo.org>

Fixes: b13d3cbfb8e8 ("inet: frag: move eviction of queues to work queue")
Reported-by: Patrick McLean <chutzpah@gentoo.org>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
I'm sending this as a separate patch so the race fix doesn't get blocked
in case I'm wrong and also it's a different issue.

 net/ipv4/inet_fragment.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 894ec30c5896..19419b60cb37 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -146,7 +146,6 @@ evict_again:
 			atomic_inc(&fq->refcnt);
 			spin_unlock(&hb->chain_lock);
 			del_timer_sync(&fq->timer);
-			WARN_ON(atomic_read(&fq->refcnt) != 1);
 			inet_frag_put(fq, f);
 			goto evict_again;
 		}
-- 
1.9.3
