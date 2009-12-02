From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
	separate vlan from bond device
Date: Wed, 2 Dec 2009 16:24:49 -0500
Message-ID: <20091202212449.GL1639@gospo.rdu.redhat.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com> <21331.1259702893@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbZLBVYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 16:24:55 -0500
Content-Disposition: inline
In-Reply-To: <21331.1259702893@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 01:28:13PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> [...]
> >I am using arp_validate, actually.  I forgot that the arp_validate
> >option doesn't show up in the output of /proc/net/bonding/bondX and I
> >intended to have that in the subject, but somehow dropped it.
> 
> 	Ok, I was doing it wrong earlier; it works with arp_validate.
> I'm seeing one problem with tcpdump, though, which I'll get to in a
> minute.
> 
> 	Could you update the summary / changelog message to mention that
> this patch fixes the specific case of arp_validate + arp_ip_target on
> VLAN?
> 
> 	Second, in regards to this:
> 
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2439,8 +2439,8 @@ int netif_receive_skb(struct sk_buff *skb)
>  		skb->skb_iif = skb->dev->ifindex;
> 
>  	null_or_orig = NULL;
> -	orig_dev = skb->dev;
> -	if (orig_dev->master) {
> +	orig_dev = __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
> +	if (orig_dev->master && !(skb->dev->priv_flags & IFF_802_1Q_VLAN)) {
>  		if (skb_bond_should_drop(skb))
>  			null_or_orig = orig_dev; /* deliver only exact match */
>  		else
> 
> 	Would it be useful to add a comment to the effect that VLAN
> packets are run through skb_bond_should_drop at the VLAN layer?
> 
> 	Lastly, in regards to this:
> 
> @@ -2492,7 +2492,7 @@ ncls:
>  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>  		if (ptype->type == type &&
>  		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
> -		     ptype->dev == orig_dev)) {
> +		     ptype->dev == orig_dev || ptype->dev == orig_dev->master)) {
>  			if (pt_prev)
>  				ret = deliver_skb(skb, pt_prev, orig_dev);
>  			pt_prev = ptype;
> 
> 	This is presumably here because orig_dev will now be the actual
> slave the packet arrived on, but we want to additionally deliver to the
> master, correct?
> 
> 	Lastly, tcpdump.
> 
> 	This patch appears to affect what traffic tcpdump of a slave or
> the bonding master itself will capture.  Previously, tcpdump of the
> active slave would see only the transmitted packets sent over the bond,
> and tcpdump of the inactive slave would see incoming Ethernet-layer
> multicast or broadcasts sent to its switch port.  Tcpdump on the master
> would see all sent and non-VLAN received traffic, and tcpdump of the
> VLAN interface over the master would see just the VLAN traffic.
> 
> 	After this change, tcpdump of the active slave or of the bonding
> master (bond0) sees both sent and received traffic for the VLAN, but
> nothing for the non-VLAN traffic other than incoming broadcast /
> multicasts.  This holds true whether or not a VLAN is configured.
> 
> 	I added a "ptype->dev == orig_dev->master" test to the ptype_all
> receive block in netif_receive_skb, but it didn't help.  At the moment,
> I'm not exactly sure why tcpdump breaks.
> 

Jay,

The issue was that that orig_dev was getting set to the active slave, so
your running tcpdump on the active slave made the conditional inside
this loop:

        list_for_each_entry_rcu(ptype, &ptype_all, list) {
                if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
                    ptype->dev == orig_dev) {
                        if (pt_prev)
                                ret = deliver_skb(skb, pt_prev, orig_dev);
                        pt_prev = ptype;
                }
        }

hit and deliver_skb was being called for all traffic coming toward
bond0.<vid>.  I'm not completely happy with this solutoin, but I think
it resolves both the original problem I was trying to solve and the
regression you discovered with your original patch.  Let me know if you
see everything working now like I do.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 726bd75..b1e3b2f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2697,6 +2697,19 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	bond = netdev_priv(dev);
 	read_lock(&bond->lock);
 
+	/*
+	 * We may have dev passed in as a vlan device, so make sure to get to the
+	 * core netdev before continuing.
+	 */
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		dev = vlan_dev_real_dev(dev);
+		/*
+		 * Don't necessarily trust passed in orig_dev since vlan accelerated
+		 * netdevs and bonding don't play well together.
+		 */
+		orig_dev = __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
+	}
+
 	pr_debug("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
 		bond->dev->name, skb->dev ? skb->dev->name : "NULL",
 		orig_dev ? orig_dev->name : "NULL");
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e75a2f3..8d8a778 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,6 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
+	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 
@@ -85,6 +86,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
+	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d131c2..9c3ba0d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2421,6 +2421,7 @@ int netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
+	struct net_device *bond_dev;
 	struct net_device *null_or_orig;
 	int ret = NET_RX_DROP;
 	__be16 type;
@@ -2487,12 +2488,24 @@ ncls:
 	if (!skb)
 		goto out;
 
+	/*
+	 * A bonding interface with a VLAN on top doesn't play nicely when the
+	 * netdev in the bond is capable of stripping the VLAN tag for us.
+	 * Knowing the base bond device is important in the event that bond
+	 * control frames arrive with a VLAN tag, but need to be serviced by
+	 * a hook installed for the base bond device.
+	 */
+	bond_dev = skb->dev;
+	if ((bond_dev->priv_flags & IFF_802_1Q_VLAN) &&
+	    (vlan_dev_real_dev(bond_dev)->priv_flags & IFF_BONDING))
+		bond_dev = vlan_dev_real_dev(bond_dev);
+
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type &&
 		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
-		     ptype->dev == orig_dev)) {
+		     ptype->dev == orig_dev || ptype->dev == bond_dev)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;
