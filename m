From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] inet: delay address promotion check until last request
 in message
Date: Sun, 8 Nov 2015 16:56:41 -0500
Message-ID: <20151108215641.GA16147@neilslaptop.think-freely.org>
References: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
 <alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44639 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbKHV5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 16:57:01 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 07, 2015 at 01:49:25AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 6 Nov 2015, Neil Horman wrote:
> 
> > The solution is to recognize that its pointless to promote an address to be a
> > new primary, if there is a possibility that it will just be removed in the near
> > future.  As such this patch peeks ahead to the next request in the provided
> > netlink message, and, if it is both valid and a RTM_DELADDR request, skips the
> > promotion check.  This eliminates the need to iterate through a nested for loop
> 
> 	flush can provide many parameters. As there is no
> any kind of indication in the netlink message that all addresses
> are removed, we can not avoid the promotion.
> 
This is true, but seems irrellevant to me.  A flush operation is a sequence of
RTM_DELADDR operations in a one or more netlink packets.  The way my patch is
written, if a set of DELADDR requests is interspersed with other non DELADDR
requests, then we do a promotion check between each consecutive set of DELADDR
requests.  As such, all that happens is that the promotion check happens
possibly more often than needed.  Its not optimal, but not harmful either.


> > +	 * Only check for address promotion when this is the last request
> > +	 * in this netlink transaction.  It allows this operation to complete
> > +	 * in O(n) time rather than O(n^2)
> 
> 	It is not correct to assume that one promotion per
> transaction is enough. The promotion happens in every subnet,
> it was not once per device.
> 

I'm not sure I understand the relevance here.  All I'm doing is, in effect
masking the promote_secondaries sysctl for an interface doing a flush operation.
Its equivalent to doing this in user space:

echo 0 > /proc/sys/net/ipv4/conf/<ifc>/promote_secondaries
A=`some arbitrary address in <ifc>`
ip addr del <every addressin in <ifc> except A>
echo 1 > /proc/sys/net/ipv4/conf/<ifc>/promote_secondaries
ip addr del A

Can you please explain to me the use case in which delaying a promotion
operation until we think we're done ('done' being defined by the above transition
from a DELADDR operation to a non-DELADDR operation in a netlink packet)
produces an outcome that differs from the expectation with this patch in place?

Best
Neil

> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
