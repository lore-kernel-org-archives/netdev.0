From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] net: sctp: bug fixing when sctp path recovers
Date: Wed, 13 Nov 2013 09:44:03 +0100
Message-ID: <52833BD3.4040003@redhat.com>
References: <1384306486-31345-1-git-send-email-changxiangzhong@gmail.com> <5282E5F9.5000506@gmail.com> <5282E9EC.3090307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dreibh@simula.no
To: Chang <changxiangzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758517Ab3KMIo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 03:44:26 -0500
In-Reply-To: <5282E9EC.3090307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 03:54 AM, Chang wrote:
> On 11/13/2013 03:37 AM, Vlad Yasevich wrote:
>> On 11/12/2013 08:34 PM, Chang Xiangzhong wrote:
>>> Look for the __two__ most recently used path/transport and set to active_path
>>> and retran_path respectively

Please also for the log, elaborate a bit more, explaining what currently
happens, and what the effects of this bug are, so that later when people
are looking through the Git log they can easily get what problem you are
trying to fix; and if possible, add:

Fixes: <12 digits SHA1> ("<commit title>")

>>> Signed-off-by: changxiangzhong@gmail.com
>>> ---
>>>   net/sctp/associola.c |    4 ++++
>>>   1 file changed, 4 insertions(+)
>>>
>>> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
>>> index ab67efc..070011a 100644
>>> --- a/net/sctp/associola.c
>>> +++ b/net/sctp/associola.c
>>> @@ -913,11 +913,15 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>>>           if (!first || t->last_time_heard > first->last_time_heard) {
>>>               second = first;
>>>               first = t;
>>> +            continue;
>>>           }
>>>           if (!second || t->last_time_heard > second->last_time_heard)
>>>               second = t;
>>
>> You might as well remove this bit and then you don't need a continue.
> I don't think we could remove this bit. My understanding of these algorithms are to find the 1st recently used path and the 2nd, assigning to active_path and retran_path respectively. If we remove the looking-for-second block, how are we suppose to find the 2nd?
> I think we can remove the continue and use else-if in the 2nd-assignment-block.
>>
>>>       }
>>>
>>> +    if (!second)
>>> +        second = first;
>>> +
>>
>> This needs to move down 1 more block.  Set the second transport after we
>> check to see if the primary is back up and we need to go back to using it.
>>
>> -vlad
>>
> I agree with this change
>>>       /* RFC 2960 6.4 Multi-Homed SCTP Endpoints
>>>        *
>>>        * By default, an endpoint should always transmit to the
>>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
