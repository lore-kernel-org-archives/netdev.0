From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Mon, 7 Mar 2016 10:28:04 -0800
Message-ID: <CAA93jw5fvGQ5L7dQupFX4ymhxquswSit1ZiATKmLp4+O4Mwbrw@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<E1abfnE-0000VS-00@www.xplot.org>
	<CA+BoTQk6J7kgdie9aX24MB+8PxN3oFUh0eVdmVrdyptW5RxQXg@mail.gmail.com>
	<CAPp0ZBYP9UzUTtPz=vivUQkE2FiGSsJjDaecQtPuK8y_d3ccqA@mail.gmail.com>
	<56DD99AA.8050403@openwrt.org>
	<CAHqTa-2-uZ0PUdwp33E588EU2a7T6KnTYs8RWfNDEzgOLseG9g@mail.gmail.com>
	<CAA93jw4JG_uEZaxk1JDKndq9K0+QPwKaAmK6=gZ8e-7qNmc=Cw@mail.gmail.com>
	<CAHqTa-1m3209qqLO19diB5ONd1o3whEnBGJkbPpV1m3UfSGJvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Felix Fietkau <nbd@openwrt.org>,
	Michal Kazior <michal.kazior@tieto.com>,
	Tim Shepard <shep@alum.mit.edu>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Andrew Mcgregor <andrewmcgr@google.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Avery Pennarun <apenwarr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35962 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbcCGS2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 13:28:19 -0500
In-Reply-To: <CAHqTa-1m3209qqLO19diB5ONd1o3whEnBGJkbPpV1m3UfSGJvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 9:14 AM, Avery Pennarun <apenwarr@gmail.com> wrote:
> On Mon, Mar 7, 2016 at 11:54 AM, Dave Taht <dave.taht@gmail.com> wrote:
>> If I can just get a coherent patch set that I can build, I will gladly
>> join you on the testing ath9k in particular... can probably do ath10k,
>> too - and do a bit of code review... this week. it's very exciting
>> watching all this activity...
>>
>> but I confess that I've totally lost track of what set of trees and
>> patchwork I should try to pull from. wireless-drivers-next? ath10k?
>> wireless-next? net-next? toke and I have a ton of x86 platforms
>> available to test on....
>>
>> Avery - which patches did you use??? on top of what?
>
> The patch series I'm currently using can be found here:
>
>   git fetch https://gfiber.googlesource.com/vendor/opensource/backports
> ath9k_txq+fq_codel

No common commits, but ok, thx for a buildable-looking tree.

d@dancer:~/git/linux$ git clone -b ath9k_txq+fq_codel --reference
net-next https://gfiber.googlesource.com/vendor/opensource/backports
Cloning into 'backports'...
warning: no common commits
remote: Sending approximately 30.48 MiB ...
remote: Counting objects: 4758, done
remote: Finding sources: 100% (5/5)
remote: Total 19312 (delta 12999), reused 19308 (delta 12999)
Receiving objects: 100% (19312/19312), 30.48 MiB | 6.23 MiB/s, done.
Resolving deltas: 100% (12999/12999), done.


>
> That's again backports-20160122, which comes from linux-next as of
> 20160122.  You can either build backports against whatever kernel
> you're using (probably easiest) or try to use that version of
> linux-next, or rebase the patches onto your favourite kernel.
>
>> In terms of "smoothing" codel...
>>
>> I emphatically do not think codel in it's current form is "ready" for
>> wireless, at the very least the target should not be much lower than
>> 20ms in your 2 station tests.  There is another bit in codel where the
>> algo "turns off" with only a single MTU's worth of packets
>> outstanding, which could get bumped to the ideal size of the
>> aggregate. "ideal" kind of being a variable based on a ton of other
>> factors...
>
> Yeah, I figured that sort of thing would come up.  I'm feeling forward
> progress just by finally seeing the buggy oscillations finally happen,
> though. :)

It's *very* exciting to see y'all break things in a measurable, yet
positive direction.

>
>> the underlying code needs to be striving successfully for per-station
>> airtime fairness for this to work at all, and the driver/card
>> interface nearly as tight as BQL is for the fq portion to behave
>> sanely. I'd configure codel at a higher target and try to observe what
>> is going on at the fq level til that got saner.
>
> That seems like two good goals.  So Emmanuel's BQL-like thing seems
> like we'll need it soon.
>
> As for per-station airtime fairness, what's a good approximation of
> that?  Perhaps round-robin between stations, one aggregate per turn,
> where each aggregate has a maximum allowed latency?

Strict round robin is a start, and simplest, yes. Sure.

"Oldest station queues first" on a round (probably) has higher
potential for maximizing txops, but requires more overhead. (shortest
queue first would be bad). There's another algo based on last received
packets from a station possibly worth fiddling with in the long run...

as "maximum allowed latency" - well, to me that is eventually also a
variable, based on the number of stations that have to be scheduled on
that round. Trying to get away from 10 stations eating 5.7ms each +
return traffic on a round would be nicer. If you want a constant, for
now, aim for 2048us or 1TU.

> I don't know how
> the current code works, but it's probably almost like that, as long as
> we only put one aggregate's worth of stuff into each hwq, which I
> guess is what the BQL-like thing will do.

I would avoid trying to think about or using 802.11e's 4 queues at the
moment[1]. We also have fallout from mu-mimo to deal with, eventually,
also, but gang scheduling starts to fall out naturally from these
structures and methods...

>
> So if I understand correctly, what we need is, in the following order:
> 1) Disable fq_codel for now, and get BQL-like thing working in ath9k
> (and ensure we're getting airtime fairness even without fq_codel);
> 2) Re-enable fq_codel and increase fq_codel's target up to 20ms for now;
> 3) Tweak fq_codel's "turn off" size to be larger (how important is this?)
>
> Is that right?

Sounds good. I have not reviewed the codel5 based implementation, it
may not even have idea "#3" in it at the moment at all.  The relevant
line in  codel.h is in codel_should_drop

" if (codel_time_before(vars->ldelay, params->target) ||
            sch->qstats.backlog <= stats->maxpacket) {"

where instead of maxpacket you might use "some currently good looking
number for the a good aggregate size for this station". I sadly note
that in wifi you also have to worry about packets (42 max on n) AND
bytes....


[1] I've published a lot of stuff showing how damaging 802.11e's edca
scheduling can be - I lean towards, at most, 2-3 aggregates being in
the hardware, essentially disabling the VO queue on 802.11n (not sure
on ac), in favor of VI, promoting or demoting an assembled aggregate
from BE to BK or VI as needed at the last second before submitting it
to the hardware, trying harder to only have one aggregate outstanding
to one station at a time, etc.
