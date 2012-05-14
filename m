From: pablo@netfilter.org
Subject: [PATCH 2/4] netfilter: ipset: fix hash size checking in kernel
Date: Mon, 14 May 2012 13:47:01 +0200
Message-ID: <1336996023-20249-3-git-send-email-pablo@netfilter.org>
References: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35229 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215Ab2ENLrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 07:47:36 -0400
In-Reply-To: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The hash size must fit both into u32 (jhash) and the max value of
size_t. The missing checking could lead to kernel crash, bug reported
by Seblu.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |   16 ++++++++++++++++
 net/netfilter/ipset/ip_set_hash_ip.c         |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_ipport.c     |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_net.c        |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_netiface.c   |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_netport.c    |   10 +++++++---
 8 files changed, 65 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 05a5d72..230a290 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -99,6 +99,22 @@ struct ip_set_hash {
 #endif
 };
 
+static size_t
+htable_size(u8 hbits)
+{
+	size_t hsize;
+
+	/* We must fit both into u32 in jhash and size_t */
+	if (hbits > 31)
+		return 0;
+	hsize = jhash_size(hbits);
+	if ((((size_t)-1) - sizeof(struct htable))/sizeof(struct hbucket)
+	    < hsize)
+		return 0;
+
+	return hsize * sizeof(struct hbucket) + sizeof(struct htable);
+}
+
 /* Compute htable_bits from the user input parameter hashsize */
 static u8
 htable_bits(u32 hashsize)
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 5139dea..828ce46 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -364,6 +364,7 @@ hash_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 netmask, hbits;
+	size_t hsize;
 	struct ip_set_hash *h;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
@@ -405,9 +406,12 @@ hash_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 9c27e24..e8dbb49 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -449,6 +449,7 @@ hash_ipport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	struct ip_set_hash *h;
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
+	size_t hsize;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -476,9 +477,12 @@ hash_ipport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 9134057..52f79d8 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -467,6 +467,7 @@ hash_ipportip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	struct ip_set_hash *h;
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
+	size_t hsize;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -494,9 +495,12 @@ hash_ipportip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 5d05e69..97583f5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -616,6 +616,7 @@ hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	struct ip_set_hash *h;
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
+	size_t hsize;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -645,9 +646,12 @@ hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 7c3d945..1721cde 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -460,6 +460,7 @@ hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	struct ip_set_hash *h;
 	u8 hbits;
+	size_t hsize;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -489,9 +490,12 @@ hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index f24037f..33bafc9 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -722,6 +722,7 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	struct ip_set_hash *h;
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
+	size_t hsize;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -752,9 +753,12 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->ahash_max = AHASH_MAX_SIZE;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index ce2e771..3a5e198 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -572,6 +572,7 @@ hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	struct ip_set_hash *h;
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
 	u8 hbits;
+	size_t hsize;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -601,9 +602,12 @@ hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
-	h->table = ip_set_alloc(
-			sizeof(struct htable)
-			+ jhash_size(hbits) * sizeof(struct hbucket));
+	hsize = htable_size(hbits);
+	if (hsize == 0) {
+		kfree(h);
+		return -ENOMEM;
+	}
+	h->table = ip_set_alloc(hsize);
 	if (!h->table) {
 		kfree(h);
 		return -ENOMEM;
-- 
1.7.10
