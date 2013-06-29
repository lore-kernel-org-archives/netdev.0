From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch net-next v2] gre: fix a regression in ioctl
Date: Fri, 28 Jun 2013 20:28:53 -0700
Message-ID: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
References: <1372471480-28992-1-git-send-email-amwang@redhat.com>
	<1372472672-1900-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:44514 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753428Ab3F2D2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 23:28:54 -0400
Received: by mail-qe0-f44.google.com with SMTP id 5so964376qeb.3
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 20:28:53 -0700 (PDT)
In-Reply-To: <1372472672-1900-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 7:24 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> When testing GRE tunnel, I got:
>
>  # ip tunnel show
>  get tunnel gre0 failed: Invalid argument
>  get tunnel gre1 failed: Invalid argument
>
> This is a regression introduced by commit c54419321455631079c7d
> ("GRE: Refactor GRE tunneling code.") because previously we
> only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
> after that commit, the check is moved for all commands.
>

right, that API got changed. But these checks can not be added to
generic ip_tunnel layer, which is also used by other tunnel modules.
Can you keep that check in ip_gre module but do it only for add and
del tunnel commands?

> So, just move it back inside SIOCADDTUNNEL and SIOCCHGTUNNEL.
>
> After this patch I got:
>
>  # ip tunnel show
>  gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
>  gre1: gre/ip  remote 192.168.122.101  local 192.168.122.45  ttl inherit
>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> v2: check TUNNEL_* flags
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index c326e86..354d78c 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -314,11 +314,6 @@ static int ipgre_tunnel_ioctl(struct net_device *dev,
>
>         if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
>                 return -EFAULT;
> -       if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
> -           p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
> -           ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING))) {
> -               return -EINVAL;
> -       }
>         p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
>         p.o_flags = gre_flags_to_tnl_flags(p.o_flags);
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 394cebc..dc7d7ac 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -712,6 +712,11 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
>
>         case SIOCADDTUNNEL:
>         case SIOCCHGTUNNEL:
> +               if (p->iph.version != 4 || p->iph.protocol != IPPROTO_GRE ||
> +                   p->iph.ihl != 5 || (p->iph.frag_off&htons(~IP_DF)) ||
> +                   ((p->i_flags|p->o_flags)&(TUNNEL_VERSION|TUNNEL_ROUTING)))
> +                       return -EINVAL;
> +
>                 err = -EPERM;
>                 if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
>                         goto done;
