From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Fri, 25 Jul 2008 15:41:09 +0800
Message-ID: <20080725074109.GA16747@gondor.apana.org.au>
References: <20080723.234556.98132946.davem@davemloft.net> <E1KM0Wl-0001zC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34390 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751151AbYGYHlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 03:41:31 -0400
Content-Disposition: inline
In-Reply-To: <E1KM0Wl-0001zC-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 09:06:39PM +0800, Herbert Xu wrote:
>
> Indeed, this is long overdue.  I'm going to spend a few cycles on
> this.  I'll start by moving the common code into net/xfrm/ipcomp.c
> so that I don't have to do it twice later.

Here is the first part:

ipsec: ipcomp - Merge IPComp implementations

This patch merges the IPv4/IPv6 IPComp implementations since most
of the code is identical.  As a result future enhancements will no
longer need to be duplicated.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/ipcomp.h b/include/net/ipcomp.h
index 330b74e..2a1092a 100644
--- a/include/net/ipcomp.h
+++ b/include/net/ipcomp.h
@@ -14,6 +14,12 @@ struct ipcomp_data {
 
 struct ip_comp_hdr;
 struct sk_buff;
+struct xfrm_state;
+
+int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb);
+int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb);
+void ipcomp_destroy(struct xfrm_state *x);
+int ipcomp_init_state(struct xfrm_state *x);
 
 static inline struct ip_comp_hdr *ip_comp_hdr(const struct sk_buff *skb)
 {
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 4670683..591ea23 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -356,10 +356,8 @@ config INET_ESP
 
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
-	select XFRM
 	select INET_XFRM_TUNNEL
-	select CRYPTO
-	select CRYPTO_DEFLATE
+	select XFRM_IPCOMP
 	---help---
 	  Support for IP Payload Compression Protocol (IPComp) (RFC3173),
 	  typically needed for IPsec.
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index a75807b..a42b64d 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -14,153 +14,14 @@
  *   - Adaptive compression.
  */
 #include <linux/module.h>
-#include <linux/crypto.h>
 #include <linux/err.h>
-#include <linux/pfkeyv2.h>
-#include <linux/percpu.h>
-#include <linux/smp.h>
-#include <linux/list.h>
-#include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
-#include <linux/mutex.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/icmp.h>
 #include <net/ipcomp.h>
 #include <net/protocol.h>
-
-struct ipcomp_tfms {
-	struct list_head list;
-	struct crypto_comp **tfms;
-	int users;
-};
-
-static DEFINE_MUTEX(ipcomp_resource_mutex);
-static void **ipcomp_scratches;
-static int ipcomp_scratch_users;
-static LIST_HEAD(ipcomp_tfms_list);
-
-static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
-{
-	struct ipcomp_data *ipcd = x->data;
-	const int plen = skb->len;
-	int dlen = IPCOMP_SCRATCH_SIZE;
-	const u8 *start = skb->data;
-	const int cpu = get_cpu();
-	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
-	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
-	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
-
-	if (err)
-		goto out;
-
-	if (dlen < (plen + sizeof(struct ip_comp_hdr))) {
-		err = -EINVAL;
-		goto out;
-	}
-
-	err = pskb_expand_head(skb, 0, dlen - plen, GFP_ATOMIC);
-	if (err)
-		goto out;
-
-	skb->truesize += dlen - plen;
-	__skb_put(skb, dlen - plen);
-	skb_copy_to_linear_data(skb, scratch, dlen);
-out:
-	put_cpu();
-	return err;
-}
-
-static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int nexthdr;
-	int err = -ENOMEM;
-	struct ip_comp_hdr *ipch;
-
-	if (skb_linearize_cow(skb))
-		goto out;
-
-	skb->ip_summed = CHECKSUM_NONE;
-
-	/* Remove ipcomp header and decompress original payload */
-	ipch = (void *)skb->data;
-	nexthdr = ipch->nexthdr;
-
-	skb->transport_header = skb->network_header + sizeof(*ipch);
-	__skb_pull(skb, sizeof(*ipch));
-	err = ipcomp_decompress(x, skb);
-	if (err)
-		goto out;
-
-	err = nexthdr;
-
-out:
-	return err;
-}
-
-static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
-{
-	struct ipcomp_data *ipcd = x->data;
-	const int plen = skb->len;
-	int dlen = IPCOMP_SCRATCH_SIZE;
-	u8 *start = skb->data;
-	const int cpu = get_cpu();
-	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
-	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
-	int err;
-
-	local_bh_disable();
-	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	local_bh_enable();
-	if (err)
-		goto out;
-
-	if ((dlen + sizeof(struct ip_comp_hdr)) >= plen) {
-		err = -EMSGSIZE;
-		goto out;
-	}
-
-	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
-	put_cpu();
-
-	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
-	return 0;
-
-out:
-	put_cpu();
-	return err;
-}
-
-static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int err;
-	struct ip_comp_hdr *ipch;
-	struct ipcomp_data *ipcd = x->data;
-
-	if (skb->len < ipcd->threshold) {
-		/* Don't bother compressing */
-		goto out_ok;
-	}
-
-	if (skb_linearize_cow(skb))
-		goto out_ok;
-
-	err = ipcomp_compress(x, skb);
-
-	if (err) {
-		goto out_ok;
-	}
-
-	/* Install ipcomp header, convert into ipcomp datagram. */
-	ipch = ip_comp_hdr(skb);
-	ipch->nexthdr = *skb_mac_header(skb);
-	ipch->flags = 0;
-	ipch->cpi = htons((u16 )ntohl(x->id.spi));
-	*skb_mac_header(skb) = IPPROTO_COMP;
-out_ok:
-	skb_push(skb, -skb_network_offset(skb));
-	return 0;
-}
+#include <net/sock.h>
 
 static void ipcomp4_err(struct sk_buff *skb, u32 info)
 {
@@ -241,156 +102,12 @@ out:
 	return err;
 }
 
-static void ipcomp_free_scratches(void)
-{
-	int i;
-	void **scratches;
-
-	if (--ipcomp_scratch_users)
-		return;
-
-	scratches = ipcomp_scratches;
-	if (!scratches)
-		return;
-
-	for_each_possible_cpu(i)
-		vfree(*per_cpu_ptr(scratches, i));
-
-	free_percpu(scratches);
-}
-
-static void **ipcomp_alloc_scratches(void)
-{
-	int i;
-	void **scratches;
-
-	if (ipcomp_scratch_users++)
-		return ipcomp_scratches;
-
-	scratches = alloc_percpu(void *);
-	if (!scratches)
-		return NULL;
-
-	ipcomp_scratches = scratches;
-
-	for_each_possible_cpu(i) {
-		void *scratch = vmalloc(IPCOMP_SCRATCH_SIZE);
-		if (!scratch)
-			return NULL;
-		*per_cpu_ptr(scratches, i) = scratch;
-	}
-
-	return scratches;
-}
-
-static void ipcomp_free_tfms(struct crypto_comp **tfms)
-{
-	struct ipcomp_tfms *pos;
-	int cpu;
-
-	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
-		if (pos->tfms == tfms)
-			break;
-	}
-
-	BUG_TRAP(pos);
-
-	if (--pos->users)
-		return;
-
-	list_del(&pos->list);
-	kfree(pos);
-
-	if (!tfms)
-		return;
-
-	for_each_possible_cpu(cpu) {
-		struct crypto_comp *tfm = *per_cpu_ptr(tfms, cpu);
-		crypto_free_comp(tfm);
-	}
-	free_percpu(tfms);
-}
-
-static struct crypto_comp **ipcomp_alloc_tfms(const char *alg_name)
-{
-	struct ipcomp_tfms *pos;
-	struct crypto_comp **tfms;
-	int cpu;
-
-	/* This can be any valid CPU ID so we don't need locking. */
-	cpu = raw_smp_processor_id();
-
-	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
-		struct crypto_comp *tfm;
-
-		tfms = pos->tfms;
-		tfm = *per_cpu_ptr(tfms, cpu);
-
-		if (!strcmp(crypto_comp_name(tfm), alg_name)) {
-			pos->users++;
-			return tfms;
-		}
-	}
-
-	pos = kmalloc(sizeof(*pos), GFP_KERNEL);
-	if (!pos)
-		return NULL;
-
-	pos->users = 1;
-	INIT_LIST_HEAD(&pos->list);
-	list_add(&pos->list, &ipcomp_tfms_list);
-
-	pos->tfms = tfms = alloc_percpu(struct crypto_comp *);
-	if (!tfms)
-		goto error;
-
-	for_each_possible_cpu(cpu) {
-		struct crypto_comp *tfm = crypto_alloc_comp(alg_name, 0,
-							    CRYPTO_ALG_ASYNC);
-		if (IS_ERR(tfm))
-			goto error;
-		*per_cpu_ptr(tfms, cpu) = tfm;
-	}
-
-	return tfms;
-
-error:
-	ipcomp_free_tfms(tfms);
-	return NULL;
-}
-
-static void ipcomp_free_data(struct ipcomp_data *ipcd)
-{
-	if (ipcd->tfms)
-		ipcomp_free_tfms(ipcd->tfms);
-	ipcomp_free_scratches();
-}
-
-static void ipcomp_destroy(struct xfrm_state *x)
-{
-	struct ipcomp_data *ipcd = x->data;
-	if (!ipcd)
-		return;
-	xfrm_state_delete_tunnel(x);
-	mutex_lock(&ipcomp_resource_mutex);
-	ipcomp_free_data(ipcd);
-	mutex_unlock(&ipcomp_resource_mutex);
-	kfree(ipcd);
-}
-
-static int ipcomp_init_state(struct xfrm_state *x)
+static int ipcomp4_init_state(struct xfrm_state *x)
 {
 	int err;
 	struct ipcomp_data *ipcd;
 	struct xfrm_algo_desc *calg_desc;
 
-	err = -EINVAL;
-	if (!x->calg)
-		goto out;
-
-	if (x->encap)
-		goto out;
-
 	x->props.header_len = 0;
 	switch (x->props.mode) {
 	case XFRM_MODE_TRANSPORT:
@@ -402,40 +119,22 @@ static int ipcomp_init_state(struct xfrm_state *x)
 		goto out;
 	}
 
-	err = -ENOMEM;
-	ipcd = kzalloc(sizeof(*ipcd), GFP_KERNEL);
-	if (!ipcd)
+	err = ipcomp_init_state(x);
+	if (err)
 		goto out;
 
-	mutex_lock(&ipcomp_resource_mutex);
-	if (!ipcomp_alloc_scratches())
-		goto error;
-
-	ipcd->tfms = ipcomp_alloc_tfms(x->calg->alg_name);
-	if (!ipcd->tfms)
-		goto error;
-	mutex_unlock(&ipcomp_resource_mutex);
-
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = ipcomp_tunnel_attach(x);
 		if (err)
 			goto error_tunnel;
 	}
 
-	calg_desc = xfrm_calg_get_byname(x->calg->alg_name, 0);
-	BUG_ON(!calg_desc);
-	ipcd->threshold = calg_desc->uinfo.comp.threshold;
-	x->data = ipcd;
 	err = 0;
 out:
 	return err;
 
 error_tunnel:
-	mutex_lock(&ipcomp_resource_mutex);
-error:
-	ipcomp_free_data(ipcd);
-	mutex_unlock(&ipcomp_resource_mutex);
-	kfree(ipcd);
+	ipcomp_destroy(x);
 	goto out;
 }
 
@@ -443,7 +142,7 @@ static const struct xfrm_type ipcomp_type = {
 	.description	= "IPCOMP4",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_COMP,
-	.init_state	= ipcomp_init_state,
+	.init_state	= ipcomp4_init_state,
 	.destructor	= ipcomp_destroy,
 	.input		= ipcomp_input,
 	.output		= ipcomp_output
@@ -481,7 +180,7 @@ module_init(ipcomp4_init);
 module_exit(ipcomp4_fini);
 
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp) - RFC3173");
+MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp/IPv4) - RFC3173");
 MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
 
 MODULE_ALIAS_XFRM_TYPE(AF_INET, XFRM_PROTO_COMP);
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 42814a2..ec99215 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -96,10 +96,8 @@ config INET6_ESP
 
 config INET6_IPCOMP
 	tristate "IPv6: IPComp transformation"
-	select XFRM
 	select INET6_XFRM_TUNNEL
-	select CRYPTO
-	select CRYPTO_DEFLATE
+	select XFRM_IPCOMP
 	---help---
 	  Support for IP Payload Compression Protocol (IPComp) (RFC3173),
 	  typically needed for IPsec.
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index ee6de42..0cfcea4 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -50,125 +50,6 @@
 #include <linux/icmpv6.h>
 #include <linux/mutex.h>
 
-struct ipcomp6_tfms {
-	struct list_head list;
-	struct crypto_comp **tfms;
-	int users;
-};
-
-static DEFINE_MUTEX(ipcomp6_resource_mutex);
-static void **ipcomp6_scratches;
-static int ipcomp6_scratch_users;
-static LIST_HEAD(ipcomp6_tfms_list);
-
-static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int nexthdr;
-	int err = -ENOMEM;
-	struct ip_comp_hdr *ipch;
-	int plen, dlen;
-	struct ipcomp_data *ipcd = x->data;
-	u8 *start, *scratch;
-	struct crypto_comp *tfm;
-	int cpu;
-
-	if (skb_linearize_cow(skb))
-		goto out;
-
-	skb->ip_summed = CHECKSUM_NONE;
-
-	/* Remove ipcomp header and decompress original payload */
-	ipch = (void *)skb->data;
-	nexthdr = ipch->nexthdr;
-
-	skb->transport_header = skb->network_header + sizeof(*ipch);
-	__skb_pull(skb, sizeof(*ipch));
-
-	/* decompression */
-	plen = skb->len;
-	dlen = IPCOMP_SCRATCH_SIZE;
-	start = skb->data;
-
-	cpu = get_cpu();
-	scratch = *per_cpu_ptr(ipcomp6_scratches, cpu);
-	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
-
-	err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
-	if (err)
-		goto out_put_cpu;
-
-	if (dlen < (plen + sizeof(*ipch))) {
-		err = -EINVAL;
-		goto out_put_cpu;
-	}
-
-	err = pskb_expand_head(skb, 0, dlen - plen, GFP_ATOMIC);
-	if (err) {
-		goto out_put_cpu;
-	}
-
-	skb->truesize += dlen - plen;
-	__skb_put(skb, dlen - plen);
-	skb_copy_to_linear_data(skb, scratch, dlen);
-	err = nexthdr;
-
-out_put_cpu:
-	put_cpu();
-out:
-	return err;
-}
-
-static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int err;
-	struct ip_comp_hdr *ipch;
-	struct ipcomp_data *ipcd = x->data;
-	int plen, dlen;
-	u8 *start, *scratch;
-	struct crypto_comp *tfm;
-	int cpu;
-
-	/* check whether datagram len is larger than threshold */
-	if (skb->len < ipcd->threshold) {
-		goto out_ok;
-	}
-
-	if (skb_linearize_cow(skb))
-		goto out_ok;
-
-	/* compression */
-	plen = skb->len;
-	dlen = IPCOMP_SCRATCH_SIZE;
-	start = skb->data;
-
-	cpu = get_cpu();
-	scratch = *per_cpu_ptr(ipcomp6_scratches, cpu);
-	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
-
-	local_bh_disable();
-	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
-	local_bh_enable();
-	if (err || (dlen + sizeof(*ipch)) >= plen) {
-		put_cpu();
-		goto out_ok;
-	}
-	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
-	put_cpu();
-	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
-
-	/* insert ipcomp header and replace datagram */
-	ipch = ip_comp_hdr(skb);
-	ipch->nexthdr = *skb_mac_header(skb);
-	ipch->flags = 0;
-	ipch->cpi = htons((u16 )ntohl(x->id.spi));
-	*skb_mac_header(skb) = IPPROTO_COMP;
-
-out_ok:
-	skb_push(skb, -skb_network_offset(skb));
-
-	return 0;
-}
-
 static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 				int type, int code, int offset, __be32 info)
 {
@@ -251,161 +132,12 @@ out:
 	return err;
 }
 
-static void ipcomp6_free_scratches(void)
-{
-	int i;
-	void **scratches;
-
-	if (--ipcomp6_scratch_users)
-		return;
-
-	scratches = ipcomp6_scratches;
-	if (!scratches)
-		return;
-
-	for_each_possible_cpu(i) {
-		void *scratch = *per_cpu_ptr(scratches, i);
-
-		vfree(scratch);
-	}
-
-	free_percpu(scratches);
-}
-
-static void **ipcomp6_alloc_scratches(void)
-{
-	int i;
-	void **scratches;
-
-	if (ipcomp6_scratch_users++)
-		return ipcomp6_scratches;
-
-	scratches = alloc_percpu(void *);
-	if (!scratches)
-		return NULL;
-
-	ipcomp6_scratches = scratches;
-
-	for_each_possible_cpu(i) {
-		void *scratch = vmalloc(IPCOMP_SCRATCH_SIZE);
-		if (!scratch)
-			return NULL;
-		*per_cpu_ptr(scratches, i) = scratch;
-	}
-
-	return scratches;
-}
-
-static void ipcomp6_free_tfms(struct crypto_comp **tfms)
-{
-	struct ipcomp6_tfms *pos;
-	int cpu;
-
-	list_for_each_entry(pos, &ipcomp6_tfms_list, list) {
-		if (pos->tfms == tfms)
-			break;
-	}
-
-	BUG_TRAP(pos);
-
-	if (--pos->users)
-		return;
-
-	list_del(&pos->list);
-	kfree(pos);
-
-	if (!tfms)
-		return;
-
-	for_each_possible_cpu(cpu) {
-		struct crypto_comp *tfm = *per_cpu_ptr(tfms, cpu);
-		crypto_free_comp(tfm);
-	}
-	free_percpu(tfms);
-}
-
-static struct crypto_comp **ipcomp6_alloc_tfms(const char *alg_name)
-{
-	struct ipcomp6_tfms *pos;
-	struct crypto_comp **tfms;
-	int cpu;
-
-	/* This can be any valid CPU ID so we don't need locking. */
-	cpu = raw_smp_processor_id();
-
-	list_for_each_entry(pos, &ipcomp6_tfms_list, list) {
-		struct crypto_comp *tfm;
-
-		tfms = pos->tfms;
-		tfm = *per_cpu_ptr(tfms, cpu);
-
-		if (!strcmp(crypto_comp_name(tfm), alg_name)) {
-			pos->users++;
-			return tfms;
-		}
-	}
-
-	pos = kmalloc(sizeof(*pos), GFP_KERNEL);
-	if (!pos)
-		return NULL;
-
-	pos->users = 1;
-	INIT_LIST_HEAD(&pos->list);
-	list_add(&pos->list, &ipcomp6_tfms_list);
-
-	pos->tfms = tfms = alloc_percpu(struct crypto_comp *);
-	if (!tfms)
-		goto error;
-
-	for_each_possible_cpu(cpu) {
-		struct crypto_comp *tfm = crypto_alloc_comp(alg_name, 0,
-							    CRYPTO_ALG_ASYNC);
-		if (IS_ERR(tfm))
-			goto error;
-		*per_cpu_ptr(tfms, cpu) = tfm;
-	}
-
-	return tfms;
-
-error:
-	ipcomp6_free_tfms(tfms);
-	return NULL;
-}
-
-static void ipcomp6_free_data(struct ipcomp_data *ipcd)
-{
-	if (ipcd->tfms)
-		ipcomp6_free_tfms(ipcd->tfms);
-	ipcomp6_free_scratches();
-}
-
-static void ipcomp6_destroy(struct xfrm_state *x)
-{
-	struct ipcomp_data *ipcd = x->data;
-	if (!ipcd)
-		return;
-	xfrm_state_delete_tunnel(x);
-	mutex_lock(&ipcomp6_resource_mutex);
-	ipcomp6_free_data(ipcd);
-	mutex_unlock(&ipcomp6_resource_mutex);
-	kfree(ipcd);
-
-	xfrm6_tunnel_free_spi((xfrm_address_t *)&x->props.saddr);
-}
-
 static int ipcomp6_init_state(struct xfrm_state *x)
 {
 	int err;
 	struct ipcomp_data *ipcd;
 	struct xfrm_algo_desc *calg_desc;
 
-	err = -EINVAL;
-	if (!x->calg)
-		goto out;
-
-	if (x->encap)
-		goto out;
-
 	x->props.header_len = 0;
 	switch (x->props.mode) {
 	case XFRM_MODE_TRANSPORT:
@@ -417,39 +149,21 @@ static int ipcomp6_init_state(struct xfrm_state *x)
 		goto out;
 	}
 
-	err = -ENOMEM;
-	ipcd = kzalloc(sizeof(*ipcd), GFP_KERNEL);
-	if (!ipcd)
+	err = ipcomp_init_state(x);
+	if (err)
 		goto out;
 
-	mutex_lock(&ipcomp6_resource_mutex);
-	if (!ipcomp6_alloc_scratches())
-		goto error;
-
-	ipcd->tfms = ipcomp6_alloc_tfms(x->calg->alg_name);
-	if (!ipcd->tfms)
-		goto error;
-	mutex_unlock(&ipcomp6_resource_mutex);
-
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = ipcomp6_tunnel_attach(x);
 		if (err)
 			goto error_tunnel;
 	}
 
-	calg_desc = xfrm_calg_get_byname(x->calg->alg_name, 0);
-	BUG_ON(!calg_desc);
-	ipcd->threshold = calg_desc->uinfo.comp.threshold;
-	x->data = ipcd;
 	err = 0;
 out:
 	return err;
 error_tunnel:
-	mutex_lock(&ipcomp6_resource_mutex);
-error:
-	ipcomp6_free_data(ipcd);
-	mutex_unlock(&ipcomp6_resource_mutex);
-	kfree(ipcd);
+	ipcomp_destroy(x);
 
 	goto out;
 }
@@ -460,9 +174,9 @@ static const struct xfrm_type ipcomp6_type =
 	.owner		= THIS_MODULE,
 	.proto		= IPPROTO_COMP,
 	.init_state	= ipcomp6_init_state,
-	.destructor	= ipcomp6_destroy,
-	.input		= ipcomp6_input,
-	.output		= ipcomp6_output,
+	.destructor	= ipcomp_destroy,
+	.input		= ipcomp_input,
+	.output		= ipcomp_output,
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 9201ef8..6d08167 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -46,6 +46,12 @@ config XFRM_STATISTICS
 
 	  If unsure, say N.
 
+config XFRM_IPCOMP
+	tristate
+	select XFRM
+	select CRYPTO
+	select CRYPTO_DEFLATE
+
 config NET_KEY
 	tristate "PF_KEY sockets"
 	select XFRM
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 332cfb0..0f439a7 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -6,4 +6,5 @@ obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o xfrm_algo.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
+obj-$(CONFIG_XFRM_IPCOMP) += xfrm_ipcomp.o
 
diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
new file mode 100644
index 0000000..b51e804
--- /dev/null
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -0,0 +1,349 @@
+/*
+ * IP Payload Compression Protocol (IPComp) - RFC3173.
+ *
+ * Copyright (c) 2003 James Morris <jmorris@intercode.com.au>
+ * Copyright (c) 2003-2008 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Todo:
+ *   - Tunable compression parameters.
+ *   - Compression stats.
+ *   - Adaptive compression.
+ */
+
+#include <linux/crypto.h>
+#include <linux/err.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/percpu.h>
+#include <linux/rtnetlink.h>
+#include <linux/smp.h>
+#include <linux/vmalloc.h>
+#include <net/ip.h>
+#include <net/ipcomp.h>
+#include <net/xfrm.h>
+
+struct ipcomp_tfms {
+	struct list_head list;
+	struct crypto_comp **tfms;
+	int users;
+};
+
+static DEFINE_MUTEX(ipcomp_resource_mutex);
+static void **ipcomp_scratches;
+static int ipcomp_scratch_users;
+static LIST_HEAD(ipcomp_tfms_list);
+
+static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipcomp_data *ipcd = x->data;
+	const int plen = skb->len;
+	int dlen = IPCOMP_SCRATCH_SIZE;
+	const u8 *start = skb->data;
+	const int cpu = get_cpu();
+	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
+	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
+
+	if (err)
+		goto out;
+
+	if (dlen < (plen + sizeof(struct ip_comp_hdr))) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	err = pskb_expand_head(skb, 0, dlen - plen, GFP_ATOMIC);
+	if (err)
+		goto out;
+
+	skb->truesize += dlen - plen;
+	__skb_put(skb, dlen - plen);
+	skb_copy_to_linear_data(skb, scratch, dlen);
+out:
+	put_cpu();
+	return err;
+}
+
+int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int nexthdr;
+	int err = -ENOMEM;
+	struct ip_comp_hdr *ipch;
+
+	if (skb_linearize_cow(skb))
+		goto out;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Remove ipcomp header and decompress original payload */
+	ipch = (void *)skb->data;
+	nexthdr = ipch->nexthdr;
+
+	skb->transport_header = skb->network_header + sizeof(*ipch);
+	__skb_pull(skb, sizeof(*ipch));
+	err = ipcomp_decompress(x, skb);
+	if (err)
+		goto out;
+
+	err = nexthdr;
+
+out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(ipcomp_input);
+
+static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipcomp_data *ipcd = x->data;
+	const int plen = skb->len;
+	int dlen = IPCOMP_SCRATCH_SIZE;
+	u8 *start = skb->data;
+	const int cpu = get_cpu();
+	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
+	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+	int err;
+
+	local_bh_disable();
+	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
+	local_bh_enable();
+	if (err)
+		goto out;
+
+	if ((dlen + sizeof(struct ip_comp_hdr)) >= plen) {
+		err = -EMSGSIZE;
+		goto out;
+	}
+
+	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
+	put_cpu();
+
+	pskb_trim(skb, dlen + sizeof(struct ip_comp_hdr));
+	return 0;
+
+out:
+	put_cpu();
+	return err;
+}
+
+int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err;
+	struct ip_comp_hdr *ipch;
+	struct ipcomp_data *ipcd = x->data;
+
+	if (skb->len < ipcd->threshold) {
+		/* Don't bother compressing */
+		goto out_ok;
+	}
+
+	if (skb_linearize_cow(skb))
+		goto out_ok;
+
+	err = ipcomp_compress(x, skb);
+
+	if (err) {
+		goto out_ok;
+	}
+
+	/* Install ipcomp header, convert into ipcomp datagram. */
+	ipch = ip_comp_hdr(skb);
+	ipch->nexthdr = *skb_mac_header(skb);
+	ipch->flags = 0;
+	ipch->cpi = htons((u16 )ntohl(x->id.spi));
+	*skb_mac_header(skb) = IPPROTO_COMP;
+out_ok:
+	skb_push(skb, -skb_network_offset(skb));
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ipcomp_output);
+
+static void ipcomp_free_scratches(void)
+{
+	int i;
+	void **scratches;
+
+	if (--ipcomp_scratch_users)
+		return;
+
+	scratches = ipcomp_scratches;
+	if (!scratches)
+		return;
+
+	for_each_possible_cpu(i)
+		vfree(*per_cpu_ptr(scratches, i));
+
+	free_percpu(scratches);
+}
+
+static void **ipcomp_alloc_scratches(void)
+{
+	int i;
+	void **scratches;
+
+	if (ipcomp_scratch_users++)
+		return ipcomp_scratches;
+
+	scratches = alloc_percpu(void *);
+	if (!scratches)
+		return NULL;
+
+	ipcomp_scratches = scratches;
+
+	for_each_possible_cpu(i) {
+		void *scratch = vmalloc(IPCOMP_SCRATCH_SIZE);
+		if (!scratch)
+			return NULL;
+		*per_cpu_ptr(scratches, i) = scratch;
+	}
+
+	return scratches;
+}
+
+static void ipcomp_free_tfms(struct crypto_comp **tfms)
+{
+	struct ipcomp_tfms *pos;
+	int cpu;
+
+	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
+		if (pos->tfms == tfms)
+			break;
+	}
+
+	BUG_TRAP(pos);
+
+	if (--pos->users)
+		return;
+
+	list_del(&pos->list);
+	kfree(pos);
+
+	if (!tfms)
+		return;
+
+	for_each_possible_cpu(cpu) {
+		struct crypto_comp *tfm = *per_cpu_ptr(tfms, cpu);
+		crypto_free_comp(tfm);
+	}
+	free_percpu(tfms);
+}
+
+static struct crypto_comp **ipcomp_alloc_tfms(const char *alg_name)
+{
+	struct ipcomp_tfms *pos;
+	struct crypto_comp **tfms;
+	int cpu;
+
+	/* This can be any valid CPU ID so we don't need locking. */
+	cpu = raw_smp_processor_id();
+
+	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
+		struct crypto_comp *tfm;
+
+		tfms = pos->tfms;
+		tfm = *per_cpu_ptr(tfms, cpu);
+
+		if (!strcmp(crypto_comp_name(tfm), alg_name)) {
+			pos->users++;
+			return tfms;
+		}
+	}
+
+	pos = kmalloc(sizeof(*pos), GFP_KERNEL);
+	if (!pos)
+		return NULL;
+
+	pos->users = 1;
+	INIT_LIST_HEAD(&pos->list);
+	list_add(&pos->list, &ipcomp_tfms_list);
+
+	pos->tfms = tfms = alloc_percpu(struct crypto_comp *);
+	if (!tfms)
+		goto error;
+
+	for_each_possible_cpu(cpu) {
+		struct crypto_comp *tfm = crypto_alloc_comp(alg_name, 0,
+							    CRYPTO_ALG_ASYNC);
+		if (IS_ERR(tfm))
+			goto error;
+		*per_cpu_ptr(tfms, cpu) = tfm;
+	}
+
+	return tfms;
+
+error:
+	ipcomp_free_tfms(tfms);
+	return NULL;
+}
+
+static void ipcomp_free_data(struct ipcomp_data *ipcd)
+{
+	if (ipcd->tfms)
+		ipcomp_free_tfms(ipcd->tfms);
+	ipcomp_free_scratches();
+}
+
+void ipcomp_destroy(struct xfrm_state *x)
+{
+	struct ipcomp_data *ipcd = x->data;
+	if (!ipcd)
+		return;
+	xfrm_state_delete_tunnel(x);
+	mutex_lock(&ipcomp_resource_mutex);
+	ipcomp_free_data(ipcd);
+	mutex_unlock(&ipcomp_resource_mutex);
+	kfree(ipcd);
+}
+EXPORT_SYMBOL_GPL(ipcomp_destroy);
+
+int ipcomp_init_state(struct xfrm_state *x)
+{
+	int err;
+	struct ipcomp_data *ipcd;
+	struct xfrm_algo_desc *calg_desc;
+
+	err = -EINVAL;
+	if (!x->calg)
+		goto out;
+
+	if (x->encap)
+		goto out;
+
+	err = -ENOMEM;
+	ipcd = kzalloc(sizeof(*ipcd), GFP_KERNEL);
+	if (!ipcd)
+		goto out;
+
+	mutex_lock(&ipcomp_resource_mutex);
+	if (!ipcomp_alloc_scratches())
+		goto error;
+
+	ipcd->tfms = ipcomp_alloc_tfms(x->calg->alg_name);
+	if (!ipcd->tfms)
+		goto error;
+	mutex_unlock(&ipcomp_resource_mutex);
+
+	calg_desc = xfrm_calg_get_byname(x->calg->alg_name, 0);
+	BUG_ON(!calg_desc);
+	ipcd->threshold = calg_desc->uinfo.comp.threshold;
+	x->data = ipcd;
+	err = 0;
+out:
+	return err;
+
+error:
+	ipcomp_free_data(ipcd);
+	mutex_unlock(&ipcomp_resource_mutex);
+	kfree(ipcd);
+	goto out;
+}
+EXPORT_SYMBOL_GPL(ipcomp_init_state);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp) - RFC3173");
+MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
