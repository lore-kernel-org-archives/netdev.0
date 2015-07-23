From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net 1/4] inet: frag: don't re-use chainlist for evictor
Date: Thu, 23 Jul 2015 12:05:37 +0200
Message-ID: <1437645940-7895-2-git-send-email-fw@strlen.de>
References: <1437645940-7895-1-git-send-email-fw@strlen.de>
Cc: Johan Schuijt <johan@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41976 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753192AbbGWKjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:39:43 -0400
In-Reply-To: <1437645940-7895-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 65ba1f1ec0eff ("inet: frags: fix a race between inet_evict_bucket
and inet_frag_kill") describes the bug, but the fix doesn't work reliably.

Problem is that ->flags member can be set on other cpu without chainlock
being held by that task, i.e. the RMW-Cycle can clear INET_FRAG_EVICTED
bit after we put the element on the evictor private list.

We can crash when walking the 'private' evictor list since an element can
be deleted from list underneath the evictor.

Join work with Nikolay Alexandrov.

Fixes: b13d3cbfb8e8 ("inet: frag: move eviction of queues to work queue")
Reported-by: Johan Schuijt <johan@transip.nl>
Tested-by: Frank Schreuder <fschreuder@transip.nl>
Signed-off-by: Nikolay Alexandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h  | 2 ++
 net/ipv4/inet_fragment.c | 8 +++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index e1300b3..56a3a56 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -45,6 +45,7 @@ enum {
  * @flags: fragment queue flags
  * @max_size: maximum received fragment size
  * @net: namespace that this frag belongs to
+ * @list_evictor: list of queues to forcefully evict (e.g. due to low memory)
  */
 struct inet_frag_queue {
 	spinlock_t		lock;
@@ -59,6 +60,7 @@ struct inet_frag_queue {
 	__u8			flags;
 	u16			max_size;
 	struct netns_frags	*net;
+	struct hlist_node	list_evictor;
 };
 
 #define INETFRAGS_HASHSZ	1024
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 5e346a0..1722348 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -151,14 +151,13 @@ evict_again:
 		}
 
 		fq->flags |= INET_FRAG_EVICTED;
-		hlist_del(&fq->list);
-		hlist_add_head(&fq->list, &expired);
+		hlist_add_head(&fq->list_evictor, &expired);
 		++evicted;
 	}
 
 	spin_unlock(&hb->chain_lock);
 
-	hlist_for_each_entry_safe(fq, n, &expired, list)
+	hlist_for_each_entry_safe(fq, n, &expired, list_evictor)
 		f->frag_expire((unsigned long) fq);
 
 	return evicted;
@@ -284,8 +283,7 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	struct inet_frag_bucket *hb;
 
 	hb = get_frag_bucket_locked(fq, f);
-	if (!(fq->flags & INET_FRAG_EVICTED))
-		hlist_del(&fq->list);
+	hlist_del(&fq->list);
 	spin_unlock(&hb->chain_lock);
 }
 
-- 
2.0.5
