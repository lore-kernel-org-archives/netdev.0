From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Thu, 10 Jan 2013 17:41:54 +0100
Message-ID: <20130110164154.GA5457@1984>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Gao,

On Fri, Dec 28, 2012 at 10:36:27AM +0800, Gao feng wrote:
> canqun zhang reported a panic BUG,kernel may panic when
> unloading nf_conntrack module.
> 
> It's because we reset nf_ct_destroy to NULL when we deal
> with init_net,it's too early.Some packets belongs to other
> netns still refers to the conntrack.when these packets need
> to be freed, kfree_skb will call nf_ct_destroy which is
> NULL.
> 
> fix this bug by moving the nf_conntrack initialize and cleanup
> codes out of the pernet operations,this job should be done
> in module_init/exit.We can't use init_net to identify if
> it's the right time.

First off, thanks for looking into this.

I want to get this fix into 3.8 and -stable but this patch includes a
rework whose scope is net-next (upcoming 3.9).

The attached patch aims to fix the issue according to your patch
description. Once this is in, we can revisit your code refactoring
proposal.

Let me know.

--gBBFr7Ir9EOA20Yy
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nf_conntrack-fix-BUG_ON-while-removing-nf_.patch"

>From a211bd666fbfe17ae7171a50ad92fedc7b9e19fa Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 10 Jan 2013 16:12:01 +0100
Subject: [PATCH] netfilter: nf_conntrack: fix BUG_ON while removing
 nf_conntrack with netns

canqun zhang reported that we're hitting BUG_ON in the
nf_conntrack_destroy path when calling kfree_skb while
rmmod'ing the nf_conntrack module.

Currently, the nf_ct_destroy hook is being set to NULL in the
destroy path of conntrack.init_net. However, this is a problem
since init_net may be destroyed before any other existing netns
(we cannot assume any specific ordering while releasing existing
netns according to what I read in recent emails).

Thanks to Gao feng for initial patch to address this issue.

Reported-by: canqun zhang <canqunzhang@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h |    2 ++
 net/netfilter/nf_conntrack_core.c         |    9 +++++----
 net/netfilter/nf_conntrack_standalone.c   |    1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index d8f5b9f..e98aeb3 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -31,6 +31,8 @@ extern void nf_conntrack_cleanup(struct net *net);
 extern int nf_conntrack_proto_init(struct net *net);
 extern void nf_conntrack_proto_fini(struct net *net);
 
+extern void nf_conntrack_cleanup_end(void);
+
 extern bool
 nf_ct_get_tuple(const struct sk_buff *skb,
 		unsigned int nhoff,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 016d95e..e4a0c4f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1376,11 +1376,12 @@ void nf_conntrack_cleanup(struct net *net)
 	synchronize_net();
 	nf_conntrack_proto_fini(net);
 	nf_conntrack_cleanup_net(net);
+}
 
-	if (net_eq(net, &init_net)) {
-		RCU_INIT_POINTER(nf_ct_destroy, NULL);
-		nf_conntrack_cleanup_init_net();
-	}
+void nf_conntrack_cleanup_end(void)
+{
+	RCU_INIT_POINTER(nf_ct_destroy, NULL);
+	nf_conntrack_cleanup_init_net();
 }
 
 void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 363285d..e7185c6 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -575,6 +575,7 @@ static int __init nf_conntrack_standalone_init(void)
 static void __exit nf_conntrack_standalone_fini(void)
 {
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
+	nf_conntrack_cleanup_end();
 }
 
 module_init(nf_conntrack_standalone_init);
-- 
1.7.10.4


--gBBFr7Ir9EOA20Yy--
