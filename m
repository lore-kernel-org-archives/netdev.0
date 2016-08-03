From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: net: vrf: Handle ipv6 multicast and link-local addresses
Date: Wed, 3 Aug 2016 21:57:27 +0200
Message-ID: <CAMuHMdU6zpowkWgUW0+8Fhx7BmwTn=FvVBoTKXUgNzLeBpFrHg@mail.gmail.com>
References: <20160727215224.EB4E26611D4@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160727215224.EB4E26611D4@gitolite.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2016 at 11:52 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/9ff74384600aeecba34ebdacbbde0627489ff601
> Commit:     9ff74384600aeecba34ebdacbbde0627489ff601
> Parent:     ba46ee4c0ed122fa14aa2f5d6994c166a01ae2c0
> Refname:    refs/heads/master
> Author:     David Ahern <dsa@cumulusnetworks.com>
> AuthorDate: Mon Jun 13 13:44:19 2016 -0700
> Committer:  David S. Miller <davem@davemloft.net>
> CommitDate: Wed Jun 15 12:34:34 2016 -0700
>
>     net: vrf: Handle ipv6 multicast and link-local addresses
>
>     IPv6 multicast and link-local addresses require special handling by the
>     VRF driver:
>     1. Rather than using the VRF device index and full FIB lookups,
>        packets to/from these addresses should use direct FIB lookups based on
>        the VRF device table.
>
>     2. fail sends/receives on a VRF device to/from a multicast address
>        (e.g, make ping6 ff02::1%<vrf> fail)
>
>     3. move the setting of the flow oif to the first dst lookup and revert
>        the change in icmpv6_echo_reply made in ca254490c8dfd ("net: Add VRF
>        support to IPv6 stack"). Linklocal/mcast addresses require use of the
>        skb->dev.
>
>     With this change connections into and out of a VRF enslaved device work
>     for multicast and link-local addresses work (icmp, tcp, and udp)
>     e.g.,
>
>     1. packets into VM with VRF config:
>         ping6 -c3 fe80::e0:f9ff:fe1c:b974%br1
>         ping6 -c3 ff02::1%br1
>
>         ssh -6 fe80::e0:f9ff:fe1c:b974%br1
>
>     2. packets going out a VRF enslaved device:
>         ping6 -c3 fe80::18f8:83ff:fe4b:7a2e%eth1
>         ping6 -c3 ff02::1%eth1
>         ssh -6 root@fe80::18f8:83ff:fe4b:7a2e%eth1
>
>     Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/vrf.c       | 98 ++++++++++++++++++++++++++++++++++++++++++++++---
>  include/net/ip6_route.h |  2 +
>  net/ipv6/icmp.c         |  2 +-
>  net/ipv6/route.c        |  5 ++-
>  4 files changed, 99 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index d2ce76c..0b5b3c2 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -785,9 +785,63 @@ out:
>         return rc;
>  }
>
> +static struct rt6_info *vrf_ip6_route_lookup(struct net *net,
> +                                            const struct net_device *dev,
> +                                            struct flowi6 *fl6,
> +                                            int ifindex,
> +                                            int flags)
> +{
> +       struct net_vrf *vrf = netdev_priv(dev);
> +       struct fib6_table *table = NULL;
> +       struct rt6_info *rt6;
> +
> +       rcu_read_lock();
> +
> +       /* fib6_table does not have a refcnt and can not be freed */
> +       rt6 = rcu_dereference(vrf->rt6);
> +       if (likely(rt6))
> +               table = rt6->rt6i_table;
> +
> +       rcu_read_unlock();
> +
> +       if (!table)
> +               return NULL;
> +
> +       return ip6_pol_route(net, table, ifindex, fl6, flags);
> +}
> +
> +static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
> +                             int ifindex)
> +{
> +       const struct ipv6hdr *iph = ipv6_hdr(skb);
> +       struct flowi6 fl6 = {
> +               .daddr          = iph->daddr,
> +               .saddr          = iph->saddr,
> +               .flowlabel      = ip6_flowinfo(iph),

The above assignment causes the following compiler warning with
m68k-linux-gnu-gcc-4.1:

    drivers/net/vrf.c: In function ‘vrf_ip6_input_dst’:
    drivers/net/vrf.c:870: warning: initialized field with
side-effects overwritten
    drivers/net/vrf.c:870: warning: (near initialization for ‘fl6’)

Unfortunately I have no idea what it means, nor do I see what's wrong
with the code.

> +               .flowi6_mark    = skb->mark,
> +               .flowi6_proto   = iph->nexthdr,
> +               .flowi6_iif     = ifindex,
> +       };

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
