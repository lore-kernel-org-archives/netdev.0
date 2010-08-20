From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Sat, 21 Aug 2010 00:06:44 +0800
Message-ID: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_conntrack_alloc() isn't called with nf_conntrack_lock locked, so hash
random initializing code maybe executed more than once on different CPUs.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_core.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index df3eedb..7ae7f71 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -65,8 +65,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
-static int nf_conntrack_hash_rnd_initted;
-static unsigned int nf_conntrack_hash_rnd;
+static unsigned int nf_conntrack_hash_rnd __read_mostly;
 
 static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
 				  u16 zone, unsigned int size, unsigned int rnd)
@@ -574,10 +573,16 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 {
 	struct nf_conn *ct;
 
-	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
-		get_random_bytes(&nf_conntrack_hash_rnd,
-				sizeof(nf_conntrack_hash_rnd));
-		nf_conntrack_hash_rnd_initted = 1;
+	if (unlikely(!nf_conntrack_hash_rnd)) {
+		unsigned int rand;
+
+		/* Why not initialize nf_conntrack_rnd in a "init()" function ?
+		 * Because there isn't enough entropy when system initializing,
+		 * and we initialize it as late as possible. */
+		do {
+			get_random_bytes(&rand, sizeof(rand));
+		} while (!rand);
+		cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
 	}
 
 	/* We don't want any race condition at early drop stage */
