From: Nikola =?ISO-8859-1?Q?Forr=F3?= <nforro@redhat.com>
Subject: Re: [PATCH] net: Fix behavior of unreachable, blackhole and
 prohibit routes
Date: Thu, 03 Sep 2015 11:05:14 +0200
Message-ID: <1441271114.3360.34.camel@redhat.com>
References: <1441102392.3250.9.camel@redhat.com> <55E5E610.501@gmail.com>
Reply-To: nforro@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbbICJFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 05:05:17 -0400
In-Reply-To: <55E5E610.501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexander,
thank you for your comments.

On 09/01/2015 10:53 AM, Alexander Duyck wrote:

> Generally updating kernel code to match user-space documentation
> isn't 
> always the best way to go.  The question I would have is if there are
> any other user-space applications out there that might be expecting
> this 
> behaviour now?
> 
Well, any application which uses connect or sendto syscalls is getting
wrong error codes. If not wrong, than at least different for ipv4 and
ipv6. I think errors in fib_props are defined for a reason.

But I think bigger issue are incorrect ICMP messages being returned to
sender, e.g. packet going to blackhole route is not silently discarded,
instead it generates ICMP net unreachable message. I think that kind of
breaks the purpose of blackhole route.

> Also your changes don't seem to match up with what you have
> described. 
> You are returning the error code from fib_table_lookup, but 
> fib_table_lookup can return -EAGAIN if there is no matching entry
> found. 
>   I don't see you describing how you would deal with that case.  You 
> might try testing your code after deleting the default route to see
> what 
> behaviour it is you get.
> 
You are right, I need to handle -EAGAIN and return -ENETUNREACH
instead.

> This bit appears to overlook the fact that fib_rules_lookup could
> also 
> be the function used to return the error via a call to fib_lookup. 
>  In 
> which case that also throws -ESRCH into the mix for return error
> codes.
> 
I don't think it does. In __fib_lookup -ESRCH returned from
fib_rules_lookup is being replaced by -ENETUNREACH.


I will submit corrected patch.

Kind regards,
Nikola
