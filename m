From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 07:34:35 -0800
Message-ID: <20080226073435.1765de3e@extreme>
References: <20080226073538.GA4101@ff.dom.local>
	<47C3E2EC.1020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Li Yewang <lyw@cn.fujitsu.com>, davem@davemloft.net,
	swhiteho@redhat.com, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56566 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497AbYBZPel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 10:34:41 -0500
In-Reply-To: <47C3E2EC.1020402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Feb 2008 18:59:08 +0900
Wei Yongjun <yjwei@cn.fujitsu.com> wrote:

> Jarek Poplawski wrote:
> 
> Maybe ip_error() does not handle the ESRCH error. In this place ESRCH eq 
> to ENETUNREACH?
> 
> static int ip_error(struct sk_buff *skb)
> {
> 	struct rtable *rt = (struct rtable*)skb->dst;
> 	unsigned long now;
> 	int code;
> 
> 	switch (rt->u.dst.error) {
> 		case EINVAL:
> 		default:
> 			goto out;
> 		case EHOSTUNREACH:
> 			code = ICMP_HOST_UNREACH;
> 			break;
> 		case ENETUNREACH:
> 			code = ICMP_NET_UNREACH;
> 			break;
> 		case EACCES:
> 			code = ICMP_PKT_FILTERED;
> 			break;
> 	}
> ...............snip....................
> }
> 
> 
> 
> > On 26-02-2008 07:34, Li Yewang wrote:
> >   
> >> Hi All
> >>
> >>    There is a bug about icmp netunreach.
> >>    If the kernel does not find a route for a packet, 
> >>    it must send a icmp netunreach packet to the source host, 
> >>    and  discard  the packet. But the  kernel  does not send 
> >>    a icmp netunreach packet because of the  fib_lookup
> >>    return value  of -ESRCH when a route  is not found. 
> >>     
> >
> > ...or because some function doesn't handle -ESRCH return from
> > fib_lookup? It seems changing this to -ESRCH was needed in some cases.
> > And you don't explain enough why it can't be handled later (like in
> > ipv4/route.c: ip_route_input_slow)?
> >   
> 
> 
> > Regards,
> > Jarek P.
> >
> >   
> >> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
> >>
> >> diff -Nurp net/core_back/fib_rules.c net/core/fib_rules.c
> >> --- net/core_back/fib_rules.c   2008-02-25 13:15:37.000000000 +0800
> >> +++ net/core/fib_rules.c        2008-02-25 13:16:01.000000000 +0800
> >> @@ -188,7 +188,7 @@ jumped:
> >>  		}
> >>  	}
> >>  
> >> -	err = -ESRCH;
> >> +	err = -ENETUNREACH;
> >>  out:
> >>  	rcu_read_unlock();
> >>
> >>     

The switch shouldn't see a problem because ENETUNREACH is already substituted
for ESRCH in:


static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
			       u8 tos, struct net_device *dev)
{
...
	/*
	 *	Now we are ready to route packet.
	 */
	if ((err = fib_lookup(net, &fl, &res)) != 0) {
		if (!IN_DEV_FORWARD(in_dev))
			goto e_hostunreach;
		goto no_route;

...
no_route:
	RT_CACHE_STAT_INC(in_no_route);
	spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
	res.type = RTN_UNREACHABLE;
	if (err == -ESRCH)
		err = -ENETUNREACH;
	goto local_input;


