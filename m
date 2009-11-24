From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/4] macvlan: export macvlan mode through netlink
Date: Tue, 24 Nov 2009 13:57:46 +0100
Message-ID: <200911241357.46690.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-5-git-send-email-arnd@arndb.de> <4B0BBB2E.8020502@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	David Miller <davem@davemloft.net>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58987 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbZKXM6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 07:58:11 -0500
In-Reply-To: <4B0BBB2E.8020502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 24 November 2009, Patrick McHardy wrote:
> Arnd Bergmann wrote:
> > @@ -600,6 +594,18 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
> >  		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
> >  			return -EADDRNOTAVAIL;
> >  	}
> > +
> > +	if (data && data[IFLA_MACVLAN_MODE]) {
> > +		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
> > +		switch (mode) {
> > +		case MACVLAN_MODE_PRIVATE:
> > +		case MACVLAN_MODE_VEPA:
> > +		case MACVLAN_MODE_BRIDGE:
> > +			break;
> > +		default:
> > +			return -EINVAL;
> 
> EINVAL is quite unspecific. In this case I think EOPNOTSUPP would
> be fine and provide more information.

ok

> > +		}
> > +	}
> >  	return 0;
> >  }
> > @@ -664,6 +670,13 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
> >  	vlan->dev      = dev;
> >  	vlan->port     = port;
> >  
> > +	vlan->mode     = MACVLAN_MODE_VEPA;
> > +	if (data && data[IFLA_MACVLAN_MODE]) {
> > +		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
> > +
> > +		vlan->mode     = mode;
> 
> This looks a bit strange, like cut-and-paste without reformatting :)
> I'd suggest to simply use "vlan->mode = nla_get_u32(...)".

Yep.

Thanks for the review. Combined changes below.

	Arnd <><
---

 drivers/net/macvlan.c |   47 +++++++++++++++++++++++------------------------
 1 files changed, 23 insertions(+), 24 deletions(-)

--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -118,15 +118,16 @@ static int macvlan_addr_busy(const struct macvlan_port *port,
 	return 0;
 }
 
-static inline void macvlan_count_rx(const struct macvlan_dev *vlan, int length,
-			     bool success, bool multicast)
+static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
+				    unsigned int len, bool success,
+				    bool multicast)
 {
 	struct macvlan_rx_stats *rx_stats;
 
 	rx_stats = per_cpu_ptr(vlan->rx_stats, smp_processor_id());
 	if (likely(success)) {
 		rx_stats->rx_packets++;;
-		rx_stats->rx_bytes += length;
+		rx_stats->rx_bytes += len;
 		if (multicast)
 			rx_stats->multicast++;
 	} else {
@@ -170,7 +171,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
-			if ((vlan->dev == src) || !(vlan->mode & mode))
+			if (vlan->dev == src || !(vlan->mode & mode))
 				continue;
 
 			nskb = skb_clone(skb, GFP_ATOMIC);
@@ -190,7 +191,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
 	struct net_device *dev;
-	int len;
+	unsigned int len;
 
 	port = rcu_dereference(skb->dev->macvlan_port);
 	if (port == NULL)
@@ -200,17 +201,22 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
 			/* frame comes from an external address */
-			macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_PRIVATE
-				| MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
+			macvlan_broadcast(skb, port, NULL,
+					  MACVLAN_MODE_PRIVATE |
+					  MACVLAN_MODE_VEPA    |
+					  MACVLAN_MODE_BRIDGE);
 		else if (src->mode == MACVLAN_MODE_VEPA)
 			/* flood to everyone except source */
 			macvlan_broadcast(skb, port, src->dev,
-				MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
+					  MACVLAN_MODE_VEPA |
+					  MACVLAN_MODE_BRIDGE);
 		else if (src->mode == MACVLAN_MODE_BRIDGE)
-			/* flood only to VEPA ports, bridge ports
-			   already saw the frame */
+			/*
+			 * flood only to VEPA ports, bridge ports
+			 * already saw the frame on the way out.
+			 */
 			macvlan_broadcast(skb, port, src->dev,
-				MACVLAN_MODE_VEPA);
+					  MACVLAN_MODE_VEPA);
 		return skb;
 	}
 
@@ -253,7 +259,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		dest = macvlan_hash_lookup(port, eth->h_dest);
 		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
-			int length = skb->len + ETH_HLEN;
+			unsigned int length = skb->len + ETH_HLEN;
 			int ret = dev_forward_skb(dest->dev, skb);
 			macvlan_count_rx(dest, length,
 					 ret == NET_RX_SUCCESS, 0);
@@ -604,8 +610,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 	if (data && data[IFLA_MACVLAN_MODE]) {
-		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
-		switch (mode) {
+		switch (nla_get_u32(data[IFLA_MACVLAN_MODE])) {
 		case MACVLAN_MODE_PRIVATE:
 		case MACVLAN_MODE_VEPA:
 		case MACVLAN_MODE_BRIDGE:
@@ -679,11 +684,8 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 	vlan->port     = port;
 
 	vlan->mode     = MACVLAN_MODE_VEPA;
-	if (data && data[IFLA_MACVLAN_MODE]) {
-		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
-
-		vlan->mode     = mode;
-	}
+	if (data && data[IFLA_MACVLAN_MODE])
+		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -710,11 +712,8 @@ static int macvlan_changelink(struct net_device *dev,
 		struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	if (data && data[IFLA_MACVLAN_MODE]) {
-		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
-		vlan->mode     = mode;
-	}
-
+	if (data && data[IFLA_MACVLAN_MODE])
+		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 	return 0;
 }
 
