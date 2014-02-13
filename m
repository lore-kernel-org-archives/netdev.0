From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Thu, 13 Feb 2014 12:14:43 -0500
Message-ID: <52FCFD83.7050204@gmail.com>
References: <52F72AFE.4060802@nsn.com> <52FA3914.90002@gmail.com> <52FA8073.2060607@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>
To: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:42027 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaBMRVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 12:21:48 -0500
In-Reply-To: <52FA8073.2060607@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2014 02:56 PM, Matija Glavinic Pecotic wrote:
> Hello Vlad,
>
> On 02/11/2014 03:52 PM, ext Vlad Yasevich wrote:
>> Hi Matija
>>
>> On 02/09/2014 02:15 AM, Matija Glavinic Pecotic wrote:
>>>
>>> --- net-next.orig/net/sctp/ulpevent.c
>>> +++ net-next/net/sctp/ulpevent.c
>>> @@ -989,7 +989,7 @@ static void sctp_ulpevent_receive_data(s
>>>  	skb = sctp_event2skb(event);
>>>  	/* Set the owner and charge rwnd for bytes received.  */
>>>  	sctp_ulpevent_set_owner(event, asoc);
>>> -	sctp_assoc_rwnd_decrease(asoc, skb_headlen(skb));
>>> +	sctp_assoc_rwnd_update(asoc, false);
>>>
>>>  	if (!skb->data_len)
>>>  		return;
>>> @@ -1035,8 +1035,9 @@ static void sctp_ulpevent_release_data(s
>>>  	}
>>>
>>>  done:
>>> -	sctp_assoc_rwnd_increase(event->asoc, len);
>>> -	sctp_ulpevent_release_owner(event);
>>> +	atomic_sub(event->rmem_len, &event->asoc->rmem_alloc);
>>> +	sctp_assoc_rwnd_update(event->asoc, true);
>>> +	sctp_association_put(event->asoc)
>>
>> Can't we simply change the order of window update and release instead
>> of open coding it like this?
>
> that was the initial idea, but sctp_ulpevent_release_owner puts
> the association and calls sctp_association_destroy if its time to
> do so. IMHO, in the case if we would switch it, we would open a
> potential race condition.

On the tx side, I agree that there would be race.  One the recieve side,
I don't think you could ever be in the codition where the last reference
on the asoc is held by a data chunk you are feeing.

However, to be completely safe we could do:
    asoc = event->asoc;
    sctp_association_hold(asoc);
    sctp_ulpevent_release_owner(event);
    sctp_assoc_rwnd_update(asoc, true);
    sctp_assocition_put(asoc);


The reason I don't like to open-code release owner is that if it
ever changes, we'll have to rememeber to change this open-coded
implementation as well.

Thanks
-vlad

>
> I agree this doesn't look the best. But since we should call
> sctp_assoc_rwnd_update after accounting and before put, we have only
> option to move sctp_assoc_rwnd_update to _ulpevent_release_owner. As on
> this path we wish to update peer and generate sack, but we for sure do not
> want it on all paths where ulpevent_release_owner is used, I see no
> alternative but to add additional parameter to ulpevent_release_owner
> which would be just passed to rwnd_update - bool update_peer. On the
> other hand, I wonder whether ulpevent_release_owner would do more then
> it should in that case?
>
>>
>> -vlad
>>
>>>  }
>>>
>>>  static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent
*event)
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
