From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 4/4] ipv6: unify fragment thresh handling code
Date: Tue, 18 Sep 2012 21:45:11 +0800
Message-ID: <1347975911-5655-5-git-send-email-amwang@redhat.com>
References: <1347975911-5655-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757609Ab2IRNpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 09:45:47 -0400
In-Reply-To: <1347975911-5655-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/inet_frag.h                 |    2 +-
 net/ipv4/inet_fragment.c                |    9 +++++++--
 net/ipv4/ip_fragment.c                  |    5 ++---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    8 +++-----
 net/ipv6/reassembly.c                   |   16 +++++-----------
 5 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 5098ee7..32786a0 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -61,7 +61,7 @@ void inet_frags_exit_net(struct netns_frags *nf, stru=
ct inet_frags *f);
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
 void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f);
+int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bo=
ol force);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 85190e6..4750d2b 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -89,7 +89,7 @@ void inet_frags_exit_net(struct netns_frags *nf, stru=
ct inet_frags *f)
 	nf->low_thresh =3D 0;
=20
 	local_bh_disable();
-	inet_frag_evictor(nf, f);
+	inet_frag_evictor(nf, f, true);
 	local_bh_enable();
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
@@ -158,11 +158,16 @@ void inet_frag_destroy(struct inet_frag_queue *q,=
 struct inet_frags *f,
 }
 EXPORT_SYMBOL(inet_frag_destroy);
=20
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f)
+int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bo=
ol force)
 {
 	struct inet_frag_queue *q;
 	int work, evicted =3D 0;
=20
+	if (!force) {
+		if (atomic_read(&nf->mem) <=3D nf->high_thresh)
+			return 0;
+	}
+
 	work =3D atomic_read(&nf->mem) - nf->low_thresh;
 	while (work > 0) {
 		read_lock(&f->lock);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index fa6a12c..448e685 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -219,7 +219,7 @@ static void ip_evictor(struct net *net)
 {
 	int evicted;
=20
-	evicted =3D inet_frag_evictor(&net->ipv4.frags, &ip4_frags);
+	evicted =3D inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false);
 	if (evicted)
 		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
 }
@@ -684,8 +684,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
=20
 	/* Start by cleaning up the memory. */
-	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
-		ip_evictor(net);
+	ip_evictor(net);
=20
 	/* Lookup (or create) queue header */
 	if ((qp =3D ip_find(net, ip_hdr(skb), user)) !=3D NULL) {
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index 5a1307b..07e4fb0 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -563,11 +563,9 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff =
*skb, u32 user)
 	hdr =3D ipv6_hdr(clone);
 	fhdr =3D (struct frag_hdr *)skb_transport_header(clone);
=20
-	if (atomic_read(&net->nf_frag.frags.mem) > net->nf_frag.frags.high_th=
resh) {
-		local_bh_disable();
-		inet_frag_evictor(&net->nf_frag.frags, &nf_frags);
-		local_bh_enable();
-	}
+	local_bh_disable();
+	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
+	local_bh_enable();
=20
 	fq =3D fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->da=
ddr);
 	if (fq =3D=3D NULL) {
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index cac690c..a1610ac 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -131,15 +131,6 @@ void ip6_frag_init(struct inet_frag_queue *q, void=
 *a)
 }
 EXPORT_SYMBOL(ip6_frag_init);
=20
-static void ip6_evictor(struct net *net, struct inet6_dev *idev)
-{
-	int evicted;
-
-	evicted =3D inet_frag_evictor(&net->ipv6.frags, &ip6_frags);
-	if (evicted)
-		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS, evicted);
-}
-
 void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq, str=
uct inet_frags *frags)
 {
 	struct net_device *dev =3D NULL;
@@ -514,6 +505,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct frag_queue *fq;
 	const struct ipv6hdr *hdr =3D ipv6_hdr(skb);
 	struct net *net =3D dev_net(skb_dst(skb)->dev);
+	int evicted;
=20
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMRE=
QDS);
=20
@@ -538,8 +530,10 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
=20
-	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
-		ip6_evictor(net, ip6_dst_idev(skb_dst(skb)));
+	evicted =3D inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false);
+	if (evicted)
+		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
+				 IPSTATS_MIB_REASMFAILS, evicted);
=20
 	fq =3D fq_find(net, fhdr->identification, &hdr->saddr, &hdr->daddr);
 	if (fq !=3D NULL) {
--=20
1.7.7.6
