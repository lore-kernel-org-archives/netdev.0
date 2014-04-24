From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH net] bridge: Handle IFLA_ADDRESS correctly when creating
 bridge device
Date: Thu, 24 Apr 2014 18:04:12 +0200
Message-ID: <CAG-2HqUhT+vbZfugfTYGzWt_qu45sKMaWXQ0uNg8SPzYNmG_5A@mail.gmail.com>
References: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
 <CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
 <1398341177.4171.11.camel@ubuntu-vm-makita> <1398341787.4171.16.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	bridge <bridge@lists.linux-foundation.org>,
	"C. R. Oldham" <cr@saltstack.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:37190 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757542AbaDXQEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:04:33 -0400
Received: by mail-yh0-f46.google.com with SMTP id c41so1181412yho.33
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 09:04:33 -0700 (PDT)
In-Reply-To: <1398341787.4171.16.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 2:16 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> When bridge device is created with IFLA_ADDRESS, we are not calling
> br_stp_change_bridge_id(), which leads to incorrect local fdb
> management and bridge id calculation, and prevents us from receiving
> frames on the bridge device.
>
> Reported-by: Tom Gundersen <teg@jklm.no>

Thanks. That looks correct to me (not able to test at the moment
though). Would this be appropriate for stable if it goes in?

Cheers,

Tom

> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/bridge/br_netlink.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index e74b6d53..a8b664e 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -445,6 +445,25 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>         return 0;
>  }
>
> +static int br_dev_newlink(struct net *src_net, struct net_device *dev,
> +                         struct nlattr *tb[], struct nlattr *data[])
> +{
> +       int err;
> +       struct net_bridge *br = netdev_priv(dev);
> +
> +       if (tb[IFLA_ADDRESS]) {
> +               spin_lock_bh(&br->lock);
> +               br_stp_change_bridge_id(br, nla_data(tb[IFLA_ADDRESS]));
> +               spin_unlock_bh(&br->lock);
> +       }
> +
> +       err = register_netdevice(dev);
> +       if (err)
> +               return err;
> +
> +       return 0;
> +}
> +
>  static size_t br_get_link_af_size(const struct net_device *dev)
>  {
>         struct net_port_vlans *pv;
> @@ -473,6 +492,7 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
>         .priv_size      = sizeof(struct net_bridge),
>         .setup          = br_dev_setup,
>         .validate       = br_validate,
> +       .newlink        = br_dev_newlink,
>         .dellink        = br_dev_delete,
>  };
>
> --
> 1.8.1.2
>
>
