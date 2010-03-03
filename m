From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Wed, 3 Mar 2010 19:09:56 +0100
Message-ID: <20100303180956.GC2760@psychotron.redhat.com>
References: <20100303114506.19575pbsu8yz2kjk@hayate.sektori.org>
 <20100303124249.GD2961@psychotron.lab.eng.brq.redhat.com>
 <20100303184256.19122kg5hcqolfgg@hayate.sektori.org>
 <20100303175229.GB2760@psychotron.redhat.com>
 <20100303200510.17531s9x98zyvwm8@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40605 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755390Ab0CCSKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 13:10:06 -0500
Content-Disposition: inline
In-Reply-To: <20100303200510.17531s9x98zyvwm8@hayate.sektori.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 03, 2010 at 07:05:10PM CET, jussi.kivilinna@mbnet.fi wrote:
>Quoting "Jiri Pirko" <jpirko@redhat.com>:
>
>>Wed, Mar 03, 2010 at 05:42:56PM CET, jussi.kivilinna@mbnet.fi wrote:
>>>Hello!
>>>
>>>Quoting "Jiri Pirko" <jpirko@redhat.com>:
>>>
>>>>+	} else if (mc_count) {
>>>>+		int size = min(priv->multicast_size, mc_count);
>>>>+		int i = 0;
>>>>+
>>>>+		mc_addrs = kmalloc(size * ETH_ALEN, GFP_ATOMIC);
>>>...
>>>>+	if (filter != basefilter)
>>>>+		goto set_filter;
>>>>+
>>>>+	if (mc_count) {
>>>>+		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, mc_addrs,
>>>>+				    mc_count * ETH_ALEN);
>>>>+		kfree(mc_addrs);
>>>
>>>mc_addrs was alloced by with 'size * ETH_ALEN', which might be less
>>>than mc_count * ETH_ALEN.
>>
>>Actually it cannot. That's covered by:
>>
>>if (mc_count > priv->multicast_size) {
>>
>>This was also in the original code. In that case "size" can be eliminated and
>>"mc_addrs" can be allocated with "mc_count * ETH_ALEN".
>>
>>Jussi are you ok with this?
>>
>>Jirka
>
>Ah, you're right. Yes, 'size' can go away, it isn't needed after all.
>I'm ok with this patch, I can fix 'size' to 'mc_count' myself later.

Here's corrected patch:

Subject: [net-2.6 PATCH] rndis_wlan: correct multicast_list handling V2

My previous patch (655ffee284dfcf9a24ac0343f3e5ee6db85b85c5) added locking in
a bad way. Because rndis_set_oid can sleep, there is need to prepare multicast
addresses into local buffer under netif_addr_lock first, then call
rndis_set_oid outside. This caused reorganizing of the whole function.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reported-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 9f6d6bf..07e6fdd 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1496,23 +1496,37 @@ static void set_multicast_list(struct usbnet *usbdev)
 {
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	struct dev_mc_list *mclist;
-	__le32 filter;
-	int ret, i, size;
-	char *buf;
+	__le32 filter, basefilter;
+	int ret;
+	char *mc_addrs = NULL;
+	int mc_count;
 
-	filter = RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST;
+	basefilter = filter = RNDIS_PACKET_TYPE_DIRECTED |
+			      RNDIS_PACKET_TYPE_BROADCAST;
 
-	netif_addr_lock_bh(usbdev->net);
 	if (usbdev->net->flags & IFF_PROMISC) {
 		filter |= RNDIS_PACKET_TYPE_PROMISCUOUS |
 			RNDIS_PACKET_TYPE_ALL_LOCAL;
-	} else if (usbdev->net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(usbdev->net) > priv->multicast_size) {
+	} else if (usbdev->net->flags & IFF_ALLMULTI) {
+		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
+	}
+
+	if (filter != basefilter)
+		goto set_filter;
+
+	/*
+	 * mc_list should be accessed holding the lock, so copy addresses to
+	 * local buffer first.
+	 */
+	netif_addr_lock_bh(usbdev->net);
+	mc_count = netdev_mc_count(usbdev->net);
+	if (mc_count > priv->multicast_size) {
 		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
-	} else if (!netdev_mc_empty(usbdev->net)) {
-		size = min(priv->multicast_size, netdev_mc_count(usbdev->net));
-		buf = kmalloc(size * ETH_ALEN, GFP_KERNEL);
-		if (!buf) {
+	} else if (mc_count) {
+		int i = 0;
+
+		mc_addrs = kmalloc(mc_count * ETH_ALEN, GFP_ATOMIC);
+		if (!mc_addrs) {
 			netdev_warn(usbdev->net,
 				    "couldn't alloc %d bytes of memory\n",
 				    size * ETH_ALEN);
@@ -1520,27 +1534,29 @@ static void set_multicast_list(struct usbnet *usbdev)
 			return;
 		}
 
-		i = 0;
-		netdev_for_each_mc_addr(mclist, usbdev->net) {
-			if (i == size)
-				break;
-			memcpy(buf + i++ * ETH_ALEN, mclist->dmi_addr, ETH_ALEN);
-		}
+		netdev_for_each_mc_addr(mclist, usbdev->net)
+			memcpy(mc_addrs + i++ * ETH_ALEN,
+			       mclist->dmi_addr, ETH_ALEN);
+	}
+	netif_addr_unlock_bh(usbdev->net);
 
-		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, buf,
-								i * ETH_ALEN);
-		if (ret == 0 && i > 0)
+	if (filter != basefilter)
+		goto set_filter;
+
+	if (mc_count) {
+		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, mc_addrs,
+				    mc_count * ETH_ALEN);
+		kfree(mc_addrs);
+		if (ret == 0)
 			filter |= RNDIS_PACKET_TYPE_MULTICAST;
 		else
 			filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
 
 		netdev_dbg(usbdev->net, "OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d\n",
-			   i, priv->multicast_size, ret);
-
-		kfree(buf);
+			   mc_count, priv->multicast_size, ret);
 	}
-	netif_addr_unlock_bh(usbdev->net);
 
+set_filter:
 	ret = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &filter,
 							sizeof(filter));
 	if (ret < 0) {
