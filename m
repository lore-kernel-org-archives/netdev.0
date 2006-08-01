From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 01 Aug 2006 09:19:34 +0200
Message-ID: <44CF0086.1030404@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090904060001000400080804"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24809 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932564AbWHAHTl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:19:41 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <44CE4DCA.8000609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090904060001000400080804
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:---------------
> [NETFILTER]: nf_queue: handle GSO packets
> 
> Handle GSO packets in nf_queue by segmenting them before queueing to
> avoid breaking GSO in case they get mangled.

While testing this patch I noticed that some meta-data is lost when
segmenting packets. With the attached patch it works fine. Some of
the fields may not appear necessary, so here's my reasoning:

- nfct/nfctinfo/nfct_reasm: the xfrm output path does an immediate
  nf_reset, so they were not necessary until now. Queueing can happen
  on any hook, so we need to preserve them.

- nf_bridge: needed for GSO on a bridge device until the deferred
  hooks are removed

- tc_verd/tc_index/input_dev: when directing a packet from a device
  supporting GSO to a device not supporting GSO using tc actions,
  these fields may be set.

Herbert, does this look sane to you?


Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------090904060001000400080804
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3a12ff1..9c6ef32 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1948,6 +1948,31 @@ struct sk_buff *skb_segment(struct sk_bu
 
 		nskb->dev = skb->dev;
 		nskb->priority = skb->priority;
+#ifdef CONFIG_NETFILTER
+		nskb->nfmark = skb->nfmark;
+		nskb->nfct = skb->nfct;
+		nf_conntrack_get(skb->nfct);
+		nskb->nfctinfo = skb->nfctinfo;
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+		nskb->nfct_reasm = skb->nfct_reasm;
+		nf_conntrack_get_reasm(skb->nfct_reasm);
+#endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+		nskb->nf_bridge = skb->nf_bridge;
+		nf_bridge_get(skb->nf_bridge);
+#endif
+#endif
+#ifdef CONFIG_NET_SCHED
+#ifdef CONFIG_NET_CLS_ACT
+		nskb->input_dev = skb->input_dev;
+		nskb->tc_verd = skb->tc_verd;
+#endif
+		nskb->tc_index = skb->tc_index;
+#endif
+		skb_copy_secmark(nskb, skb);
 		nskb->protocol = skb->protocol;
 		nskb->dst = dst_clone(skb->dst);
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));

--------------090904060001000400080804--
