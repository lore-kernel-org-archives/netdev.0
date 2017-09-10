From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] netfilter: nat: Do not use ARRAY_SIZE() on spinlocks to fix zero div
Date: Sun, 10 Sep 2017 13:41:41 +0200
Message-ID: <1505043701-13255-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If no spinlock debugging options (CONFIG_GENERIC_LOCKBREAK,
CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_LOCK_ALLOC) are enabled on a UP
platform (e.g. m68k defconfig), arch_spinlock_t is an empty struct,
hence using ARRAY_SIZE(nf_nat_locks) causes a division by zero:

    net/netfilter/nf_nat_core.c: In function ‘nf_nat_setup_info’:
    net/netfilter/nf_nat_core.c:432: warning: division by zero
    net/netfilter/nf_nat_core.c: In function ‘__nf_nat_cleanup_conntrack’:
    net/netfilter/nf_nat_core.c:535: warning: division by zero
    net/netfilter/nf_nat_core.c:537: warning: division by zero
    net/netfilter/nf_nat_core.c: In function ‘nf_nat_init’:
    net/netfilter/nf_nat_core.c:810: warning: division by zero
    net/netfilter/nf_nat_core.c:811: warning: division by zero
    net/netfilter/nf_nat_core.c:824: warning: division by zero

Fix this by using the CONNTRACK_LOCKS definition instead.

Suggested-by: Florian Westphal <fw@strlen.de>
Fixes: 8073e960a03bf7b5 ("netfilter: nat: use keyed locks")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/netfilter/nf_nat_core.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index f393a7086025f6c5..af8345fc4fbde30a 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -429,7 +429,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 
 		srchash = hash_by_src(net,
 				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-		lock = &nf_nat_locks[srchash % ARRAY_SIZE(nf_nat_locks)];
+		lock = &nf_nat_locks[srchash % CONNTRACK_LOCKS];
 		spin_lock_bh(lock);
 		hlist_add_head_rcu(&ct->nat_bysource,
 				   &nf_nat_bysource[srchash]);
@@ -532,9 +532,9 @@ static void __nf_nat_cleanup_conntrack(struct nf_conn *ct)
 	unsigned int h;
 
 	h = hash_by_src(nf_ct_net(ct), &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	spin_lock_bh(&nf_nat_locks[h % ARRAY_SIZE(nf_nat_locks)]);
+	spin_lock_bh(&nf_nat_locks[h % CONNTRACK_LOCKS]);
 	hlist_del_rcu(&ct->nat_bysource);
-	spin_unlock_bh(&nf_nat_locks[h % ARRAY_SIZE(nf_nat_locks)]);
+	spin_unlock_bh(&nf_nat_locks[h % CONNTRACK_LOCKS]);
 }
 
 static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
@@ -807,8 +807,8 @@ static int __init nf_nat_init(void)
 
 	/* Leave them the same for the moment. */
 	nf_nat_htable_size = nf_conntrack_htable_size;
-	if (nf_nat_htable_size < ARRAY_SIZE(nf_nat_locks))
-		nf_nat_htable_size = ARRAY_SIZE(nf_nat_locks);
+	if (nf_nat_htable_size < CONNTRACK_LOCKS)
+		nf_nat_htable_size = CONNTRACK_LOCKS;
 
 	nf_nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size, 0);
 	if (!nf_nat_bysource)
@@ -821,7 +821,7 @@ static int __init nf_nat_init(void)
 		return ret;
 	}
 
-	for (i = 0; i < ARRAY_SIZE(nf_nat_locks); i++)
+	for (i = 0; i < CONNTRACK_LOCKS; i++)
 		spin_lock_init(&nf_nat_locks[i]);
 
 	nf_ct_helper_expectfn_register(&follow_master_nat);
-- 
2.7.4

