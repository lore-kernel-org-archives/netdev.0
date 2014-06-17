From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP data chunk bundling when SCTP_NODELAY is set
Date: Tue, 17 Jun 2014 12:49:38 -0400
Message-ID: <53A071A2.20909@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725DD38@AcuExch.aculab.com> <53A062A9.70806@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1725DF55@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:32903 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964966AbaFQQtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 12:49:41 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so10340187qcv.12
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 09:49:40 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725DF55@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2014 12:07 PM, David Laight wrote:
> From: Vlad Yasevich
>> On 06/17/2014 10:17 AM, David Laight wrote:
>>> If SCTP_NODELAY is set it is difficult to get SCTP to bundle
>>> data chunks into ethernet packets.
>>> This leads to very high packet rates which bundling could easily
>>> reduce by a factor or 8 or 10.
>>>
>>> Nagle can't really be enabled because it generates unwanted delays
>>> when traffic is light (Nagle only really works for unidirectional bulk
>>> data and command-response when the messages are smaller than the mtu).
>>>
>>> Even if the sending application knows it has more data to send,
>>> there isn't much it can do to get the chunks bundled.
>>>
>>> AFAICT 'corking' the socket even stops full sized packets being
>>> sent - so the application will deadlock if the socket write
>>> buffer size is reached before the socket is 'uncorked'.
>>> This also means that the application can't send back to back
>>> full sized packets unless it uncorks the socket at exactly
>>> the right places.
>>>
>>> MSG_MORE isn't supported by SCTP, but I'm not sure it would help.
>>> You really need a MSG_NO_MORE flag and to leave Nagle enabled.
>>>
>>> About the only thing I can think of is to normally have Nagle
>>> enabled, and then perform the following sequence to force the
>>> buffered data chunks be sent:
>>> 1) disable Nagle
>>> 2) cork the socket
>>> 3) uncork the socket
>>> 4) enable Nagle
>>> Four socket calls is a little excessive!
>>
>> First, how are you corking an SCTP socket?  There is no SCTP_CORK
>> and looking at the code, I don't see how an SCTP queue can be
>> cored by user...
> 
> I only looked as far as seeing that the code in sm_sideffect.c
> allows someone else to have corked the socket, and the effect
> that the 'cork' had.

Right.  Cork is pretty dumb right now.  It should work more like TCP
where if you've queued up enough data to bypass nagle checks, it should
flush some number for full MTU packets.

> 
>> I suppose we could implement SCTP_CORK to do the right thing.
>>
>> I thought is possibly utilizing something like sendmmsg() and passing
>> an extra flag to let it be know that this is a multi-message send
>> that should be queued up by sctp..
> 
> It would be as easy to expose the extra flag to the 'application'
> allowing it to use sendmsg() or sendmmsg().
> While sendmmsg() saves a system call, it is fairly horrid to use.
> (and I'm sending from a kernel driver so don't care about the 
> system call cost!)
> 
> Possibly MSG_MORE with Nagle disabled could invoke the Nagle send
> delay - but you'd need to know whether any chunks in the queue
> had MSG_MORE clear.

That's why doing this with cork would be simpler.  The ULP can just
queue up a bunch of small data and if we pass nagle checks, it will be
flushed.  If not, uncork will flush it.

I could work up a patch for you if you want.

Thanks
-vlad

> It would also be nice to have a 'send on local timeout', rather than
> Nagle's 'wait for everything to be acked'.
> 
> 	David
> 
> 
> 
