From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/14] netfilter: conntrack: fix CT target for UNSPEC helpers
Date: Thu, 10 Nov 2016 01:23:45 +0100
Message-ID: <1478737427-1574-13-git-send-email-pablo@netfilter.org>
References: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1478737427-1574-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Thomas reports its not possible to attach the H.245 helper:

iptables -t raw -A PREROUTING -p udp -j CT --helper H.245
iptables: No chain/target/match by that name.
xt_CT: No such helper "H.245"

This is because H.245 registers as NFPROTO_UNSPEC, but the CT target
passes NFPROTO_IPV4/IPV6 to nf_conntrack_helper_try_module_get.

We should treat UNSPEC as wildcard and ignore the l3num instead.

Reported-by: Thomas Woerner <twoerner@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 336e21559e01..7341adf7059d 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -138,9 +138,14 @@ __nf_conntrack_helper_find(const char *name, u16 l3num, u8 protonum)
 
 	for (i = 0; i < nf_ct_helper_hsize; i++) {
 		hlist_for_each_entry_rcu(h, &nf_ct_helper_hash[i], hnode) {
-			if (!strcmp(h->name, name) &&
-			    h->tuple.src.l3num == l3num &&
-			    h->tuple.dst.protonum == protonum)
+			if (strcmp(h->name, name))
+				continue;
+
+			if (h->tuple.src.l3num != NFPROTO_UNSPEC &&
+			    h->tuple.src.l3num != l3num)
+				continue;
+
+			if (h->tuple.dst.protonum == protonum)
 				return h;
 		}
 	}
-- 
2.1.4

