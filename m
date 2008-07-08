From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Tue, 08 Jul 2008 19:41:16 +0200
Message-ID: <4873A6BC.6030205@trash.net>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net> <20080707210701.GD12997@xi.wantstofly.org> <48728784.2030202@trash.net> <487394CC.7050107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090507070305040702050005"
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34717 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbYGHRwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 13:52:35 -0400
In-Reply-To: <487394CC.7050107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090507070305040702050005
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
>> Lennert Buytenhek wrote:
>>>>> When inserting a vlan tag into an skb by hand (in the case the
>>>>> target network device hardware does not support inserting a vlan
>>>>> tag by passing it in via the TX descriptor), making a copy of the
>>>>> skb to be modified by calling skb_copy() is overkill, since
>>>>> skb_copy() will needlessly linearize the skb, copying of all of
>>>>> the fragmented data around, and checksumming the paket in software
>>>>> even if the hardware is perfectly capable of doing that by itself.
>>>>>
>>>>> For this case, pskb_copy() does exactly what is needed and no more,
>>>>> so use that instead. 
> Actually, are you sure this patch is helping for the case
> you describe? The function you changed is only called on
> the RX path.

Could you try this one please?


--------------090507070305040702050005
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 911648966b61f2b1c8d37e6ba972ca5cc908136d
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jul 8 19:49:15 2008 +0200

    vlan: avoid header copying and linearisation where possible
    
    - vlan_dev_reorder_header() is only called on the receive path after
      calling skb_share_check(). This means we can use skb_cow() since
      all we need is a writable header.
    
    - vlan_dev_hard_header() includes a work-around for some apparently
      broken out of tree MPLS code. The hard_header functions can expect
      to always have a headroom of at least there own hard_header_len
      available, so the reallocation check is unnecessary.
    
    - __vlan_put_tag() can use skb_cow_header() to avoid the skb_unshare()
      copy when the header is writable.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index e8360a2..9e7b49b 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -176,22 +176,10 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
-	if (skb_headroom(skb) < VLAN_HLEN) {
-		struct sk_buff *sk_tmp = skb;
-		skb = skb_realloc_headroom(sk_tmp, VLAN_HLEN);
-		kfree_skb(sk_tmp);
-		if (!skb) {
-			printk(KERN_ERR "vlan: failed to realloc headroom\n");
-			return NULL;
-		}
-	} else {
-		skb = skb_unshare(skb, GFP_ATOMIC);
-		if (!skb) {
-			printk(KERN_ERR "vlan: failed to unshare skbuff\n");
-			return NULL;
-		}
+	if (skb_cow_head(skb, VLAN_HLEN) < 0) {
+		kfree_skb(skb);
+		return NULL;
 	}
-
 	veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN);
 
 	/* Move the mac addresses to the beginning of the new header. */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2ccac6b..00867e9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -74,11 +74,8 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 {
 	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		if (skb_shared(skb) || skb_cloned(skb)) {
-			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
-			kfree_skb(skb);
-			skb = nskb;
-		}
+		if (skb_cow(skb, skb_headroom(skb)) < 0)
+			skb = NULL;
 		if (skb) {
 			/* Lifted from Gleb's VLAN code... */
 			memmove(skb->data - ETH_HLEN,
@@ -262,7 +259,9 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	u16 vlan_tci = 0;
 	int rc = 0;
 	int build_vlan_header = 0;
-	struct net_device *vdev = dev;
+
+	if (WARN_ON(skb_headroom(skb) < dev->hard_header_len + VLAN_HLEN))
+		return -ENOSPC;
 
 	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
 		 __func__, skb, type, len, vlan_dev_info(dev)->vlan_id,
@@ -316,29 +315,6 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 	dev = vlan_dev_info(dev)->real_dev;
 
-	/* MPLS can send us skbuffs w/out enough space.	This check will grow
-	 * the skb if it doesn't have enough headroom. Not a beautiful solution,
-	 * so I'll tick a counter so that users can know it's happening...
-	 * If they care...
-	 */
-
-	/* NOTE: This may still break if the underlying device is not the final
-	 * device (and thus there are more headers to add...) It should work for
-	 * good-ole-ethernet though.
-	 */
-	if (skb_headroom(skb) < dev->hard_header_len) {
-		struct sk_buff *sk_tmp = skb;
-		skb = skb_realloc_headroom(sk_tmp, dev->hard_header_len);
-		kfree_skb(sk_tmp);
-		if (skb == NULL) {
-			struct net_device_stats *stats = &vdev->stats;
-			stats->tx_dropped++;
-			return -ENOMEM;
-		}
-		vlan_dev_info(vdev)->cnt_inc_headroom_on_tx++;
-		pr_debug("%s: %s: had to grow skb\n", __func__, vdev->name);
-	}
-
 	if (build_vlan_header) {
 		/* Now make the underlying real hard header */
 		rc = dev_hard_header(skb, dev, ETH_P_8021Q, daddr, saddr,

--------------090507070305040702050005--
