From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net-next 1/8] tipc: decrease connection flow control window
Date: Tue, 13 May 2014 13:27:45 -0400
Message-ID: <53725611.8070808@ericsson.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>	<1399641209-26112-2-git-send-email-jon.maloy@ericsson.com> <20140513.000530.154961879638643331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <paul.gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <ying.xue@windriver.com>,
	<tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:44924 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaEMR17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:27:59 -0400
In-Reply-To: <20140513.000530.154961879638643331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2014 12:05 AM, David Miller wrote:
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Fri,  9 May 2014 09:13:22 -0400
>
>> Memory overhead when allocating big buffers for data transfer may
>> be quite significant. E.g., truesize of a 64 KB buffer turns out
>> to be 132 KB, 2 x the requested size.
>>
>> This invalidates the "worst case" calculation we have been
>> using to determine the default socket receive buffer limit,
>> which is based on the assumption that 1024x64KB = 67MB buffers
>> may be queued up on a socket.
>>
>> Since TIPC connections cannot survive hitting the buffer limit,
>> we have to compensate for this overhead.
>>
>> We do that in this commit by dividing the fix connection flow
>> control window from 1024 (2*512) messages to 512 (2*256). Since
>> older version nodes send out acks at 512 message intervals,
>> compatibility with such nodes is guaranteed, although performance
>> may be non-optimal in such cases.
>>
>> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
>> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> So all I have to do is open 64 sockets to make TIPC commit to 4GB
> of ram at once?

Yes. We are fully aware of this. But this is the way it has been the last
two years, and this series changes nothing regarding that. It was
even more before.

>
> I really think you need to rethink this, the socket limits are
> there for a reason.

We have already done that. A couple of months from now, when
we have finished our current redesign of the locking policy
and transmission path code,  you can expect a series of commits
where the connection-level flow control is completely re-worked.
It will be byte-based, and be pretty similar to what we have in TCP.

But, that solution cannot be made backwards compatible with
the current, message based flow control, so we will have to keep
supporting that one too for a while. We will probably use capability
flags to distinguish between the two, and require active enabling for
any new node to use the old algorithm. I think fixing weaknesses
in the current flow control can be seen as such support, as long
as we don't extend the limits for claimable memory further than
it is now.

Commit #1 is such a fix, while #2 will be valid even when we
introduce the new flow control. The other ones are about completely
different matters.

So, please advise me, should I resubmit the series as a whole,
without patch #1, without ##1 and 2, or do you expect us
to drop everything else until we have a new flow control?
The latter alternative will no doubt cause us some double effort.

Regards
///jon
