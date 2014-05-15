From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 09:46:45 +0100
Message-ID: <1400143605.1006.1.camel@kazak.uk.xensource.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Bader <stefan.bader@canonical.com>,
	<xen-devel@lists.xenproject.org>, netdev <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:2299 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbaEOIrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 04:47:04 -0400
In-Reply-To: <5373C8D4.2010803@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 20:49 +0100, Zoltan Kiss wrote:
> On 13/05/14 19:21, Stefan Bader wrote:
> > We had reports about this message being seen on EC2 for a while but finally a
> > reporter did notice some details about the guests and was able to provide a
> > simple way to reproduce[1].
> >
> > For my local experiments I use a Xen-4.2.2 based host (though I would say the
> > host versions are not important). The host has one NIC which is used as the
> > outgoing port of a Linux based (not openvswitch) bridge. And the PV guests use
> > that bridge. I set the mtu to 9001 (which was seen on affected instance types)
> > and also inside the guests. As described in the report one guests runs
> > redis-server and the other nodejs through two scripts (for me I had to do the
> > two sub.js calls in separate shells). After a bit the error messages appear on
> > the guest running the redis-server.
> >
> > I added some debug printk's to show a bit more detail about the skb and got the
> > following (<length>@<offset (after masking off complete pages)>):
> >
> > [ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
> > [ 698.108134] header 1490@238 -> 1 slots
> > [ 698.108139] frag #0 1614@2164 -> + 1 pages
> > [ 698.108143] frag #1 3038@1296 -> + 2 pages
> > [ 698.108147] frag #2 6076@1852 -> + 2 pages
> > [ 698.108151] frag #3 6076@292 -> + 2 pages
> > [ 698.108156] frag #4 6076@2828 -> + 3 pages
> > [ 698.108160] frag #5 3038@1268 -> + 2 pages
> > [ 698.108164] frag #6 2272@1824 -> + 1 pages
> > [ 698.108168] frag #7 3804@0 -> + 1 pages
> > [ 698.108172] frag #8 6076@264 -> + 2 pages
> > [ 698.108177] frag #9 3946@2800 -> + 2 pages
> > [ 698.108180] frags adding 18 slots
> >
> > Since I am not deeply familiar with the networking code, I wonder about two things:
> > - is there something that should limit the skb data length from all frags
> >    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
> I think netfront should be able to handle 64K packets at most.

Ah, maybe this relates to this fix from Wei?

commit 9ecd1a75d977e2e8c48139c7d3efed183f898d94
Author: Wei Liu <wei.liu2@citrix.com>
Date:   Mon Apr 22 02:20:41 2013 +0000

    xen-netfront: reduce gso_max_size to account for max TCP header
    
    The maximum packet including header that can be handled by netfront / netback
    wire format is 65535. Reduce gso_max_size accordingly.
    
    Drop skb and print warning when skb->len > 65535. This can 1) save the effort
    to send malformed packet to netback, 2) help spotting misconfiguration of
    netfront in the future.
    
    Signed-off-by: Wei Liu <wei.liu2@citrix.com>
    Acked-by: Ian Campbell <ian.campbell@citrix.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 1bb2e20..1db10141 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -36,7 +36,7 @@
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/if_ether.h>
-#include <linux/tcp.h>
+#include <net/tcp.h>
 #include <linux/udp.h>
 #include <linux/moduleparam.h>
 #include <linux/mm.h>
@@ -547,6 +547,16 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
 
+	/* If skb->len is too big for wire format, drop skb and alert
+	 * user about misconfiguration.
+	 */
+	if (unlikely(skb->len > XEN_NETIF_MAX_TX_SIZE)) {
+		net_alert_ratelimited(
+			"xennet: skb->len = %u, too big for wire format\n",
+			skb->len);
+		goto drop;
+	}
+
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
@@ -1058,7 +1068,8 @@ err:
 
 static int xennet_change_mtu(struct net_device *dev, int mtu)
 {
-	int max = xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
+	int max = xennet_can_sg(dev) ?
+		XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER : ETH_DATA_LEN;
 
 	if (mtu > max)
 		return -EINVAL;
@@ -1362,6 +1373,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
+	netif_set_gso_max_size(netdev, XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER);
+
 	np->netdev = netdev;
 
 	netif_carrier_off(netdev);
diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index 9dfc120..58fadca 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -47,6 +47,7 @@
 #define _XEN_NETTXF_extra_info		(3)
 #define  XEN_NETTXF_extra_info		(1U<<_XEN_NETTXF_extra_info)
 
+#define XEN_NETIF_MAX_TX_SIZE 0xFFFF
 struct xen_netif_tx_request {
     grant_ref_t gref;      /* Reference to buffer page */
     uint16_t offset;       /* Offset within buffer page */
