From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net] netfilter: nf_conntrack: Use net_mutex for helper unregistration.
Date: Thu,  5 May 2016 15:50:37 -0700
Message-ID: <1462488637-46877-1-git-send-email-joe@ovn.org>
Cc: Joe Stringer <joe@ovn.org>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a user loads nf_conntrack_ftp, sends FTP traffic through a network
namespace, destroys that namespace then unloads the FTP helper module,
then the kernel will crash.

Florian's assessment of the bug:

    AFAIU following happens:

    1. ct is created with ftp helper in netns x
    2. netns x gets destroyed
    3. netns destruction is scheduled
    4. netns destruction wq starts, removes netns from global list
    5. ftp helper is unloaded, which resets all helpers of the conntracks

    ... but because netns is already gone from list the for_each_net() loop
    doesn't include it, so we do not change any of the conntracks in net
    namespaces that are already dead.

    6. netns destruction invokes destructor for rmmod'ed helper

Backtrace:

BUG: unable to handle kernel paging request at ffffffffa03d60c8
IP: [<ffffffffa00bc797>] nf_ct_helper_destroy+0x97/0x170 [nf_conntrack]
...
Oops: 0000 [#1] SMP
Workqueue: netns cleanup_net
...
Call Trace:
 [<ffffffffa00bc73c>] ? nf_ct_helper_destroy+0x3c/0x170 [nf_conntrack]
 [<ffffffffa00b6c9c>] nf_ct_delete+0x3c/0x1e0 [nf_conntrack]
 [<ffffffffa00bc9f0>] ? nf_conntrack_helper_fini+0x30/0x30 [nf_conntrack]
 [<ffffffffa00b75c8>] nf_ct_iterate_cleanup+0x258/0x270 [nf_conntrack]
 [<ffffffffa00bcf0f>] nf_ct_l3proto_pernet_unregister+0x2f/0x60 [nf_conntrack]
 [<ffffffffa00370e9>] ipv4_net_exit+0x19/0x50 [nf_conntrack_ipv4]
 [<ffffffff81668fa8>] ops_exit_list.isra.4+0x38/0x60
 [<ffffffff8166a35e>] cleanup_net+0x1be/0x290
 [<ffffffff81085b2c>] process_one_work+0x1dc/0x660
 [<ffffffff81085ab1>] ? process_one_work+0x161/0x660
 [<ffffffff810860db>] worker_thread+0x12b/0x4a0
 [<ffffffff81085fb0>] ? process_one_work+0x660/0x660
 [<ffffffff8108ca22>] kthread+0xf2/0x110
 [<ffffffff817a6c02>] ret_from_fork+0x22/0x40
 [<ffffffff8108c930>] ? kthread_create_on_node+0x220/0x220

Fix the issue by using net_mutex during conntrack helper unregistration.

Suggested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Joe Stringer <joe@ovn.org>
---

I've boiled it down to a repro script here:
https://gist.github.com/joestringer/465328172ee8960242142572b0ffc6e1

There's nothing special about the FTP server (requires pyftpdlib):
https://github.com/openvswitch/ovs/blob/v2.5.0/tests/test-l7.py

Other script dependencies are conntrack, ip, bridge-utils, wget.

This issue may be mitigated by disabling automatic conntrack helper
assignment.

In regards to affected kernels, I looked back as far as 3.13 and I can
still reproduce the issue with the above script. I haven't looked further.
---
 net/core/net_namespace.c            | 1 +
 net/netfilter/nf_conntrack_helper.c | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b629b1..cf9058409082 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -28,6 +28,7 @@
 static LIST_HEAD(pernet_list);
 static struct list_head *first_device = &pernet_list;
 DEFINE_MUTEX(net_mutex);
+EXPORT_SYMBOL_GPL(net_mutex);
 
 LIST_HEAD(net_namespace_list);
 EXPORT_SYMBOL_GPL(net_namespace_list);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 3b40ec575cd5..6860b19be406 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -449,10 +449,10 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	 */
 	synchronize_rcu();
 
-	rtnl_lock();
+	mutex_lock(&net_mutex);
 	for_each_net(net)
 		__nf_conntrack_helper_unregister(me, net);
-	rtnl_unlock();
+	mutex_unlock(&net_mutex);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
 
-- 
2.1.4

