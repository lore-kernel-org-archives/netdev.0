From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Tue, 08 Jul 2008 20:50:09 +0200
Message-ID: <4873B6E1.9010702@trash.net>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net> <20080707210701.GD12997@xi.wantstofly.org> <48728784.2030202@trash.net> <487394CC.7050107@trash.net> <20080708185226.GD14330@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000806090904090808000709"
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36235 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989AbYGHTB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 15:01:28 -0400
In-Reply-To: <20080708185226.GD14330@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000806090904090808000709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Lennert Buytenhek wrote:
> On Tue, Jul 08, 2008 at 06:24:44PM +0200, Patrick McHardy wrote:
>
>   
>> Actually, are you sure this patch is helping for the case
>> you describe? The function you changed is only called on
>> the RX path.
>>     
>
> You're right, I got confused with setting ->vlan_features, which is
> the actual thing that controls whether ->hard_start_xmit() gets send
> fragmented skbs or not.
>
> skb_copy() shows high in the profiles, but it's not the skb_copy() in
> vlan_check_reorder_header() (my bad), it's the skb_copy() call in
> skb_unshare() called via include/linux/if_vlan.h:__vlan_put_tag().
>   

Yes, thats expected for TCP packets.
> I've gathered some numbers for zero-copy (sendfile) sending a 1 GiB
> file filled with zeroes from the box that has the mv643xx_eth to a
> random x86 box:
>
> - 2.6.26-rc9, no VLAN tagging: ~71 sec, 14.4 MiB/s
> - 2.6.29-rc9, VLAN tagging: ~107 sec, 9.57 MiB/s
> - 2.6.29-rc9, VLAN tagging with [1] + [2]: ~94 sec: 10.9 MiB/s
> - 2.6.29-rc9, VLAN tagging with [1] + [2] + [3]: ~81 sec: 12.6 MiB/s
>
> I'm wondering whether lying to the stack about HW VLAN accel
> capability and adding the VLAN tag to the ethernet header in a
> private buffer in the driver will give me the performance back.
>
> (If I'd have to guess, I'd say that the existence of a frag list
> shouldn't matter for the shareability of an skb, but there's probably
> a good reason why skb_unshare() calls skb_copy() and not pskb_copy().)
>   

Without checking if its actually needed, I would tend to agree because
a caller can't rely on getting a linearized skb back except when its
guaranteed to be cloned, in the case it could simply copy it always.

Anyway, the copy in __vlan_put_tag() is overkill since the header
is usually writable. See the patch I sent in my second mail, it
should reduce the overhead significantly.

Actually there was a small bug in the one I sent, so attached again
to this mail.



--------------000806090904090808000709
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 9381fc4a49cb8b75d5ff38e4f5d14d7e135adc4c
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jul 8 19:56:17 2008 +0200

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
index 2ccac6b..b6e52c0 100644
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
@@ -262,12 +259,14 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	u16 vlan_tci = 0;
 	int rc = 0;
 	int build_vlan_header = 0;
-	struct net_device *vdev = dev;
 
 	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
 		 __func__, skb, type, len, vlan_dev_info(dev)->vlan_id,
 		 daddr);
 
+	if (WARN_ON(skb_headroom(skb) < dev->hard_header_len))
+		return -ENOSPC;
+
 	/* build vlan header only if re_order_header flag is NOT set.  This
 	 * fixes some programs that get confused when they see a VLAN device
 	 * sending a frame that is VLAN encoded (the consensus is that the VLAN
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

--------------000806090904090808000709--
