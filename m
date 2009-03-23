From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Mon, 23 Mar 2009 13:25:44 +0100
Message-ID: <49C77FC8.2010803@netfilter.org>
References: <20090323093353.14253.76823.stgit@Decadence> <49C77971.8080302@trash.net> <49C77C89.1010108@netfilter.org> <49C77D1D.7010204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33657 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754919AbZCWM0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 08:26:55 -0400
In-Reply-To: <49C77D1D.7010204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>>> - NETLINK_NO_CONGESTION_CONTROL seems a bit more descriptive than
>>>   "NO_ENOBUFS"
>>>
>>> - The ENOBUFS error itself is actually not the problem, but the
>>>   congestion handling. It still makes sense to notify userspace
>>>   of congestion. I'd suggest to deliver the error, but avoid setting
>>>   the congestion bit.
>>
>> I thought about this choice but I see one problem with this. The ENOBUFS
>> error is attached to the congestion control.
> 
> What do you mean by "attached to"? Congestion control is done by
> setting and testing bit 0 of nlk->state.

Yes, but once we set that bit to 1, we stop sending ENOBUFS to
userspace. So I think that congestion also applies to error reporting,
with "attached to" I meant "related" :).

>> If we keep reporting
>> ENOBUFS errors to userspace with no congestion control, the listener may
>> keep receiving ENOBUFS indefinitely. In other words, the congestion
>> control seems to me like a way to avoid spamming ENOBUFS errors to
>> userspace.
> 
> The error will be cleared by the next call to recvmsg().

Yes, but think about this scenario:

1) We hit ENOBUFS, you call recvmsg() you get the error, and error is
cleared.
2) You're going to call recvmsg() again but before doing so, we hit
ENOBUFS again. So you call recvmsg() and you get the error again.

I think that this may lead to indefinitely getting ENOBUFS without
retrieving data under very heavy load.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
