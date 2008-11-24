From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Fix update_pmtu crash with GRE
Date: Mon, 24 Nov 2008 14:49:57 +0800
Message-ID: <20081124064957.GA15999@gondor.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au> <E1KnpaS-0004Pe-Qt@gondolin.me.apana.org.au> <48EDC429.5090502@snapgear.com> <20081009103956.GA18751@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57168 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751410AbYKXGuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 01:50:07 -0500
Content-Disposition: inline
In-Reply-To: <20081009103956.GA18751@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 06:39:56PM +0800, Herbert Xu wrote:
>
> > +/*
> > + * We've finished passing through netfilter, so we can remove the fake dst.
> > + * This is required by some lower layers, eg ip_gre
> > + */
> > +static int br_nf_dev_queue_xmit_finish(struct sk_buff *skb)
> > +{
> > +	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
> > +		dst_release(skb->dst);
> > +		skb->dst = NULL;
> > +	}
> > +
> > +	return br_dev_queue_push_xmit(skb);
> > +}
> 
> Alternatively we could give fake_rtable an ops structure.

Looks like this fell through the cracks:

bridge: Fix update_pmtu crash with GRE

As GRE tries to call the update_pmtu function on skb->dst and
bridge supplies an skb->dst that has a NULL ops field, all is
not well.

This patch fixes this by giving the bridge device an ops field
with an update_pmtu function.  For the moment I've left all
other fields blank but we can fill them in later should the
need arise.

Based on report and patch by Philip Craig.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index fa5cda4..45f61c3 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -101,6 +101,18 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
+static void fake_update_pmtu(struct dst_entry *dst, u32 mtu)
+{
+}
+
+static struct dst_ops fake_dst_ops = {
+	.family =		AF_INET,
+	.protocol =		__constant_htons(ETH_P_IP),
+	.update_pmtu =		fake_update_pmtu,
+	.entry_size =		sizeof(struct rtable),
+	.entries =		ATOMIC_INIT(0),
+};
+
 /*
  * Initialize bogus route table used to keep netfilter happy.
  * Currently, we fill in the PMTU entry because netfilter
@@ -117,6 +129,7 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 	rt->u.dst.path = &rt->u.dst;
 	rt->u.dst.metrics[RTAX_MTU - 1] = 1500;
 	rt->u.dst.flags	= DST_NOXFRM;
+	rt->u.dst.ops = &fake_dst_ops;
 }
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
