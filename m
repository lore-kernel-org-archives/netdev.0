From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPCOMP] Use per-cpu buffers
Date: Thu, 9 Sep 2004 22:22:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909122202.GA3170@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@davemloft.net, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Here is a really ugly patch to get IPCOMP to use per-cpu buffers.  But
I'm afraid it really is necessary.  At 300K per SA IPCOMP isn't very
affordable at all.

With per-cpu buffers this goes down to 300K per CPU.

I've also turned the kmalloc'ed scratch space into a vmalloc'ed one
since people may be loading the ipcomp module after the system has
been running for a while.  On an i386 machine with 64M of RAM or less
this can often cause a 64K kmalloc to fail.

The crypto deflate buffer space are vmalloc'ed already as well.

Part of the ugliness comes from the lazy allocation.  However we need
the lazy initialisation since new IPCOMP algorithms may be introduced
in future.  That means we can't allocate space for every single IPCOMP
algorithm at module-load time.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ipcomp.patch"

===== include/net/ipcomp.h 1.1 vs edited =====
--- 1.1/include/net/ipcomp.h	2003-05-17 07:02:27 +10:00
+++ edited/include/net/ipcomp.h	2004-09-09 21:28:02 +10:00
@@ -5,8 +5,7 @@
 
 struct ipcomp_data {
 	u16 threshold;
-	u8 *scratch;
-	struct crypto_tfm *tfm;
+	struct crypto_tfm **tfms;
 };
 
 #endif
===== net/ipv4/ipcomp.c 1.33 vs edited =====
--- 1.33/net/ipv4/ipcomp.c	2004-08-25 20:48:12 +10:00
+++ edited/net/ipv4/ipcomp.c	2004-09-09 21:32:44 +10:00
@@ -16,25 +16,48 @@
 #include <linux/config.h>
 #include <linux/module.h>
 #include <asm/scatterlist.h>
+#include <asm/semaphore.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
+#include <linux/percpu.h>
+#include <linux/smp.h>
+#include <linux/list.h>
+#include <linux/vmalloc.h>
+#include <linux/rtnetlink.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/icmp.h>
 #include <net/ipcomp.h>
 
+struct ipcomp_tfms {
+	struct list_head list;
+	struct crypto_tfm **tfms;
+	int users;
+};
+
+static DECLARE_MUTEX(ipcomp_resource_sem);
+static void **ipcomp_scratches;
+static int ipcomp_scratch_users;
+static LIST_HEAD(ipcomp_tfms_list);
+
 static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err, plen, dlen;
 	struct iphdr *iph;
 	struct ipcomp_data *ipcd = x->data;
-	u8 *start, *scratch = ipcd->scratch;
+	u8 *start, *scratch;
+	struct crypto_tfm *tfm;
+	int cpu;
 	
 	plen = skb->len;
 	dlen = IPCOMP_SCRATCH_SIZE;
 	start = skb->data;
 
-	err = crypto_comp_decompress(ipcd->tfm, start, plen, scratch, &dlen);
+	cpu = get_cpu();
+	scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
+	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+
+	err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
 	if (err)
 		goto out;
 
@@ -52,6 +75,7 @@
 	iph = skb->nh.iph;
 	iph->tot_len = htons(dlen + iph->ihl * 4);
 out:	
+	put_cpu();
 	return err;
 }
 
@@ -97,14 +121,20 @@
 	int err, plen, dlen, ihlen;
 	struct iphdr *iph = skb->nh.iph;
 	struct ipcomp_data *ipcd = x->data;
-	u8 *start, *scratch = ipcd->scratch;
+	u8 *start, *scratch;
+	struct crypto_tfm *tfm;
+	int cpu;
 	
 	ihlen = iph->ihl * 4;
 	plen = skb->len - ihlen;
 	dlen = IPCOMP_SCRATCH_SIZE;
 	start = skb->data + ihlen;
 
-	err = crypto_comp_compress(ipcd->tfm, start, plen, scratch, &dlen);
+	cpu = get_cpu();
+	scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
+	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+
+	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
 	if (err)
 		goto out;
 
@@ -114,9 +144,13 @@
 	}
 	
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
+	put_cpu();
+
 	pskb_trim(skb, ihlen + dlen + sizeof(struct ip_comp_hdr));
+	return 0;
 	
 out:	
+	put_cpu();
 	return err;
 }
 
@@ -260,12 +294,132 @@
 	return err;
 }
 
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
+	for_each_cpu(i) {
+		void *scratch = *per_cpu_ptr(scratches, i);
+		if (scratch)
+			vfree(scratch);
+	}
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
+	for_each_cpu(i) {
+		void *scratch = vmalloc(IPCOMP_SCRATCH_SIZE);
+		if (!scratch)
+			return NULL;
+		*per_cpu_ptr(scratches, i) = scratch;
+	}
+
+	return scratches;
+}
+
+static void ipcomp_free_tfms(struct crypto_tfm **tfms)
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
+	for_each_cpu(cpu) {
+		struct crypto_tfm *tfm = *per_cpu_ptr(tfms, cpu);
+		if (tfm)
+			crypto_free_tfm(tfm);
+	}
+	free_percpu(tfms);
+}
+
+static struct crypto_tfm **ipcomp_alloc_tfms(const char *alg_name)
+{
+	struct ipcomp_tfms *pos;
+	struct crypto_tfm **tfms;
+	int cpu;
+
+	/* This can be any valid CPU ID so we don't need locking. */
+	cpu = smp_processor_id();
+
+	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
+		struct crypto_tfm *tfm;
+
+		tfms = pos->tfms;
+		tfm = *per_cpu_ptr(tfms, cpu);
+
+		if (!strcmp(crypto_tfm_alg_name(tfm), alg_name)) {
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
+	pos->tfms = tfms = alloc_percpu(struct crypto_tfm *);
+	if (!tfms)
+		goto error;
+
+	for_each_cpu(cpu) {
+		struct crypto_tfm *tfm = crypto_alloc_tfm(alg_name, 0);
+		if (!tfm)
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
 static void ipcomp_free_data(struct ipcomp_data *ipcd)
 {
-	if (ipcd->tfm)
-		crypto_free_tfm(ipcd->tfm);
-	if (ipcd->scratch)
-		kfree(ipcd->scratch);	
+	if (ipcd->tfms)
+		ipcomp_free_tfms(ipcd->tfms);
+	ipcomp_free_scratches();
 }
 
 static void ipcomp_destroy(struct xfrm_state *x)
@@ -274,7 +428,9 @@
 	if (!ipcd)
 		return;
 	xfrm_state_delete_tunnel(x);
+	down(&ipcomp_resource_sem);
 	ipcomp_free_data(ipcd);
+	up(&ipcomp_resource_sem);
 	kfree(ipcd);
 }
 
@@ -294,25 +450,26 @@
 	err = -ENOMEM;
 	ipcd = kmalloc(sizeof(*ipcd), GFP_KERNEL);
 	if (!ipcd)
-		goto error;
+		goto out;
 
 	memset(ipcd, 0, sizeof(*ipcd));
 	x->props.header_len = 0;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct iphdr);
 
-	ipcd->scratch = kmalloc(IPCOMP_SCRATCH_SIZE, GFP_KERNEL);
-	if (!ipcd->scratch)
+	down(&ipcomp_resource_sem);
+	if (!ipcomp_alloc_scratches())
 		goto error;
-	
-	ipcd->tfm = crypto_alloc_tfm(x->calg->alg_name, 0);
-	if (!ipcd->tfm)
+
+	ipcd->tfms = ipcomp_alloc_tfms(x->calg->alg_name);
+	if (!ipcd->tfms)
 		goto error;
+	up(&ipcomp_resource_sem);
 
 	if (x->props.mode) {
 		err = ipcomp_tunnel_attach(x);
 		if (err)
-			goto error;
+			goto error_tunnel;
 	}
 
 	calg_desc = xfrm_calg_get_byname(x->calg->alg_name);
@@ -323,11 +480,12 @@
 out:
 	return err;
 
+error_tunnel:
+	down(&ipcomp_resource_sem);
 error:
-	if (ipcd) {
-		ipcomp_free_data(ipcd);
-		kfree(ipcd);
-	}
+	ipcomp_free_data(ipcd);
+	up(&ipcomp_resource_sem);
+	kfree(ipcd);
 	goto out;
 }
 
===== net/ipv6/ipcomp6.c 1.24 vs edited =====
--- 1.24/net/ipv6/ipcomp6.c	2004-08-25 20:48:12 +10:00
+++ edited/net/ipv6/ipcomp6.c	2004-09-09 21:36:23 +10:00
@@ -36,14 +36,31 @@
 #include <net/xfrm.h>
 #include <net/ipcomp.h>
 #include <asm/scatterlist.h>
+#include <asm/semaphore.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
 #include <linux/random.h>
+#include <linux/percpu.h>
+#include <linux/smp.h>
+#include <linux/list.h>
+#include <linux/vmalloc.h>
+#include <linux/rtnetlink.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 
+struct ipcomp6_tfms {
+	struct list_head list;
+	struct crypto_tfm **tfms;
+	int users;
+};
+
+static DECLARE_MUTEX(ipcomp6_resource_sem);
+static void **ipcomp6_scratches;
+static int ipcomp6_scratch_users;
+static LIST_HEAD(ipcomp6_tfms_list);
+
 static int ipcomp6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
 	int err = 0;
@@ -53,7 +70,9 @@
 	struct ipv6hdr *iph;
 	int plen, dlen;
 	struct ipcomp_data *ipcd = x->data;
-	u8 *start, *scratch = ipcd->scratch;
+	u8 *start, *scratch;
+	struct crypto_tfm *tfm;
+	int cpu;
 
 	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
 		skb_linearize(skb, GFP_ATOMIC) != 0) {
@@ -82,20 +101,24 @@
 	dlen = IPCOMP_SCRATCH_SIZE;
 	start = skb->data;
 
-	err = crypto_comp_decompress(ipcd->tfm, start, plen, scratch, &dlen);
+	cpu = get_cpu();
+	scratch = *per_cpu_ptr(ipcomp6_scratches, cpu);
+	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+
+	err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
 	if (err) {
 		err = -EINVAL;
-		goto out;
+		goto out_put_cpu;
 	}
 
 	if (dlen < (plen + sizeof(struct ipv6_comp_hdr))) {
 		err = -EINVAL;
-		goto out;
+		goto out_put_cpu;
 	}
 
 	err = pskb_expand_head(skb, 0, dlen - plen, GFP_ATOMIC);
 	if (err) {
-		goto out;
+		goto out_put_cpu;
 	}
 
 	skb_put(skb, dlen - plen);
@@ -104,6 +127,8 @@
 	iph = skb->nh.ipv6h;
 	iph->payload_len = htons(skb->len);
 	
+out_put_cpu:
+	put_cpu();
 out:
 	if (tmp_hdr)
 		kfree(tmp_hdr);
@@ -124,7 +149,9 @@
 	struct ipv6_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
 	int plen, dlen;
-	u8 *start, *scratch = ipcd->scratch;
+	u8 *start, *scratch;
+	struct crypto_tfm *tfm;
+	int cpu;
 
 	hdr_len = skb->h.raw - skb->data;
 
@@ -144,14 +171,21 @@
 	dlen = IPCOMP_SCRATCH_SIZE;
 	start = skb->h.raw;
 
-	err = crypto_comp_compress(ipcd->tfm, start, plen, scratch, &dlen);
+	cpu = get_cpu();
+	scratch = *per_cpu_ptr(ipcomp6_scratches, cpu);
+	tfm = *per_cpu_ptr(ipcd->tfms, cpu);
+
+	err = crypto_comp_compress(tfm, start, plen, scratch, &dlen);
 	if (err) {
+		put_cpu();
 		goto error;
 	}
 	if ((dlen + sizeof(struct ipv6_comp_hdr)) >= plen) {
+		put_cpu();
 		goto out_ok;
 	}
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
+	put_cpu();
 	pskb_trim(skb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
 
 	/* insert ipcomp header and replace datagram */
@@ -254,12 +288,132 @@
 	return err;
 }
 
+static void ipcomp6_free_scratches(void)
+{
+	int i;
+	void **scratches;
+
+	if (--ipcomp6_scratch_users)
+		return;
+
+	scratches = ipcomp6_scratches;
+	if (!scratches)
+		return;
+
+	for_each_cpu(i) {
+		void *scratch = *per_cpu_ptr(scratches, i);
+		if (scratch)
+			vfree(scratch);
+	}
+
+	free_percpu(scratches);
+}
+
+static void **ipcomp6_alloc_scratches(void)
+{
+	int i;
+	void **scratches;
+
+	if (ipcomp6_scratch_users++)
+		return ipcomp6_scratches;
+
+	scratches = alloc_percpu(void *);
+	if (!scratches)
+		return NULL;
+
+	ipcomp6_scratches = scratches;
+
+	for_each_cpu(i) {
+		void *scratch = vmalloc(IPCOMP_SCRATCH_SIZE);
+		if (!scratch)
+			return NULL;
+		*per_cpu_ptr(scratches, i) = scratch;
+	}
+
+	return scratches;
+}
+
+static void ipcomp6_free_tfms(struct crypto_tfm **tfms)
+{
+	struct ipcomp6_tfms *pos;
+	int cpu;
+
+	list_for_each_entry(pos, &ipcomp6_tfms_list, list) {
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
+	for_each_cpu(cpu) {
+		struct crypto_tfm *tfm = *per_cpu_ptr(tfms, cpu);
+		if (tfm)
+			crypto_free_tfm(tfm);
+	}
+	free_percpu(tfms);
+}
+
+static struct crypto_tfm **ipcomp6_alloc_tfms(const char *alg_name)
+{
+	struct ipcomp6_tfms *pos;
+	struct crypto_tfm **tfms;
+	int cpu;
+
+	/* This can be any valid CPU ID so we don't need locking. */
+	cpu = smp_processor_id();
+
+	list_for_each_entry(pos, &ipcomp6_tfms_list, list) {
+		struct crypto_tfm *tfm;
+
+		tfms = pos->tfms;
+		tfm = *per_cpu_ptr(tfms, cpu);
+
+		if (!strcmp(crypto_tfm_alg_name(tfm), alg_name)) {
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
+	list_add(&pos->list, &ipcomp6_tfms_list);
+
+	pos->tfms = tfms = alloc_percpu(struct crypto_tfm *);
+	if (!tfms)
+		goto error;
+
+	for_each_cpu(cpu) {
+		struct crypto_tfm *tfm = crypto_alloc_tfm(alg_name, 0);
+		if (!tfm)
+			goto error;
+		*per_cpu_ptr(tfms, cpu) = tfm;
+	}
+
+	return tfms;
+
+error:
+	ipcomp6_free_tfms(tfms);
+	return NULL;
+}
+
 static void ipcomp6_free_data(struct ipcomp_data *ipcd)
 {
-	if (ipcd->tfm)
-		crypto_free_tfm(ipcd->tfm);
-	if (ipcd->scratch)
-		kfree(ipcd->scratch);
+	if (ipcd->tfms)
+		ipcomp6_free_tfms(ipcd->tfms);
+	ipcomp6_free_scratches();
 }
 
 static void ipcomp6_destroy(struct xfrm_state *x)
@@ -268,7 +422,9 @@
 	if (!ipcd)
 		return;
 	xfrm_state_delete_tunnel(x);
+	down(&ipcomp6_resource_sem);
 	ipcomp6_free_data(ipcd);
+	up(&ipcomp6_resource_sem);
 	kfree(ipcd);
 
 	xfrm6_tunnel_free_spi((xfrm_address_t *)&x->props.saddr);
@@ -290,25 +446,26 @@
 	err = -ENOMEM;
 	ipcd = kmalloc(sizeof(*ipcd), GFP_KERNEL);
 	if (!ipcd)
-		goto error;
+		goto out;
 
 	memset(ipcd, 0, sizeof(*ipcd));
 	x->props.header_len = 0;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	
-	ipcd->scratch = kmalloc(IPCOMP_SCRATCH_SIZE, GFP_KERNEL);
-	if (!ipcd->scratch)
+	down(&ipcomp6_resource_sem);
+	if (!ipcomp6_alloc_scratches())
 		goto error;
 
-	ipcd->tfm = crypto_alloc_tfm(x->calg->alg_name, 0);
-	if (!ipcd->tfm)
+	ipcd->tfms = ipcomp6_alloc_tfms(x->calg->alg_name);
+	if (!ipcd->tfms)
 		goto error;
+	up(&ipcomp6_resource_sem);
 
 	if (x->props.mode) {
 		err = ipcomp6_tunnel_attach(x);
 		if (err)
-			goto error;
+			goto error_tunnel;
 	}
 
 	calg_desc = xfrm_calg_get_byname(x->calg->alg_name);
@@ -318,11 +475,12 @@
 	err = 0;
 out:
 	return err;
+error_tunnel:
+	down(&ipcomp6_resource_sem);
 error:
-	if (ipcd) {
-		ipcomp6_free_data(ipcd);
-		kfree(ipcd);
-	}
+	ipcomp6_free_data(ipcd);
+	up(&ipcomp6_resource_sem);
+	kfree(ipcd);
 
 	goto out;
 }

--ew6BAiZeqk4r7MaW--
