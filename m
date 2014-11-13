From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Thu, 13 Nov 2014 15:25:02 -0800
Message-ID: <CAADnVQJn4+0pCOeSu3oT0fvaJ=CtvD3wmczm4Jn6KjWgZoFrLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:43436 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934023AbaKMXZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 18:25:03 -0500
Received: by mail-qg0-f51.google.com with SMTP id j5so11012069qga.38
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 15:25:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 2:29 PM, Mahesh Bandewar <maheshb@google.com> wrote:
> The device operates in two different modes and the difference
> in these two modes in primarily in the TX side.
>
> (a) L2 mode : In this mode, the device behaves as a L2 device.
> TX processing upto L2 happens on the stack of the virtual device
> associated with (namespace). Packets are switched after that
> into the main device (default-ns) and queued for xmit.
>
> RX processing is simple and all multicast, broadcast (if
> applicable), and unicast belonging to the address(es) are
> delivered to the virtual devices.
>
> (b) L3 mode : In this mode, the device behaves like a L3 device.
> TX processing upto L3 happens on the stack of the virtual device
> associated with (namespace). Packets are switched to the
> main-device (default-ns) for the L2 processing. Hence the routing
> table of the default-ns will be used in this mode.
>
> RX processins is somewhat similar to the L2 mode except that in
> this mode only Unicast packets are delivered to the virtual device
> while main-dev will handle all other packets.

great stuff. would be interesting to see a 'typical use'
scenario of l2 vs l3 mode. Why users would pick one
or another?
I can only think of different default ip in different ns
would force l2. Anything else?

Few comments:

> +++ b/drivers/net/ipvlan/ipvlan.h
...
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/errno.h>
> +#include <linux/slab.h>
> +#include <linux/string.h>
> +#include <linux/rculist.h>
> +#include <linux/notifier.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_link.h>
> +#include <linux/atomic.h>
> +#include <linux/if_vlan.h>
> +#include <linux/inet.h>
> +#include <linux/hash.h>
> +#include <linux/ip.h>
> +#include <linux/inetdevice.h>
> +#include <net/rtnetlink.h>
> +#include <net/gre.h>
> +#include <net/route.h>
> +#include <net/addrconf.h>

I don't think it's a good style to put all headers that all
.c need into common .h
Rather put them into individual .c

> +static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
> +{
> +       void *lyr3h = NULL;
> +
> +       switch (skb->protocol) {
> +       case htons(ETH_P_ARP): {
> +               struct arphdr *arph;
> +
> +               if (unlikely(!pskb_may_pull(skb, sizeof(struct arphdr))))
> +                       return NULL;
> +
> +               arph = arp_hdr(skb);
> +               *type = IPVL_ARP;
> +               lyr3h = arph;
> +               break;
> +       }
...

> +static struct ipvl_addr *ipvlan_addr_lookup(struct ipvl_port *port,
> +                                           void *lyr3h, int addr_type,
> +                                           bool use_dest)
> +{
> +       struct ipvl_addr *addr = NULL;
> +
> +       if (addr_type == IPVL_IPV6) {
> +               struct ipv6hdr *ip6h = NULL;
> +               struct in6_addr *i6addr;
> +
> +               ip6h = (struct ipv6hdr *)lyr3h;
> +               i6addr = use_dest ? &ip6h->daddr : &ip6h->saddr;
> +               addr = ipvlan_ht_addr_lookup(port, i6addr, true);

imo it looks very artificial to split logically single
lookup function into two: get() that returns 'type'/
'void * lyr3h' and lookup() that uses them.
It feels error prone.
Also everywhere lookup() follows get() immediately.
I think single lookup() would be much cleaner.
