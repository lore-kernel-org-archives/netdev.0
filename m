From: Injong Rhee <rhee@ncsu.edu>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 08 Mar 2011 20:30:57 -0500
Message-ID: <4D76D851.4050600@ncsu.edu>
References: <il4vur$3ka$1@dough.gmane.org>	<20110308111011.GA27967@xanadu.blop.info>	<4D764AAC.30302@ncsu.edu>	<20110308.114346.48506864.davem@davemloft.net> <20110308152103.714f5f05@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, lucas.nussbaum@loria.fr,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	sangtae.ha@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:34504 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068Ab1CIBbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 20:31:00 -0500
In-Reply-To: <20110308152103.714f5f05@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HyStart is a slow start algorithm, but not a congestion control=20
algorithm. So the difference between vegas and hystart is obvious. Yes.=
=20
Both hystart and vegas use delays for indication of congestion. But=20
hystart exits slow starts at the detection of congestion and enters=20
normal congestion avoidance; in some sense, it is much safer than vegas=
=20
as it does not change the regular behaviors of congestion control.

I think the main problem arising right now is not because it is using=20
noisy delays as congestion indication, but because of rather some=20
implementation issues like use of Hz, hardcoding 2ms, etc.

Then, you might ask why hystart can use delays while vegas can't. The=20
main motivation for use delays during slow start is that slow start=20
creates an environment where delay samples can be more trusted. That is=
=20
because it sends so many packets as a a burst because of doubling=20
windows, which can be used as packet train to estimate the available=20
capacity more reliably.

(tool 1) When many packets are sent in burst, the spacing in returning=20
ACKs can be a good indicator. Hystart also uses delays as an estimation=
=2E

(tool 2) If estimated avg delays increase beyond a certain threshold, i=
t=20
sees that as a possible congestion.

Now, both tools can be wrong. But that is not catastrophic since=20
congestion avoidance can kick in to save the day. In a pipe where no=20
other flows are competing, then exiting slow start too early can slow=20
things down as the window can be still too small. But that is in fact=20
when delays are most reliable. So those tests that say bad performance=20
with hystart are in fact, where hystart is supposed to perform well.

Then why do we have a bad performance? I think the answer is again the=20
implementation flaws -- use different hardware, some hardwired codes,=20
etc, and also could be related to a few corner cases like very low RTT=20
links.

Let us examine Stephen's analysis in more detail.

1. Use of minRTT is ok. I agree.
2. Dmin can be too large at the beginning. But it is just like minRTT.=20
This cannot be too large. If you trust minRTT, then delay estimation=20
should say that there is a congestion. This is exactly the opposite cas=
e=20
to the cases we are seeing. If Dmin is too large, then hystart would no=
t=20
exit the slow start as it does not detect the congestion. That is not=20
what we are seeing right now.

3. Dmin can be smaller than clock resolution. That is why we are using =
a=20
bunch of ACKs to get better accuracy. With a bunch of ACKs, we get=20
higher value of spacing so that we can take average.

4. If ACKs are nudged together, then hystart does not quit slow start.=20
Instead, it sees that there is no congestion. It is when it sees big=20
spacing between ACKs -- that is when it detects congestion.





On 3/8/11 6:21 PM, Stephen Hemminger wrote:
> On Tue, 08 Mar 2011 11:43:46 -0800 (PST)
> David Miller<davem@davemloft.net>  wrote:
>
>> From: Injong Rhee<rhee@ncsu.edu>
>> Date: Tue, 08 Mar 2011 10:26:36 -0500
>>
>>> Thanks for updating CUBIC hystart. You might want to test the
>>> cases with more background traffic and verify whether this
>>> threshold is too conservative.
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
>> Again, it's impossible to react fast enough.  No matter what you twe=
ak
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
>    "Thus, by checking whether =E2=88=86(N ) is larger than Dmin , we
> can detect whether cwnd has reached the available capacity
> of the path"
>
> So what goes wrong:
>    1. Dmin can be too large because this connection always sees delay=
s
> due to other traffic or hardware. i.e buffer bloat.  This would cause
> the bandwidth estimate to be too low and therefore TCP would leave
> slow start too early (and not get up to full bandwidth).
>
>    2. Dmin can be smaller than the clock resolution. This would cause
> either sample to be ignored, or Dmin to be zero. If Dmin is zero,
> the bandwidth estimate would in theory be infinite, which would
> lead to TCP not leaving slow start because of Hystart. Instead
> TCP would leave slow start at first loss.
>
> Other possible problems:
>    3. ACK's could be nudged together by variations in delay.
> This would cause HyStart to exit slow start prematurely. To false
> think it is an ACK train.
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
>
> 1. Needs to use better resolution than HZ. Since HZ can be 100.
> 2. Hardcoding 2ms as spacing between ACK's as train is wrong
>     for local networks.
>
>
>
>
>

