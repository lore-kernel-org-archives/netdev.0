From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] netfilter: nf_conntrack: release conntrack from rcu callback
Date: Mon,  6 Jan 2014 19:54:32 +0400
Message-ID: <1389023672-14351-1-git-send-email-avagin@openvz.org>
Cc: netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vvs@openvz.org, Andrey Vagin <avagin@openvz.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lets look at destroy_conntrack:

hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
...
nf_conntrack_free(ct)
	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);

The hash is protected by rcu, so readers look up conntracks without
locks.
A conntrack is removed from the hash, but in this moment a few readers
still can use the conntrack, so if we call kmem_cache_free now, all
readers will read released object.

Bellow you can find more tricky race condition of three tasks.

task 1			task 2			task 3
			nf_conntrack_find_get
			 ____nf_conntrack_find
destroy_conntrack
 hlist_nulls_del_rcu
 nf_conntrack_free
 kmem_cache_free
						__nf_conntrack_alloc
						 kmem_cache_alloc
						 memset(&ct->tuplehash[IP_CT_DIR_MAX],
			 if (nf_ct_is_dying(ct))

In this case the task 2 will not understand, that it uses a wrong
conntrack.

I'm not sure, that I have ever seen this race condition in a real life.
Currently we are investigating a bug, which is reproduced on a few node.
In our case one conntrack is initialized from a few tasks concurrently,
we don't have any other explanation for this.

<2>[46267.083061] kernel BUG at net/ipv4/netfilter/nf_nat_core.c:322!
...
<4>[46267.083951] RIP: 0010:[<ffffffffa01e00a4>]  [<ffffffffa01e00a4>] nf_nat_setup_info+0x564/0x590 [nf_nat]
...
<4>[46267.085549] Call Trace:
<4>[46267.085622]  [<ffffffffa023421b>] alloc_null_binding+0x5b/0xa0 [iptable_nat]
<4>[46267.085697]  [<ffffffffa02342bc>] nf_nat_rule_find+0x5c/0x80 [iptable_nat]
<4>[46267.085770]  [<ffffffffa0234521>] nf_nat_fn+0x111/0x260 [iptable_nat]
<4>[46267.085843]  [<ffffffffa0234798>] nf_nat_out+0x48/0xd0 [iptable_nat]
<4>[46267.085919]  [<ffffffff814841b9>] nf_iterate+0x69/0xb0
<4>[46267.085991]  [<ffffffff81494e70>] ? ip_finish_output+0x0/0x2f0
<4>[46267.086063]  [<ffffffff81484374>] nf_hook_slow+0x74/0x110
<4>[46267.086133]  [<ffffffff81494e70>] ? ip_finish_output+0x0/0x2f0
<4>[46267.086207]  [<ffffffff814b5890>] ? dst_output+0x0/0x20
<4>[46267.086277]  [<ffffffff81495204>] ip_output+0xa4/0xc0
<4>[46267.086346]  [<ffffffff814b65a4>] raw_sendmsg+0x8b4/0x910
<4>[46267.086419]  [<ffffffff814c10fa>] inet_sendmsg+0x4a/0xb0
<4>[46267.086491]  [<ffffffff814459aa>] ? sock_update_classid+0x3a/0x50
<4>[46267.086562]  [<ffffffff81444d67>] sock_sendmsg+0x117/0x140
<4>[46267.086638]  [<ffffffff8151997b>] ? _spin_unlock_bh+0x1b/0x20
<4>[46267.086712]  [<ffffffff8109d370>] ? autoremove_wake_function+0x0/0x40
<4>[46267.086785]  [<ffffffff81495e80>] ? do_ip_setsockopt+0x90/0xd80
<4>[46267.086858]  [<ffffffff8100be0e>] ? call_function_interrupt+0xe/0x20
<4>[46267.086936]  [<ffffffff8118cb10>] ? ub_slab_ptr+0x20/0x90
<4>[46267.087006]  [<ffffffff8118cb10>] ? ub_slab_ptr+0x20/0x90
<4>[46267.087081]  [<ffffffff8118f2e8>] ? kmem_cache_alloc+0xd8/0x1e0
<4>[46267.087151]  [<ffffffff81445599>] sys_sendto+0x139/0x190
<4>[46267.087229]  [<ffffffff81448c0d>] ? sock_setsockopt+0x16d/0x6f0
<4>[46267.087303]  [<ffffffff810efa47>] ? audit_syscall_entry+0x1d7/0x200
<4>[46267.087378]  [<ffffffff810ef795>] ? __audit_syscall_exit+0x265/0x290
<4>[46267.087454]  [<ffffffff81474885>] ? compat_sys_setsockopt+0x75/0x210
<4>[46267.087531]  [<ffffffff81474b5f>] compat_sys_socketcall+0x13f/0x210
<4>[46267.087607]  [<ffffffff8104dea3>] ia32_sysret+0x0/0x5
<4>[46267.087676] Code: 91 20 e2 01 75 29 48 89 de 4c 89 f7 e8 56 fa ff ff 85 c0 0f 84 68 fc ff ff 0f b6 4d c6 41 8b 45 00 e9 4d fb ff ff e8 7c 19 e9 e0 <0f> 0b eb fe f6 05 17 91 20 e2 80 74 ce 80 3d 5f 2e 00 00 00 74
<1>[46267.088023] RIP  [<ffffffffa01e00a4>] nf_nat_setup_info+0x564/0x590

Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/net/netfilter/nf_conntrack.h |  2 ++
 net/netfilter/nf_conntrack_core.c    | 11 +++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 01ea6ee..492e857 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -76,6 +76,8 @@ struct nf_conn {
            plus 1 for any connection(s) we are `master' for */
 	struct nf_conntrack ct_general;
 
+	struct rcu_head rcu;
+
 	spinlock_t lock;
 
 	/* XXX should I move this to the tail ? - Y.K */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 43549eb..40e0d61 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -198,6 +198,14 @@ clean_from_lists(struct nf_conn *ct)
 	nf_ct_remove_expectations(ct);
 }
 
+static void nf_conntrack_free_rcu(struct rcu_head *head)
+{
+	struct nf_conn *ct = container_of(head, struct nf_conn, rcu);
+
+	pr_debug("destroy_conntrack: returning ct=%p to slab\n", ct);
+	nf_conntrack_free(ct);
+}
+
 static void
 destroy_conntrack(struct nf_conntrack *nfct)
 {
@@ -236,8 +244,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	if (ct->master)
 		nf_ct_put(ct->master);
 
-	pr_debug("destroy_conntrack: returning ct=%p to slab\n", ct);
-	nf_conntrack_free(ct);
+	call_rcu(&ct->rcu, nf_conntrack_free_rcu);
 }
 
 static void nf_ct_delete_from_lists(struct nf_conn *ct)
-- 
1.8.4.2
