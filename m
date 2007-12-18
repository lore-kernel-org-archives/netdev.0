From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Tue, 18 Dec 2007 17:34:11 -0500
Message-ID: <47684AE3.7080007@hp.com>
References: <OF87295D1E.4B69B8F8-ON882573B5.00755AB2-882573B5.0078619A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:30576 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbXLRWeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 17:34:15 -0500
In-Reply-To: <OF87295D1E.4B69B8F8-ON882573B5.00755AB2-882573B5.0078619A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Brian Haley <brian.haley@hp.com> wrote on 12/18/2007 12:57:54 PM:
> 
>> Trying to connect() to an IPv6 link-local multicast address by
>> specifying the outgoing multicast interface doesn't work, you have to
>> bind to a device first with an SO_BINDTODEVICE setsockopt() call.

Other OSes allow this operation, like FreeBSD, Tru64 UNIX and Solaris.

>         No, you simply have to specify sin6_scope_id for link-scope
> addresses, like you do in unicast cases.

But isn't this why IPV6_MULTICAST_IF exists?  So you don't have to bind 
to an interface or use the scope id?  RFC 3493 does not mention having 
to set a scope id in order to send multicast packets:

    IPv6 applications may send multicast packets by simply specifying an
    IPv6 multicast address as the destination address, for example in the
    destination address argument of the sendto() function.

> Your patch requires them
> to match (if specified), but I don't think IPV6_MULTICAST_IF should
> override or require a match for a valid sin6_scope_id (or be an error).

The patch won't override sk_bound_dev_if, or sin6_scope_id, it's a last 
resort for link-local multicast.  As far as matching, I think they 
should if you set both SO_BINDTODEVICE/sin6_scope_id and 
IPV6_MULTICAST_IF.  I can relax that check if you like.

The one thing my patch does do is set sk_bound_dev_if, which it never 
did - that seemed like the right thing to do since that's what the scope 
id path does, and makes sure we always continue to use this interface.

>         If I read it correctly, the existing code uses IPV6_MULTICAST_IF
> if the sin6_scope_id is not set, otherwise honors the interface specified
> in the connect. That seems like correct behaviour to me, and RFC 3493
> doesn't address the relative precedence of the two that I see. This is
> in the "linklocal" branch, and all unicast linklocal's require specifying
> sin6_scope_id. Multicast doesn't if require a scope_id in the case where
> you've done an IPV6_MULTICAST_IF, but it should still allow a different
> scope_id when you have used IPV6_MULTICAST_IF.

The IPV6_ADDR_MULTICAST check is inside the sin6_scope_id if() 
statement, so will never get checked if the scope hasn't been specified, 
that's the bug.  Since that isn't required for multicast we always get 
an EINVAL here.

>         Do you have application code that you believe is correct that
> doesn't work?

Yes, a customer does.

-Brian
