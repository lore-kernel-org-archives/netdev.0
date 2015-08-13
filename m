From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [Cluster-devel] [PATCH 4/6] dlm: use sctp 1-to-1 API
Date: Thu, 13 Aug 2015 09:13:22 -0300
Message-ID: <55CC89E2.40109@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
 <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB794EB@AcuExch.aculab.com>
 <55CB4729.2060203@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB7979F@AcuExch.aculab.com>
 <55CB778E.4050002@gmail.com> <55CC6571.70009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"tan.hu@zte.com.cn" <tan.hu@zte.com.cn>,
	Neil Horman <nhorman@tuxdriver.com>
To: Steven Whitehouse <swhiteho@redhat.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"cluster-devel@redhat.com" <cluster-devel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:33851 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbbHMMNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 08:13:30 -0400
Received: by qgeg42 with SMTP id g42so29496501qge.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 05:13:29 -0700 (PDT)
In-Reply-To: <55CC6571.70009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 13-08-2015 06:37, Steven Whitehouse escreveu:
> Hi,
>
> On 12/08/15 17:42, Marcelo Ricardo Leitner wrote:
>> Em 12-08-2015 12:33, David Laight escreveu:
>>> From: Marcelo Ricardo Leitner
>>>> Sent: 12 August 2015 14:16
>>>> Em 12-08-2015 07:23, David Laight escreveu:
>>>>> From: Marcelo Ricardo Leitner
>>>>>> Sent: 11 August 2015 23:22
>>>>>> DLM is using 1-to-many API but in a 1-to-1 fashion. That is, it's not
>>>>>> needed but this causes it to use sctp_do_peeloff() to mimic an
>>>>>> kernel_accept() and this causes a symbol dependency on sctp module.
>>>>>>
>>>>>> By switching it to 1-to-1 API we can avoid this dependency and also
>>>>>> reduce quite a lot of SCTP-specific code in lowcomms.c.
>>>>> ...
>>>>>
>>>>> You still need to enable sctp notifications (I think the patch deleted
>>>>> that code).
>>>>> Otherwise you don't get any kind of indication if the remote system
>>>>> 'resets' (ie sends an new INIT chunk) on an existing connection.
>>>>
>>>> Right, it would miss the restart event and could generate a corrupted
>>>> tx/rx buffers by glueing parts of old messages with new ones.
>>>
>>> Except that it is SCTP so you'd expect DATA chunks to contain entire
>>> messages and so get unexpected message sequences rather than corrupt
>>> messages.
>>
>> I was thinking on cases where the buf for recvmsg is not enough to
>> hold the chunk, so that the remaining is left for another attempt
>> (sctp_recvmsg, around line 2130), but sounds like we won't purge rx
>> buffer when the reset happens so that doesn't matter. The association
>> is replaced, but the buffers are kept.
>>
>> Out of order messages aren't a problem for dlm. It can recover from
>> that just fine, as it doesn't have a specific handshake at beginning
>> or something like that and upper layers are agnostic to that state
>> transition (disconnect/reconnect/...), this should be fine.
>>
> I'm not sure thats true - DLM does rely on message ordering in some
> cases in order to ensure correct functioning. So depending on how SCTP
> is interfaced to DLM, it might potentially be an issue,

Yes, that ordering is still kept. Like, it won't flip a newer message to 
a first position. It's just that if DLM had its own handshake exposing 
its version and features, one peer (the old one) would get it out of the 
blue and the other (the new one) would never get it. Or if its messages 
would depend on a previous state, meaning LockMsgC is only acceptable if 
LockMsgA was already performed on that connection. That is my 
understanding from what David pointed out and what I checked here.

Then as lowcomms previously allowed connection closing without telling 
anyone above it that it happened, it should be fine, right? It will just 
finish processing the old messages and then start on the new ones, just 
like before.

Thanks,
Marcelo
