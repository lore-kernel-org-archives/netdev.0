From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/12: nf_conntrack: use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
Date: Thu, 26 Mar 2009 20:02:33 +0100 (MET)
Message-ID: <20090326190227.23365.25636.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 78f3648601fdc7a8166748bbd6d0555a88efa24a
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Mar 25 17:24:34 2009 +0100

    netfilter: nf_conntrack: use hlist_add_head_rcu() in nf_conntrack_set_hashsize()
    
    Using hlist_add_head() in nf_conntrack_set_hashsize() is quite dangerous.
    Without any barrier, one CPU could see a loop while doing its lookup.
    Its true new table cannot be seen by another cpu, but previous table is still
    readable.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 55befe5..54e983f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1121,7 +1121,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 					struct nf_conntrack_tuple_hash, hnode);
 			hlist_del_rcu(&h->hnode);
 			bucket = __hash_conntrack(&h->tuple, hashsize, rnd);
-			hlist_add_head(&h->hnode, &hash[bucket]);
+			hlist_add_head_rcu(&h->hnode, &hash[bucket]);
 		}
 	}
 	old_size = nf_conntrack_htable_size;
