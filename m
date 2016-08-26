From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] rhashtable: fix a memory leak in alloc_bucket_locks()
Date: Fri, 26 Aug 2016 08:51:39 -0700
Message-ID: <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
         <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
         <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com>
         <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
         <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: CAI Qian <caiqian@redhat.com>, Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34126 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753741AbcHZPvr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 11:51:47 -0400
Received: by mail-pf0-f193.google.com with SMTP id g202so5098096pfb.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 08:51:46 -0700 (PDT)
In-Reply-To: <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If vmalloc() was successful, do not attempt a kmalloc_array()

Fixes: 4cf0b354d92e ("rhashtable: avoid large lock-array allocations")
Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
---
 lib/rhashtable.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5ba520b544d7..56054e541a0f 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -77,17 +77,18 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 	size = min_t(unsigned int, size, tbl->size >> 1);
 
 	if (sizeof(spinlock_t) != 0) {
+		tbl->locks = NULL;
 #ifdef CONFIG_NUMA
 		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
 		    gfp == GFP_KERNEL)
 			tbl->locks = vmalloc(size * sizeof(spinlock_t));
-		else
 #endif
 		if (gfp != GFP_KERNEL)
 			gfp |= __GFP_NOWARN | __GFP_NORETRY;
 
-		tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
-					   gfp);
+		if (!tbl->locks)
+			tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
+						   gfp);
 		if (!tbl->locks)
 			return -ENOMEM;
 		for (i = 0; i < size; i++)
