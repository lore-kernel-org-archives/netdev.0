From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch net-next] ipip: fix a regression in ioctl
Date: Sat, 29 Jun 2013 20:43:10 -0700
Message-ID: <CALnjE+qoo3D6YDpZogPq8LOJLZxoOTLa73WJFHnH2MbnFB2f7Q@mail.gmail.com>
References: <1372479115-7003-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:42028 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750798Ab3F3DnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 23:43:11 -0400
Received: by mail-qa0-f51.google.com with SMTP id f11so1285270qae.10
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 20:43:10 -0700 (PDT)
In-Reply-To: <1372479115-7003-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 9:11 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> This is a regression introduced by
> commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)
>
> Similar to GRE tunnel, previously we only check the parameters
> for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
> check is moved for all commands.
>
> So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
>
> Also, the check for i_key, o_key etc. is suspicious too,
> which did not exist before.
>
This check is sanity check since ipip is not suppose to have these
parameters set, generic layer do allow all parameters.
Earlier ipip was not using generic layer, therefore that check was not present.

> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> ---
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index e6905fb..9d6ca81 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -244,11 +244,11 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>         if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
>                 return -EFAULT;
>
> -       if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
> -                       p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
> -               return -EINVAL;
> -       if (p.i_key || p.o_key || p.i_flags || p.o_flags)
> -               return -EINVAL;
> +       if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
> +               if (p.iph.version != 4 || p.iph.protocol != IPPROTO_IPIP ||
> +                   p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)))
> +                       return -EINVAL;
> +       }
>         if (p.iph.ttl)
>                 p.iph.frag_off |= htons(IP_DF);
>
