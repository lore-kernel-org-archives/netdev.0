From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential race in ip4_datagram_release_cb
Date: Fri, 6 Jun 2014 11:13:54 -0700
Message-ID: <CAADnVQJB_1aPJ4tz_BaHuZAf-vQqfEWxcaQSCb7s1nSySMomYw@mail.gmail.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	<1402059375.3645.284.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQL=D_KF2iRLO1Ufoih3Rg-WtSA9UYuU0OjOZebGBryVHA@mail.gmail.com>
	<1402071367.3645.305.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQL47b+nFo+WUJGw=oCEVwRHtK98poe8SJqw4F-jAUXoyw@mail.gmail.com>
	<1402077364.3645.310.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Preobrazhensky <preobr@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	dormando <dormando@rydia.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36013 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaFFSNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 14:13:55 -0400
Received: by mail-qg0-f49.google.com with SMTP id a108so5151128qge.36
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 11:13:55 -0700 (PDT)
In-Reply-To: <1402077364.3645.310.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 6, 2014 at 10:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-06-06 at 10:44 -0700, Alexei Starovoitov wrote:
>> On Fri, Jun 6, 2014 at 9:16 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> > We should either :
>> >
>> > 1) use xchg() and no lock at all to change sk_dst_cache, as we did for
>> > sk_rx_dst ( cf udp_sk_rx_dst_set() )
>> >
>> > 2) No longer use sk_dst_lock, and always use the socket lock
>> > (sk->sk_lock.slock) instead.
>>
>> Probably needs some combination of both.
>
> I do not think so.
>
> If we use xchg(), then we do not need anything else.
>
> If we use a spinlock, then xchg() seems useless.
>
> Any combination is buggy.
>
> In the past, UDP transmit was holding socket lock,
> but we added a lockless path, and I suppose more people
> use a UDP socket from different threads.
>
> Then, Steffen added the ip4_datagram_release_cb() thing,
> increasing the chance of mixing both 'protections'.
>
> Setting sk_dst_cache should hardly be a hot path.

yeah. if we use sk_lock.slock then xchg is obviously not needed.
By 'both' I meant to do xchg() and get rid of sk_dst_lock to speed it up.
Though not worth going too fancy if speed is not needed.

>
