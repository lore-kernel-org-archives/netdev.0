From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v4 1/2] geneve: implement support for IPv6-based tunnels
Date: Wed, 21 Oct 2015 13:06:18 +0800
Message-ID: <CAEP_g=9pXGiDgZ9Y-2ZY+VjSRYP2wXQ=qv_iryMyq25OqF_k4g@mail.gmail.com>
References: <1443638045-27229-1-git-send-email-linville@tuxdriver.com> <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:32854 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbbJUFGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 01:06:39 -0400
Received: by lffv3 with SMTP id v3so15486779lff.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 22:06:38 -0700 (PDT)
In-Reply-To: <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of this looks pretty good to me, I just have a few last things
that I noticed:

On Tue, Oct 20, 2015 at 11:11 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 8f5c02eed47d..217b472ab9e7 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
>  /* Pseudo network device */
>  struct geneve_dev {
>         struct hlist_node  hlist;       /* vni hash table */
>         struct net         *net;        /* netns for packet i/o */
>         struct net_device  *dev;        /* netdev for geneve tunnel */
> -       struct geneve_sock *sock;       /* socket used for geneve tunnel */
> +       struct geneve_sock *sock4;      /* IPv4 socket used for geneve tunnel */
> +       struct geneve_sock *sock6;      /* IPv6 socket used for geneve tunnel */

It might be worth wrapping sock6 in #if IS_ENABLED(CONFIG_IPV6). Not
because I'm trying to save space but because we make initializing it
conditional on this, so it would catch if somebody tries to access it
uninitialized.

> +static int geneve_open(struct net_device *dev)
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +       bool ipv6 = geneve->remote.sa.sa_family == AF_INET6;
> +       bool metadata = !!geneve->collect_md;

A small thing but geneve->collect_md is also a bool, so I guess we
probably don't need the !!.

> +#if IS_ENABLED(CONFIG_IPV6)
> +static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
> +                            __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
> +                            bool csum, bool xnet)
> +{
[...]
> +       skb_scrub_packet(skb, xnet);

I realized that I wasn't really all that clear with my previous
comment here. I was just asking if we should also use
skb_scrub_packet() in the IPv4 to keep things consistent. I agree that
the rt/dst differences makes sharing code a bit difficult in the
general sense.

> +static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
> +                                   struct ip_tunnel_info *info)
[...]
> +       if (geneve->collect_md) {
> +               if (unlikely(info && !(info->mode & IP_TUNNEL_INFO_TX))) {
> +                       netdev_dbg(dev, "no tunnel metadata\n");
> +                       goto tx_error;

It seems like this should also be checking for !info here - that's
perhaps the main cause of not having any tunnel metadata. This is the
same with IPv4 though too.

> @@ -870,14 +1139,29 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
> -       if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
> +       if (!data[IFLA_GENEVE_ID] ||
> +           (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6]) ||
> +           (!data[IFLA_GENEVE_REMOTE] && !data[IFLA_GENEVE_REMOTE6]))
>                 return -EINVAL;

I think this will conflict with/revert my change in -net. Obviously,
the conflict will need to be resolved at some point, but it's probably
just best to remove the whole block here so the resolution is obvious.
