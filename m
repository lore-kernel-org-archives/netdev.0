From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Sun, 29 Dec 2013 17:01:21 -0500 (EST)
Message-ID: <20131229.170121.154913581019152817.davem@davemloft.net>
References: <1388237920-5140-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943Ab3L2WBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 17:01:23 -0500
In-Reply-To: <1388237920-5140-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 28 Dec 2013 14:38:40 +0100

>  Or is the real bug the use of netdev_priv in macvlan_hard_header()?

That's a really good question.

On the surface it really looks like header ops cannot assume anything
about the netdev_priv().  These operations are really meant to be
stateless and apply to an entire class of devices.  macvlan is trying
to make it's operations specific to exactly one device.

For example, eth_header() only assumes that the device the packet is
going over has an ETH_ALEN length MAC address.

Or at least, based upon what the vlan is trying to do it appears this
way.

But, ironically, vlan_dev_hard_header() makes this same assumption.  It
uses netdev_priv() the same way macvlan is.

So the more I think about this, the more I think that the operations
assignment VLAN is doing is illegal.  If it wants to "pass through"
it must do so with explicit handlers, ones that pass the expected
device to the hard header ops.

So vlan_dev.c would have things like:

static int vlan_passthru_hard_header(struct sk_buff *skb, struct net_device *dev,
				     unsigned short type,
				     const void *daddr, const void *saddr,
				     unsigned int len)
{
	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
	struct net_device *real_dev = vlan->real_dev;

	return real_dev->header_ops->create(skb, real_dev, type, daddr, saddr, len);
}

static int vlan_passthru_rebuild_header(struct sk_buff *skb)
{
	struct net_device *dev = skb->dev;
	struct net_device *real_dev;
	struct vlan_dev_priv *vlan;

	vlan = vlan_dev_priv(dev);
	real_dev = vlan->real_dev;

	return real_dev->header_ops->rebuild(skb);
}

and then:

static const struct header_ops vlan_passthru_header_ops = {
	.create	 = vlan_passthru_hard_header,
	.rebuild = vlan_passthru_rebuild_header,
	.parse	 = eth_header_parse,
};

BTW, ARCNET is another case which cares about the netdev_priv() in it's
header_ops.

Can someone test this?

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 762896e..91eb467 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -530,6 +530,35 @@ static const struct header_ops vlan_header_ops = {
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
+	return real_dev->header_ops->create(skb, real_dev, type, daddr, saddr, len);
+}
+
+static int vlan_passthru_rebuild_header(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct net_device *real_dev;
+	struct vlan_dev_priv *vlan;
+
+	vlan = vlan_dev_priv(dev);
+	real_dev = vlan->real_dev;
+
+	return real_dev->header_ops->rebuild(skb);
+}
+
+static const struct header_ops vlan_passthru_header_ops = {
+	.create	 = vlan_passthru_hard_header,
+	.rebuild = vlan_passthru_rebuild_header,
+	.parse	 = eth_header_parse,
+};
+
 static struct device_type vlan_type = {
 	.name	= "vlan",
 };
@@ -573,7 +602,7 @@ static int vlan_dev_init(struct net_device *dev)
 
 	dev->needed_headroom = real_dev->needed_headroom;
 	if (real_dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
-		dev->header_ops      = real_dev->header_ops;
+		dev->header_ops      = &vlan_passthru_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 	} else {
 		dev->header_ops      = &vlan_header_ops;
