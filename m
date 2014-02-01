From: Tommi Rantala <tt.rantala@gmail.com>
Subject: Re: BUG ip_dst_cache (Not tainted): Poison overwritten
Date: Sat, 1 Feb 2014 22:29:52 +0200
Message-ID: <CA+ydwtpmFbhkck9z8G7tfHQZW+4rWSepQMgPURqVCwrZ77v2bA@mail.gmail.com>
References: <CA+ydwtrWCgi=v7v=8yjNMV37Aa4ua9zbqYM5_uUdQrLSQt+VEw@mail.gmail.com>
	<1391201873.28432.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	trinity@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:48498 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140AbaBAU3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 15:29:53 -0500
In-Reply-To: <1391201873.28432.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-31 Eric Dumazet <eric.dumazet@gmail.com>:
> On Fri, 2014-01-31 at 22:11 +0200, Tommi Rantala wrote:
>> Hello,
>>
>> Hit this while fuzzing v3.13-9218-g0e47c96 with trinity in a qemu
>> virtual machine.
>>
>> Tommi
>
> Hi Tommi
>
> Could you please try the following fix ?

Thanks, giving this a spin. This does not reproduce very easily with
Trinity, I'll let you know if anything blows up.

Tommi

> I'll send an official patch in a couple of hours
>
> There are two bugs :
> One dst leak, and one plain bug, as rt initial NULL
> value might be scratched.
>
>  net/ipv4/ip_tunnel.c |   27 ++++++++++-----------------
>  1 file changed, 10 insertions(+), 17 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index bd28f386bd02..bc6acdcb7625 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -101,27 +101,21 @@ static void tunnel_dst_reset_all(struct ip_tunnel *t)
>                 __tunnel_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
>  }
>
> -static struct dst_entry *tunnel_dst_get(struct ip_tunnel *t)
> +static struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
>  {
>         struct dst_entry *dst;
>
>         rcu_read_lock();
>         dst = rcu_dereference(this_cpu_ptr(t->dst_cache)->dst);
> -       if (dst)
> +       if (dst) {
> +               if (dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
> +                       rcu_read_unlock();
> +                       tunnel_dst_reset(t);
> +                       return NULL;
> +               }
>                 dst_hold(dst);
> -       rcu_read_unlock();
> -       return dst;
> -}
> -
> -static struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
> -{
> -       struct dst_entry *dst = tunnel_dst_get(t);
> -
> -       if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
> -               tunnel_dst_reset(t);
> -               return NULL;
>         }
> -
> +       rcu_read_unlock();
>         return dst;
>  }
>
> @@ -584,7 +578,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
>         struct flowi4 fl4;
>         u8     tos, ttl;
>         __be16 df;
> -       struct rtable *rt = NULL;       /* Route to the other host */
> +       struct rtable *rt;              /* Route to the other host */
>         unsigned int max_headroom;      /* The extra header space needed */
>         __be32 dst;
>         int err;
> @@ -657,8 +651,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
>         init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
>                          tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
>
> -       if (connected)
> -               rt = (struct rtable *)tunnel_dst_check(tunnel, 0);
> +       rt = (connected) ? (struct rtable *)tunnel_dst_check(tunnel, 0) : NULL;
>
>         if (!rt) {
>                 rt = ip_route_output_key(tunnel->net, &fl4);
>
>
