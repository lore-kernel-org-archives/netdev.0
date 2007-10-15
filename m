From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] kmalloc+memset -> kzalloc in frag_alloc_queue
Date: Mon, 15 Oct 2007 18:48:41 +0400
Message-ID: <20071015144841.GA1009@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: den@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:60664 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761259AbXJOOqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:46:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kmalloc + memset -> kzalloc in frag_alloc_queue

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./net/ipv4/ip_fragment.c.alloc	2007-10-15 13:55:25.000000000 +0400
+++ ./net/ipv4/ip_fragment.c	2007-10-15 17:47:41.000000000 +0400
@@ -144,7 +144,7 @@ static __inline__ void ip4_frag_free(str
 
 static __inline__ struct ipq *frag_alloc_queue(void)
 {
-	struct ipq *qp = kmalloc(sizeof(struct ipq), GFP_ATOMIC);
+	struct ipq *qp = kzalloc(sizeof(struct ipq), GFP_ATOMIC);
 
 	if (!qp)
 		return NULL;
@@ -265,15 +265,10 @@ static struct ipq *ip_frag_create(struct
 		goto out_nomem;
 
 	qp->protocol = iph->protocol;
-	qp->q.last_in = 0;
 	qp->id = iph->id;
 	qp->saddr = iph->saddr;
 	qp->daddr = iph->daddr;
 	qp->user = user;
-	qp->q.len = 0;
-	qp->q.meat = 0;
-	qp->q.fragments = NULL;
-	qp->iif = 0;
 	qp->peer = sysctl_ipfrag_max_dist ? inet_getpeer(iph->saddr, 1) : NULL;
 
 	/* Initialize a timer for this entry. */
--- ./net/ipv6/netfilter/nf_conntrack_reasm.c.alloc	2007-10-15 13:55:25.000000000 +0400
+++ ./net/ipv6/netfilter/nf_conntrack_reasm.c	2007-10-15 17:47:29.000000000 +0400
@@ -137,9 +137,10 @@ static void nf_frag_free(struct inet_fra
 
 static inline struct nf_ct_frag6_queue *frag_alloc_queue(void)
 {
-	struct nf_ct_frag6_queue *fq = kmalloc(sizeof(struct nf_ct_frag6_queue), GFP_ATOMIC);
+	struct nf_ct_frag6_queue *fq;
 
-	if (!fq)
+	fq = kzalloc(sizeof(struct nf_ct_frag6_queue), GFP_ATOMIC);
+	if (fq == NULL)
 		return NULL;
 	atomic_add(sizeof(struct nf_ct_frag6_queue), &nf_frags.mem);
 	return fq;
@@ -230,8 +231,6 @@ nf_ct_frag6_create(unsigned int hash, __
 		goto oom;
 	}
 
-	memset(fq, 0, sizeof(struct nf_ct_frag6_queue));
-
 	fq->id = id;
 	ipv6_addr_copy(&fq->saddr, src);
 	ipv6_addr_copy(&fq->daddr, dst);
