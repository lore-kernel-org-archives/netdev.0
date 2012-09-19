From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/4] ipv6: add a new namespace for nf_conntrack_reasm
Date: Wed, 19 Sep 2012 10:50:08 +0800
Message-ID: <1348023011-16195-2-git-send-email-amwang@redhat.com>
References: <1348023011-16195-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348023011-16195-1-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As pointed by Michal, it is necessary to add a new
namespace for nf_conntrack_reasm code, this prepares
for the second patch.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
Cc: David Miller <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/net_namespace.h             |    3 +
 include/net/netns/ipv6.h                |    8 ++
 net/ipv6/netfilter/nf_conntrack_reasm.c |  137 +++++++++++++++++++++--=
--------
 3 files changed, 106 insertions(+), 42 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5ae57f1..d61e2b3 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -93,6 +93,9 @@ struct net {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
 	struct netns_ct		ct;
 #endif
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+	struct netns_nf_frag	nf_frag;
+#endif
 	struct sock		*nfnl;
 	struct sock		*nfnl_stash;
 #endif
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 0318104..214cb0a 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -71,4 +71,12 @@ struct netns_ipv6 {
 #endif
 #endif
 };
+
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+struct netns_nf_frag {
+	struct netns_sysctl_ipv6 sysctl;
+	struct netns_frags	frags;
+};
+#endif
+
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index f94fb3a..f40f327 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -71,27 +71,26 @@ struct nf_ct_frag6_queue
 };
=20
 static struct inet_frags nf_frags;
-static struct netns_frags nf_init_frags;
=20
 #ifdef CONFIG_SYSCTL
 static struct ctl_table nf_ct_frag6_sysctl_table[] =3D {
 	{
 		.procname	=3D "nf_conntrack_frag6_timeout",
-		.data		=3D &nf_init_frags.timeout,
+		.data		=3D &init_net.nf_frag.frags.timeout,
 		.maxlen		=3D sizeof(unsigned int),
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec_jiffies,
 	},
 	{
 		.procname	=3D "nf_conntrack_frag6_low_thresh",
-		.data		=3D &nf_init_frags.low_thresh,
+		.data		=3D &init_net.nf_frag.frags.low_thresh,
 		.maxlen		=3D sizeof(unsigned int),
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec,
 	},
 	{
 		.procname	=3D "nf_conntrack_frag6_high_thresh",
-		.data		=3D &nf_init_frags.high_thresh,
+		.data		=3D &init_net.nf_frag.frags.high_thresh,
 		.maxlen		=3D sizeof(unsigned int),
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec,
@@ -99,7 +98,55 @@ static struct ctl_table nf_ct_frag6_sysctl_table[] =3D=
 {
 	{ }
 };
=20
-static struct ctl_table_header *nf_ct_frag6_sysctl_header;
+static int __net_init nf_ct_frag6_sysctl_register(struct net *net)
+{
+	struct ctl_table *table;
+	struct ctl_table_header *hdr;
+
+	table =3D nf_ct_frag6_sysctl_table;
+	if (!net_eq(net, &init_net)) {
+		table =3D kmemdup(table, sizeof(nf_ct_frag6_sysctl_table),
+				GFP_KERNEL);
+		if (table =3D=3D NULL)
+			goto err_alloc;
+
+		table[0].data =3D &net->ipv6.frags.high_thresh;
+		table[1].data =3D &net->ipv6.frags.low_thresh;
+		table[2].data =3D &net->ipv6.frags.timeout;
+	}
+
+	hdr =3D register_net_sysctl(net, "net/netfilter", table);
+	if (hdr =3D=3D NULL)
+		goto err_reg;
+
+	net->ipv6.sysctl.frags_hdr =3D hdr;
+	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(table);
+err_alloc:
+	return -ENOMEM;
+}
+
+static void __net_exit nf_ct_frags6_sysctl_unregister(struct net *net)
+{
+	struct ctl_table *table;
+
+	table =3D net->nf_frag.sysctl.frags_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(net->nf_frag.sysctl.frags_hdr);
+	if (!net_eq(net, &init_net))
+		kfree(table);
+}
+
+#else
+static int __net_init nf_ct_frag6_sysctl_register(struct net *net)
+{
+	return 0;
+}
+static void __net_exit nf_ct_frags6_sysctl_unregister(struct net *net)
+{
+}
 #endif
=20
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
@@ -131,13 +178,6 @@ static __inline__ void fq_kill(struct nf_ct_frag6_=
queue *fq)
 	inet_frag_kill(&fq->q, &nf_frags);
 }
=20
-static void nf_ct_frag6_evictor(void)
-{
-	local_bh_disable();
-	inet_frag_evictor(&nf_init_frags, &nf_frags);
-	local_bh_enable();
-}
-
 static void nf_ct_frag6_expire(unsigned long data)
 {
 	struct nf_ct_frag6_queue *fq;
@@ -158,9 +198,9 @@ out:
 }
=20
 /* Creation primitives. */
-
-static __inline__ struct nf_ct_frag6_queue *
-fq_find(__be32 id, u32 user, struct in6_addr *src, struct in6_addr *ds=
t)
+static inline struct nf_ct_frag6_queue *fq_find(struct net *net, __be3=
2 id,
+						u32 user, struct in6_addr *src,
+						struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
@@ -174,7 +214,7 @@ fq_find(__be32 id, u32 user, struct in6_addr *src, =
struct in6_addr *dst)
 	read_lock_bh(&nf_frags.lock);
 	hash =3D inet6_hash_frag(id, src, dst, nf_frags.rnd);
=20
-	q =3D inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
+	q =3D inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
 	if (q =3D=3D NULL)
 		goto oom;
@@ -312,7 +352,7 @@ found:
 	fq->q.meat +=3D skb->len;
 	if (payload_len > fq->q.max_size)
 		fq->q.max_size =3D payload_len;
-	atomic_add(skb->truesize, &nf_init_frags.mem);
+	atomic_add(skb->truesize, &fq->q.net->mem);
=20
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
@@ -322,7 +362,7 @@ found:
 		fq->q.last_in |=3D INET_FRAG_FIRST_IN;
 	}
 	write_lock(&nf_frags.lock);
-	list_move_tail(&fq->q.lru_list, &nf_init_frags.lru_list);
+	list_move_tail(&fq->q.lru_list, &fq->q.net->lru_list);
 	write_unlock(&nf_frags.lock);
 	return 0;
=20
@@ -391,7 +431,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, str=
uct net_device *dev)
 		clone->ip_summed =3D head->ip_summed;
=20
 		NFCT_FRAG6_CB(clone)->orig =3D NULL;
-		atomic_add(clone->truesize, &nf_init_frags.mem);
+		atomic_add(clone->truesize, &fq->q.net->mem);
 	}
=20
 	/* We have to remove fragment header from datagram and to relocate
@@ -415,7 +455,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, str=
uct net_device *dev)
 			head->csum =3D csum_add(head->csum, fp->csum);
 		head->truesize +=3D fp->truesize;
 	}
-	atomic_sub(head->truesize, &nf_init_frags.mem);
+	atomic_sub(head->truesize, &fq->q.net->mem);
=20
 	head->local_df =3D 1;
 	head->next =3D NULL;
@@ -527,6 +567,8 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *=
skb, u32 user)
 {
 	struct sk_buff *clone;
 	struct net_device *dev =3D skb->dev;
+	struct net *net =3D skb_dst(skb) ? dev_net(skb_dst(skb)->dev)
+				       : dev_net(skb->dev);
 	struct frag_hdr *fhdr;
 	struct nf_ct_frag6_queue *fq;
 	struct ipv6hdr *hdr;
@@ -560,10 +602,13 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff=
 *skb, u32 user)
 	hdr =3D ipv6_hdr(clone);
 	fhdr =3D (struct frag_hdr *)skb_transport_header(clone);
=20
-	if (atomic_read(&nf_init_frags.mem) > nf_init_frags.high_thresh)
-		nf_ct_frag6_evictor();
+	if (atomic_read(&net->nf_frag.frags.mem) > net->nf_frag.frags.high_th=
resh) {
+		local_bh_disable();
+		inet_frag_evictor(&net->nf_frag.frags, &nf_frags);
+		local_bh_enable();
+	}
=20
-	fq =3D fq_find(fhdr->identification, user, &hdr->saddr, &hdr->daddr);
+	fq =3D fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->da=
ddr);
 	if (fq =3D=3D NULL) {
 		pr_debug("Can't find and can't create new queue\n");
 		goto ret_orig;
@@ -621,8 +666,31 @@ void nf_ct_frag6_output(unsigned int hooknum, stru=
ct sk_buff *skb,
 	nf_conntrack_put_reasm(skb);
 }
=20
+static int nf_ct_net_init(struct net *net)
+{
+	net->nf_frag.frags.high_thresh =3D IPV6_FRAG_HIGH_THRESH;
+	net->nf_frag.frags.low_thresh =3D IPV6_FRAG_LOW_THRESH;
+	net->nf_frag.frags.timeout =3D IPV6_FRAG_TIMEOUT;
+	inet_frags_init_net(&net->nf_frag.frags);
+
+	return nf_ct_frag6_sysctl_register(net);
+}
+
+static void nf_ct_net_exit(struct net *net)
+{
+	nf_ct_frags6_sysctl_unregister(net);
+	inet_frags_exit_net(&net->nf_frag.frags, &nf_frags);
+}
+
+static struct pernet_operations nf_ct_net_ops =3D {
+	.init =3D nf_ct_net_init,
+	.exit =3D nf_ct_net_exit,
+};
+
 int nf_ct_frag6_init(void)
 {
+	int ret =3D 0;
+
 	nf_frags.hashfn =3D nf_hashfn;
 	nf_frags.constructor =3D ip6_frag_init;
 	nf_frags.destructor =3D NULL;
@@ -631,32 +699,17 @@ int nf_ct_frag6_init(void)
 	nf_frags.match =3D ip6_frag_match;
 	nf_frags.frag_expire =3D nf_ct_frag6_expire;
 	nf_frags.secret_interval =3D 10 * 60 * HZ;
-	nf_init_frags.timeout =3D IPV6_FRAG_TIMEOUT;
-	nf_init_frags.high_thresh =3D IPV6_FRAG_HIGH_THRESH;
-	nf_init_frags.low_thresh =3D IPV6_FRAG_LOW_THRESH;
-	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
=20
-#ifdef CONFIG_SYSCTL
-	nf_ct_frag6_sysctl_header =3D register_net_sysctl(&init_net, "net/net=
filter",
-							nf_ct_frag6_sysctl_table);
-	if (!nf_ct_frag6_sysctl_header) {
+	ret =3D register_pernet_subsys(&nf_ct_net_ops);
+	if (ret)
 		inet_frags_fini(&nf_frags);
-		return -ENOMEM;
-	}
-#endif
=20
-	return 0;
+	return ret;
 }
=20
 void nf_ct_frag6_cleanup(void)
 {
-#ifdef CONFIG_SYSCTL
-	unregister_net_sysctl_table(nf_ct_frag6_sysctl_header);
-	nf_ct_frag6_sysctl_header =3D NULL;
-#endif
+	unregister_pernet_subsys(&nf_ct_net_ops);
 	inet_frags_fini(&nf_frags);
-
-	nf_init_frags.low_thresh =3D 0;
-	nf_ct_frag6_evictor();
 }
--=20
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
