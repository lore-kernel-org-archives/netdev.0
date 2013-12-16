From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] tipc: correctly unlink packets from deferred
 queue
Date: Mon, 16 Dec 2013 13:11:49 -0500
Message-ID: <52AF4265.2070507@windriver.com>
References: <1387187185-6914-1-git-send-email-erik.hugne@ericsson.com> <52AF1CA2.6000406@windriver.com> <20131216163518.GB20740@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60867 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab3LPSLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 13:11:39 -0500
In-Reply-To: <20131216163518.GB20740@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-12-16 11:35 AM, Erik Hugne wrote:
> On Mon, Dec 16, 2013 at 10:30:42AM -0500, Paul Gortmaker wrote:
>> On 13-12-16 04:46 AM, erik.hugne@ericsson.com wrote:
>>> From: Erik Hugne <erik.hugne@ericsson.com>
>>>
>>> When we pull a packet from the deferred queue, the next
>>> pointer for the current packet being processed might still
>>> refer to deferred packets. This is incorrect, and will
>>> lead to an oops if the last fragment have once been put on
>>> the deferred queue, and at least one packet have been
>>
>> Once again, I have to ask when this behaviour was introduced.
>> This should always be a question that you ask yourself, and
>> that you consider putting in the commit log.  Please add it
>> to your self-check list.
>>
>> So, is this a fail we introduce with the pending two series,
>> or with the series already taken by DaveM?
> 
> The problem have always been there, but the window for when
> it may occur increased after commit 40ba3cdf5
> tipc: message reassembly using fragment chain

OK, so put that in the commit log:

"It is our understanding that this problem has always existed,
however, with the recent change of commit 40ba3cdf5
("tipc: message reassembly using fragment chain"), the window
for it possibly happening has increased."

In this case, your choice of net-next is probably OK, given
the above new information, but  we need to put the info in the
commit log, so it makes it more clear for net vs. net-next.

In the end, Dave makes the final decision of net vs net-next,
based on the information we provide him, along with information
you aren't aware of, like how deep we are into the current rcN,
whether Linus is in a good mood and so on.  If we aren't sure,
we can even specify that, after the three dashes in the commit,
by listing the pros/cons of each.

> 
>>
>> Otherwise, if it is an older problem than that, then why
>> is this tagged net-next?  It looks like a genuine bug fix
>> for an oops, if the existing mainline code has this bug.
>>
>>> deferred after this fragment. The result of this is that
>>> the fragment chain linked together with the defer-queue.
>>
>> "...chain is linked ..."   ?
>
> What we have seen is that after successful delivery of a 
> fragmented message, the last packet in the fragment chain
> will point into the deferred queue. When we later free the
> chain, kfree_skb_list will also free packets from the defer-queue.

My comment was wrt. the missing "if" in the sentence, but I
like the more detailed paragraph you have given above better.

> 
> In theory, the same thing can occur for non-fragmented traffic
> aswell.
> 
>>
>>>
>>> We fix this by clearing the next pointer for the current
>>> packet being processed.
>>>
>>> [...] general protection fault: 0000
>>
>> Was this all that was in the header?  Seems overly edited, and
>> missing content (registers, EIP, etc.)
>>
>>> [...]
>>> [...] ? trace_hardirqs_on+0xd/0x10
>>> [...] tipc_link_recv_fragment+0xd1/0x1b0 [tipc]
>>> [...] tipc_recv_msg+0x4e4/0x920 [tipc]
>>> [...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
>>> [...] tipc_l2_rcv_msg+0xcc/0x250 [tipc]
>>> [...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
>>> [...] __netif_receive_skb_core+0x80b/0xd00
>>> [...] ? __netif_receive_skb_core+0x144/0xd00
>>> [...] __netif_receive_skb+0x26/0x70
>>> [...] netif_receive_skb+0x2d/0x200
>>
>> Same here, why have you bothered to clobber the addresses?
>> Deleting the printk time prefix from non-time critical bugs is
>> fine, but don't delete the addresses, since they convey some
>> relative information about functions nearby etc.
> 
> Just trying to avoid an unnecessarily verbose commit message.
> As the oops was from Ying's test system with non-upstream tipc
> code i didn't think the addresses added any value

You don't need to mangle the log, but it is always good to
specify up front if non-merged code is in use.  We have had
people come to netdev in the past, saying there is a bug in
core code like net/core/dev.c -- and only after digging in
do we find they are using some broken (un-reviewed) patches
from some vendor SDK in their kernel, which actually caused
the issue in that particular case.

So, something like "Note that the above backtrace was observed
on a tree with some additional pending TIPC changes in place,
but nothing in those changes, or in the backtrace above appears
to play a role in causing this issue."  Or, even better, simply
prove to yourself that you _can_ reproduce it on what is already
accepted into the net-next code base, if the WIP in Ying's test
system isn't at all related to this problem.

> 
> Should i do an edit/resend anyway?

Given all of the above, yes please.

Paul.
--

> 
> //E
> 
