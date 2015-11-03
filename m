From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Resource leak in unshare
Date: Mon, 02 Nov 2015 17:08:19 -0800
Message-ID: <1446512899.23275.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
	 <87oafcrzsa.fsf@x220.int.ebiederm.org>
	 <1446494052.23275.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446508987.23275.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Vyukov <dvyukov@google.com>, nicolas.dichtel@6wind.com,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446508987.23275.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

sit0 device allocates its percpu storage twice :
- One time in ipip6_tunnel_init()
- One time in ipip6_fb_tunnel_init()

Thus we leak 48 bytes per possible cpu per network namespace dismantle.

ipip6_fb_tunnel_init() can be much simpler and does not
return an error, and should be called after register_netdev()

Note that ipip6_tunnel_clone_6rd() also needs to be called
after register_netdev() (calling ipip6_tunnel_init())

Fixes: ebe084aafb7e ("sit: Use ipip6_tunnel_init as the ndo_init function.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---

 net/ipv6/sit.c |   26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 94428fd85b2f..dcccae86190f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1394,34 +1394,20 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
+static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	tunnel->dev = dev;
-	tunnel->net = dev_net(dev);
-
 	iph->version		= 4;
 	iph->protocol		= IPPROTO_IPV6;
 	iph->ihl		= 5;
 	iph->ttl		= 64;
 
-	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
-	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
-	if (!tunnel->dst_cache) {
-		free_percpu(dev->tstats);
-		return -ENOMEM;
-	}
-
 	dev_hold(dev);
 	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
-	return 0;
 }
 
 static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1831,23 +1817,19 @@ static int __net_init sit_init_net(struct net *net)
 	 */
 	sitn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
 
-	err = ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
-	if (err)
-		goto err_dev_free;
-
-	ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
 	err = register_netdev(sitn->fb_tunnel_dev);
 	if (err)
 		goto err_reg_dev;
 
+	ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
+	ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
+
 	t = netdev_priv(sitn->fb_tunnel_dev);
 
 	strcpy(t->parms.name, sitn->fb_tunnel_dev->name);
 	return 0;
 
 err_reg_dev:
-	dev_put(sitn->fb_tunnel_dev);
-err_dev_free:
 	ipip6_dev_free(sitn->fb_tunnel_dev);
 err_alloc_dev:
 	return err;
