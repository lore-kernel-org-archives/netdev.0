From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: fix nf_conntrack_l4proto_register()
Date: Fri, 29 Oct 2010 19:57:02 +0200
Message-ID: <1288375022.2560.306.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While doing __rcu annotations work on net/netfilter I found following
bug. On some arches, it is possible we publish a table while its content
is not yet committed to memory, and lockless reader can dereference wild
pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/nf_conntrack_proto.c |    6 ++++++
 1 files changed, 6 insertions(+)

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


