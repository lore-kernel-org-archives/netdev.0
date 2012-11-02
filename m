From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: switching network namespace midway
Date: Thu, 1 Nov 2012 22:25:43 -0400
Message-ID: <20121102022542.GD18091@kvack.org>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com> <878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org> <CAFaHj6Ey4vzXskvsKB_dG4fKGsn4X5oCF3N0YpGskiSaXrGSOw@mail.gmail.com> <20121025155927.GI15034@kvack.org> <87a9var0ih.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	rsa <ravi.mlists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:41542 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762605Ab2KBCZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 22:25:44 -0400
Content-Disposition: inline
In-Reply-To: <87a9var0ih.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 09:15:34AM -0700, Eric W. Biederman wrote:
> > I've read IPv4 gre code, and it appears to do the right thing on rx, but it 
> > does *not* appear to handle namespaces correctly on transmit.  In general, 
> > I would expect pretty much all code to get namespace handling correct for 
> > the rx case.  I'll have a closer look at fixing this tomorrow if nobody else 
> > beats me to it.
> 
> It will be interesting to see what you come up with. 

Well, I finally had some time to work on the ip_gre module a bit today, 
and here's what I came up with.  The basic idea is to store the network 
namespace in the ip_tunnel structure at creation time for use in sending 
and receiving packets, allowing the gre network device to be safely moved 
into another network namespace.  This works for me in moving a gre tunnel 
into an lxc container, and survives module unload and namespace 
destruction.  I'll try to spend a bit more time adding similar support to 
the other ip_tunnel devices over the next few days.  Comments/thoughts?

		-ben
-- 
"Thought is the essence of where you are now."


diff --git a/include/net/ipip.h b/include/net/ipip.h
index ddc077c..9cfba92 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -19,6 +19,7 @@ struct ip_tunnel_6rd_parm {
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct net_device	*dev;
+	struct net		*net;		/* Namespace for packet i/o */
 
 	int			err_count;	/* Number of arrived ICMP errors */
 	unsigned long		err_time;	/* Time when the last ICMP error arrived */
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7240f8e..705dc66 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -461,6 +461,7 @@ static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
 	dev_net_set(dev, net);
 
 	nt = netdev_priv(dev);
+	nt->net = net;
 	nt->parms = *parms;
 	dev->rtnl_link_ops = &ipgre_link_ops;
 
@@ -484,8 +485,10 @@ failed_free:
 
 static void ipgre_tunnel_uninit(struct net_device *dev)
 {
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ipgre_net *ign;
+
+	ign = net_generic(tunnel->net, ipgre_net_id);
 
 	ipgre_tunnel_unlink(ign, netdev_priv(dev));
 	dev_put(dev);
@@ -837,7 +840,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tos = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
 	}
 
-	rt = ip_route_output_gre(dev_net(dev), &fl4, dst, tiph->saddr,
+	rt = ip_route_output_gre(tunnel->net, &fl4, dst, tiph->saddr,
 				 tunnel->parms.o_key, RT_TOS(tos),
 				 tunnel->parms.link);
 	if (IS_ERR(rt)) {
@@ -1010,7 +1013,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 		struct flowi4 fl4;
 		struct rtable *rt;
 
-		rt = ip_route_output_gre(dev_net(dev), &fl4,
+		rt = ip_route_output_gre(tunnel->net, &fl4,
 					 iph->daddr, iph->saddr,
 					 tunnel->parms.o_key,
 					 RT_TOS(iph->tos),
@@ -1341,7 +1344,6 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 
 	dev->features		|= GRE_FEATURES;
@@ -1432,6 +1434,7 @@ static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
 static int __net_init ipgre_init_net(struct net *net)
 {
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	struct ip_tunnel *tunnel;
 	int err;
 
 	ign->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "gre0",
@@ -1445,6 +1448,9 @@ static int __net_init ipgre_init_net(struct net *net)
 	ipgre_fb_tunnel_init(ign->fb_tunnel_dev);
 	ign->fb_tunnel_dev->rtnl_link_ops = &ipgre_link_ops;
 
+	tunnel = netdev_priv(ign->fb_tunnel_dev);
+	tunnel->net = net;
+
 	if ((err = register_netdev(ign->fb_tunnel_dev)))
 		goto err_reg_dev;
 
