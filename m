From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] netfilter: nf_conntrack: consolidate lock/unlock into unlock_wait
Date: Mon, 14 Mar 2016 12:39:02 +0100
Message-ID: <1457955542-2377-1-git-send-email-hofrat@osadl.org>
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spin_lock()/spin_unlock() is synchronizing on the 
nf_conntrack_locks_all_lock which is equivalent to 
spin_unlock_wait() but the later should be more efficient.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was compile tested with: x86_64_defconfig (implies CONFIG_NETFILTER=y)
Simple run test on x86 64 with a few trivial ipfilter rules active.

Patch is against linux-next (localversion-next is next-20160311)

 net/netfilter/nf_conntrack_core.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f60b4fd..afde5f5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -74,8 +74,7 @@ void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
 	spin_lock(lock);
 	while (unlikely(nf_conntrack_locks_all)) {
 		spin_unlock(lock);
-		spin_lock(&nf_conntrack_locks_all_lock);
-		spin_unlock(&nf_conntrack_locks_all_lock);
+		spin_unlock_wait(&nf_conntrack_locks_all_lock);
 		spin_lock(lock);
 	}
 }
@@ -121,8 +120,7 @@ static void nf_conntrack_all_lock(void)
 	nf_conntrack_locks_all = true;
 
 	for (i = 0; i < CONNTRACK_LOCKS; i++) {
-		spin_lock(&nf_conntrack_locks[i]);
-		spin_unlock(&nf_conntrack_locks[i]);
+		spin_unlock_wait(&nf_conntrack_locks[i]);
 	}
 }
 
-- 
2.1.4
