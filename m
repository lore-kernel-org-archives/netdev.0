From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next v2] tcp: use RFC6298 compliant TCP RTO calculation
Date: Wed, 15 Jun 2016 13:38:30 -0700
Message-ID: <CANn89iLY27dQLXEmk9GMtACjjE0CWxqSK2FdM-Zo5HM5iA82XQ@mail.gmail.com>
References: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
 <20160614191841.21496-1-dmetz@mytum.de> <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615174114.GA16217@virgo.localdomain> <CAK6E8=fgQitOiXwjjn0gq93w7m5DQ2OHr_wvq-oGeAF2fhE-uA@mail.gmail.com>
 <16f7fad2-e8e3-44b7-af09-43467840bd00@mytum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Metz <daniel.metz@rohde-schwarz.com>
To: Daniel Metz <dmetz@mytum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33923 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225AbcFOUic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:38:32 -0400
Received: by mail-yw0-f177.google.com with SMTP id c72so24621844ywb.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 13:38:31 -0700 (PDT)
In-Reply-To: <16f7fad2-e8e3-44b7-af09-43467840bd00@mytum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 1:34 PM, Daniel Metz <dmetz@mytum.de> wrote:
> Yuchung Cheng | 2016-06-15 20:02:
>> Let me explain in a different way:
>>
>> * RFC6298 applies a lower bound of 1 second to RTO (section 2.4)
>>
>> * Linux currently applies a lower bound of 200ms (min_rto) to
>> K*RTTVAR, but /not/ RTO itself.
>>
>> * This patch applies the lower bound of 200ms to RTO, similar to RFC6298
>>
>>
>> Let's say the SRTT is 100ms and RTT variations is 10ms. The variation
>> is low because we've been sending large chunks, and RTT is fairly
>> stable, and we sample on every ACK. The RTOs produced are
>>
>> RFC6298: RTO=1s
>> Linux: RTO=300ms
>> This patch: RTO=200ms
>>
>> Then we send 1 packet out. The receiver delays the ACK up to 200ms.
>> The actual RTT can be longer because other network components further
>> delay the data or the ACK. This patch would surely fire the RTO
>> spuriously.
>>
>> so we can either implement RFC6298 faithfully, or apply the
>> lower-bound as-is, or something in between. But the current patch
>> as-is is more aggressive. Did I miss something?
>
> Thank you for the clarification. The fundamental thought of this patch was
> to decrease Linux RTO overestimation. This also involved not clinging to the
> RFC 6298 MinRTO of 1 second ((2.4) "[...] at the same time acknowledging
> that at some future point, research may show that a smaller minimum RTO is
> acceptable or superior."). A more aggressive RTO will of course increase the
> amount of Spurious Retransmission. The question is, if the benefit is higher
> than the sacrifice. The tests we conducted did not show significant negative
> impact so far. However, for sender-limited TCP flows the results were
> promising.
>

I guess the problem is that some folks use smaller rto than
RTAX_RTO_MIN , look at tcp_rto_min()
