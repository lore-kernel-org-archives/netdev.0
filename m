From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/11] netfilter: nat: switch to new rhlist interface
Date: Wed, 30 Nov 2016 22:57:20 +0100
Message-ID: <1480543045-3389-7-git-send-email-pablo@netfilter.org>
References: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

I got offlist bug report about failing connections and high cpu usage.
This happens because we hit 'elasticity' checks in rhashtable that
refuses bucket list exceeding 16 entries.

The nat bysrc hash unfortunately needs to insert distinct objects that
share same key and are identical (have same source tuple), this cannot
be avoided.

Switch to the rhlist interface which is designed for this.

The nulls_base is removed here, I don't think its needed:

A (unlikely) false positive results in unneeded port clash resolution,
a false negative results in packet drop during conntrack confirmation,
when we try to insert the duplicate into main conntrack hash table.

Tested by adding multiple ip addresses to host, then adding
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

... and then creating multiple connections, from same source port but
different addresses:

for i in $(seq 2000 2032);do nc -p 1234 192.168.7.1 $i > /dev/null  & done

(all of these then get hashed to same bysource slot)

Then, to test that nat conflict resultion is working:

nc -s 10.0.0.1 -p 1234 192.168.7.1 2000
nc -s 10.0.0.2 -p 1234 192.168.7.1 2000

tcp  .. src=10.0.0.1 dst=192.168.7.1 sport=1234 dport=2000 src=192.168.7.1 dst=192.168.7.10 sport=2000 dport=1024 [ASSURED]
tcp  .. src=10.0.0.2 dst=192.168.7.1 sport=1234 dport=2000 src=192.168.7.1 dst=192.168.7.10 sport=2000 dport=1025 [ASSURED]
tcp  .. src=192.168.7.10 dst=192.168.7.1 sport=1234 dport=2000 src=192.168.7.1 dst=192.168.7.10 sport=2000 dport=1234 [ASSURED]
tcp  .. src=192.168.7.10 dst=192.168.7.1 sport=1234 dport=2001 src=192.168.7.1 dst=192.168.7.10 sport=2001 dport=1234 [ASSURED]
[..]

-> nat altered source ports to 1024 and 1025, respectively.
This can also be confirmed on destination host which shows
ESTAB      0      0   192.168.7.1:2000      192.168.7.10:1024
ESTAB      0      0   192.168.7.1:2000      192.168.7.10:1025
ESTAB      0      0   192.168.7.1:2000      192.168.7.10:1234

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Fixes: 870190a9ec907 ("netfilter: nat: convert nat bysrc hash to rhashtable")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  2 +-
 net/netfilter/nf_nat_core.c          | 40 +++++++++++++++++++++---------------
 2 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 50418052a520..dc143ada9762 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -118,7 +118,7 @@ struct nf_conn {
 	struct nf_ct_ext *ext;
 
 #if IS_ENABLED(CONFIG_NF_NAT)
-	struct rhash_head	nat_bysource;
+	struct rhlist_head nat_bysource;
 #endif
 	/* Storage reserved for other modules, must be the last member */
 	union nf_conntrack_proto proto;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index c632429706eb..5b9c884a452e 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -42,7 +42,7 @@ struct nf_nat_conn_key {
 	const struct nf_conntrack_zone *zone;
 };
 
-static struct rhashtable nf_nat_bysource_table;
+static struct rhltable nf_nat_bysource_table;
 
 inline const struct nf_nat_l3proto *
 __nf_nat_l3proto_find(u8 family)
@@ -207,7 +207,6 @@ static struct rhashtable_params nf_nat_bysource_params = {
 	.obj_cmpfn = nf_nat_bysource_cmp,
 	.nelem_hint = 256,
 	.min_size = 1024,
-	.nulls_base = (1U << RHT_BASE_SHIFT),
 };
 
 /* Only called for SRC manip */
@@ -226,12 +225,15 @@ find_appropriate_src(struct net *net,
 		.tuple = tuple,
 		.zone = zone
 	};
+	struct rhlist_head *hl;
 
-	ct = rhashtable_lookup_fast(&nf_nat_bysource_table, &key,
-				    nf_nat_bysource_params);
-	if (!ct)
+	hl = rhltable_lookup(&nf_nat_bysource_table, &key,
+			     nf_nat_bysource_params);
+	if (!hl)
 		return 0;
 
+	ct = container_of(hl, typeof(*ct), nat_bysource);
+
 	nf_ct_invert_tuplepr(result,
 			     &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 	result->dst = tuple->dst;
@@ -449,11 +451,17 @@ nf_nat_setup_info(struct nf_conn *ct,
 	}
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
+		struct nf_nat_conn_key key = {
+			.net = nf_ct_net(ct),
+			.tuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
+			.zone = nf_ct_zone(ct),
+		};
 		int err;
 
-		err = rhashtable_insert_fast(&nf_nat_bysource_table,
-					     &ct->nat_bysource,
-					     nf_nat_bysource_params);
+		err = rhltable_insert_key(&nf_nat_bysource_table,
+					  &key,
+					  &ct->nat_bysource,
+					  nf_nat_bysource_params);
 		if (err)
 			return NF_DROP;
 	}
@@ -570,8 +578,8 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 	 * will delete entry from already-freed table.
 	 */
 	ct->status &= ~IPS_NAT_DONE_MASK;
-	rhashtable_remove_fast(&nf_nat_bysource_table, &ct->nat_bysource,
-			       nf_nat_bysource_params);
+	rhltable_remove(&nf_nat_bysource_table, &ct->nat_bysource,
+			nf_nat_bysource_params);
 
 	/* don't delete conntrack.  Although that would make things a lot
 	 * simpler, we'd end up flushing all conntracks on nat rmmod.
@@ -701,8 +709,8 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 	if (!nat)
 		return;
 
-	rhashtable_remove_fast(&nf_nat_bysource_table, &ct->nat_bysource,
-			       nf_nat_bysource_params);
+	rhltable_remove(&nf_nat_bysource_table, &ct->nat_bysource,
+			nf_nat_bysource_params);
 }
 
 static struct nf_ct_ext_type nat_extend __read_mostly = {
@@ -837,13 +845,13 @@ static int __init nf_nat_init(void)
 {
 	int ret;
 
-	ret = rhashtable_init(&nf_nat_bysource_table, &nf_nat_bysource_params);
+	ret = rhltable_init(&nf_nat_bysource_table, &nf_nat_bysource_params);
 	if (ret)
 		return ret;
 
 	ret = nf_ct_extend_register(&nat_extend);
 	if (ret < 0) {
-		rhashtable_destroy(&nf_nat_bysource_table);
+		rhltable_destroy(&nf_nat_bysource_table);
 		printk(KERN_ERR "nf_nat_core: Unable to register extension\n");
 		return ret;
 	}
@@ -867,7 +875,7 @@ static int __init nf_nat_init(void)
 	return 0;
 
  cleanup_extend:
-	rhashtable_destroy(&nf_nat_bysource_table);
+	rhltable_destroy(&nf_nat_bysource_table);
 	nf_ct_extend_unregister(&nat_extend);
 	return ret;
 }
@@ -886,7 +894,7 @@ static void __exit nf_nat_cleanup(void)
 	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		kfree(nf_nat_l4protos[i]);
 
-	rhashtable_destroy(&nf_nat_bysource_table);
+	rhltable_destroy(&nf_nat_bysource_table);
 }
 
 MODULE_LICENSE("GPL");
-- 
2.1.4

