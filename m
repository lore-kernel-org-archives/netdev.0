From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Wed, 29 Jan 2014 12:21:26 -0500
Message-ID: <CA+FuTSeZ=ZFz4NmYvWfkU9B_NjqpHrd9-NUDv3b+kheGC-5ruQ@mail.gmail.com>
References: <20140128205756.074448668@goodmis.org> <52E8E025.2060803@6wind.com>
 <20140129075745.4227a2ed@gandalf.local.home> <52E9267C.90403@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52E9267C.90403@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From d101450583c3a472a2a94904cfe13fd4e7d2f519 Mon Sep 17 00:00:00 2001
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Wed, 29 Jan 2014 16:40:30 +0100
> Subject: [PATCH] sit: fix double free of fb_tunnel_dev on exit
>
> This problem was fixed upstream by commit 9434266f2c64 ("sit: fix use after free
> of fb_tunnel_dev").
> The upstream patch depends on upstream commit 5e6700b3bf98 ("sit: add support of
> x-netns"), which was not backported into 3.10 branch.
>
> First, explain the problem: when the sit module is unloaded, sit_cleanup() is
> called.
> rmmod sit
> => sit_cleanup()
>   => rtnl_link_unregister()
>     => __rtnl_kill_links()
>       => for_each_netdev(net, dev) {
>         if (dev->rtnl_link_ops == ops)
>                 ops->dellink(dev, &list_kill);
>         }
> At this point, the FB device is deleted (and all sit tunnels).
>   => unregister_pernet_device()
>     => unregister_pernet_operations()
>       => ops_exit_list()
>         => sit_exit_net()
>           => sit_destroy_tunnels()
>           In this function, no tunnel is found.
>           => unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
> We delete the FB device a second time here!
>
> Because we cannot simply remove the second deletion (sit_exit_net() must remove
> the FB device when a netns is deleted), we add an rtnl ops which delete all sit
> device excepting the FB device and thus we can keep the explicit deletion in
> sit_exit_net().
>
> CC: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/sit.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 0491264b8bfc..620d326e8fdd 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -1507,6 +1507,15 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
>  #endif
>  };
>
> +static void ipip6_dellink(struct net_device *dev, struct list_head *head)
> +{
> +       struct net *net = dev_net(dev);
> +       struct sit_net *sitn = net_generic(net, sit_net_id);
> +
> +       if (dev != sitn->fb_tunnel_dev)
> +               unregister_netdevice_queue(dev, head);
> +}
> +
>  static struct rtnl_link_ops sit_link_ops __read_mostly = {
>         .kind           = "sit",
>         .maxtype        = IFLA_IPTUN_MAX,
> @@ -1517,6 +1526,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
>         .changelink     = ipip6_changelink,
>         .get_size       = ipip6_get_size,
>         .fill_info      = ipip6_fill_info,
> +       .dellink        = ipip6_dellink,
>  };
>
>  static struct xfrm_tunnel sit_handler __read_mostly = {
> --
> 1.8.4.1


This looks good to me. It is the same as the backport "sit: fix use
after free of fb_tunnel_dev" (9434266f2c64), minus the small code
cleanup at the end of that patch that is not relevant to 3.10.27 (do
not define sit_net *sitn in sit_exit_net if it is not used there. But in
3.10.27 it is used, in unregister_netdevice_queue).
