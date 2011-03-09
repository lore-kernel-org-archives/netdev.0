From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 8 Mar 2011 20:33:39 -0500
Message-ID: <AANLkTi=k+9ObSFjS2txWWqrAAR6WD+TJpnnxfi+W-xJj@mail.gmail.com>
References: <il4vur$3ka$1@dough.gmane.org>
	<20110308111011.GA27967@xanadu.blop.info>
	<4D764AAC.30302@ncsu.edu>
	<20110308.114346.48506864.davem@davemloft.net>
	<20110308152103.714f5f05@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rhee@ncsu.edu,
	lucas.nussbaum@loria.fr, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46894 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289Ab1CIBdl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 20:33:41 -0500
Received: by bwz15 with SMTP id 15so315744bwz.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 17:33:40 -0800 (PST)
In-Reply-To: <20110308152103.714f5f05@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Thank you for your feedback. Please see my answers below.

On Tue, Mar 8, 2011 at 6:21 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Tue, 08 Mar 2011 11:43:46 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Injong Rhee <rhee@ncsu.edu>
>> Date: Tue, 08 Mar 2011 10:26:36 -0500
>>
>> > Thanks for updating CUBIC hystart. You might want to test the
>> > cases with more background traffic and verify whether this
>> > threshold is too conservative.
>>
>> So let's get down to basics.
>>
>> What does Hystart do specially that allows it to avoid all of the
>> problems that TCP VEGAS runs into.
>>
>> Specifically, that if you use RTTs to make congestion control
>> decisions it is impossible to notice new bandwidth becomming availab=
le
>> fast enough.
>>
>> Again, it's impossible to react fast enough. =C2=A0No matter what yo=
u tweak
>> all of your various settings to, this problem will still exist.
>>
>> This is a core issue, you cannot get around it.
>>
>> This is why I feel that Hystart is fundamentally flawed and we shoul=
d
>> turn it off by default if not flat-out remove it.
>>
>> Distributions are turning it off by default already, therefore it's
>> stupid for the upstream kernel to behave differently if that's what
>> %99 of the world is going to end up experiencing.
>
> The assumption in Hystart that spacing between ACK's is solely due to
> congestion is a bad. If you read the paper, this is why FreeBSD's
> estimation logic is dismissed. The Hystart problem is different
> than the Vegas issue.
>
> Algorithms that look at min RTT are ok, since the lower bound is
> fixed; additional queuing and variation in network only increases RTT
> it never reduces it. With a min RTT it is possible to compute the
> upper bound on available bandwidth. i.e If all packets were as good a=
s
> this estimate minRTT then the available bandwidth is X. But then usin=
g
> an individual RTT sample to estimate unused bandwidth is flawed. To
> quote paper.
>
> =C2=A0"Thus, by checking whether =E2=88=86(N ) is larger than Dmin , =
we
> can detect whether cwnd has reached the available capacity
> of the path"
>
> So what goes wrong:
> =C2=A01. Dmin can be too large because this connection always sees de=
lays
> due to other traffic or hardware. i.e buffer bloat. =C2=A0This would =
cause
> the bandwidth estimate to be too low and therefore TCP would leave
> slow start too early (and not get up to full bandwidth).

This is true. But the idea is that running the congestion avoidance
algorithm of CUBIC for this case is better than hurting other flows
with abrupt perturbation, since the growth of CUBIC is quite
responsive and grab the bandwidth quickly in normal network
conditions.

>
> =C2=A02. Dmin can be smaller than the clock resolution. This would ca=
use
> either sample to be ignored, or Dmin to be zero. If Dmin is zero,
> the bandwidth estimate would in theory be infinite, which would
> lead to TCP not leaving slow start because of Hystart. Instead
> TCP would leave slow start at first loss.

True. But since HyStart didn't clamp the threshold,  ca->delay_min>>4,
it can prematurely leave slow start for very small Dmin. I think this
needs to be fixed, along with the hard-coded 2ms you mentioned below.


>
> Other possible problems:
> =C2=A03. ACK's could be nudged together by variations in delay.
> This would cause HyStart to exit slow start prematurely. To false
> think it is an ACK train.

This doesn't happen when the delay is not too small (in typical WAN
including DSL), but it is possible with very small delays since the
code checking the valid ACK train uses the 2ms fixed value, which is
large for LAN.

>
> Noise in network is not catastrophic, it just
> causes TCP to exit slow-start early and have to go into normal
> window growth phase. The problem is that the original non-Hystart
> behavior of Cubic is unfair; the first flow dominates the link
> and other flows are unable to get in. If you run tests with two
> flows one will get a larger share of the bandwidth.
>
> I think Hystart is okay in concept but there may be issues
> on low RTT links as well as other corner cases that need bug
> fixing.

We do not use the delay as indication of congestion, but we use it for
improving the stability and overall performance.
Preventing burst losses quite help for mid to large BDP paths and the
performance results with non-TCP-SACK receivers are also encouraging.
I will work on the fix for the issues below.

>
> 1. Needs to use better resolution than HZ. Since HZ can be 100.
> 2. Hardcoding 2ms as spacing between ACK's as train is wrong
> =C2=A0 for local networks.
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
