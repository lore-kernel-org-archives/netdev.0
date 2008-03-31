From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [PATCH] GENETLINK: Global lock refined to family granularity
Date: Mon, 31 Mar 2008 13:21:38 +0200
Message-ID: <47F0C942.9070603@st.com>
References: <47EB8D8D.8020506@st.com> <20080331103350.GZ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog16.obsmtp.com ([207.126.144.130]:55962 "EHLO
	s200aog16.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbYCaLXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 07:23:55 -0400
In-Reply-To: <20080331103350.GZ20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.3.2008 12:33, Thomas Graf wrote:
> * Richard MUSIL <richard.musil@st.com> 2008-03-27 13:05
>> This patch is a revive of the patch I posted half a year ago. In that time
>> Thomas Graf (who was acting as maintainer of genetlink module) accepted
>> the idea, but suggested to do it using RCU lists. Since I did not have
>> and experience with RCU lists, we agreed, he will implement it himself.
>>
>> Since that time, he neither did it, nor replied to my recent emails and
>> I guess he is no longer active.
> 
> Sorry but I didn't receive any recent emails.

Sent two of them, one on 25.9.2007 and one on 25.1.2008, no reply, must
got lost.

>> I am asking, whomever maintains genetlink right now, for including this
>> patch. (Currently, this is patch to linux-2.6.25-rc7.)
>>
>> The idea behind (i.e. why I needed it) is device driver, which uses
>> genetlink to talk to userspace and which creates virtual devices and
>> registers families for them in the runtime. So these devices can also
>> talk to userspace using genetlink.
>>
>> Current implementation prevents that, because processing any single
>> genetlink message blocks complete genetlink infrastructure (i.e.
>> registrations, and deregistrations).
> 
> On a first sight your patch seemed very legitimate although the amount
> of locks taken for every single message received was very irritating.

It takes two locks, instead of one. I do not see, how it could be less
(in terms of synchronization primitives - but not necessarily mutexes)
if I want that level of granularity. Might be more efficient with RCU
lists (but I do not know), but complexity remains the same.

> Also your patch explicitely allows registration operations but when the
> family being currently received on is manipulated, it will simply deadlock.

In that case, nothing can be done. Of course, trying to unregister
family form its own handler could lead to either crash or deadlock. The
point was, it would not deadlock when manipulating other family - which
happens with current implementation.
Also, it would allow processing of different messages in parallel as
long as they are belonging to different families. Right now, the
processing is blocked as long as any single message is processed.

> So this patch is about allowing registration of operations for other
> families at the cost of two additional locks for every message received

I am not sure about two additional locks, so far I see only one - the
family lock.

> combined with complex locking logic. All a bit much for something that
> can be easly solved using a workqueue.

I am not convinced about that. Does it mean you suggest that any
genetlink message handler should by default offload processing to
workqueue, so it won't block any other message processing from any other
family?

I can imagine running two completely different families with two
completely different needs which do not know about each other at all.
Right now, the one can easily block the other.

So the workqueue does not seem that obvious to me.

> BTW, your patch does not account for multicast group registration.

You right it does not. Should I look into it, or was your answer
definitive no?

Richard
