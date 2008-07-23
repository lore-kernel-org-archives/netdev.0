From: jean-pascal billaud <billaud@vmware.com>
Subject: Re: delayed ack timer, slow start and LRO
Date: Wed, 23 Jul 2008 10:58:28 -0700
Message-ID: <48877144.3090006@vmware.com>
References: <488659A6.5030703@vmware.com> <Pine.LNX.4.64.0807231439390.13775@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:59797 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753474AbYGWSBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 14:01:19 -0400
In-Reply-To: <Pine.LNX.4.64.0807231439390.13775@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Tue, 22 Jul 2008, jean-pascal billaud wrote:
>
> Some corrections to assumptions below...
>
>   
>> I have a question related to the interaction between the delayed ack
>> timer, slow start and LRO.
>>
>> If the sender is doing a slow start, it is going to send one packet. The
>> receiver's delayed ack timer is going to
>> kick in and when it expires it will send a ack.
>>
>> Then the sender is going to send 2 packets now. LRO will aggregates them
>> and the receiver's delayed ack timer is going
>> to kick in, hoping another packet will arrives which is not going to be
>> the case. When the timer expires it is going to
>> send a ack.
>>     
>
> What makes you think so? ...please see conditions in
> __tcp_ack_snd_check(). ...and like somebody else mentioned, there are
> quickacks in the picture as well (aka. Delayed ACK After Slow-Start,
> DAASS).
>   
Ok. I found the quickack mode bound by TCP_MAX_QUICKACKS, so by knowing that my assumptions
are not correct anymore. I am going to check if BSD has the same behavior.

>   
>> The sender is now going to send 4 packets. LRO will aggregate them and
>> the receiver's delayed ack timer is going to
>> kick in, hoping another packet will arrives which is not going to be the
>> case. When the timer expires it is going to
>> send a ack.
>>     
>
> Likewise, though in here tcp_max_burst would prevent as large growth as
> without lro (in other slow-starts than the initial one).
>
>   
>> The sender is now going to send ... So I am under the impression that
>> due to the fact that LRO is aggregating packets,
>> the delayed ack timer will kick in every single time.
>>
>> So how is this fixed in linux ? I believe that ABC implementation will
>> fix this issue even if I am not completely sure
>> about that ?
>>     
>
> ABC is nowadays disable by default because it was found to annoy small
> segment sending folks enough for them to periodically to come up
> complaining with that "discovery" on netdev... :-) ...ABC is not
> that necessary in Linux anyway because Linux' segment based counting is
> not vulnerable to same kind of problems that byte-based approach would
> be. Faster window growth during slow-start could be done without ABC
> though nobody has yet stepped in to do that (though I just got an idea
> while writing how to do that cleanly :-)).
>
>   
>> Also as LRO adds some latency, it seems possible to me that the sender
>> retransmission timer will expires before the
>> delayed ack timer expires.
>>     
>
> In theory yes, but in reality that shouldn't happen since RTT is
> calculated so that it would include the delayed ACK delays.
>
>   
>> In this case, how is this gonna work ? Is it
>> possible that the sender will stay stuck in
>> its slow start trying to retransmit endlessly the same n packets ?
>>     
>
> It wouldn't anyway, because receiver would ACK out-of-order (a duplicate
> below window) segments immediately. ...And we would resort FRTO in between
> too and RTO would be declared spurious and TCP would continue sending
> new data.
>
>
> --
>  i.
>   
thanks for your help,

--jp


