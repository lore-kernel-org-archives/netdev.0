From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 06:06:02 -0700
Message-ID: <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
	 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029090849.GC5944@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>
To: Christoph Paasch <christoph.paasch@uclouvain.be>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:53068 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895Ab3J2NGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 09:06:05 -0400
Received: by mail-pd0-f174.google.com with SMTP id z10so3852846pdj.19
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 06:06:04 -0700 (PDT)
In-Reply-To: <20131029090849.GC5944@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")

(Jerry is working on adding native GRO support for tunnels)

skb_segment() only deals with a frag_list chain containing MSS sized
fragments.

This patch adds support any kind of frag, and adds a new sysctl,
as clearly the GRO layer should avoid building frag_list skbs
on a router, as the segmentation is adding cpu overhead.

Note that we could try to reuse page fragments instead of doing
copy to linear skbs, but this requires a fair amount of work,
and possible truesize nightmares, as we do not track individual
(per page fragment) truesizes.

/proc/sys/net/core/gro_frag_list_enable possible values are :

0 : GRO layer is not allowed to use frag_list to extend skb capacity
1 : GRO layer is allowed to use frag_list, but skb_segment()
    automatically sets the sysctl to 0.
2 : GRO is allowed to use frag_list, and skb_segment() wont
    clear the sysctl.

Default value is 1 : automatic discovery

Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Reported-by: Jerry Chu <hkchu@google.com>
Cc: Michael Dalton <mwdalton@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/sysctl/net.txt |   19 +++++++++++++++++++
 include/linux/netdevice.h    |    1 +
 net/core/skbuff.c            |   29 ++++++++++++++++++++---------
 net/core/sysctl_net_core.c   |   10 ++++++++++
 4 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 9a0319a82470..8778568ae64e 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -87,6 +87,25 @@ sysctl.net.busy_read globally.
 Will increase power usage.
 Default: 0 (off)
 
+gro_frag_list_enable
+--------------------
+
+GRO layer can build full size GRO packets (~64K of payload) if it is allowed
+to extend skb using the frag_list pointer. However, this strategy is a win
+on hosts, where TCP flows are terminated. For a router, using frag_list
+skbs is not a win because we have to segment skbs before transmit,
+as most NIC drivers do not support frag_list.
+As soon as one frag_list skb has to be segmented, this sysctl is automatically
+changed from 1 to 0.
+If the value is set to 2, kernel wont change it.
+
+Choices : 0 (off),
+          1 (on, with automatic change to 0)
+          2 (on, permanent)
+
+Default: 1 (on, with automatic downgrade on a router)
+
+
 rmem_default
 ------------
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 27f62f746621..b82ff52f301e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2807,6 +2807,7 @@ extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
+extern int		sysctl_gro_frag_list_enable;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 bool netdev_has_any_upper_dev(struct net_device *dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0ab32faa520f..d5b74ed1e9cb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2761,7 +2761,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	unsigned int len;
 	__be16 proto;
 	bool csum;
-	int sg = !!(features & NETIF_F_SG);
+	bool sg = !!(features & NETIF_F_SG);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
@@ -2793,7 +2793,13 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			hsize = len;
 
 		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+			if (fskb->len != len) {
+				if (sysctl_gro_frag_list_enable == 1)
+					sysctl_gro_frag_list_enable = 0;
+				hsize = len;
+				sg = false;
+				goto do_linear;
+			}
 
 			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);
@@ -2812,6 +2818,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			skb_release_head_state(nskb);
 			__skb_push(nskb, doffset);
 		} else {
+do_linear:
 			nskb = __alloc_skb(hsize + doffset + headroom,
 					   GFP_ATOMIC, skb_alloc_rx_flag(skb),
 					   NUMA_NO_NODE);
@@ -2838,9 +2845,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
-			goto perform_csum_check;
-
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
 			nskb->csum = skb_copy_and_csum_bits(skb, offset,
@@ -2849,6 +2853,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			continue;
 		}
 
+		if (fskb != skb_shinfo(skb)->frag_list)
+			goto perform_csum_check;
+
 		frag = skb_shinfo(nskb)->frags;
 
 		skb_copy_from_linear_data_offset(skb, offset,
@@ -2944,9 +2951,11 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		int i = skbinfo->nr_frags;
 		int nr_frags = pinfo->nr_frags + i;
 
-		if (nr_frags > MAX_SKB_FRAGS)
+		if (unlikely(nr_frags > MAX_SKB_FRAGS)) {
+			if (!sysctl_gro_frag_list_enable)
+				return -E2BIG;
 			goto merge;
-
+		}
 		offset -= headlen;
 		pinfo->nr_frags = nr_frags;
 		skbinfo->nr_frags = 0;
@@ -2977,9 +2986,11 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		unsigned int first_size = headlen - offset;
 		unsigned int first_offset;
 
-		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
+		if (unlikely(nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)) {
+			if (!sysctl_gro_frag_list_enable)
+				return -E2BIG;
 			goto merge;
-
+		}
 		first_offset = skb->data -
 			       (unsigned char *)page_address(page) +
 			       offset;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cca444190907..2d6aaf6d5838 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -24,6 +24,7 @@
 
 static int zero = 0;
 static int one = 1;
+static int two = 2;
 static int ushort_max = USHRT_MAX;
 
 #ifdef CONFIG_RPS
@@ -360,6 +361,15 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "gro_frag_list_enable",
+		.data		= &sysctl_gro_frag_list_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &two,
+	},
 	{ }
 };
 
