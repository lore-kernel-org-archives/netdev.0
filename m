From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to activate software
 MPLS GSO segmentation
Date: Tue, 3 Jun 2014 11:38:55 +0900
Message-ID: <20140603023852.GA20728@verge.net.au>
References: <1401684215-14713-1-git-send-email-horms@verge.net.au>
 <20140602162145.GA3836@casper.infradead.org>
 <20140603001640.GA31821@verge.net.au>
 <CAEP_g=8T6kzvQrxQ8f9B9QKiTJq0t3-Eu26c2hycfHTfZNyJbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	YAMAMOTO Takashi <yamamoto@valinux.co.jp>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39367 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaFCCi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 22:38:59 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8T6kzvQrxQ8f9B9QKiTJq0t3-Eu26c2hycfHTfZNyJbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2014 at 05:45:22PM -0700, Jesse Gross wrote:
> On Mon, Jun 2, 2014 at 5:16 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Mon, Jun 02, 2014 at 05:21:45PM +0100, Thomas Graf wrote:
> >> On 06/02/14 at 01:43pm, Simon Horman wrote:
> >> > +#ifdef CONFIG_NET_MPLS_GSO
> >> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> >> > +                                      struct net_device *dev,
> >> > +                                      netdev_features_t features)
> >> > +{
> >> > +   /* There is no support for MPLS LRO. So the only way that
> >> > +    * an MPLS skb could require GSO segmentation is if it
> >> > +    * was received as a non-MPLS skb and then became an MPLS skb.
> >> > +    * This may be effected by Open vSwitch in which case the
> >> > +    * mac_len will non-zero and not equal to skb_network_offset
> >> > +    * as the former indicates the end of L2 while the latter indicates
> >> > +    * the beginning of L3 and there is a gap between them occupied
> >> > +    * by the MPLS label stack.
> >> > +    *
> >> > +    * Thus it is possible to avoid traversing any VLAN tags that are
> >> > +    * present to determine if the ethtype is MPLS. Instead the
> >> > +    * inequality of mac_len and skb_network_offset are used to
> >> > +    * determine if a packet is MPLS for the purpose of determining
> >> > +    * offload features.
> >> > +    */
> >> > +   if (skb->mac_len && skb->mac_len != skb_network_offset(skb))
> >> > +           features &= dev->mpls_features;
> >> > +   return features;
> >> > +}
> >>
> >> Could you elaborate a bit on the safety of this? What about
> >> GRE GSO which sets mac_len to the inner network offset?
> >
> > Hi Thomas,
> >
> > thanks for pointing that out.
> >
> > It seems to me that I made an error in extending an assumption
> > that is true inside the (unmerged MPLS patch for) the Open vSwitch
> > datapath to code outside of the datapath. I had thought this
> > would be safe as the check should only trigger for packets
> > manipulated by the datapath.
> >
> > I now think that its possible that the GRE GSO code could kick in: if the
> > datapath outputs to GRE. And even if that is not the case it seems to me
> > that adding an assumption in code in net/core/dev.c to the way mac_len is
> > set which has not been universally adopted throughout net/ is asking for
> > trouble.
> >
> > My _untested_ alternate approach as illustrated below is to check the
> > ethernet type for MPLS, using skb_network_protocol to account for TEB and
> > VLANs.
> >
> > I am slightly concerned about the performance implications of this
> > approach.  I notice harmonize_features() already makes a call to
> > skb_network_protocol(). So if performance is a problem perhaps that call
> > could be leveraged somehow.
> 
> To be honest, I think this actually really belongs as part of
> netif_skb_features()/harmonize_features(). The point of those
> functions is to return the offloading features that are available for
> a given packet, so it's not clear why they wouldn't take MPLS into
> account. If we merged them then it would both be cleaner and should
> avoid any performance issues.

I think that the reason that I didn't do this initially
was that I wanted to handle mpls_features in a similar way
to that of hw_enc_features.

In light of the feedback from you and Thomas I do agree that
it seems to make sense to handle things in
netif_skb_features()/harmonize_features().

As per your suggestion I have tested the following
revised patch.

From: Simon Horman <horms@verge.net.au>

[PATCH v4.1] MPLS: Use mpls_features to activate software MPLS GSO segmentation

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
v4.1
* Use ethertype of packet to detect MPLS rather than
  relying on mac_len indicating a gap between the end of L2
  and the beginning of L3. That assumption seems to
  be broken by the GRE GSO code.
* Move mpls_features handling into harmonize_features()
  This allows an existing call in there to skb_network_protocol()
  to be leveraged.
* Removed acks as the patch has now changed in a material way

v4
* Correct typos in comment
* Added Ack from YAMAMOTO Takashi
v3
* As requested by David Miller
  - Do not mark net_mpls_features as inline
  - Correct alignment of parameters

v2
* Added Ack from Jesse Gross
* Removed duplicate 'Thus' from changelog
---
 net/core/dev.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0355ca5..0fc92ee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2498,11 +2498,38 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 	return 0;
 }
 
+/* If MPLS offload request, verify we are testing hardware MPLS features
+ * instead of standard features for the netdev.
+ */
+#ifdef CONFIG_NET_MPLS_GSO
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   netdev_features_t features)
+{
+	int tmp;
+	__be16 type;
+
+	type = skb_network_protocol(skb, &tmp);
+	if (unlikely(type == cpu_to_be16(ETH_P_MPLS_UC) ||
+		     type == cpu_to_be16(ETH_P_MPLS_MC)))
+		features &= skb->dev->mpls_features;
+
+	return features;
+}
+#else
+static netdev_features_t net_mpls_features(struct sk_buff *skb,
+					   netdev_features_t features)
+{
+	return features;
+}
+#endif
+
 static netdev_features_t harmonize_features(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	int tmp;
 
+	features = net_mpls_features(skb, features);
+
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
 		features &= ~NETIF_F_ALL_CSUM;
-- 
2.0.0.rc2
