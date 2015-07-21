From: Florian Westphal <fw@strlen.de>
Subject: Re: reproducable panic eviction work queue
Date: Tue, 21 Jul 2015 20:34:53 +0200
Message-ID: <20150721183453.GL11985@breakpoint.cc>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl>
 <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
 <55AA243D.5020306@cumulusnetworks.com>
 <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
 <55AA717D.8080800@cumulusnetworks.com>
 <55ACEDE9.3090205@transip.nl>
 <20150720143023.GC11985@breakpoint.cc>
 <55AE3208.8090403@transip.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Johan Schuijt <johan@transip.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Frank Schreuder <fschreuder@transip.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37751 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933342AbbGUSfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 14:35:00 -0400
Content-Disposition: inline
In-Reply-To: <55AE3208.8090403@transip.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Schreuder <fschreuder@transip.nl> wrote:

[ inet frag evictor crash ]

We believe we found the bug.  This patch should fix it.

We cannot share list for buckets and evictor, the flag member is
subject to race conditions so flags & INET_FRAG_EVICTED test is not
reliable.

It would be great if you could confirm that this fixes the problem
for you, we'll then make formal patch submission.

Please apply this on kernel without previous test patches, wheter you
use affected -stable or net-next kernel shouldn't matter since those are
similar enough.

Many thanks!

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
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
 
