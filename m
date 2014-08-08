From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: Always untag vlan-tagged traffic on input.
Date: Fri, 8 Aug 2014 17:26:18 +0200
Message-ID: <20140808152618.GC1878@nanopsycho.orion>
References: <1407423334-3422-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Vladislav Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:48620 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008AbaHHP0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 11:26:21 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so5832220wgg.24
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 08:26:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1407423334-3422-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 07, 2014 at 04:55:34PM CEST, vyasevic@redhat.com wrote:
>Currently the functionality to untag traffic on input resides
>as part of the vlan module and is build only when VLAN support
>is enabled in the kernel.  When VLAN is disabled, the function
>vlan_untag() turns into a stub and doesn't really untag the
>packets.  This seems to create an interesting interaction
>between VMs supporting checksum offloading and some network drivers.
>
>There are some drivers that do not allow the user to change
>tx-vlan-offload feature of the driver.  These drivers also seem
>to assume that any VLAN-tagged traffic they transmit will
>have the vlan information in the vlan_tci and not in the vlan
>header already in the skb.  When transmitting skbs that already
>have tagged data with partial checksum set, the checksum doesn't
>appear to be updated correctly by the card thus resulting in a
>failure to establish TCP connections.
>
>The following is a packet trace taken on the receiver where a
>sender is a VM with a VLAN configued.  The host VM is running on
>doest not have VLAN support and the outging interface on the
>host is tg3:
>10:12:43.503055 52:54:00:ae:42:3f > 28:d2:44:7d:c2:de, ethertype 802.1Q
>(0x8100), length 78: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 27243,
>offset 0, flags [DF], proto TCP (6), length 60)
>    10.0.100.1.58545 > 10.0.100.10.ircu-2: Flags [S], cksum 0xdc39 (incorrect
>-> 0x48d9), seq 1069378582, win 29200, options [mss 1460,sackOK,TS val
>4294837885 ecr 0,nop,wscale 7], length 0
>10:12:44.505556 52:54:00:ae:42:3f > 28:d2:44:7d:c2:de, ethertype 802.1Q
>(0x8100), length 78: vlan 100, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 27244,
>offset 0, flags [DF], proto TCP (6), length 60)
>    10.0.100.1.58545 > 10.0.100.10.ircu-2: Flags [S], cksum 0xdc39 (incorrect
>-> 0x44ee), seq 1069378582, win 29200, options [mss 1460,sackOK,TS val
>4294838888 ecr 0,nop,wscale 7], length 0
>
>This connection finally times out.
>
>I've only access to the TG3 hardware in this configuration thus have
>only tested this with TG3 driver.  There are a lot of other drivers
>that do not permit user changes to vlan acceleration features, and
>I don't know if they all suffere from a similar issue.
>
>The patch attempt to fix this another way.  It moves the vlan header
>stipping code out of the vlan module and always builds it into the
>kernel network core.  This way, even if vlan is not supported on
>a virtualizatoin host, the virtual machines running on top of such
>host will still work with VLANs enabled.
>
>CC: Patrick McHardy <kaber@trash.net>
>CC: Nithin Nayak Sujir <nsujir@broadcom.com>
>CC: Michael Chan <mchan@broadcom.com>
>Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>---
>
>If this is accepted, please consider for stable as well.
>
> include/linux/if_vlan.h |  6 ------
> include/linux/skbuff.h  |  1 +
> net/8021q/vlan_core.c   | 53 -------------------------------------------------
> net/bridge/br_vlan.c    |  2 +-
> net/core/dev.c          |  2 +-
> net/core/skbuff.c       | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
> 6 files changed, 56 insertions(+), 61 deletions(-)
>
>diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>index 4967916..d69f057 100644
>--- a/include/linux/if_vlan.h
>+++ b/include/linux/if_vlan.h
>@@ -187,7 +187,6 @@ vlan_dev_get_egress_qos_mask(struct net_device *dev, u32 skprio)
> }
> 
> extern bool vlan_do_receive(struct sk_buff **skb);
>-extern struct sk_buff *vlan_untag(struct sk_buff *skb);
> 
> extern int vlan_vid_add(struct net_device *dev, __be16 proto, u16 vid);
> extern void vlan_vid_del(struct net_device *dev, __be16 proto, u16 vid);
>@@ -241,11 +240,6 @@ static inline bool vlan_do_receive(struct sk_buff **skb)
> 	return false;
> }
> 
>-static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
>-{
>-	return skb;
>-}
>-
> static inline int vlan_vid_add(struct net_device *dev, __be16 proto, u16 vid)
> {
> 	return 0;
>diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>index ec89301..401a96c 100644
>--- a/include/linux/skbuff.h
>+++ b/include/linux/skbuff.h
>@@ -2549,6 +2549,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
> void skb_scrub_packet(struct sk_buff *skb, bool xnet);
> unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
> struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
>+struct sk_buff *skb_untag(struct sk_buff *skb);
> 
> struct skb_checksum_ops {
> 	__wsum (*update)(const void *mem, int len, __wsum wsum);
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index 75d4277..90cc2bd 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -112,59 +112,6 @@ __be16 vlan_dev_vlan_proto(const struct net_device *dev)
> }
> EXPORT_SYMBOL(vlan_dev_vlan_proto);
> 
>-static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
>-{
>-	if (skb_cow(skb, skb_headroom(skb)) < 0) {
>-		kfree_skb(skb);
>-		return NULL;
>-	}
>-
>-	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
>-	skb->mac_header += VLAN_HLEN;
>-	return skb;
>-}
>-
>-struct sk_buff *vlan_untag(struct sk_buff *skb)
>-{
>-	struct vlan_hdr *vhdr;
>-	u16 vlan_tci;
>-
>-	if (unlikely(vlan_tx_tag_present(skb))) {
>-		/* vlan_tci is already set-up so leave this for another time */
>-		return skb;
>-	}
>-
>-	skb = skb_share_check(skb, GFP_ATOMIC);
>-	if (unlikely(!skb))
>-		goto err_free;
>-
>-	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
>-		goto err_free;
>-
>-	vhdr = (struct vlan_hdr *) skb->data;
>-	vlan_tci = ntohs(vhdr->h_vlan_TCI);
>-	__vlan_hwaccel_put_tag(skb, skb->protocol, vlan_tci);
>-
>-	skb_pull_rcsum(skb, VLAN_HLEN);
>-	vlan_set_encap_proto(skb, vhdr);
>-
>-	skb = vlan_reorder_header(skb);
>-	if (unlikely(!skb))
>-		goto err_free;
>-
>-	skb_reset_network_header(skb);
>-	skb_reset_transport_header(skb);
>-	skb_reset_mac_len(skb);
>-
>-	return skb;
>-
>-err_free:
>-	kfree_skb(skb);
>-	return NULL;
>-}
>-EXPORT_SYMBOL(vlan_untag);
>-
>-
> /*
>  * vlan info and vid list
>  */
>diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>index 2b2774f..e0040fc 100644
>--- a/net/bridge/br_vlan.c
>+++ b/net/bridge/br_vlan.c
>@@ -183,7 +183,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
> 	 */
> 	if (unlikely(!vlan_tx_tag_present(skb) &&
> 		     skb->protocol == proto)) {
>-		skb = vlan_untag(skb);
>+		skb = skb_untag(skb);
> 		if (unlikely(!skb))
> 			return false;
> 	}
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 367a586..8970259 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3588,7 +3588,7 @@ another_round:
> 
> 	if (skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
> 	    skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
>-		skb = vlan_untag(skb);
>+		skb = skb_untag(skb);
> 		if (unlikely(!skb))
> 			goto unlock;
> 	}
>diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>index 58ff88e..00db366 100644
>--- a/net/core/skbuff.c
>+++ b/net/core/skbuff.c
>@@ -62,6 +62,7 @@
> #include <linux/scatterlist.h>
> #include <linux/errqueue.h>
> #include <linux/prefetch.h>
>+#include <linux/if_vlan.h>
> 
> #include <net/protocol.h>
> #include <net/dst.h>
>@@ -3959,3 +3960,55 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
> 	return shinfo->gso_size;
> }
> EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
>+
>+static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
>+{
>+	if (skb_cow(skb, skb_headroom(skb)) < 0) {
>+		kfree_skb(skb);
>+		return NULL;
>+	}
>+
>+	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
>+	skb->mac_header += VLAN_HLEN;
>+	return skb;
>+}
>+
>+struct sk_buff *skb_untag(struct sk_buff *skb)

I would suggest to rename this to "skb_vlan_untag" to make this clear.
Other than that, the patch looks good to me.


>+{
>+	struct vlan_hdr *vhdr;
>+	u16 vlan_tci;
>+
>+	if (unlikely(vlan_tx_tag_present(skb))) {
>+		/* vlan_tci is already set-up so leave this for another time */
>+		return skb;
>+	}
>+
>+	skb = skb_share_check(skb, GFP_ATOMIC);
>+	if (unlikely(!skb))
>+		goto err_free;
>+
>+	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN)))
>+		goto err_free;
>+
>+	vhdr = (struct vlan_hdr *)skb->data;
>+	vlan_tci = ntohs(vhdr->h_vlan_TCI);
>+	__vlan_hwaccel_put_tag(skb, skb->protocol, vlan_tci);
>+
>+	skb_pull_rcsum(skb, VLAN_HLEN);
>+	vlan_set_encap_proto(skb, vhdr);
>+
>+	skb = skb_reorder_vlan_header(skb);
>+	if (unlikely(!skb))
>+		goto err_free;
>+
>+	skb_reset_network_header(skb);
>+	skb_reset_transport_header(skb);
>+	skb_reset_mac_len(skb);
>+
>+	return skb;
>+
>+err_free:
>+	kfree_skb(skb);
>+	return NULL;
>+}
>+EXPORT_SYMBOL(skb_untag);
>-- 
>1.9.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
