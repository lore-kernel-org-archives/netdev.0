From: pablo@netfilter.org
Subject: [PATCH 2/2] netfilter: nf_ct_ecache: fix crash with multiple containers, one shutting down
Date: Fri,  6 Jul 2012 13:39:39 +0200
Message-ID: <1341574779-3373-3-git-send-email-pablo@netfilter.org>
References: <1341574779-3373-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341574779-3373-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hans reports that he's still hitting:

BUG: unable to handle kernel NULL pointer dereference at 000000000000027c
IP: [<ffffffff813615db>] netlink_has_listeners+0xb/0x60
PGD 0
Oops: 0000 [#3] PREEMPT SMP
CPU 0

It happens when adding a number of containers with do:

nfct_query(h, NFCT_Q_CREATE, ct);

and most likely one namespace shuts down.

this problem was supposed to be fixed by:
70e9942 netfilter: nf_conntrack: make event callback registration per-netns

Still, it was missing one rcu_access_pointer to check if the callback
is set or not.

Reported-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_ecache.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index a88fb69..e1ce104 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -78,7 +78,7 @@ nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *e;
 
-	if (net->ct.nf_conntrack_event_cb == NULL)
+	if (!rcu_access_pointer(net->ct.nf_conntrack_event_cb))
 		return;
 
 	e = nf_ct_ecache_find(ct);
-- 
1.7.10

