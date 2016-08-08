From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Mon, 8 Aug 2016 17:17:17 +0200
Message-ID: <20160808151716.GA8477@penelope.isobedori.kobe.vergenet.net>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
 <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
 <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
 <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_C3Hq-V4uPWLELSc2VMywjYSnKiFJ4VJQDnPpCu7s1Xkw@mail.gmail.com>
 <20160720000243.GA4688@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_CUPCfAPKfoco9GghiAZ=QyEqxpd90uo3NvEtG9STXMVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36752 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbcHHPRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 11:17:21 -0400
Received: by mail-wm0-f41.google.com with SMTP id q128so125549351wma.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 08:17:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_CUPCfAPKfoco9GghiAZ=QyEqxpd90uo3NvEtG9STXMVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 11:06:37AM -0700, pravin shelar wrote:
> On Tue, Jul 19, 2016 at 5:02 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > On Mon, Jul 18, 2016 at 03:34:52PM -0700, pravin shelar wrote:
> >> On Sun, Jul 17, 2016 at 9:50 PM, Simon Horman
> >> <simon.horman@netronome.com> wrote:
> >> > [CC Jiri Benc for portion regarding GRE]
> >> >
> >> > Hi Pravin,
> >> >
> >> > On Fri, Jul 15, 2016 at 02:07:37PM -0700, pravin shelar wrote:
> >> >> On Wed, Jul 13, 2016 at 12:31 AM, Simon Horman
> >> >> <simon.horman@netronome.com> wrote:
> >> >> > Hi Pravin,
> >> >> >
> >> >> > On Thu, Jul 07, 2016 at 01:54:15PM -0700, pravin shelar wrote:
> >> >> >> On Wed, Jul 6, 2016 at 10:59 AM, Simon Horman
> >> >> >> <simon.horman@netronome.com> wrote:
> >> >> >
> >> >> > ...
> >> >>
> >> >> >
> >> >> >> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> >> >> >> > index 0ea128eeeab2..86f2cfb19de3 100644
> >> >> >> > --- a/net/openvswitch/flow.c
> >> >> >> > +++ b/net/openvswitch/flow.c
> >> >> >> ...
> >> >> >>
> >> >> >> > @@ -723,9 +729,17 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
> >> >> >> >         key->phy.skb_mark = skb->mark;
> >> >> >> >         ovs_ct_fill_key(skb, key);
> >> >> >> >         key->ovs_flow_hash = 0;
> >> >> >> > +       key->phy.is_layer3 = skb->mac_len == 0;
> >> >> >>
> >> >> >> I do not think mac_len can be used. mac_header needs to be checked.
> >> >> >> ...
> >> >> >
> >> >> > Yes, indeed. The update to use skb_mac_header_was_set() here accidently
> >> >> > slipped into the following patch, sorry about that.
> >> >> >
> >> >> > With that change in place I believe that this patch is internally
> >> >> > consistent because mac_header and mac_len are set correctly by the
> >> >> > call to key_extract() which is called by ovs_flow_key_extract() just
> >> >> > after where the excerpt above ends.
> >> >> >
> >> >> > That said, I do think that it is possible to rely on skb_mac_header_was_set
> >> >> > throughout the datapath, including action processing etc... I have provided
> >> >> > an incremental patch - which I created on top of this entire series - at
> >> >> > the end of this email. If you prefer that approach I am happy to take it,
> >> >> > though I do feel that using mac_len leads to slightly cleaner code. Let me
> >> >> > know what you think.
> >> >> >
> >> >>
> >> >>
> >> >> I am not sure if you can use only mac_len to detect L3 packet. This
> >> >> does not work with MPLS packets, mac_len is used to account MPLS
> >> >> headers pushed on skb. Therefore in case of a MPLS header on L3
> >> >> packet, mac_len would be non zero and we have to look at either
> >> >> mac_header or some other metadata like is_layer3 flag from key to
> >> >> check for L3 packet.
> >> >
> >> > At least within OvS mac_len does not include the length of the MPLS label
> >> > stack. Rather, the MPLS label stack length is the difference between the
> >> > end of (mac_header + mac_len) and network_header.
> >> >
> >> > So I think that the scheme does work as mac_len is 0 if there is no L2
> >> > header regardless of if an MPLS label stack is present or not.
> >> >
> >>
> >> I was thinking in overall networking stack rather than just ovs
> >> datapath. I think we should have consistent method of detecting L3
> >> packet. As commented in previous mail it could be achieved using
> >> skb-protocol and device type.
> >
> > This is somewhat of a surprise to me. As far as I recall when MPLS support
> > was added to OvS it and the accompanying support for MPLS GSO was the only
> > MPLS support present in the kernel. And at the time the scheme developed by
> > Jesse Gross, myself and others was as I describe above.
> >
> > Internally OvS relies on this scheme and in particular it is used
> > by skb_mpls_header() to calculate the beginning of the MPLS label stack
> > accurately in the presence of VLAN tags.
> >
> > Is it mpls_gso_segment() that you are concerned about?
> > If so, perhaps the problem could be addressed there.
> 
> Yes.
> Can you read the comment I made in previous main in context of
> function skb_mpls_header(). I have given rational for requested
> change.

Hi Pravin,

I have made an attempt to implement your suggestion to the extent that
I understand it. The following is an incremental change on top
of this patch-set. Does it move things closer to what you have in mind?

Light testing seems to indicate that it works for GSO skbs
received over both L3 and L2 GRE tunnels by OvS with both
IP-in-MPLS and IP (without MPLS) payloads.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72ece516535d..42033537eb4d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2171,17 +2171,14 @@ static inline void skb_reset_mac_header(struct sk_buff *skb)
 	skb->mac_header = skb->data - skb->head;
 }
 
-static inline void skb_unset_mac_header(struct sk_buff *skb)
-{
-	skb->mac_header = (typeof(skb->mac_header))~0U;
-}
-
 static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
 {
 	skb_reset_mac_header(skb);
 	skb->mac_header += offset;
 }
 
+bool skb_mac_header_present(struct sk_buff *skb);
+
 static inline void skb_pop_mac_header(struct sk_buff *skb)
 {
 	skb->mac_header = skb->network_header;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3864b4b68fa1..8e55e9503c9d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4883,3 +4883,11 @@ struct sk_buff *pskb_extract(struct sk_buff *skb, int off,
 	return clone;
 }
 EXPORT_SYMBOL(pskb_extract);
+
+bool skb_mac_header_present(struct sk_buff *skb)
+{
+	return skb->dev->type == ARPHRD_ETHER ||
+		(skb->dev->type == ARPHRD_NONE &&
+		 skb->protocol == htons(ETH_P_TEB));
+}
+EXPORT_SYMBOL(skb_mac_header_present);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a20248355da0..3f730ad4a874 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -283,8 +283,6 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 
 		if (tunnel->dev->type != ARPHRD_NONE)
 			skb_pop_mac_header(skb);
-		else if (tpi->proto != htons(ETH_P_TEB))
-			skb_unset_mac_header(skb);
 		else
 			skb_reset_mac_header(skb);
 		if (tunnel->collect_md) {
@@ -453,6 +451,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
 
+	skb_set_inner_protocol(skb, proto);
 	iptunnel_xmit(skb->sk, rt, skb, fl.saddr, key->u.ipv4.dst, IPPROTO_GRE,
 		      key->tos, key->ttl, df, false);
 	return;
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 2055e57ed1c3..113cba89653d 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -39,16 +39,18 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 	mpls_features = skb->dev->mpls_features & features;
 	segs = skb_mac_gso_segment(skb, mpls_features);
 
-
-	/* Restore outer protocol. */
-	skb->protocol = mpls_protocol;
-
 	/* Re-pull the mac header that the call to skb_mac_gso_segment()
 	 * above pulled.  It will be re-pushed after returning
 	 * skb_mac_gso_segment(), an indirect caller of this function.
 	 */
 	__skb_pull(skb, skb->data - skb_mac_header(skb));
 
+	/* Restore outer protocol. */
+	skb->protocol = mpls_protocol;
+	if (!IS_ERR(segs))
+		for (skb = segs; skb; skb = skb->next)
+			skb->protocol = mpls_protocol;
+
 	return segs;
 }
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 0001f651c934..424164222f1e 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -163,18 +163,20 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		return -ENOMEM;
 
 	skb_push(skb, MPLS_HLEN);
-	skb_reset_mac_header(skb);
-
-	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
-	*new_mpls_lse = mpls->mpls_lse;
-
-	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
-	if (skb->mac_len) {
+	if (key->phy.is_layer3) {
+		new_mpls_lse = (__be32 *)skb->data;
+	} else {
 		update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
 		memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
 			skb->mac_len);
+		skb_reset_mac_header(skb);
+		new_mpls_lse = (__be32 *)skb_mpls_header(skb);
 	}
+	*new_mpls_lse = mpls->mpls_lse;
+
+	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
+
 	if (!skb->inner_protocol)
 		skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
@@ -186,30 +188,31 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		    const __be16 ethertype)
 {
-	int err;
-
-	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
-	if (unlikely(err))
-		return err;
-
-	skb_postpull_rcsum(skb, skb_mpls_header(skb), MPLS_HLEN);
-
-	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
-		skb->mac_len);
+	if (!key->phy.is_layer3) {
+		struct ethhdr *hdr;
+		int err;
 
-	__skb_pull(skb, MPLS_HLEN);
-	skb_reset_mac_header(skb);
+		skb_postpull_rcsum(skb, skb_mpls_header(skb), MPLS_HLEN);
 
-	if (skb->mac_len) {
-		struct ethhdr *hdr;
+		err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
+		if (unlikely(err))
+			return err;
 
 		/* skb_mpls_header() is used to locate the ethertype
 		 * field correctly in the presence of VLAN tags.
 		 */
 		hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
 		update_ethertype(skb, hdr, ethertype);
+
+		memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
+			skb->mac_len);
 	}
 
+	__skb_pull(skb, MPLS_HLEN);
+
+	if (!key->phy.is_layer3)
+		skb_reset_mac_header(skb);
+
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
 
@@ -220,15 +223,23 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		    const __be32 *mpls_lse, const __be32 *mask)
 {
+	__be16 mac_len;
 	__be32 *stack;
 	__be32 lse;
 	int err;
 
+	if (flow_key->phy.is_layer3) {
+		mac_len = 0;
+		stack = (__be32 *)skb->data;
+	} else {
+		mac_len = skb->mac_len;
+	}
+
 	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
 	if (unlikely(err))
 		return err;
-
 	stack = (__be32 *)skb_mpls_header(skb);
+
 	lse = OVS_MASKED(*stack, *mpls_lse, *mask);
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		__be32 diff[] = { ~(*stack), lse };
@@ -308,8 +319,8 @@ static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	skb_pull_rcsum(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
-	skb->mac_len -= ETH_HLEN;
 
+	key->phy.is_layer3 = true;
 	invalidate_flow_key(key);
 	return 0;
 }
@@ -325,7 +336,7 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
 
 	skb_push(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
-	skb->mac_len += ETH_HLEN;
+	skb->mac_len = ETH_HLEN;
 
 	hdr = eth_hdr(skb);
 	ether_addr_copy(hdr->h_source, ethh->addresses.eth_src);
@@ -334,6 +345,7 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
 
 	skb_postpush_rcsum(skb, hdr, ETH_HLEN);
 
+	key->phy.is_layer3 = false;
 	invalidate_flow_key(key);
 	return 0;
 }
@@ -795,6 +807,9 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 		u16 mru = OVS_CB(skb)->mru;
 		u32 cutlen = OVS_CB(skb)->cutlen;
 
+		if (vport->dev->type == ARPHRD_NONE && !key->phy.is_layer3)
+			skb->protocol = htons(ETH_P_TEB);
+
 		if (unlikely(cutlen > 0)) {
 			if (skb->len - cutlen > ETH_HLEN)
 				pskb_trim(skb, skb->len - cutlen);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 42587d5bf894..812f8e10d9d4 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -448,7 +448,7 @@ invalid:
  *
  * Initializes @skb header pointers as follows:
  *
- *    - skb->mac_header: the Ethernet header.
+ *    - skb->mac_header: the Ethernet header if flow is L2, unset otherwise
  *
  *    - skb->network_header: just past the Ethernet header, or just past the
  *      VLAN header, to the first byte of the Ethernet payload.
@@ -465,17 +465,19 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	/* Flags are always used as part of stats */
 	key->tp.flags = 0;
 
-	skb_reset_mac_header(skb);
-
 	/* Link layer. */
 	key->eth.tci = 0;
 	if (key->phy.is_layer3) {
 		if (skb_vlan_tag_present(skb))
 			key->eth.tci = htons(skb->vlan_tci);
 		key->eth.type = skb->protocol;
+		skb_reset_network_header(skb);
 	} else {
-		struct ethhdr *eth = eth_hdr(skb);
+		struct ethhdr *eth;
+
+		skb_reset_mac_header(skb);
 
+		eth = eth_hdr(skb);
 		ether_addr_copy(key->eth.src, eth->h_source);
 		ether_addr_copy(key->eth.dst, eth->h_dest);
 
@@ -493,11 +495,11 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 		key->eth.type = parse_ethertype(skb);
 		if (unlikely(key->eth.type == htons(0)))
 			return -ENOMEM;
-	}
 
-	skb_reset_network_header(skb);
-	skb_reset_mac_len(skb);
-	__skb_push(skb, skb->data - skb_mac_header(skb));
+		skb_reset_network_header(skb);
+		skb_reset_mac_len(skb);
+		__skb_push(skb, skb->data - skb_mac_header(skb));
+	}
 
 	/* Network layer. */
 	if (key->eth.type == htons(ETH_P_IP)) {
@@ -608,12 +610,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 		 * header and the beginning of the L3 header differ.
 		 *
 		 * Advance network_header to the beginning of the L3
-		 * header. mac_len corresponds to the end of the L2 header.
+		 * header. For packets with an L2 header mac_len corresponds
+		 * to the end of the L2 header.
 		 */
 		while (1) {
+			__u16 mac_len;
 			__be32 lse;
 
-			error = check_header(skb, skb->mac_len + stack_len);
+			mac_len = key->phy.is_layer3 ? 0 : skb->mac_len;
+
+			error = check_header(skb, mac_len + stack_len);
 			if (unlikely(error))
 				return 0;
 
@@ -622,7 +628,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 			if (stack_len == MPLS_HLEN)
 				memcpy(&key->mpls.top_lse, &lse, MPLS_HLEN);
 
-			skb_set_network_header(skb, skb->mac_len + stack_len);
+			skb_set_network_header(skb, mac_len + stack_len);
 			if (lse & htonl(MPLS_LS_S_MASK))
 				break;
 
@@ -729,7 +735,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	ovs_ct_fill_key(skb, key);
 	key->ovs_flow_hash = 0;
-	key->phy.is_layer3 = skb_mac_header_was_set(skb) == 0;
+	key->phy.is_layer3 = !skb_mac_header_present(skb);
 	key->recirc_id = 0;
 
 	err = key_extract(skb, key);
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 7a06e19f5279..1a1fcec88695 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -116,7 +116,7 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.create		= geneve_create,
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.get_options	= geneve_get_options,
-	.send		= ovs_netdev_send,
+	.send		= dev_queue_xmit,
 };
 
 static int __init ovs_geneve_tnl_init(void)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index c1cab9dd392f..cbfb0afe041d 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -87,7 +87,7 @@ static struct vport *gre_create(const struct vport_parms *parms)
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.send		= ovs_netdev_send,
+	.send		= dev_queue_xmit,
 	.destroy	= ovs_netdev_tunnel_destroy,
 };
 
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 5ad184bd5802..3d392e84e7a7 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -255,7 +255,7 @@ static netdev_tx_t internal_dev_recv(struct sk_buff *skb)
 	struct pcpu_sw_netstats *stats;
 
 	/* Only send/receive L2 packets */
-	if (!skb->mac_len) {
+	if (!skb_mac_header_present(skb)) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 7d54414b35eb..b6b45cf90816 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -197,21 +197,6 @@ void ovs_netdev_tunnel_destroy(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
 
-int ovs_netdev_send(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-
-	if (dev->type != ARPHRD_ETHER && skb->mac_len) {
-		skb->protocol = htons(ETH_P_TEB);
-	} else if (dev->type == ARPHRD_ETHER && !skb->mac_len) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
-
-	return dev_queue_xmit(skb);
-}
-EXPORT_SYMBOL_GPL(ovs_netdev_send);
-
 /* Returns null if this device is not attached to a datapath. */
 struct vport *ovs_netdev_get_vport(struct net_device *dev)
 {
@@ -226,7 +211,7 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
-	.send		= ovs_netdev_send,
+	.send		= dev_queue_xmit,
 };
 
 int __init ovs_netdev_init(void)
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 13f11ad7e35a..5eb7694348b5 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -153,7 +153,7 @@ static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.create			= vxlan_create,
 	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
-	.send			= ovs_netdev_send,
+	.send			= dev_queue_xmit,
 };
 
 static int __init ovs_vxlan_tnl_init(void)
