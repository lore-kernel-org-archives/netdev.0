From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Fri, 01 Jul 2011 15:18:23 -0700
Message-ID: <1309558703.7277.78.camel@Joe-Laptop>
References: <4E0D3E80.5080209@redhat.com>
	 <1309491349.7277.22.camel@Joe-Laptop> <4E0D43C3.5090502@redhat.com>
	 <20110701.000646.268663722441785795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110701.000646.268663722441785795.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-01 at 00:06 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> >>> BTW, you can kill the export of netpoll_send_skb_on_dev() too.
> >> Not too sure about that.
> >> It's used in netpoll.h by netpoll_send_skb.
> >> It could be called from anywhere.
> >> It's currently called/used by bonding.h.
> > % git grep netpoll_send_skb_on_dev .
[]
> > No modules use it...
> Right, this is a relic that bonding was using at one point
> in the past but it no longer does.

Are you sure?

netpoll.h:

void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
			     struct net_device *dev);
static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
{
	netpoll_send_skb_on_dev(np, skb, np->dev);
}

$ grep -rP --include=*.[ch] -w netpoll_send_skb *
drivers/net/bonding/bonding.h:		netpoll_send_skb(np, skb);
include/linux/netpoll.h:static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
net/bridge/br_private.h:		netpoll_send_skb(np, skb);
net/core/netpoll.c:			"netpoll_send_skb(): %s enabled interrupts in poll (%pF)\n",
net/core/netpoll.c:	netpoll_send_skb(np, skb);
net/core/netpoll.c:		netpoll_send_skb(np, send_skb);

from bonding.h

#ifdef CONFIG_NET_POLL_CONTROLLER
static inline void bond_netpoll_send_skb(const struct slave *slave,
					 struct sk_buff *skb)
{
	struct netpoll *np = slave->np;

	if (np)
		netpoll_send_skb(np, skb);
}

and br_private.h

static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
				       struct sk_buff *skb)
{
	struct netpoll *np = p->np;

	if (np)
		netpoll_send_skb(np, skb);
}

These are inlined and dependent on CONFIG_NET_POLL_CONTROLLER
in drivers/net/Kconfig so doesn't netpoll_send_skb_on_dev need
to be SYMBOL_EXPORTed?

cheers, Joe
