From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: NULL pointer dereference when loading the gre module
 (3.10.0-rc4)
Date: Fri, 07 Jun 2013 11:15:00 -0400
Message-ID: <1370618100.9844.73.camel@gandalf.local.home>
References: <20130606221656.GA11475@uio.no>
	 <20130607030648.GA28618@home.goodmis.org> <20130607085421.GF15083@uio.no>
	 <1370612441.24311.411.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370612441.24311.411.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-07 at 06:40 -0700, Eric Dumazet wrote:
> On Fri, 2013-06-07 at 10:54 +0200, Steinar H. Gunderson wrote:
> > On Thu, Jun 06, 2013 at 11:06:48PM -0400, Steven Rostedt wrote:
> > > Note the faulting address is 0xffffffffa0e52001, which is around the
> > > above address, be interesting to know what was at that location.
> > 
> > Doh, I looked at the wrong place in kallsyms:
> > 
> > ffffffffa0e52000 u ip_tunnel_init_net   [ip_gre]
> > ffffffffa0e55000 t gre_err      [gre]
> > ffffffffa0e5503d t gre_gso_send_check   [gre]
> > ffffffffa0e55053 t gre_rcv      [gre]
> > 
> > So it's really ip_tunnel_init_net+1.
> > 
> > /* Steinar */
> 
> " u " for ip_tunnel_init_net ?
> 
> Looks like someone forgot taking refcounts on a module ...
> 
> CC Pravin B Shelar, as this probably comes from commit
> c54419321455631079c7d6e60bc732dd0c5914c5
> ("GRE: Refactor GRE tunneling code.")

int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
				  struct rtnl_link_ops *ops, char *devname)
{

[...]

}
EXPORT_SYMBOL_GPL(ip_tunnel_init_net);

Really, you exported a symbol that can go away if CONFIG_NET_NS is not
set?

----
net: Remove __net_init/exit from exported functions

If CONFIG_NET_NS is not set then __net_init is the same as __init and
__net_exit is the same as __exit. These functions will be removed from
memory after the module loads or is removed. Functions that are exported
for use by other functions should never be labeled for removal.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e4147ec..850b5b5 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -853,8 +853,8 @@ void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_dellink);
 
-int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
-				  struct rtnl_link_ops *ops, char *devname)
+int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+		       struct rtnl_link_ops *ops, char *devname)
 {
 	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
 	struct ip_tunnel_parm parms;
@@ -899,7 +899,7 @@ static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head)
 		unregister_netdevice_queue(itn->fb_tunnel_dev, head);
 }
 
-void __net_exit ip_tunnel_delete_net(struct ip_tunnel_net *itn)
+void ip_tunnel_delete_net(struct ip_tunnel_net *itn)
 {
 	LIST_HEAD(list);
 
