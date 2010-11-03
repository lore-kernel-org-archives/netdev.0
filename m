From: kaber@trash.net
Subject: [PATCH 3/5] netfilter: fix nf_conntrack_l4proto_register()
Date: Wed,  3 Nov 2010 23:12:50 +0100
Message-ID: <1288822372-21245-4-git-send-email-kaber@trash.net>
References: <1288822372-21245-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288822372-21245-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

While doing __rcu annotations work on net/netfilter I found following
bug. On some arches, it is possible we publish a table while its content
is not yet committed to memory, and lockless reader can dereference wild
pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_proto.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index ed6d929..dc7bb74 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -292,6 +292,12 @@ int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 
 		for (i = 0; i < MAX_NF_CT_PROTO; i++)
 			proto_array[i] = &nf_conntrack_l4proto_generic;
+
+		/* Before making proto_array visible to lockless readers,
+		 * we must make sure its content is committed to memory.
+		 */
+		smp_wmb();
+
 		nf_ct_protos[l4proto->l3proto] = proto_array;
 	} else if (nf_ct_protos[l4proto->l3proto][l4proto->l4proto] !=
 					&nf_conntrack_l4proto_generic) {
-- 
1.7.1

