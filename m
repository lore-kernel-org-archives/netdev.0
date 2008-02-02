From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: [PATCH] NOTRACK only untracked
Date: Sat, 02 Feb 2008 14:58:10 -0200
Message-ID: <47A4A122.5070701@bspu.unibel.by>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301080000010501000208"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:35341 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbYBBM6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 07:58:17 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m12CwDU7022888
	for <netdev@vger.kernel.org>; Sat, 2 Feb 2008 14:58:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090301080000010501000208
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit

There are modification of NOTRACK netfilter target to avoid creating new 
connection entries for packets, unrelated to any existing connection.

Best way to make new target (clone NOTRACK to NOTRACK-NEW and fix - to mix 
both), but I have enough motivation to this work ;)

PS There are not same patch with netfilter@vger.kernel.org. Verifyed and 
fixed. (& net-2.6.25)

PPS Idea about u32 was bad. Sorry.

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by

--------------090301080000010501000208
Content-Type: text/plain;
 name="notrack-new.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="notrack-new.patch"

diff -pruN net-2.6.orig/net/netfilter/Kconfig net-2.6.fixed/net/netfilter/Kconfig
--- net-2.6.orig/net/netfilter/Kconfig	2008-01-30 20:17:08.000000000 +0200
+++ net-2.6.fixed/net/netfilter/Kconfig	2008-02-02 14:37:22.000000000 +0200
@@ -375,6 +375,12 @@ config NETFILTER_XT_TARGET_NOTRACK
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_TARGET_NOTRACK_NEW
+	bool "NOTRACK safe (only new)"
+	depends on NETFILTER_XT_TARGET_NOTRACK
+	help
+	  Slow but safe way to NOTRACK only new/untracked connections.
+
 config NETFILTER_XT_TARGET_RATEEST
 	tristate '"RATEEST" target support'
 	depends on NETFILTER_XTABLES
diff -pruN net-2.6.orig/net/netfilter/nf_conntrack_core.c net-2.6.fixed/net/netfilter/nf_conntrack_core.c
--- net-2.6.orig/net/netfilter/nf_conntrack_core.c	2008-01-30 20:17:08.000000000 +0200
+++ net-2.6.fixed/net/netfilter/nf_conntrack_core.c	2008-02-02 14:22:53.000000000 +0200
@@ -587,6 +587,9 @@ resolve_normal_ct(struct sk_buff *skb,
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
+#ifdef CONFIG_NETFILTER_XT_TARGET_NOTRACK_NEW
+	struct nf_conntrack_expect *exp;
+#endif
 
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
 			     dataoff, l3num, protonum, &tuple, l3proto,
@@ -598,6 +601,17 @@ resolve_normal_ct(struct sk_buff *skb,
 	/* look for tuple match */
 	h = nf_conntrack_find_get(&tuple);
 	if (!h) {
+#ifdef CONFIG_NETFILTER_XT_TARGET_NOTRACK_NEW
+		if(skb->nfctinfo == IP_CT_NEW) {
+		    exp = nf_ct_expect_find_get(&tuple);
+		    if(!exp){
+			skb->nfct = &nf_conntrack_untracked.ct_general;
+			nf_conntrack_get(skb->nfct);
+			return NULL;
+		    }
+		    nf_ct_expect_put(exp);
+		}
+#endif
 		h = init_conntrack(&tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
@@ -675,6 +689,12 @@ nf_conntrack_in(int pf, unsigned int hoo
 	ct = resolve_normal_ct(skb, dataoff, pf, protonum, l3proto, l4proto,
 			       &set_reply, &ctinfo);
 	if (!ct) {
+#ifdef CONFIG_NETFILTER_XT_TARGET_NOTRACK_NEW
+		if(skb->nfct == &nf_conntrack_untracked.ct_general){
+		    NF_CT_STAT_INC_ATOMIC(ignore);
+		    return NF_ACCEPT;
+		}
+#endif
 		/* Not valid part of a connection */
 		NF_CT_STAT_INC_ATOMIC(invalid);
 		return NF_ACCEPT;
diff -pruN net-2.6.orig/net/netfilter/xt_NOTRACK.c net-2.6.fixed/net/netfilter/xt_NOTRACK.c
--- net-2.6.orig/net/netfilter/xt_NOTRACK.c	2008-01-30 20:17:08.000000000 +0200
+++ net-2.6.fixed/net/netfilter/xt_NOTRACK.c	2008-02-02 14:22:02.000000000 +0200
@@ -21,6 +21,9 @@ notrack_tg(struct sk_buff *skb, const st
 	if (skb->nfct != NULL)
 		return XT_CONTINUE;
 
+#ifdef CONFIG_NETFILTER_XT_TARGET_NOTRACK_NEW
+	skb->nfctinfo = IP_CT_NEW;
+#else
 	/* Attach fake conntrack entry.
 	   If there is a real ct entry correspondig to this packet,
 	   it'll hang aroun till timing out. We don't deal with it
@@ -28,6 +31,7 @@ notrack_tg(struct sk_buff *skb, const st
 	skb->nfct = &nf_conntrack_untracked.ct_general;
 	skb->nfctinfo = IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
+#endif
 
 	return XT_CONTINUE;
 }

--------------090301080000010501000208--
