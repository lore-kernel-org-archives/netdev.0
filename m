From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: conntrack: skip clash resolution if nat is in place
Date: Tue, 12 Jul 2016 18:11:02 +0200
Message-ID: <1468339862-4028-7-git-send-email-pablo@netfilter.org>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The clash resolution is not easy to apply if the NAT table is
registered. Even if no NAT rules are installed, the nul-binding ensures
that a unique tuple is used, thus, the packet that loses race gets a
different source port number, as described by:

http://marc.info/?l=netfilter-devel&m=146818011604484&w=2

Clash resolution with NAT is also problematic if addresses/port range
ports are used since the conntrack that wins race may describe a
different mangling that we may have earlier applied to the packet via
nf_nat_setup_info().

Fixes: 71d8c47fc653 ("netfilter: conntrack: introduce clash resolution on insertion race")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Marc Dionne <marc.c.dionne@gmail.com>
---
 net/netfilter/nf_conntrack_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 62c42e9..9f530ad 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -646,6 +646,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->allow_clash &&
+	    !nfct_nat(ct) &&
 	    !nf_ct_is_dying(ct) &&
 	    atomic_inc_not_zero(&ct->ct_general.use)) {
 		nf_ct_acct_merge(ct, ctinfo, (struct nf_conn *)skb->nfct);
-- 
2.1.4

