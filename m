From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: enable cookie-echo retransmission transport switch
Date: Fri, 13 Jun 2008 08:57:54 -0400
Message-ID: <48526ED2.50006@hp.com>
References: <4850A7F2.6090906@cn.fujitsu.com> <48513BA4.9030403@hp.com> <4851C3AD.9030600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:3086 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354AbYFMM57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 08:57:59 -0400
In-Reply-To: <4851C3AD.9030600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> Vlad,
> 
>   Thanks for your comments.
> 
> Vlad Yasevich wrote:
>> Gui Jianfeng wrote:
>>> Vlad,
>>> This patch enables cookie-echo retransmission transport switch
>>> feature. If COOKIE-ECHO retransmission happens, it will be sent to the
>>> address other than the one last sent to.
>>>
>> NAK.
>>
>> You can't blindly choose a different transport since they could
>> be unconfirmed and can't really be used until we confirm them
>> with HBs.  So, you can only do this when the user issued an
>> sctp_connectx() and we have multiple confirmed transports.
>>
>> In this case only confirmed transports are allowed, otherwise
>> there is a possibility of hijacking associations.
>>
>   Choosing a transport here just gives a suggestion for sctp_outq_flush(),
>   sctp_outq_flush() will judge again. If the selected transport is in 
>   INACTIVE or UNCONFIRMED, active_path will be used.
>   So COOKIE-ECHO won't be sent to a unconfirmed address.
> 

Yep, and this completely nullifies the thing you are trying to do.  So, instead
of trying other available transports, we end up just sending on the active path
is at this stage of association is the same as primary.

>> Also, looking at this, the same problem exists in current
>> code for selection INIT transports.
>>
>> We don't correctly treat peers passed to connectx() as confirmed
>> and don't select the correct transport.
>>
>> Once you fix that above, you can just re-use the function and
>> re-use init_last_sent_to.
> 
>   Will do.

Just an FYI, here is a way BSD handles this:
	a.  they assume all destinations passed to connectx() are
	    reachable/confirmed.
	b.  when processing INIT-ACK, they tag all the existing destinations
	    with a flag, and clear the flag if the destination is in INIT-ACK.
	c.  they free all destinations that have the flag set at the end of
	    INIT-ACK.

I think a simpler way would to add another state to the transport that allows 
sending handshakes and correctly transitions to confirmed when association is
fully formed.  In BSD, they end up walking the destination chain 3 times, which
is just a waste.

-vlad
> 
>> -vlad
>>
> 
> 
> 
>>
> 

