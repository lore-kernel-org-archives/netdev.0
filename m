From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock in MD5 Signature support
Date: Tue, 20 Feb 2007 23:49:18 -0800 (PST)
Message-ID: <20070220.234918.41635974.davem@davemloft.net>
References: <53701.81.105.127.245.1166379186.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leigh@solinno.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41348
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbXBUHtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:49:19 -0500
In-Reply-To: <53701.81.105.127.245.1166379186.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Sun, 17 Dec 2006 18:13:06 -0000 (GMT)

> It was all going so well, and then it deadlocked.  What can be done
> about this?

Sorry for taking so long about this.

The problem is that tcp_md5sig_pool_lock is taken in both
software-interrupt and non-software-interrupt contexts, but
it is always acquired/released using spin_lock/spin_unlock.

The most conservative fix, which I'll use for 2.6.21 and
2.6.x-stable, is the following.

I invite anyone to rewrite this md5 signature pool mutual
exclusion code, it's not exactly the best :-)

Thanks for reporting this problem.

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
 
