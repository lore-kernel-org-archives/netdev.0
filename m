From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 9/9] Consolidate the xxx_put
Date: Fri, 12 Oct 2007 17:29:01 +0400
Message-ID: <470F769D.8000501@openvz.org>
References: <470F6EAE.60308@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41904 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757139AbXJLNbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 09:31:42 -0400
In-Reply-To: <470F6EAE.60308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These ones use the generic data types too, so move
them in one place.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index cf583cf..911c2cd 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -51,4 +51,10 @@ void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
 int inet_frag_evictor(struct inet_frags *f);
 
+static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
+{
+	if (atomic_dec_and_test(&q->refcnt))
+		inet_frag_destroy(q, f, NULL);
+}
+
 #endif
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 4ea7948..4470a50 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -154,8 +154,7 @@ static __inline__ struct ipq *frag_alloc_queue(void)
 
 static __inline__ void ipq_put(struct ipq *ipq)
 {
-	if (atomic_dec_and_test(&ipq->q.refcnt))
-		inet_frag_destroy(&ipq->q, &ip4_frags, NULL);
+	inet_frag_put(&ipq->q, &ip4_frags);
 }
 
 /* Kill ipq entry. It is not destroyed immediately,
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 862d089..bf6f2f0 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -149,8 +149,7 @@ static inline struct nf_ct_frag6_queue *frag_alloc_queue(void)
 
 static __inline__ void fq_put(struct nf_ct_frag6_queue *fq)
 {
-	if (atomic_dec_and_test(&fq->q.refcnt))
-		inet_frag_destroy(&fq->q, &nf_frags, NULL);
+	inet_frag_put(&fq->q, &nf_frags);
 }
 
 /* Kill fq entry. It is not destroyed immediately,
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 454db16..a50fbea 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -167,8 +167,7 @@ static inline struct frag_queue *frag_alloc_queue(void)
 
 static __inline__ void fq_put(struct frag_queue *fq)
 {
-	if (atomic_dec_and_test(&fq->q.refcnt))
-		inet_frag_destroy(&fq->q, &ip6_frags, NULL);
+	inet_frag_put(&fq->q, &ip6_frags);
 }
 
 /* Kill fq entry. It is not destroyed immediately,
-- 
1.5.3.4

