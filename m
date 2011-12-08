From: Ted Feng <artisdom@gmail.com>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Thu, 8 Dec 2011 18:46:21 +0800
Message-ID: <20111208104619.GA20150@ted-OptiPlex-380>
References: <CAM7b5hzt8D6hn3=XEcm9E3_BwJxj-YABpkufCpuhjiPLDxCsMQ@mail.gmail.com>
 <20111206173220.GA28763@kroah.com>
 <CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
 <20111207.235602.1465915988125994516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, jwboyer@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111207.235602.1465915988125994516.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ted Feng <artisdom@gmail.com>

Same fix as 731abb9cb2 for ipip and sit tunnel.
Commit 1c5cae815d removed an explicit call to dev_alloc_name in
ipip_tunnel_locate and ipip6_tunnel_locate, because register_netdevice
will now create a valid name, however the tunnel keeps a copy of the
name in the private parms structure. Fix this by copying the name back
after register_netdevice has successfully returned.

This shows up if you do a simple tunnel add, followed by a tunnel show:

$ sudo ip tunnel add mode ipip remote 10.2.20.211
$ ip tunnel
tunl0: ip/ip  remote any  local any  ttl inherit  nopmtudisc
tunl%d: ip/ip  remote 10.2.20.211  local any  ttl inherit
$ sudo ip tunnel add mode sit remote 10.2.20.212
$ ip tunnel
sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc 6rd-prefix 2002::/16
sit%d: ioctl 89f8 failed: No such device
sit%d: ipv6/ip  remote 10.2.20.212  local any  ttl inherit

Cc: stable@vger.kernel.org
Signed-off-by: Ted Feng <artisdom@gmail.com>
---
 net/ipv4/ipip.c |    7 ++++++-
 net/ipv6/sit.c  |    7 ++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 065effd..0b2e732 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -285,6 +285,8 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 	if (register_netdevice(dev) < 0)
 		goto failed_free;
 
+	strcpy(nt->parms.name, dev->name);
+
 	dev_hold(dev);
 	ipip_tunnel_link(ipn, nt);
 	return nt;
@@ -759,7 +761,6 @@ static int ipip_tunnel_init(struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
 
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
@@ -825,6 +826,7 @@ static void ipip_destroy_tunnels(struct ipip_net *ipn, struct list_head *head)
 static int __net_init ipip_init_net(struct net *net)
 {
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
+	struct ip_tunnel *t;
 	int err;
 
 	ipn->tunnels[0] = ipn->tunnels_wc;
@@ -848,6 +850,9 @@ static int __net_init ipip_init_net(struct net *net)
 	if ((err = register_netdev(ipn->fb_tunnel_dev)))
 		goto err_reg_dev;
 
+	t = netdev_priv(ipn->fb_tunnel_dev);
+
+	strcpy(t->parms.name, ipn->fb_tunnel_dev->name);
 	return 0;
 
 err_reg_dev:
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a7a1860..96f3623 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -263,6 +263,8 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	if (register_netdevice(dev) < 0)
 		goto failed_free;
 
+	strcpy(nt->parms.name, dev->name);
+
 	dev_hold(dev);
 
 	ipip6_tunnel_link(sitn, nt);
@@ -1144,7 +1146,6 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
 
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
@@ -1207,6 +1208,7 @@ static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_hea
 static int __net_init sit_init_net(struct net *net)
 {
 	struct sit_net *sitn = net_generic(net, sit_net_id);
+	struct ip_tunnel *t;
 	int err;
 
 	sitn->tunnels[0] = sitn->tunnels_wc;
@@ -1231,6 +1233,9 @@ static int __net_init sit_init_net(struct net *net)
 	if ((err = register_netdev(sitn->fb_tunnel_dev)))
 		goto err_reg_dev;
 
+	t = netdev_priv(sitn->fb_tunnel_dev);
+
+	strcpy(t->parms.name, sitn->fb_tunnel_dev->name);
 	return 0;
 
 err_reg_dev:
