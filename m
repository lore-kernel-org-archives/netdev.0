From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Tue, 31 Dec 2013 16:24:48 -0500 (EST)
Message-ID: <20131231.162448.1656983197554902144.davem@davemloft.net>
References: <1388237920-5140-1-git-send-email-fw@strlen.de>
	<20131229.170121.154913581019152817.davem@davemloft.net>
	<20131230102712.GO29632@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab3LaVYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 16:24:49 -0500
In-Reply-To: <20131230102712.GO29632@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 30 Dec 2013 11:27:12 +0100

> I wonder if this needs to use dev_hard_header() to protect against
> NULL header_ops/create hook. macvlan does this.

Good catch.

> similar, e.g. drivers/net/plip/plip.c defines 'create' and 'cache' but
> no 'rebuild'.

Likewise, and it looks like the neighbour code could crash if the right
things happen over a PLIP device.  Also fixed by the patch below.

The following is what I committed and will submit to -stable, thanks!

====================
vlan: Fix header ops passthru when doing TX VLAN offload.

When the vlan code detects that the real device can do TX VLAN offloads
in hardware, it tries to arrange for the real device's header_ops to
be invoked directly.

But it does so illegally, by simply hooking the real device's
header_ops up to the VLAN device.

This doesn't work because we will end up invoking a set of header_ops
routines which expect a device type which matches the real device, but
will see a VLAN device instead.

Fix this by providing a pass-thru set of header_ops which will arrange
to pass the proper real device instead.

To facilitate this add a dev_rebuild_header().  There are
implementations which provide a ->cache and ->create but not a
->rebuild (f.e. PLIP).  So we need a helper function just like
dev_hard_header() to avoid crashes.

Use this helper in the one existing place where the
header_ops->rebuild was being invoked, the neighbour code.

With lots of help from Florian Westphal.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |  9 +++++++++
 net/8021q/vlan_dev.c      | 19 ++++++++++++++++++-
 net/core/neighbour.c      |  2 +-
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d9a550b..7514b9c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1912,6 +1912,15 @@ static inline int dev_parse_header(const struct sk_buff *skb,
 	return dev->header_ops->parse(skb, haddr);
 }
 
+static inline int dev_rebuild_header(struct sk_buff *skb)
+{
+	const struct net_device *dev = skb->dev;
+
+	if (!dev->header_ops || !dev->header_ops->rebuild)
+		return 0;
+	return dev->header_ops->rebuild(skb);
+}
+
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 int register_gifconf(unsigned int family, gifconf_func_t *gifconf);
 static inline int unregister_gifconf(unsigned int family)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 762896e..47c908f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -530,6 +530,23 @@ static const struct header_ops vlan_header_ops = {
 	.parse	 = eth_header_parse,
 };
 
+static int vlan_passthru_hard_header(struct sk_buff *skb, struct net_device *dev,
+				     unsigned short type,
+				     const void *daddr, const void *saddr,
+				     unsigned int len)
+{
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	struct net_device *real_dev = vlan->real_dev;
+
+	return dev_hard_header(skb, real_dev, type, daddr, saddr, len);
+}
+
+static const struct header_ops vlan_passthru_header_ops = {
+	.create	 = vlan_passthru_hard_header,
+	.rebuild = dev_rebuild_header,
+	.parse	 = eth_header_parse,
+};
+
 static struct device_type vlan_type = {
 	.name	= "vlan",
 };
@@ -573,7 +590,7 @@ static int vlan_dev_init(struct net_device *dev)
 
 	dev->needed_headroom = real_dev->needed_headroom;
 	if (real_dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
-		dev->header_ops      = real_dev->header_ops;
+		dev->header_ops      = &vlan_passthru_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 	} else {
 		dev->header_ops      = &vlan_header_ops;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 36b1443..932c6d7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1275,7 +1275,7 @@ int neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
 			    skb->len) < 0 &&
-	    dev->header_ops->rebuild(skb))
+	    dev_rebuild_header(skb))
 		return 0;
 
 	return dev_queue_xmit(skb);
-- 
1.7.11.7
