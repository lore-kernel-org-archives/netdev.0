From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: policy routing vs dnat replies
Date: Thu, 04 Oct 2012 08:39:41 -0400
Message-ID: <506D838D.1060004@earthlink.net>
References: <CALCETrWs4NDb_4KzJqnQVAkWHuaUS3Xrguuk2wwZGGKo8TqSLA@mail.gmail.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:37886 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756200Ab2JDMjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 08:39:43 -0400
In-Reply-To: <CALCETrWs4NDb_4KzJqnQVAkWHuaUS3Xrguuk2wwZGGKo8TqSLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2012 08:44 PM, Andy Lutomirski wrote:
> I hit an annoying policy routing corner case today.  I have a router
> with two WAN interfaces (and no BGP).  I have policy routing set up so
> that, if a source address matches either of my public networks, then
> outgoing packets use the correct interface.  If neither rule matches
> (e.g. the source is 0.0.0.0 for source address selection), then the
> default route is whichever one I prefer at the moment.  It looks like
> this:
>
> $ ip rule
> 0:	from all lookup local
> 32766:	from all lookup main
> 32767:	from all lookup default
> 40000:	from<net2>  lookup isp2
> 40001:	from<net1>  lookup isp1
> 40010:	from all lookup real_default
>
> The relevant routes are:
>
> default via<gw1>  dev eth0.2  table isp1  src<src1>
> default via<gw2>  dev eth0.3  table isp2  src<src2>
> default via<gw2>  dev eth0.3  table real_default  src<src2>   metric 101
> default via<gw1>  dev eth0.2  table real_default  src<src1>   metric 102
>
> (Yes, this is a bit verbose, but I don't know a more concise way to do this.)
>
> This works nicely: if I specifically bind to one of my public
> addresses, the corresponding WAN link is used, and if not or if I'm
> coming from a private address, then the metrics determine which link
> to use.
>
> DNAT breaks it.  I have a rule:
> -A PREROUTING -i eth0.2 -d<ip1>  -p tcp --dport<port>  -j DNAT --to
> <internal host>
>
> <ip1>  lives on isp1.  Someone sends a SYN.  It gets routed to the
> internal host, and that host sends a SYN/ACK back.  The SYN/ACK has a
> source ip that isn't on net1 or net2, so it matches the 'lookup
> real_default' rule and gets routed to *gw2*.  iptables rewrites the
> source address after the routing decision, and my router sends a
> packet with a source address belonging to isp1 to isp2's gateway.  The
> packet is then dropped.
>
> Is there any way I can either convince iptables to rewrite the source
> address in the prerouting hook or to query the conntrack source
> address from the policy rule?  Is there a better solution?  I'm
> currently using a somewhat gross combination of MARK and fwmark
> matches to work around this problem.  One possibility would be:
>
> Thanks,
> Andy
>
> P.S.  Linux 3.2 (at least) appears to have a bug: the SYN/ACK has
> ctdir ORIGINAL as seen from the the mangle PREROUTING chain.  I'll
> send a real bug report for that if I can reproduce it cleanly on a
> newer kernel.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>    
Well what I did faced with a similar problem was add a higher prio rule
that said if from ip1 lookup isp1.

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
