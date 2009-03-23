From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Mon, 23 Mar 2009 13:41:38 +0100
Message-ID: <49C78382.9000600@trash.net>
References: <20090323093353.14253.76823.stgit@Decadence> <49C77971.8080302@trash.net> <49C77C89.1010108@netfilter.org> <49C77D1D.7010204@trash.net> <49C77FC8.2010803@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37744 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbZCWMlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 08:41:47 -0400
In-Reply-To: <49C77FC8.2010803@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
>>> Patrick McHardy wrote:
>>>> - NETLINK_NO_CONGESTION_CONTROL seems a bit more descriptive than
>>>>   "NO_ENOBUFS"
>>>>
>>>> - The ENOBUFS error itself is actually not the problem, but the
>>>>   congestion handling. It still makes sense to notify userspace
>>>>   of congestion. I'd suggest to deliver the error, but avoid setting
>>>>   the congestion bit.
>>> I thought about this choice but I see one problem with this. The ENOBUFS
>>> error is attached to the congestion control.
>> What do you mean by "attached to"? Congestion control is done by
>> setting and testing bit 0 of nlk->state.
> 
> Yes, but once we set that bit to 1, we stop sending ENOBUFS to
> userspace. So I think that congestion also applies to error reporting,
> with "attached to" I meant "related" :).

That's correct, there can only be a single outstanding error at any
time.

>>> If we keep reporting
>>> ENOBUFS errors to userspace with no congestion control, the listener may
>>> keep receiving ENOBUFS indefinitely. In other words, the congestion
>>> control seems to me like a way to avoid spamming ENOBUFS errors to
>>> userspace.
>> The error will be cleared by the next call to recvmsg().
> 
> Yes, but think about this scenario:
> 
> 1) We hit ENOBUFS, you call recvmsg() you get the error, and error is
> cleared.
> 2) You're going to call recvmsg() again but before doing so, we hit
> ENOBUFS again. So you call recvmsg() and you get the error again.
> 
> I think that this may lead to indefinitely getting ENOBUFS without
> retrieving data under very heavy load.

I'm not sure that this would be a bad thing under the circumstances
you describe. We drop packets, we notify userspace.

I agree though that my proposed way isn't ideal either, since we can't
queue errors, they will be delivered sporadically (not reflecting the
true amount of dropped messages) and without stopping to queue new
messages, it can't be determined at which "position" the error occured.

But I think some notification or other way to notice whats happening
is needed for userspace, otherwise it can neither report not handle
this in any way.

