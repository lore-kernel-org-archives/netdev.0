From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 7/7] openvswitch: use ipgre tunnel rather
 than gretap tunnel
Date: Fri, 6 May 2016 15:54:02 +0900
Message-ID: <20160506065400.GA15277@penelope.isobedori.kobe.vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-8-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BAFuZjoUgza9n8g1pborjCsYAC0DU4cXsff_9q9Cp+Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36311 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbcEFGyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 02:54:12 -0400
Received: by mail-pf0-f176.google.com with SMTP id c189so48072612pfb.3
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 23:54:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_BAFuZjoUgza9n8g1pborjCsYAC0DU4cXsff_9q9Cp+Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC Jiri Benc]

On Thu, May 05, 2016 at 02:45:15PM -0700, pravin shelar wrote:
> On Wed, May 4, 2016 at 12:36 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > This allows GRE tunnels to send and receive both
> > layer 2 packets (packets with an ethernet header) and
> > layer 3 packets (packets without an ethernet header).
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> > v9
> > New Patch
> > ---
> >  include/net/gre.h              |  4 ++--
> >  net/ipv4/ip_gre.c              |  8 ++++----
> >  net/openvswitch/vport-gre.c    |  4 ++--
> >  net/openvswitch/vport-netdev.c | 12 +++++++++++-
> >  net/openvswitch/vport-netdev.h |  1 +
> >  5 files changed, 20 insertions(+), 9 deletions(-)
> >
> ...
> ...
> > diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> > index f003225de994..b1aa02904ae4 100644
> > --- a/net/openvswitch/vport-gre.c
> > +++ b/net/openvswitch/vport-gre.c
> > @@ -60,7 +60,7 @@ static struct vport *gre_tnl_create(const struct vport_parms *parms)
> >                 return vport;
> >
> >         rtnl_lock();
> > -       dev = gretap_fb_dev_create(net, parms->name, NET_NAME_USER);
> > +       dev = gre_fb_dev_create(net, parms->name, NET_NAME_USER);
> >         if (IS_ERR(dev)) {
> >                 rtnl_unlock();
> >                 ovs_vport_free(vport);
> > @@ -87,7 +87,7 @@ static struct vport *gre_create(const struct vport_parms *parms)
> >  static struct vport_ops ovs_gre_vport_ops = {
> >         .type           = OVS_VPORT_TYPE_GRE,
> >         .create         = gre_create,
> > -       .send           = ovs_netdev_send_tap,
> > +       .send           = ovs_netdev_send_raw_tun,
> >         .destroy        = ovs_netdev_tunnel_destroy,
> >  };
> >
> 
> This trick of using vport-send only works in case of compat tunnel
> device mode. But in normal case the LWT interface allows us to use net
> devices for tunnel traffic. So you need some sort of mechanism to
> handle l3 only packets on vport-netdev.

Thanks. Clearly I did not consider that and clearly I should have.

On the kernel side I wonder if something like the following (untested
with tunnel vport-netdev) would resolve the problem.

I think that some work probably also needs to be done in user-space to make it
aware of how to handle l3 only packets on such vports.

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 906ae9c58c2e..7a06e19f5279 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -116,7 +116,7 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.create		= geneve_create,
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.get_options	= geneve_get_options,
-	.send		= ovs_netdev_send_tap,
+	.send		= ovs_netdev_send,
 };
 
 static int __init ovs_geneve_tnl_init(void)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index b1aa02904ae4..c1cab9dd392f 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -87,7 +87,7 @@ static struct vport *gre_create(const struct vport_parms *parms)
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.send		= ovs_netdev_send_raw_tun,
+	.send		= ovs_netdev_send,
 	.destroy	= ovs_netdev_tunnel_destroy,
 };
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index e6a2718204a8..0ffe07721336 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -197,25 +197,20 @@ void ovs_netdev_tunnel_destroy(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
 
-int ovs_netdev_send_tap(struct sk_buff *skb)
+int ovs_netdev_send(struct sk_buff *skb)
 {
-	/* Only send L2 packets */
-	if (skb->mac_len)
-		return dev_queue_xmit(skb);
+	struct net_device *dev = skb->dev;
 
-	kfree_skb(skb);
-	return -EINVAL;
-}
-EXPORT_SYMBOL_GPL(ovs_netdev_send_tap);
-
-int ovs_netdev_send_raw_tun(struct sk_buff *skb)
-{
-	if (skb->mac_len)
-		skb->protocol = ntohs(ETH_P_TEB);
+	if (dev->type != ARPHRD_ETHER && skb->mac_len) {
+		skb->protocol = htons(ETH_P_TEB);
+	} else if (dev->type == ARPHRD_ETHER && !skb->mac_len) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
 
 	return dev_queue_xmit(skb);
 }
-EXPORT_SYMBOL_GPL(ovs_netdev_send_raw_tun);
+EXPORT_SYMBOL_GPL(ovs_netdev_send);
 
 /* Returns null if this device is not attached to a datapath. */
 struct vport *ovs_netdev_get_vport(struct net_device *dev)
@@ -231,7 +226,7 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
-	.send		= ovs_netdev_send_tap,
+	.send		= ovs_netdev_send,
 };
 
 int __init ovs_netdev_init(void)
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index ae59c02ba6a9..637b14a9963c 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -34,6 +34,5 @@ void ovs_netdev_exit(void);
 
 void ovs_netdev_tunnel_destroy(struct vport *vport);
 
-int ovs_netdev_send_tap(struct sk_buff *skb);
-int ovs_netdev_send_raw_tun(struct sk_buff *skb);
+int ovs_netdev_send(struct sk_buff *skb);
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 009a4aab505a..13f11ad7e35a 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -153,7 +153,7 @@ static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.create			= vxlan_create,
 	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
-	.send			= ovs_netdev_send_tap,
+	.send			= ovs_netdev_send,
 };
 
 static int __init ovs_vxlan_tnl_init(void)
