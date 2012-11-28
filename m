From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2 net-next] sctp: Add support to per-association statistics
 via a new SCTP_GET_ASSOC_STATS call
Date: Tue, 27 Nov 2012 20:40:29 -0500
Message-ID: <50B56B8D.9060702@gmail.com>
References: <1352991680-12289-1-git-send-email-michele@acksyn.org> <50AA57EA.4000907@gmail.com> <20121127220810.GB3869@fante.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:45943 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab2K1Bkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 20:40:32 -0500
In-Reply-To: <20121127220810.GB3869@fante.int.rhx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2012 05:08 PM, Michele Baldessari wrote:
> Hi Vlad,
>
> thanks a lot for your review.
>
> On Mon, Nov 19, 2012 at 11:01:46AM -0500, Vlad Yasevich wrote:
> <snip>
>>> @@ -1152,8 +1156,11 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
>>>   		 */
>>>   		if (sctp_chunk_is_data(chunk))
>>>   			asoc->peer.last_data_from = chunk->transport;
>>> -		else
>>> +		else {
>>>   			SCTP_INC_STATS(net, SCTP_MIB_INCTRLCHUNKS);
>>> +			if (chunk->chunk_hdr->type == SCTP_CID_SACK)
>>> +				asoc->stats.isacks++;
>>> +		}
>>
>> Should the above include asoc->stats.ictrlchunks++; just like ep_bh_rcv()?
>
> Indeed, I will add that.
>
>>>
>>>   		if (chunk->transport)
>>>   			chunk->transport->last_time_heard = jiffies;
>>> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
>>> index 1859e2b..32ab55b 100644
>>> --- a/net/sctp/endpointola.c
>>> +++ b/net/sctp/endpointola.c
>>> @@ -480,8 +480,11 @@ normal:
>>>   		 */
>>>   		if (asoc && sctp_chunk_is_data(chunk))
>>>   			asoc->peer.last_data_from = chunk->transport;
>>> -		else
>>> +		else {
>>>   			SCTP_INC_STATS(sock_net(ep->base.sk), SCTP_MIB_INCTRLCHUNKS);
>>> +			if (asoc)
>>> +				asoc->stats.ictrlchunks++;
>>> +		}
>>>
>>>   		if (chunk->transport)
>>>   			chunk->transport->last_time_heard = jiffies;
>>> diff --git a/net/sctp/input.c b/net/sctp/input.c
>>> index 8bd3c27..54c449b 100644
>>> --- a/net/sctp/input.c
>>> +++ b/net/sctp/input.c
>>> @@ -281,6 +281,8 @@ int sctp_rcv(struct sk_buff *skb)
>>>   		SCTP_INC_STATS_BH(net, SCTP_MIB_IN_PKT_SOFTIRQ);
>>>   		sctp_inq_push(&chunk->rcvr->inqueue, chunk);
>>>   	}
>>> +	if (asoc)
>>> +		asoc->stats.ipackets++;
>>>
>>>   	sctp_bh_unlock_sock(sk);
>>
>> This needs a bit more thought.  Current counting behaves differently
>> depending on whether the user holds a socket lock or not.
>> If the user holds the lock, we'll end counting the packet before it is
>> processed.  If the user isn't holding the lock, we'll count the packet after
>> it is processed.
>
> I see. What do you prefer: use atomic64 for this specific counter or
> since it is a temporary miscount we go ahead and ignore it or do you
> have other approaches in mind?

You could count it in sctp_inq_push...  Would that make sense?

-vlad
