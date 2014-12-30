From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] tunnel: support propagating lower device state
Date: Tue, 30 Dec 2014 12:33:41 -0800
Message-ID: <CAHA+R7OTFAc=1D=WRxLNuqScBJ+wD-wc-qxtNaFxSji_kRi1PA@mail.gmail.com>
References: <20141227095950.20a062d2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:46497 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbaL3Udl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 15:33:41 -0500
Received: by mail-qa0-f43.google.com with SMTP id n4so7353025qaq.16
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 12:33:41 -0800 (PST)
In-Reply-To: <20141227095950.20a062d2@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 27, 2014 at 9:59 AM, Stephen Hemminger <shemming@brocade.com> wrote:
> @@ -982,8 +1045,17 @@ int ip_tunnel_init_net(struct net *net,
>         for (i = 0; i < IP_TNL_HASH_SIZE; i++)
>                 INIT_HLIST_HEAD(&itn->tunnels[i]);
>
> +       itn->lower_dev = kcalloc(NETDEV_HASHENTRIES, sizeof(struct hlist_head),
> +                                GFP_KERNEL);
> +       if (!itn->lower_dev) {
> +               kfree(itn->tunnels);
> +               return -ENOMEM;
> +       }
> +
>         if (!ops) {
>                 itn->fb_tunnel_dev = NULL;
> +               kfree(itn->tunnels);
> +               kfree(itn->lower_dev);
>                 return 0;
>         }
>
> @@ -1003,7 +1075,12 @@ int ip_tunnel_init_net(struct net *net,
>         }
>         rtnl_unlock();
>
> -       return PTR_ERR_OR_ZERO(itn->fb_tunnel_dev);
> +       if (IS_ERR(itn->fb_tunnel_dev)) {
> +               kfree(itn->tunnels);
> +               return PTR_ERR(itn->fb_tunnel_dev);
> +       }
> +       return 0;
> +
>  }

Are you sure we really need to free itn->tunnels on
failure path? It is not allocated inside ip_tunnel_init_net()
anyway.
