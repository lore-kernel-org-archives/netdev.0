From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Fri, 22 Apr 2005 09:22:21 +1000
Message-ID: <20050422092221.4950e23c@localhost.localdomain>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
	<4252EB9D.9070305@trash.net>
	<20050407120417.4297cd14@dxpl.pdx.osdl.net>
	<42628300.9010007@trash.net>
	<20050419110639.47767113@localhost.localdomain>
	<42666098.5060409@trash.net>
	<20050421132020.41858bc4@localhost.localdomain>
	<426832E1.7020003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <426832E1.7020003@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 01:10:25 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > So duplication is a no go...
> > Unless there is a different way of accounting for qlen (like a callback).
> 
> Instead of a callback you could store parent pointers in struct Qdisc
> and walk up the tree. One place that would need additional changes to
> cope with qlen changes of more than 1 is HFSC. It uses q.qlen == 1 as
> indication that a leaf qdisc was activated by the last enqueue
> operation. An increment of 2 when q.qlen was 0 before would cause HFSC
> to forget to activate a class.

I'm thinking of changing enqueue (and maybe later dequeue) API to decouple
the qlen assumption.

Either:
	rc = qdisc->enqueue(skb, qdisc, &my->qlen)
or add NET_XMIT_DUPPED
	rc = qdisc->enqueue(skb, qdisc);
	if (rc < NET_XMIT_SUCCESS) {
		++my->dropped;
	} else {
		my->qlen++;
		if (rc == NET_XMIT_DUPPED)
			my->qlen++;
}
