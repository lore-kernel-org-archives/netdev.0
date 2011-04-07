From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output routes."
Date: Thu, 07 Apr 2011 13:31:06 +0900
Message-ID: <87ipuqsmwl.fsf@devron.myhome.or.jp>
References: <87oc4kj1bt.fsf@devron.myhome.or.jp>
	<20110406.132829.116375350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:45927 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab1DGEbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:31:11 -0400
In-Reply-To: <20110406.132829.116375350.davem@davemloft.net> (David Miller's
	message of "Wed, 06 Apr 2011 13:28:29 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> Date: Tue, 05 Apr 2011 22:05:10 +0900
>
>> ipv4: Set rt->rt_iif more sanely on output routes.
>> (1018b5c01636c7c6bda31a719bda34fc631db29a)
>> 
>> The above patch seems to be caused of avahi breakage.
>> 
>> I'm not debugging fully though, avahi is using IP_PKTINFO and checking
>> in_pktinfo->ipi_ifindex > 0.
>> 
>> And if I reverted above patch, it seems to fix avahi's IP_PKTINFO problem.
>
> in_pktinfo is given to the application only during recvmsg() calls, the
> call chain is (for example):
>
> udp_recvmsg()
> 	--> ip_cmsg_recv()
> 		--> ip_cmsg_recv_pktinfo()
>
> Therefore we will only be working with receive packets, whose routes are
> computed using ip_route_input*() which will fill in the rt_iif field
> appropriately.
>
> The only exception to this would be packets which are looped back, in
> which case the cached output route attached to the packet will be used.

I see.

> Your RFC patch should work, but we're trying to make "struct rtable"
> smaller rather than larger.

I felt it from git hisotry.

> In what way does routing break if you simply restore the original
> rt_iif assignment in output route creation?  That's the most preferred
> fix for this.

I'm not pretty sure though, output message is

	ip_finish_output2: No header cache and no neighbour!

I'm not debugging this though,

static inline bool rt_is_output_route(struct rtable *rt)
{
	return rt->rt_iif == 0;
}

from review I guess the above is one of cause.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
