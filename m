From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to activate software
 MPLS GSO segmentation
Date: Tue, 3 Jun 2014 13:30:47 +0900
Message-ID: <20140603043047.GB22191@verge.net.au>
References: <1401684215-14713-1-git-send-email-horms@verge.net.au>
 <20140602162145.GA3836@casper.infradead.org>
 <20140603001640.GA31821@verge.net.au>
 <CAEP_g=8T6kzvQrxQ8f9B9QKiTJq0t3-Eu26c2hycfHTfZNyJbg@mail.gmail.com>
 <20140603023852.GA20728@verge.net.au>
 <1401766922.3645.195.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	YAMAMOTO Takashi <yamamoto@valinux.co.jp>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53242 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaFCEau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:30:50 -0400
Content-Disposition: inline
In-Reply-To: <1401766922.3645.195.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Jun 02, 2014 at 08:42:02PM -0700, Eric Dumazet wrote:
> Hi Simon
> 
> On Tue, 2014-06-03 at 11:38 +0900, Simon Horman wrote:
> > +/* If MPLS offload request, verify we are testing hardware MPLS features
> > + * instead of standard features for the netdev.
> > + */
> > +#ifdef CONFIG_NET_MPLS_GSO
> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +					   netdev_features_t features)
> > +{
> > +	int tmp;
> > +	__be16 type;
> > +
> > +	type = skb_network_protocol(skb, &tmp);
> > +	if (unlikely(type == cpu_to_be16(ETH_P_MPLS_UC) ||
> > +		     type == cpu_to_be16(ETH_P_MPLS_MC)))
> 
> I believe net/core/dev.c prefers to use htons(ETH_P_MPLS_UC)

Thanks, I will fix that.

> (check netif_skb_features())
> 
> > +		features &= skb->dev->mpls_features;
> > +
> > +	return features;
> > +}
> > +#else
> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +					   netdev_features_t features)
> > +{
> > +	return features;
> > +}
> > +#endif
> > +
> >  static netdev_features_t harmonize_features(struct sk_buff *skb,
> >  	netdev_features_t features)
> >  {
> >  	int tmp;
> 
> 	_be16 type;
> 
> 	type = skb_network_protocol(skb, &tmp);
> 
> >  
> > +	features = net_mpls_features(skb, features);
> 
> 	features = net_mpls_features(skb, features, type);
> 
> > +
> >  	if (skb->ip_summed != CHECKSUM_NONE &&
> >  	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
> 
> 	!can_checksum_protocol(features, type)) {
> 
> >  		features &= ~NETIF_F_ALL_CSUM;

Thanks, I'll switch things around as you suggest.

> I guess CONFIG_NET_MPLS_GSO will be set by all distros, right ?

That seems likely to me.


From: Simon Horman <horms@verge.net.au>

MPLS: Use mpls_features to activate software MPLS GSO segmentation

If an MPLS packet requires segmentation then use mpls_features
to determine if the software implementation should be used.

As no driver advertises MPLS GSO segmentation this will always be
the case.

I had not noticed that this was necessary before as software MPLS GSO
segmentation was already being used in my test environment. I believe that
the reason for that is the skbs in question always had fragments and the
driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
case for most drivers). Thus software segmentation was activated by
skb_gso_ok().

This introduces the overhead of an extra call to skb_network_protocol()
in the case where where CONFIG_NET_MPLS_GSO is set and
skb->ip_summed == CHECKSUM_NONE.

Thanks to Jesse Gross for prompting me to investigate this.

Signed-off-by: Simon Horman <horms@verge.net.au>

---
v4.2
* As suggested by Eric Dumazet
  - Use htons() instead of cpu_to_be16()
  - Refactor code to pass type to net_mpls_features.

v4.1
* Following fedback from Thomas Graff and Jesse Gross
  - Use ethertype of packet to detect MPLS rather than
    relying on mac_len indicating a gap between the end of L2
    and the beginning of L3. That assumption seems to
    be broken by the GRE GSO code.
  - Move mpls_features handling into harmonize_features()
    This allows an existing call in there to skb_network_protocol()
    to be leveraged.
  - Removed acks as the patch has now changed in a material way

v4
* As suggested by YAMAMOTO Takashi
  - Correct typos in comment
* Added Ack from YAMAMOTO Takashi
v3
* As requested by David Miller
  - Do not mark net_mpls_features as inline
  - Correct alignment of parameters

v2
* Added Ack from Jesse Gross
* Removed duplicate 'Thus' from changelog
---
 net/core/dev.c | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0355ca5..7c063ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2498,13 +2498,42 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 	return 0;
 }
 
+/* If MPLS offload request, verify we are testing hardware MPLS features
+ * instead of standard features for the netdev.
+ */
+#ifdef CONFIG_NET_MPLS_GSO
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   netdev_features_t features,
+					   __be16 type)
+{
+	int tmp;
+
+	if (unlikely(type == htons(ETH_P_MPLS_UC) ||
+		     type == htons(ETH_P_MPLS_MC)))
+		features &= skb->dev->mpls_features;
+
+	return features;
+}
+#else
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   netdev_features_t features,
+					   __be16 type)
+{
+	return features;
+}
+#endif
+
 static netdev_features_t harmonize_features(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	int tmp;
+	__be16 type;
+
+	type = skb_network_protocol(skb, &tmp);
+	features = net_mpls_features(skb, features, type);
 
 	if (skb->ip_summed != CHECKSUM_NONE &&
-	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
+	    !can_checksum_protocol(features, type)) {
 		features &= ~NETIF_F_ALL_CSUM;
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
-- 
2.0.0.rc2
