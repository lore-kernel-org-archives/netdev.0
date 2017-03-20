From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 1/2] net: Busy polling should ignore sender CPUs
Date: Mon, 20 Mar 2017 14:48:48 -0700
Message-ID: <20170320214848.13922.79201.stgit@localhost.localdomain>
References: <20170320214643.13922.51284.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320214643.13922.51284.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is a cleanup/fix for NAPI IDs following the changes that made it
so that sender_cpu and napi_id were doing a better job of sharing the same
location in the sk_buff.

One issue I found is that we weren't validating the napi_id as being valid
before we started trying to setup the busy polling.  This change corrects
that by using the MIN_NAPI_ID value that is now used in both allocating the
NAPI IDs, as well as validating them.

Fixes: 52bd2d62ce675 ("net: better skb->sender_cpu and skb->napi_id cohabitation")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/net/busy_poll.h |   11 +++++++++--
 net/core/dev.c          |    6 +++---
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index c0452de83086..edf1310212a1 100644
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
@@ -58,10 +64,11 @@ static inline unsigned long busy_loop_end_time(void)
 
 static inline bool sk_can_busy_loop(const struct sock *sk)
 {
-	return sk->sk_ll_usec && sk->sk_napi_id && !signal_pending(current);
+	return sk->sk_ll_usec &&
+	       (sk->sk_napi_id >= MIN_NAPI_ID) &&
+	       !signal_pending(current);
 }
 
-
 static inline bool busy_loop_timeout(unsigned long end_time)
 {
 	unsigned long now = busy_loop_us_clock();
diff --git a/net/core/dev.c b/net/core/dev.c
index 7869ae3837ca..5bbe30c08a5b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5143,10 +5143,10 @@ static void napi_hash_add(struct napi_struct *napi)
 
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
 
