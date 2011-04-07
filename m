From: David Miller <davem@davemloft.net>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output
 routes."
Date: Wed, 06 Apr 2011 22:42:44 -0700 (PDT)
Message-ID: <20110406.224244.104071339.davem@davemloft.net>
References: <20110406.132829.116375350.davem@davemloft.net>
	<87ipuqsmwl.fsf@devron.myhome.or.jp>
	<20110406.223400.71127145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hirofumi@mail.parknet.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401Ab1DGFnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 01:43:21 -0400
In-Reply-To: <20110406.223400.71127145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Apr 2011 22:34:00 -0700 (PDT)

> From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> Date: Thu, 07 Apr 2011 13:31:06 +0900
> 
>> I'm not pretty sure though, output message is
>> 
>> 	ip_finish_output2: No header cache and no neighbour!
>> 
>> I'm not debugging this though,
>> 
>> static inline bool rt_is_output_route(struct rtable *rt)
>> {
>> 	return rt->rt_iif == 0;
>> }
>> 
>> from review I guess the above is one of cause.
> 
> arp_bind_neighbour() is only called if rt_is_output_route() is true
> or route is unicast.
> 
> If packet is sent using a route for which arp_bind_neighbour() has not
> been called, you will see that warning message.

Ok, the problem is that, for output routes in original code:

1) user's flow device index is stored in rt->rt_iif

2) arp_bind_neighbour() tests meanwhile used rt->fl.iif

So we do need, for now, to add a new member.  But I think for
correct semantics it needs to have inverse meaning to the one
you added in your RFC patch.

So fix is something like:

1) Add "int rt_route_iif;" to struct rtable

2) For input routes, always set rt_route_iif to same value as rt_iif

3) For output routes, always set rt_route_iif to zero.  Set rt_iif
   as it is done currently.

4) Change rt_is_{output,input}_route() to test rt_route_iif

This should fix the bug and not introduce new regressions.

Can you write and test such a patch with your test case?

Thank you!
