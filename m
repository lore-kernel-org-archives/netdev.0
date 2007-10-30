From: David Miller <davem@davemloft.net>
Subject: Re: MD5 signature pool race bug?
Date: Mon, 29 Oct 2007 22:01:35 -0700 (PDT)
Message-ID: <20071029.220135.186369787.davem@davemloft.net>
References: <20071025113612.2ea69262@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751122AbXJ3FBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 01:01:40 -0400
In-Reply-To: <20071025113612.2ea69262@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 25 Oct 2007 11:36:12 -0700

> Looking at this bug report:
> 	http://bugzilla.kernel.org/show_bug.cgi?id=9173
 ...
> It looks like there may be a race between the tricky allocate per-cpu pool
> and free-per-cpu pool logic.  IMHO the pool management code is more complex
> than it needs to be and may be the source of the bug. Couldn't the signature
> just use normal kmalloc/kfree and slab cache?

This bug was fixed by the patch below, please close this
bug.

Thanks!

commit 2c4f6219aca5939b57596278ea8b014275d4917b
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Feb 20 23:51:47 2007 -0800

    [TCP]: Fix MD5 signature pool locking.
    
    The locking calls assumed that these code paths were only
    invoked in software interrupt context, but that isn't true.
    
    Therefore we need to use spin_{lock,unlock}_bh() throughout.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ac6516c..74c4d10 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2266,12 +2266,12 @@ void tcp_free_md5sig_pool(void)
 {
 	struct tcp_md5sig_pool **pool = NULL;
 
-	spin_lock(&tcp_md5sig_pool_lock);
+	spin_lock_bh(&tcp_md5sig_pool_lock);
 	if (--tcp_md5sig_users == 0) {
 		pool = tcp_md5sig_pool;
 		tcp_md5sig_pool = NULL;
 	}
-	spin_unlock(&tcp_md5sig_pool_lock);
+	spin_unlock_bh(&tcp_md5sig_pool_lock);
 	if (pool)
 		__tcp_free_md5sig_pool(pool);
 }
@@ -2314,36 +2314,36 @@ struct tcp_md5sig_pool **tcp_alloc_md5sig_pool(void)
 	int alloc = 0;
 
 retry:
-	spin_lock(&tcp_md5sig_pool_lock);
+	spin_lock_bh(&tcp_md5sig_pool_lock);
 	pool = tcp_md5sig_pool;
 	if (tcp_md5sig_users++ == 0) {
 		alloc = 1;
-		spin_unlock(&tcp_md5sig_pool_lock);
+		spin_unlock_bh(&tcp_md5sig_pool_lock);
 	} else if (!pool) {
 		tcp_md5sig_users--;
-		spin_unlock(&tcp_md5sig_pool_lock);
+		spin_unlock_bh(&tcp_md5sig_pool_lock);
 		cpu_relax();
 		goto retry;
 	} else
-		spin_unlock(&tcp_md5sig_pool_lock);
+		spin_unlock_bh(&tcp_md5sig_pool_lock);
 
 	if (alloc) {
 		/* we cannot hold spinlock here because this may sleep. */
 		struct tcp_md5sig_pool **p = __tcp_alloc_md5sig_pool();
-		spin_lock(&tcp_md5sig_pool_lock);
+		spin_lock_bh(&tcp_md5sig_pool_lock);
 		if (!p) {
 			tcp_md5sig_users--;
-			spin_unlock(&tcp_md5sig_pool_lock);
+			spin_unlock_bh(&tcp_md5sig_pool_lock);
 			return NULL;
 		}
 		pool = tcp_md5sig_pool;
 		if (pool) {
 			/* oops, it has already been assigned. */
-			spin_unlock(&tcp_md5sig_pool_lock);
+			spin_unlock_bh(&tcp_md5sig_pool_lock);
 			__tcp_free_md5sig_pool(p);
 		} else {
 			tcp_md5sig_pool = pool = p;
-			spin_unlock(&tcp_md5sig_pool_lock);
+			spin_unlock_bh(&tcp_md5sig_pool_lock);
 		}
 	}
 	return pool;
@@ -2354,11 +2354,11 @@ EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
 struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
 {
 	struct tcp_md5sig_pool **p;
-	spin_lock(&tcp_md5sig_pool_lock);
+	spin_lock_bh(&tcp_md5sig_pool_lock);
 	p = tcp_md5sig_pool;
 	if (p)
 		tcp_md5sig_users++;
-	spin_unlock(&tcp_md5sig_pool_lock);
+	spin_unlock_bh(&tcp_md5sig_pool_lock);
 	return (p ? *per_cpu_ptr(p, cpu) : NULL);
 }
 
