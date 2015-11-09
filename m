From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] inet: delay address promotion check until last request
 in message
Date: Mon, 9 Nov 2015 16:43:18 -0500
Message-ID: <20151109214318.GC27281@hmsreliant.think-freely.org>
References: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
 <alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
 <20151108215641.GA16147@neilslaptop.think-freely.org>
 <alpine.LFD.2.11.1511092149400.1635@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60927 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbbKIVnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 16:43:41 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1511092149400.1635@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 10:35:42PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 8 Nov 2015, Neil Horman wrote:
> 
> > On Sat, Nov 07, 2015 at 01:49:25AM +0200, Julian Anastasov wrote:
> > > 
> > > 	flush can provide many parameters. As there is no
> > > any kind of indication in the netlink message that all addresses
> > > are removed, we can not avoid the promotion.
> > > 
> > This is true, but seems irrellevant to me.  A flush operation is a sequence of
> > RTM_DELADDR operations in a one or more netlink packets.  The way my patch is
> > written, if a set of DELADDR requests is interspersed with other non DELADDR
> > requests, then we do a promotion check between each consecutive set of DELADDR
> > requests.  As such, all that happens is that the promotion check happens
> > possibly more often than needed.  Its not optimal, but not harmful either.
> 
> 	It is harmful, you miss promotion for some of the
> subnets, see below...
> 
> > > > +	 * Only check for address promotion when this is the last request
> > > > +	 * in this netlink transaction.  It allows this operation to complete
> > > > +	 * in O(n) time rather than O(n^2)
> > > 
> > > 	It is not correct to assume that one promotion per
> > > transaction is enough. The promotion happens in every subnet,
> > > it was not once per device.
> > > 
> > 
> > I'm not sure I understand the relevance here.  All I'm doing is, in effect
> > masking the promote_secondaries sysctl for an interface doing a flush operation.
> > Its equivalent to doing this in user space:
> > 
> > echo 0 > /proc/sys/net/ipv4/conf/<ifc>/promote_secondaries
> > A=`some arbitrary address in <ifc>`
> > ip addr del <every addressin in <ifc> except A>
> > echo 1 > /proc/sys/net/ipv4/conf/<ifc>/promote_secondaries
> > ip addr del A
> > 
> > Can you please explain to me the use case in which delaying a promotion
> > operation until we think we're done ('done' being defined by the above transition
> > from a DELADDR operation to a non-DELADDR operation in a netlink packet)
> > produces an outcome that differs from the expectation with this patch in place?
> 
> 	Here is how we can miss promotion...
> 
> dev=eth1
> ifconfig $dev up
> ip addr add 1.2.3.4/24 dev $dev
> ip addr add 1.2.3.4/16 dev $dev
> ip addr add 1.2.3.44/24 dev $dev
> ip addr add 1.2.3.44/16 dev $dev
> echo 1 > /proc/sys/net/ipv4/conf/$dev/promote_secondaries
> ip addr flush dev $dev to 1.2.3.4/30
> ip -V
> ip utility, iproute2-ss010824
> 
> What happens is a request to delete just primary addresses:
> 1.2.3.4/24 and 1.2.3.4/16. The /30 is chosen in such a way,
> so that any repeating attempts to flush the secondary
> addresses are avoided. As result, with your patch, only
> 1.2.3.44/16 is promoted (the last secondary), 1.2.3.44/24
> which is first in the list of the secondaries, is not
> promoted, it is removed. You can even use 1.2.3.4/24,
> 1.2.3.5/16, 1.2.3.44/24 and 1.2.3.55/16 in case the
> equal IPs are not a good example.
> 
> The problem will be more visible if one builds netlink message
> by hand containing DEL for different primaries.
> 
Ah, crap, Ok.  I didn't consider the use case in which user space would build a
filter of addresses that were on a mix of subnets.  That makes sense now, thanks
for the explination.

I suppose then the only optimization to be had here is to detect the case of a
complete flush of all addresses in user space and either manually or
automatically disable promotion during the flush operation

Neil

> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
