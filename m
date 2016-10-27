From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v3 4/9] ipv6: sr: add core files for SR HMAC support
Date: Thu, 27 Oct 2016 15:33:54 +0200
Message-ID: <1477575239-11228-5-git-send-email-david.lebrun@uclouvain.be>
References: <1477575239-11228-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56624 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbcJ0Nri (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:47:38 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 6033E67DBE3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 15:32:16 +0200 (CEST)
In-Reply-To: <1477575239-11228-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the necessary functions to compute and check the HMAC signature
of an SR-enabled packet. Two HMAC algorithms are supported: hmac(sha1) and
hmac(sha256).

In order to avoid dynamic memory allocation for each HMAC computation,
a per-cpu ring buffer is allocated for this purpose.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/linux/seg6_hmac.h      |   6 +
 include/net/seg6_hmac.h        |  61 ++++++
 include/uapi/linux/seg6_hmac.h |  20 ++
 net/ipv6/Kconfig               |  12 ++
 net/ipv6/seg6_hmac.c           | 437 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 536 insertions(+)
 create mode 100644 include/linux/seg6_hmac.h
 create mode 100644 include/net/seg6_hmac.h
 create mode 100644 include/uapi/linux/seg6_hmac.h
 create mode 100644 net/ipv6/seg6_hmac.c

diff --git a/include/linux/seg6_hmac.h b/include/linux/seg6_hmac.h
new file mode 100644
index 0000000..da437eb
--- /dev/null
+++ b/include/linux/seg6_hmac.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_SEG6_HMAC_H
+#define _LINUX_SEG6_HMAC_H
+
+#include <uapi/linux/seg6_hmac.h>
+
+#endif
diff --git a/include/net/seg6_hmac.h b/include/net/seg6_hmac.h
new file mode 100644
index 0000000..6e5ee6a
--- /dev/null
+++ b/include/net/seg6_hmac.h
@@ -0,0 +1,61 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _NET_SEG6_HMAC_H
+#define _NET_SEG6_HMAC_H
+
+#include <net/flow.h>
+#include <net/ip6_fib.h>
+#include <net/sock.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/route.h>
+#include <net/seg6.h>
+#include <linux/seg6_hmac.h>
+
+#define SEG6_HMAC_MAX_DIGESTSIZE	160
+#define SEG6_HMAC_RING_SIZE		256
+
+struct seg6_hmac_info {
+	struct list_head list;
+
+	u32 hmackeyid;
+	char secret[SEG6_HMAC_SECRET_LEN];
+	u8 slen;
+	u8 alg_id;
+};
+
+struct seg6_hmac_algo {
+	u8 alg_id;
+	char name[64];
+	struct crypto_shash * __percpu *tfms;
+	struct shash_desc * __percpu *shashs;
+};
+
+extern int seg6_hmac_compute(struct seg6_hmac_info *hinfo,
+			     struct ipv6_sr_hdr *hdr, struct in6_addr *saddr,
+			     u8 *output);
+extern struct seg6_hmac_info *seg6_hmac_info_lookup(struct net *net, u32 key);
+extern int seg6_hmac_info_add(struct net *net, u32 key,
+			      struct seg6_hmac_info *hinfo);
+extern int seg6_hmac_info_del(struct net *net, u32 key,
+			      struct seg6_hmac_info *hinfo);
+extern int seg6_push_hmac(struct net *net, struct in6_addr *saddr,
+			  struct ipv6_sr_hdr *srh);
+extern bool seg6_hmac_validate_skb(struct sk_buff *skb);
+extern int seg6_hmac_init(void);
+extern void seg6_hmac_exit(void);
+extern int seg6_hmac_net_init(struct net *net);
+extern void seg6_hmac_net_exit(struct net *net);
+
+#endif
diff --git a/include/uapi/linux/seg6_hmac.h b/include/uapi/linux/seg6_hmac.h
new file mode 100644
index 0000000..0b5eda7
--- /dev/null
+++ b/include/uapi/linux/seg6_hmac.h
@@ -0,0 +1,20 @@
+#ifndef _UAPI_LINUX_SEG6_HMAC_H
+#define _UAPI_LINUX_SEG6_HMAC_H
+
+#define SEG6_HMAC_SECRET_LEN	64
+#define SEG6_HMAC_FIELD_LEN	32
+
+struct sr6_tlv_hmac {
+	__u8 type;
+	__u8 len;
+	__u16 reserved;
+	__be32 hmackeyid;
+	__u8 hmac[SEG6_HMAC_FIELD_LEN];
+} __attribute__((packed));
+
+enum {
+	SEG6_HMAC_ALGO_SHA1 = 1,
+	SEG6_HMAC_ALGO_SHA256 = 2,
+};
+
+#endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 2343e4f..c647712 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -289,4 +289,16 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_SEG6_HMAC
+	bool "IPv6: Segment Routing HMAC support"
+	depends on IPV6
+	select CRYPTO_HMAC
+	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+	---help---
+	  Support for HMAC signature generation and verification
+	  of SR-enabled packets.
+
+	  If unsure, say N.
+
 endif # IPV6
diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
new file mode 100644
index 0000000..96fe950
--- /dev/null
+++ b/net/ipv6/seg6_hmac.c
@@ -0,0 +1,437 @@
+/*
+ *  SR-IPv6 implementation -- HMAC functions
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/in6.h>
+#include <linux/icmpv6.h>
+#include <linux/mroute6.h>
+#include <linux/slab.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+
+#include <net/sock.h>
+#include <net/snmp.h>
+
+#include <net/ipv6.h>
+#include <net/protocol.h>
+#include <net/transp_v6.h>
+#include <net/rawv6.h>
+#include <net/ndisc.h>
+#include <net/ip6_route.h>
+#include <net/addrconf.h>
+#include <net/xfrm.h>
+
+#include <linux/cryptohash.h>
+#include <crypto/hash.h>
+#include <crypto/sha.h>
+#include <net/seg6.h>
+#include <net/genetlink.h>
+#include <net/seg6_hmac.h>
+#include <linux/random.h>
+
+static char * __percpu *hmac_ring;
+
+static struct seg6_hmac_algo hmac_algos[] = {
+	{
+		.alg_id = SEG6_HMAC_ALGO_SHA1,
+		.name = "hmac(sha1)",
+	},
+	{
+		.alg_id = SEG6_HMAC_ALGO_SHA256,
+		.name = "hmac(sha256)",
+	},
+};
+
+static struct seg6_hmac_algo *__hmac_get_algo(u8 alg_id)
+{
+	struct seg6_hmac_algo *algo;
+	int i, alg_count;
+
+	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
+	for (i = 0; i < alg_count; i++) {
+		algo = &hmac_algos[i];
+		if (algo->alg_id == alg_id)
+			return algo;
+	}
+
+	return NULL;
+}
+
+static int __do_hmac(struct seg6_hmac_info *hinfo, const char *text, u8 psize,
+		     u8 *output, int outlen)
+{
+	struct seg6_hmac_algo *algo;
+	struct crypto_shash *tfm;
+	struct shash_desc *shash;
+	int ret, dgsize;
+
+	algo = __hmac_get_algo(hinfo->alg_id);
+	if (!algo)
+		return -ENOENT;
+
+	tfm = *this_cpu_ptr(algo->tfms);
+
+	dgsize = crypto_shash_digestsize(tfm);
+	if (dgsize > outlen) {
+		pr_debug("sr-ipv6: __do_hmac: digest size too big (%d / %d)\n",
+			 dgsize, outlen);
+		return -ENOMEM;
+	}
+
+	ret = crypto_shash_setkey(tfm, hinfo->secret, hinfo->slen);
+	if (ret < 0) {
+		pr_debug("sr-ipv6: crypto_shash_setkey failed: err %d\n", ret);
+		goto failed;
+	}
+
+	shash = *this_cpu_ptr(algo->shashs);
+	shash->tfm = tfm;
+
+	ret = crypto_shash_digest(shash, text, psize, output);
+	if (ret < 0) {
+		pr_debug("sr-ipv6: crypto_shash_digest failed: err %d\n", ret);
+		goto failed;
+	}
+
+	return dgsize;
+
+failed:
+	return ret;
+}
+
+int seg6_hmac_compute(struct seg6_hmac_info *hinfo, struct ipv6_sr_hdr *hdr,
+		      struct in6_addr *saddr, u8 *output)
+{
+	__be32 hmackeyid = cpu_to_be32(hinfo->hmackeyid);
+	u8 tmp_out[SEG6_HMAC_MAX_DIGESTSIZE];
+	int plen, i, dgsize, wrsize;
+	char *ring, *off;
+
+	/* a 160-byte buffer for digest output allows to store highest known
+	 * hash function (RadioGatun) with up to 1216 bits
+	 */
+
+	/* saddr(16) + first_seg(1) + cleanup(1) + keyid(4) + seglist(16n) */
+	plen = 16 + 1 + 1 + 4 + (hdr->first_segment + 1) * 16;
+
+	/* this limit allows for 14 segments */
+	if (plen >= SEG6_HMAC_RING_SIZE)
+		return -EMSGSIZE;
+
+	local_bh_disable();
+	ring = *this_cpu_ptr(hmac_ring);
+	off = ring;
+	memcpy(off, saddr, 16);
+	off += 16;
+	*off++ = hdr->first_segment;
+	*off++ = !!(sr_has_cleanup(hdr)) << 7;
+	memcpy(off, &hmackeyid, 4);
+	off += 4;
+
+	for (i = 0; i < hdr->first_segment + 1; i++) {
+		memcpy(off, hdr->segments + i, 16);
+		off += 16;
+	}
+
+	dgsize = __do_hmac(hinfo, ring, plen, tmp_out,
+			   SEG6_HMAC_MAX_DIGESTSIZE);
+	local_bh_enable();
+
+	if (dgsize < 0)
+		return dgsize;
+
+	wrsize = SEG6_HMAC_FIELD_LEN;
+	if (wrsize > dgsize)
+		wrsize = dgsize;
+
+	memset(output, 0, SEG6_HMAC_FIELD_LEN);
+	memcpy(output, tmp_out, wrsize);
+
+	return 0;
+}
+EXPORT_SYMBOL(seg6_hmac_compute);
+
+/* checks if an incoming SR-enabled packet's HMAC status matches
+ * the incoming policy.
+ *
+ * called with rcu_read_lock()
+ */
+bool seg6_hmac_validate_skb(struct sk_buff *skb)
+{
+	u8 hmac_output[SEG6_HMAC_FIELD_LEN];
+	struct net *net = dev_net(skb->dev);
+	struct seg6_hmac_info *hinfo;
+	struct sr6_tlv_hmac *tlv;
+	struct ipv6_sr_hdr *srh;
+	struct inet6_dev *idev;
+
+	idev = __in6_dev_get(skb->dev);
+
+	srh = (struct ipv6_sr_hdr *)skb_transport_header(skb);
+
+	tlv = seg6_get_tlv_hmac(srh);
+
+	/* mandatory check but no tlv */
+	if (idev->cnf.seg6_require_hmac > 0 && !tlv)
+		return false;
+
+	/* no check */
+	if (idev->cnf.seg6_require_hmac < 0)
+		return true;
+
+	/* check only if present */
+	if (idev->cnf.seg6_require_hmac == 0 && !tlv)
+		return true;
+
+	/* now, seg6_require_hmac >= 0 && tlv */
+
+	hinfo = seg6_hmac_info_lookup(net, be32_to_cpu(tlv->hmackeyid));
+	if (!hinfo)
+		return false;
+
+	if (seg6_hmac_compute(hinfo, srh, &ipv6_hdr(skb)->saddr, hmac_output))
+		return false;
+
+	if (memcmp(hmac_output, tlv->hmac, SEG6_HMAC_FIELD_LEN) != 0)
+		return false;
+
+	return true;
+}
+EXPORT_SYMBOL(seg6_hmac_validate_skb);
+
+/* called with rcu_read_lock() */
+struct seg6_hmac_info *seg6_hmac_info_lookup(struct net *net, u32 key)
+{
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+	struct seg6_hmac_info *hinfo;
+
+	list_for_each_entry_rcu(hinfo, &sdata->hmac_infos, list) {
+		if (hinfo->hmackeyid == key)
+			return hinfo;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(seg6_hmac_info_lookup);
+
+int seg6_hmac_info_add(struct net *net, u32 key, struct seg6_hmac_info *hinfo)
+{
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+	struct seg6_hmac_info *old_hinfo;
+
+	old_hinfo = seg6_hmac_info_lookup(net, key);
+	if (old_hinfo)
+		return -EEXIST;
+
+	list_add_rcu(&hinfo->list, &sdata->hmac_infos);
+
+	return 0;
+}
+EXPORT_SYMBOL(seg6_hmac_info_add);
+
+int seg6_hmac_info_del(struct net *net, u32 key, struct seg6_hmac_info *hinfo)
+{
+	struct seg6_hmac_info *tmp;
+
+	tmp = seg6_hmac_info_lookup(net, key);
+	if (!tmp)
+		return -ENOENT;
+
+	/* entry was replaced, ignore deletion */
+	if (tmp != hinfo)
+		return -ENOENT;
+
+	list_del_rcu(&hinfo->list);
+	synchronize_net();
+
+	return 0;
+}
+EXPORT_SYMBOL(seg6_hmac_info_del);
+
+static void seg6_hmac_info_flush(struct net *net)
+{
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+	struct seg6_hmac_info *hinfo;
+
+	mutex_lock(&sdata->lock);
+	while ((hinfo = list_first_or_null_rcu(&sdata->hmac_infos,
+					       struct seg6_hmac_info,
+					       list)) != NULL) {
+		list_del_rcu(&hinfo->list);
+		mutex_unlock(&sdata->lock);
+		synchronize_net();
+		kfree(hinfo);
+		mutex_lock(&sdata->lock);
+	}
+
+	mutex_unlock(&sdata->lock);
+}
+
+int seg6_push_hmac(struct net *net, struct in6_addr *saddr,
+		   struct ipv6_sr_hdr *srh)
+{
+	struct seg6_hmac_info *hinfo;
+	struct sr6_tlv_hmac *tlv;
+	int err = -ENOENT;
+
+	tlv = seg6_get_tlv_hmac(srh);
+	if (!tlv)
+		return -EINVAL;
+
+	rcu_read_lock();
+
+	hinfo = seg6_hmac_info_lookup(net, be32_to_cpu(tlv->hmackeyid));
+	if (!hinfo)
+		goto out;
+
+	memset(tlv->hmac, 0, SEG6_HMAC_FIELD_LEN);
+	err = seg6_hmac_compute(hinfo, srh, saddr, tlv->hmac);
+
+out:
+	rcu_read_unlock();
+	return err;
+}
+EXPORT_SYMBOL(seg6_push_hmac);
+
+static int seg6_hmac_init_ring(void)
+{
+	int i;
+
+	hmac_ring = alloc_percpu(char *);
+
+	if (!hmac_ring)
+		return -ENOMEM;
+
+	for_each_possible_cpu(i) {
+		char *ring = kzalloc(SEG6_HMAC_RING_SIZE, GFP_KERNEL);
+
+		if (!ring)
+			return -ENOMEM;
+
+		*per_cpu_ptr(hmac_ring, i) = ring;
+	}
+
+	return 0;
+}
+
+static int seg6_hmac_init_algo(void)
+{
+	struct seg6_hmac_algo *algo;
+	struct crypto_shash *tfm;
+	struct shash_desc *shash;
+	int i, alg_count, cpu;
+
+	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
+
+	for (i = 0; i < alg_count; i++) {
+		struct crypto_shash **p_tfm;
+		int shsize;
+
+		algo = &hmac_algos[i];
+		algo->tfms = alloc_percpu(struct crypto_shash *);
+		if (!algo->tfms)
+			return -ENOMEM;
+
+		for_each_possible_cpu(cpu) {
+			tfm = crypto_alloc_shash(algo->name, 0, GFP_KERNEL);
+			if (IS_ERR(tfm))
+				return PTR_ERR(tfm);
+			p_tfm = per_cpu_ptr(algo->tfms, cpu);
+			*p_tfm = tfm;
+		}
+
+		p_tfm = this_cpu_ptr(algo->tfms);
+		tfm = *p_tfm;
+
+		shsize = sizeof(*shash) + crypto_shash_descsize(tfm);
+
+		algo->shashs = alloc_percpu(struct shash_desc *);
+		if (!algo->shashs)
+			return -ENOMEM;
+
+		for_each_possible_cpu(cpu) {
+			shash = kzalloc(shsize, GFP_KERNEL);
+			if (!shash)
+				return -ENOMEM;
+			*per_cpu_ptr(algo->shashs, cpu) = shash;
+		}
+	}
+
+	return 0;
+}
+
+int __init seg6_hmac_init(void)
+{
+	int ret;
+
+	ret = seg6_hmac_init_ring();
+	if (ret < 0)
+		goto out;
+
+	ret = seg6_hmac_init_algo();
+
+out:
+	return ret;
+}
+EXPORT_SYMBOL(seg6_hmac_init);
+
+int __net_init seg6_hmac_net_init(struct net *net)
+{
+	struct seg6_pernet_data *sdata = seg6_pernet(net);
+
+	INIT_LIST_HEAD(&sdata->hmac_infos);
+	return 0;
+}
+EXPORT_SYMBOL(seg6_hmac_net_init);
+
+void seg6_hmac_exit(void)
+{
+	struct seg6_hmac_algo *algo = NULL;
+	int i, alg_count, cpu;
+
+	for_each_possible_cpu(i) {
+		char *ring = *per_cpu_ptr(hmac_ring, i);
+
+		kfree(ring);
+	}
+	free_percpu(hmac_ring);
+
+	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
+	for (i = 0; i < alg_count; i++) {
+		algo = &hmac_algos[i];
+		for_each_possible_cpu(cpu) {
+			struct crypto_shash *tfm;
+			struct shash_desc *shash;
+
+			shash = *per_cpu_ptr(algo->shashs, cpu);
+			kfree(shash);
+			tfm = *per_cpu_ptr(algo->tfms, cpu);
+			crypto_free_shash(tfm);
+		}
+		free_percpu(algo->tfms);
+		free_percpu(algo->shashs);
+	}
+}
+EXPORT_SYMBOL(seg6_hmac_exit);
+
+void __net_exit seg6_hmac_net_exit(struct net *net)
+{
+	seg6_hmac_info_flush(net);
+}
+EXPORT_SYMBOL(seg6_hmac_net_exit);
-- 
2.7.3
