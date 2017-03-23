From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [net-next PATCH v2 1/8] net: Busy polling should ignore sender CPUs
Date: Thu, 23 Mar 2017 14:36:37 -0700
Message-ID: <20170323213637.12615.11197.stgit@localhost.localdomain>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170323211820.12615.88907.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This patch is a cleanup/fix for NAPI IDs following the changes that made it
so that sender_cpu and napi_id were doing a better job of sharing the same
location in the sk_buff.

One issue I found is that we weren't validating the napi_id as being valid
before we started trying to setup the busy polling.  This change corrects
that by using the MIN_NAPI_ID value that is now used in both allocating the
NAPI IDs, as well as validating them.

Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/net/busy_poll.h |    9 +++++++--
 net/core/dev.c          |   13 +++++++++----
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index c0452de83086..3fcda9e70c3f 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -35,6 +35,12 @@
 extern unsigned int sysctl_net_busy_read __read_mostly;
 extern unsigned int sysctl_net_busy_poll __read_mostly;
 
+/*		0 - Reserved to indicate value not set
+ *     1..NR_CPUS - Reserved for sender_cpu
+ *  NR_CPUS+1..~0 - Region available for NAPI IDs
+ */
+#define MIN_NAPI_ID ((unsigned int)(NR_CPUS + 1))
+
 static inline bool net_busy_loop_on(void)
 {
 	return sysctl_net_busy_poll;
@@ -58,10 +64,9 @@ static inline unsigned long busy_loop_end_time(void)
 
 static inline bool sk_can_busy_loop(const struct sock *sk)
 {
-	return sk->sk_ll_usec && sk->sk_napi_id && !signal_pending(current);
+	return sk->sk_ll_usec && !signal_pending(current);
 }
 
-
 static inline bool busy_loop_timeout(unsigned long end_time)
 {
 	unsigned long now = busy_loop_us_clock();
diff --git a/net/core/dev.c b/net/core/dev.c
index 7869ae3837ca..ab337bf5bbf4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5066,15 +5066,20 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	int (*napi_poll)(struct napi_struct *napi, int budget);
 	void *have_poll_lock = NULL;
 	struct napi_struct *napi;
+	unsigned int napi_id;
 	int rc;
 
 restart:
+	napi_id = READ_ONCE(sk->sk_napi_id);
+	if (napi_id < MIN_NAPI_ID)
+		return 0;
+
 	rc = false;
 	napi_poll = NULL;
 
 	rcu_read_lock();
 
-	napi = napi_by_id(sk->sk_napi_id);
+	napi = napi_by_id(napi_id);
 	if (!napi)
 		goto out;
 
@@ -5143,10 +5148,10 @@ static void napi_hash_add(struct napi_struct *napi)
 
 	spin_lock(&napi_hash_lock);
 
-	/* 0..NR_CPUS+1 range is reserved for sender_cpu use */
+	/* 0..NR_CPUS range is reserved for sender_cpu use */
 	do {
-		if (unlikely(++napi_gen_id < NR_CPUS + 1))
-			napi_gen_id = NR_CPUS + 1;
+		if (unlikely(++napi_gen_id < MIN_NAPI_ID))
+			napi_gen_id = MIN_NAPI_ID;
 	} while (napi_by_id(napi_gen_id));
 	napi->napi_id = napi_gen_id;
 
