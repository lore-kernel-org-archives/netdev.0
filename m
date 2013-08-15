From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 1/2] macvtap: include all checksum offloads in
 TUN_OFFLOAD mask
Date: Thu, 15 Aug 2013 22:09:45 +0300
Message-ID: <20130815190945.GA11569@redhat.com>
References: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
 <1376586173-4242-2-git-send-email-vyasevic@redhat.com>
 <20130815182430.GB10265@redhat.com>
 <520D21CA.4090400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758242Ab3HOTH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 15:07:59 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7FJ7xbu005068
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 15:07:59 -0400
Content-Disposition: inline
In-Reply-To: <520D21CA.4090400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 02:45:30PM -0400, Vlad Yasevich wrote:
> On 08/15/2013 02:24 PM, Michael S. Tsirkin wrote:
> >On Thu, Aug 15, 2013 at 01:02:52PM -0400, Vlad Yasevich wrote:
> >>The features of the macvlan are based on the features of lower
> >>device and thus can have checksum featurs other then IFF_F_HW_CSUM
> >
> >s/featurs/features/
> >
> >:set spell spelllang=en_us
> >
> >or whatever's the equivalent in your editor of choice.
> >
> >>set.  However, TUN_OFFLOAD mask only includes IFF_F_HW_CSUM.  Thus
> >>when performing gso segmentation during macvtap_forward(),
> >>it is possbile to end up with skbs that have ip_summed set
> >>to CHECKSUM_PARTIAL.  This is incorrect when the user
> >>turns off checksum offloading.
> >>
> >>Include all possible checksum offload values so that
> >>we'll properly mask them off when performing GSO.
> >>
> >>Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >>---
> >>  drivers/net/macvtap.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >>diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> >>index b51db2a..8121358 100644
> >>--- a/drivers/net/macvtap.c
> >>+++ b/drivers/net/macvtap.c
> >>@@ -65,7 +65,7 @@ static struct cdev macvtap_cdev;
> >>
> >>  static const struct proto_ops macvtap_socket_ops;
> >>
> >>-#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
> >>+#define TUN_OFFLOADS (NETIF_F_ALL_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
> >>  		      NETIF_F_TSO6 | NETIF_F_UFO)
> >>  #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
> >>  /*
> >
> >Okay so you are talking about hardware that sets some other
> >checksum bit besides HW_CSUM, e.g. IP_CSUM, so
> >
> >         vlan->tap_features = vlan->dev->features &
> >                             (feature_mask | ~TUN_OFFLOADS);
> >
> >will not clear IP_CSUM even if feature_mask is 0.
> >
> >Maybe mention this in the changelog, in case user
> >will wonder whether his hardware is affected.
> >
> >So I agree, that's a bug, but if you make this change the reverse will hold
> >(on this hardware):
> >if user sets TUN_F_CSUM, we won't set NETIF_F_IP_CSUM
> >so checksum offloading won't work.
> >
> >So I think you want s/NETIF_F_HW_CSUM/NETIF_F_ALL_CSUM/ everywhere
> >and not just in this place.
> 
> Yes.  I thought about that, but forgot to do in this patch set.

In fact I wonder why do we do it like this at all.
tap_features have nothing to do with the device,
they only have to do with tap.
For example, you might have a dumb device with no
checksum support but userspace said it does not need a checksum,
we can have NETIF_F_HW_CSUM there anyway.

So why don't we just
        vlan->tap_features = feature_mask;
?
In fact, this is exactly set_features, so why don't
we just use set_features everywhere?
Then this patch won't be needed at all.

Kind of like this - compile-tested only - do you have a setup with
IP_CSUM which you can use to test?

-->

macvtap: fix up tap features

There's no apparent need to have separate tap features
masked according to the lowerdev config:
we only use them in software so hardware configuration
does not matter.
Drop tap_features and use set_features directly


This fixes bugs for some unusual hardware configurations,
for example, we only masked HW_CSUM so for hardware with
e.g. IP_CSUM the checksum bit remained set, which would cause
packets with CHECKSUM_PARTIAL to be sent to userspace
even when offloads are disabled.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a98ed9f..26cea91 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -289,7 +289,7 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 	/* Apply the forward feature mask so that we perform segmentation
 	 * according to users wishes.
 	 */
-	features = netif_skb_features(skb) & vlan->tap_features;
+	features = netif_skb_features(skb) & vlan->set_features;
 	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
@@ -382,11 +382,6 @@ static int macvtap_newlink(struct net *src_net,
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	INIT_LIST_HEAD(&vlan->queue_list);
 
-	/* Since macvlan supports all offloads by default, make
-	 * tap support all offloads also.
-	 */
-	vlan->tap_features = TUN_OFFLOADS;
-
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
@@ -1027,7 +1022,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
 	features = vlan->dev->features;
 
 	if (arg & TUN_F_CSUM) {
-		feature_mask = NETIF_F_HW_CSUM;
+		feature_mask = NETIF_F_HW_CSUM;
 
 		if (arg & (TUN_F_TSO4 | TUN_F_TSO6)) {
 			if (arg & TUN_F_TSO_ECN)
@@ -1055,11 +1050,6 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
 	else
 		features &= ~RX_OFFLOADS;
 
-	/* tap_features are the same as features on tun/tap and
-	 * reflect user expectations.
-	 */
-	vlan->tap_features = vlan->dev->features &
-			    (feature_mask | ~TUN_OFFLOADS);
 	vlan->set_features = features;
 	netdev_update_features(vlan->dev);
 
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index ddd33fd..e446e82 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -76,7 +76,6 @@ struct macvlan_dev {
 	struct list_head	queue_list;
 	int			numvtaps;
 	int			numqueues;
-	netdev_features_t	tap_features;
 	int			minor;
 };
 
