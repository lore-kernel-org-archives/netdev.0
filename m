From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Wed, 19 Nov 2014 15:44:34 +0800
Message-ID: <CADvbK_cRRhNN23Cf-3Ar+aiheb+5tBWv2R0ooQe6t1mb=Xei0Q@mail.gmail.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
	<546B8093.4080507@6wind.com>
	<CAHA+R7NjO+bDhN5QX95d8V0VqvbacxCzoHWT5NpDaDn3YCtCeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	network dev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34961 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771AbaKSHog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 02:44:36 -0500
Received: by mail-wg0-f48.google.com with SMTP id y19so63663wgg.7
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 23:44:34 -0800 (PST)
In-Reply-To: <CAHA+R7NjO+bDhN5QX95d8V0VqvbacxCzoHWT5NpDaDn3YCtCeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 7:25 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Tue, Nov 18, 2014 at 9:23 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>>
>> A quick look at the ipv6 side seems to show that there is the same problem.
>> Can
>> you provide the IPv6 patch too?
>>
>
> IPv6 doesn't use ip_tunnel library, so needs to provide its own implementation:
>
> diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
> index ec84d03..3ae094b 100644
> --- a/net/ipv6/ip6_vti.c
> +++ b/net/ipv6/ip6_vti.c
> @@ -911,6 +911,16 @@ static int vti6_newlink(struct net *src_net,
> struct net_device *dev,
>         return vti6_tnl_create2(dev);
>  }
>
> +static void vti6_dellink(struct net_device *dev, struct list_head *head)
> +{
> +       struct net *net = dev_net(dev);
> +       struct vti6_net *ip6n = net_generic(net, vti6_net_id);
> +
> +       if (dev != ip6n->fb_tnl_dev)
> +               unregister_netdevice_queue(dev, head);
> +}
> +
> +
>  static int vti6_changelink(struct net_device *dev, struct nlattr *tb[],
>                            struct nlattr *data[])
>  {
> @@ -986,6 +996,7 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
>         .setup          = vti6_dev_setup,
>         .validate       = vti6_validate,
>         .newlink        = vti6_newlink,
> +       .dellink        = vti6_dellink,
>         .changelink     = vti6_changelink,
>         .get_size       = vti6_get_size,
>         .fill_info      = vti6_fill_info,

the issue do not exist in ip6_vti. cause vti6_init_net() complete the
device ip6_vti0 initialization,
 in which dev->rtnl_link_ops never be pointed.  so the ip6_vti0's
rtnl_link_ops is null, which lead
 to the  dellink() will never be invoked in rtnl_dellink():

        if (!ops || !ops->dellink)
                return -EOPNOTSUPP;

        ops->dellink(dev, &list_kill);
        unregister_netdevice_many(&list_kill);

instead, "ip link del ip6_vti0" wil return:
RTNETLINK answers: Operation not supported

if this patch for ip6 is to be consistent with ipv4 vti. I suggest we
should also add the below code
to init ip6_vti0's rtnl_link_ops when the ip6_vti0 is inited:
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 31089d1..e68c099 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1020,6 +1020,7 @@ static int __net_init vti6_init_net(struct net *net)
        if (!ip6n->fb_tnl_dev)
                goto err_alloc_dev;
        dev_net_set(ip6n->fb_tnl_dev, net);
+       ip6n->fb_tnl_dev->rtnl_link_ops = &vti6_link_ops;

        err = vti6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
        if (err < 0)
