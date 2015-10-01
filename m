From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFT v3] geneve: implement support for IPv6-based tunnels
Date: Thu, 1 Oct 2015 09:26:59 -0700
Message-ID: <CAEP_g=9g=Bt09+Kf9CWaSuhPFhUVXcesW28ksq+8b5hQwzf6Vw@mail.gmail.com>
References: <1443632696-9900-1-git-send-email-linville@tuxdriver.com> <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33670 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbbJAQ1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 12:27:20 -0400
Received: by lahh2 with SMTP id h2so78132477lah.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 09:27:18 -0700 (PDT)
In-Reply-To: <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 11:34 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 8f5c02eed47d..291d3d7754a8 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> +#define GENEVE_F_IPV6          0x00000001

I wasn't sure why we needed this flag. Can't we just look at the
remote address family?

> -static void geneve_sock_release(struct geneve_sock *gs)
> +static void __geneve_sock_release(struct geneve_sock *gs)
>  {
>         if (--gs->refcnt)
>                 return;

Do we need a check for NULL first here?

> +#if IS_ENABLED(CONFIG_IPV6)
> +static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
> +                            __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
> +                            bool csum, bool xnet)
> +{
> +       struct genevehdr *gnvh;
> +       int min_headroom;
> +       int err;
> +
> +       skb_scrub_packet(skb, xnet);

Is there a reason why this applies to only IPv6? It seems like it
would be common

> +static struct dst_entry *geneve_get_dst(struct sk_buff *skb,

It might be worth clarifying this name - it wasn't immediately obvious
to me the difference between geneve_get_rt() and geneve_get_dst() is
IPv4 vs. IPv6.

> +#if IS_ENABLED(CONFIG_IPV6)
> +static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
> +                                   struct ip_tunnel_info *info)
[...]
> +       dst = geneve_get_dst(skb, dev, &fl6, info);
> +       if (IS_ERR(dst)) {
> +               netdev_dbg(dev, "no route to %pI6\n", &fl6.daddr);
> +               dev->stats.tx_carrier_errors++;
> +               goto tx_error;
> +       }

It looks like we double log/count this error (although this also
appears to be a problem for IPv4).

> +       err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
> +                                  &fl6.saddr, &fl6.daddr, 0, ttl,
> +                                  sport, geneve->dst_port, !udp_csum);

It seems like TOS is not handled here?

> @@ -823,9 +1095,11 @@ static int geneve_configure(struct net *net, struct net_device *dev,
>         int err;
>
>         if (metadata) {
> -               if (rem_addr || vni || tos || ttl)
> +               if (remote != &geneve_remote_unspec || vni || tos || ttl)
>                         return -EINVAL;

I think this will fail in the non-compat metadata case. The remote
that is passed in will be a zeroed copy on the stack, so the address
won't match the static version. I believe the check should be for
AF_UNSPEC instead.
