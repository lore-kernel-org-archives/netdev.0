From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference when loading the gre module
 (3.10.0-rc4)
Date: Fri, 07 Jun 2013 13:26:05 -0700
Message-ID: <1370636765.24311.440.camel@edumazet-glaptop>
References: <20130607030648.GA28618@home.goodmis.org>
	 <20130607085421.GF15083@uio.no>
	 <1370612441.24311.411.camel@edumazet-glaptop>
	 <1370618100.9844.73.camel@gandalf.local.home>
	 <20130607154634.GA7529@uio.no>
	 <1370621543.9844.78.camel@gandalf.local.home>
	 <20130607175233.GA20230@uio.no>
	 <1370629568.9844.87.camel@gandalf.local.home>
	 <20130607183438.GA23064@uio.no>
	 <1370630659.9844.89.camel@gandalf.local.home>
	 <20130607184622.GA24906@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130607184622.GA24906@uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 20:46 +0200, Steinar H. Gunderson wrote:
> On Fri, Jun 07, 2013 at 02:44:19PM -0400, Steven Rostedt wrote:
> > Do know if you have CONFIG_NET_NS set in your .config?
> 
> Sorry, I forgot to answer this: No, it is not set.

OK please try the following patch, Steven forgot to update the include
file as well.

I tried this patch and it solved the problem for me.

Thanks


[PATCH] ip_tunnel: remove __net_init/exit from exported functions

If CONFIG_NET_NS is not set then __net_init is the same as __init and
__net_exit is the same as __exit. These functions will be removed from
memory after the module loads or is removed. Functions that are exported
for use by other functions should never be labeled for removal.

Bug introduced by commit c54419321455631079c
("GRE: Refactor GRE tunneling code.")

Reported-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip_tunnels.h |    6 +++---
 net/ipv4/ip_tunnel.c     |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 40b4dfc..1be442f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -95,10 +95,10 @@ struct ip_tunnel_net {
 int ip_tunnel_init(struct net_device *dev);
 void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
-int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
-				  struct rtnl_link_ops *ops, char *devname);
+int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+		       struct rtnl_link_ops *ops, char *devname);
 
-void __net_exit ip_tunnel_delete_net(struct ip_tunnel_net *itn);
+void ip_tunnel_delete_net(struct ip_tunnel_net *itn);
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 7c79cf8..e189db4 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -853,7 +853,7 @@ void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_dellink);
 
-int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 				  struct rtnl_link_ops *ops, char *devname)
 {
 	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
@@ -899,7 +899,7 @@ static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head)
 		unregister_netdevice_queue(itn->fb_tunnel_dev, head);
 }
 
-void __net_exit ip_tunnel_delete_net(struct ip_tunnel_net *itn)
+void ip_tunnel_delete_net(struct ip_tunnel_net *itn)
 {
 	LIST_HEAD(list);
 
