From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to activate software
 MPLS GSO segmentation
Date: Tue, 3 Jun 2014 09:16:40 +0900
Message-ID: <20140603001640.GA31821@verge.net.au>
References: <1401684215-14713-1-git-send-email-horms@verge.net.au>
 <20140602162145.GA3836@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	YAMAMOTO Takashi <yamamoto@valinux.co.jp>, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44600 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbaFCAQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:16:44 -0400
Content-Disposition: inline
In-Reply-To: <20140602162145.GA3836@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2014 at 05:21:45PM +0100, Thomas Graf wrote:
> On 06/02/14 at 01:43pm, Simon Horman wrote:
> > +#ifdef CONFIG_NET_MPLS_GSO
> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +					   struct net_device *dev,
> > +					   netdev_features_t features)
> > +{
> > +	/* There is no support for MPLS LRO. So the only way that
> > +	 * an MPLS skb could require GSO segmentation is if it
> > +	 * was received as a non-MPLS skb and then became an MPLS skb.
> > +	 * This may be effected by Open vSwitch in which case the
> > +	 * mac_len will non-zero and not equal to skb_network_offset
> > +	 * as the former indicates the end of L2 while the latter indicates
> > +	 * the beginning of L3 and there is a gap between them occupied
> > +	 * by the MPLS label stack.
> > +	 *
> > +	 * Thus it is possible to avoid traversing any VLAN tags that are
> > +	 * present to determine if the ethtype is MPLS. Instead the
> > +	 * inequality of mac_len and skb_network_offset are used to
> > +	 * determine if a packet is MPLS for the purpose of determining
> > +	 * offload features.
> > +	 */
> > +	if (skb->mac_len && skb->mac_len != skb_network_offset(skb))
> > +		features &= dev->mpls_features;
> > +	return features;
> > +}
> 
> Could you elaborate a bit on the safety of this? What about
> GRE GSO which sets mac_len to the inner network offset?

Hi Thomas,

thanks for pointing that out.

It seems to me that I made an error in extending an assumption
that is true inside the (unmerged MPLS patch for) the Open vSwitch
datapath to code outside of the datapath. I had thought this
would be safe as the check should only trigger for packets
manipulated by the datapath.

I now think that its possible that the GRE GSO code could kick in: if the
datapath outputs to GRE. And even if that is not the case it seems to me
that adding an assumption in code in net/core/dev.c to the way mac_len is
set which has not been universally adopted throughout net/ is asking for
trouble.

My _untested_ alternate approach as illustrated below is to check the
ethernet type for MPLS, using skb_network_protocol to account for TEB and
VLANs.

I am slightly concerned about the performance implications of this
approach.  I notice harmonize_features() already makes a call to
skb_network_protocol(). So if performance is a problem perhaps that call
could be leveraged somehow.


diff --git a/net/core/dev.c b/net/core/dev.c
index 0355ca5..736c48c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2540,6 +2540,33 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_skb_features);
 
+/* If MPLS offload request, verify we are testing hardware MPLS features
+ * instead of standard features for the netdev.
+ */
+#ifdef CONFIG_NET_MPLS_GSO
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   struct net_device *dev,
+					   netdev_features_t features)
+{
+	__be16 type;
+	int depth;
+
+	type = skb_network_protocol(skb, &depth);
+	if (type == cpu_to_be16(ETH_P_MPLS_UC) ||
+	    type == cpu_to_be16(ETH_P_MPLS_MC))
+		features &= dev->mpls_features;
+
+	return features;
+}
+#else
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   struct net_device *dev,
+					   netdev_features_t features)
+{
+	return features;
+}
+#endif
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -2576,6 +2603,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (skb->encapsulation)
 			features &= dev->hw_enc_features;
 
+		features = net_mpls_features(skb, dev, features);
+
 		if (netif_needs_gso(skb, features)) {
 			if (unlikely(dev_gso_segment(skb, features)))
 				goto out_kfree_skb;
