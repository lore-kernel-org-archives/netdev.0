From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: SO_TIMESTAMP on tcp sockets?
Date: Tue, 8 May 2012 14:35:14 -0700
Message-ID: <CALCETrUeBhH8irvZmpYPdjnnLwTfaLTEgU6g_m+r=82iLcREpw@mail.gmail.com>
References: <CALCETrVUjLz63uzr+UTf-G1jq9QDcX6Gf9D6AWK8_GmunsJGnw@mail.gmail.com>
 <1336451831.3752.2373.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34237 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab2EHVff convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 17:35:35 -0400
Received: by pbbrp8 with SMTP id rp8so8555375pbb.19
        for <netdev@vger.kernel.org>; Tue, 08 May 2012 14:35:35 -0700 (PDT)
In-Reply-To: <1336451831.3752.2373.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 7, 2012 at 9:37 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Mon, 2012-05-07 at 18:39 -0700, Andy Lutomirski wrote:
>> I've been using SO_TIMESTAMPNS to good effect on udp sockets. =A0I'd
>> like to do the same thing for tcp. =A0I realize that this is
>> semantically strange [1], but I don't think there's a real issue for
>> my use case. =A0We have very thin streams -- we are likely to proces=
s
>> each incoming segment as it is received, and I want the most precise
>> timestamp possible on each segment.
>>
>> A simple approach (I think) would be for a recvmsg on a tcp socket
>> with SO_TIMESTAMP(NS) to return at most one skb worth of data along
>> with the timestamp associated with that skb. =A0This could be a litt=
le
>> strange if multiple segments overlap or if lro is involved, but
>> neither of those cases seems like a major problem.
>>
>> Is there any interest in something like this?
>>
>
> LRO/GRO is not really a problem, buffers are merged because they are
> received in a very short time period. If you want nanosec timestampin=
g
> on TCP, just cancel the whole idea.
>
> TCP can 'collapse' several buffers onto single ones (to reduce memory
> overhead). Which timestamp would be chosen at collapse time ?
>
> net-next also has tcp coalescing, wich also merge buffers as soon as
> they enter receive or ofo queue.

Hmm.  Here are two possibilities:

1. When timestamping is on, turn off all coalescing on that socket.
Throughput starts to suck, but at least for my use case this is
irrelevant.

2. Instead of timestamping when a given piece of data arrived,
timestamp when the socket last became readable in the POLLIN sense.
Return the answer as ancillary data on the first recvmsg after the
socket becomes readable.  This would be enough for my purposes.
(Basically, I want to be able to correlate my receives with pcap data,
at least in the common case, and I also want to be able to estimate
latency between the network interrupt and my app handling the data.
The phy timestamp would be even better, but that's not supported on my
hardware.)

>
> Another problem with SO_TIMESTAMPNS is it globally enables time stamp=
ing
> on all skbs on the host, adding some latencies. (ktime_get() can be
> slowed down when time keeping triggers and hold xtime seqlock)
>
>

This doesn't bother me too much -- I'm already paying that cost.  In
any case, it should be mostly fixable by taking the xtime lock for
write a lot less often than we do now.  Getting the time (via vdso,
which is probably much better optimized than ktime_get) takes about
15ns on my machine.

--Andy
