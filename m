From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Wed, 25 Aug 2010 18:49:35 -0700
Message-ID: <AANLkTik5N=j-2NQRFFktOs7gfDEU=Gdrva4fw6BKRqxT@mail.gmail.com>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
	<1282632262.2378.1681.camel@edumazet-laptop>
	<4C737D15.5060400@nets.rwth-aachen.de>
	<423116d1d215b0fb3d1c966fb8167508@localhost>
	<4C73DE32.1030802@nets.rwth-aachen.de>
	<20100824162844.GA7889@nuttenaction>
	<AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
	<cb32d2a8676d5447e04882302228c4b6@localhost>
	<AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com>
	<20100825225942.GA3190@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:58180 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225Ab0HZBtj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 21:49:39 -0400
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o7Q1nbtT017861
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 18:49:37 -0700
Received: from gxk6 (gxk6.prod.google.com [10.202.11.6])
	by kpbe19.cbf.corp.google.com with ESMTP id o7Q1naKx023589
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 18:49:36 -0700
Received: by gxk6 with SMTP id 6so547605gxk.30
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 18:49:36 -0700 (PDT)
In-Reply-To: <20100825225942.GA3190@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 25, 2010 at 3:59 PM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Jerry Chu | 2010-08-25 13:20:52 [-0700]:
>
>>Ok, let's try to finalize the API signature so our apps folks can pro=
gram to it
>>now and don't have to change it later when we have a more complete
>>implementation involving the TCP option as well.
>>
>>What should we call this new option? TCP_UTO or TCP_USERTIMEOUT
>>or else?
>
> Well, currently I am not sure if this is the best idea. Your implemen=
tation
> address the local timeout, user's can tweak their local timeout. UTO =
on the
> other hand provides functionality to tweak peer's timeout. I will use=
 your

Yes on a 2nd look RFC5482 seems more complex than I originally thought,=
 allowing
many different combinations of local/adv/remote UTO... Are they really
useful, e.g.,
why allowing USER_TIMEOUT to be different from ADV_UTO?? My original th=
ought
was the local UTO will always be the same as the one advertised to
remote so only
one API will be needed plus bunch of flags for ENABLED, CHANGEABLE...

> timeout implementation (see the comments below) if I receive a TCP UT=
O options
> message, but via setsockopt TCP_UTO I try to modify peer's TCP timeou=
t. Local
> and remote RTO of them must not necessarily coherent. =A0For example =
the local
> RTO can be larger as the remote RTO.
>
> My idea is that TCP_UTO should be used for the remote part. Another o=
ption
> should be taken for the local part, no matter if TCP_UTO will overwri=
te the
> local part too if the local timeout if smaller as the announced timeo=
ut.

Ok. How about TCP_USER_TIMEOUT, which clearly refers to the local timeo=
ut?
(Is it useful to elevate it to SO_USER_TIMEOUT?)

You can call yours TCP_UTO and the key differentiator is 'O' (referring=
 to a TCP
option).

>
> TCP_REMOTE_UTO and TCP_LOCAL_RTO, ... no idea at the moment! ;(
>
> Any ideas on that?
>
>>It will take a single argument of unsigned int in milliseconds
>>(right?) that specifies
>>"user_timeout". The first retransmit timer pops after user_timeout wi=
ll cause
>>the connection to be aborted and ETIMEOUT to be returned.
>
> 2^32 / (1000 * 60 * 60 * 24) > 22 days -> great!
>
>>>This interface should be sufficient for you and later
>>> for me. Afterwards I provide an patch which apply on your groundwor=
k. My
>>> patch handle TCP UTO specific functionality like TCP option protoco=
l
>>> handling functionality, socket option, permissions, lower- and uppe=
r
>>> bounds, ...
>>
>>The keepalive timer is driven off a different timer sk_timer than
>>icsk_retransmit_timer
>>so as far as code is concerned they are separate (and I don't see any
>>interaction
>>between the two).
>>
>>But RFC5482 does contain the following paragraph:
>>
>>4.2. TCP Keep-Alives
>>
>> =A0 Some TCP implementations, such as those in BSD systems, use a
>> =A0 different abort policy for TCP keep-alives than for user data. =A0=
Thus,
>> =A0 the TCP keep-alive mechanism might abort a connection that would
>> =A0 otherwise have survived the transient period without connectivit=
y.
>> =A0 Therefore, if a connection that enables keep-alives is also usin=
g the
>> =A0 TCP User Timeout Option, then the keep-alive timer MUST be set t=
o a
>> =A0 value larger than that of the adopted USER TIMEOUT.
>>
>>At this moment I'm not inclined to muck with the keepalive code (alth=
ough
>>the change could be simple) so I'll leave this case for you to handle=
=2E
>>
>>>
>>> Today in the evening I will focus on TCP Quick ACK modifications. A=
fter
>>> that I am in the Alps for vacation for 5 days. Later on I will work=
 on the
>>> patch (the patch is in a good state, modification and testing shoul=
d
>>> consume only 2 evenings - hopefully ;-).
>>>
>>> Cherry, is this ok for you?
>>
>>Sound good (and it's Jerry, not the girlish Cherry :) Oh, please comm=
ent on
>>my plan above.
>
> Sounds good for me! I mean I must see working code for final conclusi=
on, but
> the basic components are good. And sorry for the naming, Jerry - it w=
as not
> intention!

Ok, will send a new patch soon (but please comment on the above and nam=
ing).

Jerry

>
> Hagen
>
