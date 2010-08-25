From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Wed, 25 Aug 2010 13:20:52 -0700
Message-ID: <AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
	<1282632262.2378.1681.camel@edumazet-laptop>
	<4C737D15.5060400@nets.rwth-aachen.de>
	<423116d1d215b0fb3d1c966fb8167508@localhost>
	<4C73DE32.1030802@nets.rwth-aachen.de>
	<20100824162844.GA7889@nuttenaction>
	<AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
	<cb32d2a8676d5447e04882302228c4b6@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:29975 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab0HYUU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 16:20:56 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o7PKKsje029961
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 13:20:54 -0700
Received: from yxk30 (yxk30.prod.google.com [10.190.3.158])
	by wpaz29.hot.corp.google.com with ESMTP id o7PKKqcB002739
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 13:20:53 -0700
Received: by yxk30 with SMTP id 30so415956yxk.20
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 13:20:52 -0700 (PDT)
In-Reply-To: <cb32d2a8676d5447e04882302228c4b6@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hagen,

On Wed, Aug 25, 2010 at 1:21 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> On Tue, 24 Aug 2010 15:13:44 -0700, Jerry Chu <hkchu@google.com> wrote:
>> On Tue, Aug 24, 2010 at 9:28 AM, Hagen Paul Pfeifer <hagen@jauu.net>
> wrote:
>
>> So it looks like the user timeout can be used in either senario
> (shortening
>> or lengthening) and in both cases is a lower bound, i.e., the connection
>> should abort at or shortly after the specified user timeout.
>>
>> In this case does it make sense to combine the two? Will your TCP_UTO
>> patch be ready anytime soon?
>>
>> Again an alternative is to allow configuring tcp_retries2 and
> TCP_RTO_MAX
>> directly. I'm open to suggestion but we'd like to get something in
> sooner.
>
> Hello Chu! My Idea: you provide functionality to modify the user timeout.
> The interface should be generic enough to allow small as well as large - up
> to 22 days - values.

Ok, let's try to finalize the API signature so our apps folks can program to it
now and don't have to change it later when we have a more complete
implementation involving the TCP option as well.

What should we call this new option? TCP_UTO or TCP_USERTIMEOUT
or else?

It will take a single argument of unsigned int in milliseconds
(right?) that specifies
"user_timeout". The first retransmit timer pops after user_timeout will cause
the connection to be aborted and ETIMEOUT to be returned.

The RTO backoff code is largely intact. I've added some small tweak when
user_timeout is small to allow for a couple of more retries.

>This interface should be sufficient for you and later
> for me. Afterwards I provide an patch which apply on your groundwork. My
> patch handle TCP UTO specific functionality like TCP option protocol
> handling functionality, socket option, permissions, lower- and upper
> bounds, ...

Sounds good - you will provide all the missing details as described in RFC5482.

>
> Did you check interactions with other TCP timers like keep-alive timer?

The keepalive timer is driven off a different timer sk_timer than
icsk_retransmit_timer
so as far as code is concerned they are separate (and I don't see any
interaction
between the two).

But RFC5482 does contain the following paragraph:

4.2. TCP Keep-Alives

   Some TCP implementations, such as those in BSD systems, use a
   different abort policy for TCP keep-alives than for user data.  Thus,
   the TCP keep-alive mechanism might abort a connection that would
   otherwise have survived the transient period without connectivity.
   Therefore, if a connection that enables keep-alives is also using the
   TCP User Timeout Option, then the keep-alive timer MUST be set to a
   value larger than that of the adopted USER TIMEOUT.

At this moment I'm not inclined to muck with the keepalive code (although
the change could be simple) so I'll leave this case for you to handle.

>
> Today in the evening I will focus on TCP Quick ACK modifications. After
> that I am in the Alps for vacation for 5 days. Later on I will work on the
> patch (the patch is in a good state, modification and testing should
> consume only 2 evenings - hopefully ;-).
>
> Cherry, is this ok for you?

Sound good (and it's Jerry, not the girlish Cherry :) Oh, please comment on
my plan above.

Jerry

>
> Hagen
>
