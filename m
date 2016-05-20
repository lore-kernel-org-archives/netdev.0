From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 20 May 2016 14:29:01 +0900
Message-ID: <20160520052858.GA15505@vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <20160517163250.7ead555e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36044 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbcETF3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 01:29:12 -0400
Received: by mail-pa0-f47.google.com with SMTP id bt5so35977840pac.3
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 22:29:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160517163250.7ead555e@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Tue, May 17, 2016 at 04:32:50PM +0200, Jiri Benc wrote:
> Looking through the patchset again, this time more deeply. Sorry for
> the delay.

No need to be sorry, good things take time.

> On Wed,  4 May 2016 16:36:30 +0900, Simon Horman wrote:
> > +struct ovs_action_push_eth {
> > +	struct ovs_key_ethernet addresses;
> > +	__be16   eth_type;
> 
> Extra spaces.

Sorry about that.

As per some earlier discussion I plan to remove the eth_type field entirely.

> 
> > +static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
> > +{
> > +	skb_pull_rcsum(skb, ETH_HLEN);
> > +	skb_reset_mac_header(skb);
> > +	skb->mac_len -= ETH_HLEN;
> > +
> > +	invalidate_flow_key(key);
> > +	return 0;
> > +}
> 
> There's a fundamental question here: how should pop_eth behave when
> vlan tag is present?
> 
> There are two options: either vlan is considered part of the Ethernet
> header and pop_eth means implicitly resetting vlan tag, or packet can
> have vlan tag even if it's not Ethernet.
> 
> This patch seems to implement the first option; however, skb->vlan_tci
> should be reset and pop_eth should check whether the vlan tag is
> present in the frame (deaccelerated) and remove it if it is. Otherwise,
> the behavior of pop_eth would be inconsistent.
> 
> However, I'm not sure whether the second option does not make more
> sense. It may, in fact, be needed - ARPHRD_NONE tunnel port could not
> be set as an access port otherwise (unless I'm missing something).
> 
> In that case, pop_eth will need to put the vlan tag to skb->vlan_tci if
> it's in the frame itself. Also, push_vlan and pop_vlan would need to be
> modified to work with is_layer3 packets.

Good point.

The second option does seem rather tempting although I'm not sure
that it actually plays out in the access-port scenario at this time.

> > +static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
> > +		    const struct ovs_action_push_eth *ethh)
> > +{
> > +	int err;
> > +
> > +	/* De-accelerate any hardware accelerated VLAN tag added to a previous
> > +	 * Ethernet header */
> > +	err = skb_vlan_deaccel(skb);
> 
> Why? Just keep it in skb->vlan_tci.

Agreed, this seems unnecessary.

> > --- a/net/openvswitch/flow.c
> > +++ b/net/openvswitch/flow.c
> > @@ -468,28 +468,31 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
> >  
> >  	skb_reset_mac_header(skb);
> >  
> > -	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
> > -	 * header in the linear data area.
> > -	 */
> > -	eth = eth_hdr(skb);
> > -	ether_addr_copy(key->eth.src, eth->h_source);
> > -	ether_addr_copy(key->eth.dst, eth->h_dest);
> > +	/* Link layer. */
> > +	if (key->phy.is_layer3) {
> > +		key->eth.tci = 0;
> 
> Could make sense to use skb->vlan_tci, see above.

The incremental patch below is what I have so far.
The patch to add skb_vlan_deaccel() should also be dropped.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c413c588a24f..6853ab008861 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2994,6 +2994,7 @@ int skb_vlan_pop(struct sk_buff *skb);
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
 			     gfp_t gfp);
+int skb_vlan_accel(struct sk_buff *skb);
 
 static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7a1d48983f81..a36c7491f714 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4482,12 +4482,28 @@ pull:
 	return err;
 }
 
-int skb_vlan_pop(struct sk_buff *skb)
+/* If a vlan tag is present move it to hw accel tag */
+int skb_vlan_accel(struct sk_buff *skb)
 {
 	u16 vlan_tci;
 	__be16 vlan_proto;
 	int err;
 
+	vlan_proto = skb->protocol;
+	err = __skb_vlan_pop(skb, &vlan_tci);
+	if (unlikely(err))
+		return err;
+
+	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
+	return 0;
+}
+EXPORT_SYMBOL(skb_vlan_accel);
+
+int skb_vlan_pop(struct sk_buff *skb)
+{
+	u16 vlan_tci;
+	int err;
+
 	if (likely(skb_vlan_tag_present(skb))) {
 		skb->vlan_tci = 0;
 	} else {
@@ -4500,19 +4516,13 @@ int skb_vlan_pop(struct sk_buff *skb)
 		if (err)
 			return err;
 	}
-	/* move next vlan tag to hw accel tag */
+
 	if (likely((skb->protocol != htons(ETH_P_8021Q) &&
 		    skb->protocol != htons(ETH_P_8021AD)) ||
 		   skb->len < VLAN_ETH_HLEN))
 		return 0;
 
-	vlan_proto = skb->protocol;
-	err = __skb_vlan_pop(skb, &vlan_tci);
-	if (unlikely(err))
-		return err;
-
-	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
-	return 0;
+	return skb_vlan_accel(skb);
 }
 EXPORT_SYMBOL(skb_vlan_pop);
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 7d9b2307d6eb..ad2331cde732 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -302,6 +302,17 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
 
 static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
 {
+	/* Push outermost VLAN tag to skb metadata unless a VLAN tag
+	 * is already present there.
+	 */
+	if ((skb->protocol == htons(ETH_P_8021Q) ||
+	     skb->protocol == htons(ETH_P_8021AD)) &&
+	    !skb_vlan_tag_present(skb)) {
+		int err = skb_vlan_accel(skb);
+		if (unlikely(err))
+			return err;
+	}
+
 	skb_pull_rcsum(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
 	skb->mac_len -= ETH_HLEN;
@@ -314,13 +325,6 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
 		    const struct ovs_action_push_eth *ethh)
 {
 	struct ethhdr *hdr;
-	int err;
-
-	/* De-accelerate any hardware accelerated VLAN tag added to a previous
-	 * Ethernet header */
-	err = skb_vlan_deaccel(skb);
-	if (unlikely(err))
-		return err;
 
 	/* Add the new Ethernet header */
 	if (skb_cow_head(skb, ETH_HLEN) < 0)
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 4d2698596033..fdefee776d4f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -469,8 +469,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	skb_reset_mac_header(skb);
 
 	/* Link layer. */
+	key->eth.tci = 0;
 	if (key->phy.is_layer3) {
-		key->eth.tci = 0;
+		if (skb_vlan_tag_present(skb))
+			key->eth.tci = htons(skb->vlan_tci);
 	} else {
 		eth = eth_hdr(skb);
 		ether_addr_copy(key->eth.src, eth->h_source);
@@ -481,7 +483,6 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 		 * update skb->csum here.
 		 */
 
-		key->eth.tci = 0;
 		if (skb_vlan_tag_present(skb))
 			key->eth.tci = htons(skb->vlan_tci);
 		else if (eth->h_proto == htons(ETH_P_8021Q))
