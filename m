From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 13:23:15 -0700
Message-ID: <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
References: <20090309112521.GB37984@bts.sk>
	 <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	 <20090309195906.M50328@bts.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Marian_=CFurkovi=E8?= <md@bts.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:61594 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691AbZCIUXS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 16:23:18 -0400
Received: by an-out-0708.google.com with SMTP id c2so953790anc.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 13:23:15 -0700 (PDT)
In-Reply-To: <20090309195906.M50328@bts.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 1:02 PM, Marian =CFurkovi=E8 <md@bts.sk> wrote:
> On Mon, 9 Mar 2009 11:01:52 -0700, John Heffner wrote
>> On Mon, Mar 9, 2009 at 4:25 AM, Marian =CFurkovi=E8 <md@bts.sk> wrot=
e:
>> > =A0 As rx window autotuning is enabled in all recent kernels and w=
ith 1 GB
>> > of RAM the maximum tcp_rmem becomes 4 MB, this problem is spreadin=
g rapidly
>> > and we believe it needs urgent attention. As demontrated above, su=
ch huge
>> > rx window (which is at least 100*BDP of the example above) does no=
t deliver
>> > any performance gain but instead it seriously harms other hosts an=
d/or
>> > applications. It should also be noted, that host with autotuning e=
nabled
>> > steals an unfair share of the total available bandwidth, which mig=
ht look
>> > like a "better" performing TCP stack at first sight - however such=
 behaviour
>> > is not appropriate (RFC2914, section 3.2).
>>
>> It's well known that "standard" TCP fills all available drop-tail
>> buffers, and that this behavior is not desirable.
>
> Well, in practice that was always limited by receive window size, whi=
ch
> was by default 64 kB on most operating systems. So this undesirable b=
ehavior
> was limited to hosts where receive window was manually increased to h=
uge values.
>
> Today, the real effect of autotuning is the same as changing the rece=
ive window
> size to 4 MB on *all* hosts, since there's no mechanism to prevent it=
 from
> growing the window to maximum even for low RTT paths.
>
>> The situation you describe is exactly what congestion control (the
>> topic of RFC2914) should fix. =A0It is not the role of receive windo=
w
>> (flow control). =A0It is really the sender's job to detect and react=
 to
>> this, not the receiver's. =A0(We have had this discussion before on
>> netdev.)
>
> It's not of high importance whose job it is according to pure theory.
> What matters is, that autotuning introduced serious problem at LAN co=
ntext
> by disabling any possibility to properly react to increasing RTT. Aga=
in,
> it's not important whether this functionality was there by design or =
by
> coincidence, but it was holding the system well-balanced for many yea=
rs.

This is not a theoretical exercise, but one in good system design.
This "well-balanced" system was really broken all along, and
autotuning has exposed this.

A drop-tail queue size of 1000 packets on a local interface is
questionable, and I think this is the real source of your problem.
This change was introduced a few years ago on most drivers --
generally used to be 100 by default.  This was partly because TCP
slow-start has problems when a drop-tail queue is smaller than the
BDP.  (Limited slow-start is meant to address this problem, but
requires tuning to the right value.)  Again, using AQM is likely the
best solution.


> Now, as autotuning is enabled by default in stock kernel, this proble=
m is
> spreading into LANs without users even knowing what's going on. There=
fore
> I'd like to suggest to look for a decent fix which could be implement=
ed
> in relatively short time frame. My proposal is this:
>
> - measure RTT during the initial phase of TCP connection (first X seg=
ments)
> - compute maximal receive window size depending on measured RTT using
> =A0configurable constant representing the bandwidth part of BDP
> - let autotuning do its work upto that limit.

Let's take this proposal, and try it instead at the sender side, as
part of congestion control.  Would this proposal make sense in that
position?  Would you seriously consider it there?

(As a side note, this is in fact what happens if you disable
timestamps, since TCP cannot get an updated measurement of RTT without
timestamps, only a lower bound.  However, I consider this a limitation
not a feature.)

  -John
