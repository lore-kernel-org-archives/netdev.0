From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] rhashtable: use cond_resched()
Date: Thu, 26 Feb 2015 07:20:34 -0800
Message-ID: <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
	 <20150226075354.GA30061@acer.localdomain>
	 <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:37272 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbbBZPUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:20:36 -0500
Received: by iecrl12 with SMTP id rl12so16457892iec.4
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 07:20:36 -0800 (PST)
In-Reply-To: <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If a hash table has 128 slots and 16384 elems, expand to 256 slots
takes more than one second. For larger sets, a soft lockup is detected.

Holding cpu for that long, even in a work queue is a show stopper
for non preemptable kernels.

cond_resched() at strategic points to allow process scheduler
to reschedule us.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 lib/rhashtable.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e3a04e4b3ec5..f3073fc600ed 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -17,6 +17,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/log2.h>
+#include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/mm.h>
@@ -414,6 +415,7 @@ int rhashtable_expand(struct rhashtable *ht)
 			}
 		}
 		unlock_buckets(new_tbl, old_tbl, new_hash);
+		cond_resched();
 	}
 
 	/* Unzip interleaved hash chains */
@@ -437,6 +439,7 @@ int rhashtable_expand(struct rhashtable *ht)
 				complete = false;
 
 			unlock_buckets(new_tbl, old_tbl, old_hash);
+			cond_resched();
 		}
 	}
 
@@ -495,6 +498,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 				   tbl->buckets[new_hash + new_tbl->size]);
 
 		unlock_buckets(new_tbl, tbl, new_hash);
+		cond_resched();
 	}
 
 	/* Publish the new, valid hash table */
