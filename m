From: Dave Taht <dave.taht@gmail.com>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 15:45:10 -0700
Message-ID: <CAA93jw5pTHpUOX=iUnck8Eun2iNqkuKwG-Jd0X1oNxD_s9_prA@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
	<CAB=NE6XrkdiZcGEDGuYe=SwLBhTm=Mt4NaPzjV9j_W-8sVosOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36392 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1H2WpM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 18:45:12 -0400
In-Reply-To: <CAB=NE6XrkdiZcGEDGuYe=SwLBhTm=Mt4NaPzjV9j_W-8sVosOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a few other things to correct and comment on from the earlier
postings on this topic, but I'll start here, and work backwards.

On Mon, Aug 29, 2011 at 2:10 PM, Luis R. Rodriguez <mcgrof@gmail.com> w=
rote:
> On Mon, Aug 29, 2011 at 2:02 PM, Luis R. Rodriguez <mcgrof@gmail.com>=
 wrote:
>> Hope this helps sum up the issue for 802.11 and what we are faced wi=
th.
>
> I should elaborate a bit more here on ensuring people understand that
> the "bufferbloat" issue assumes simply not retrying frames is a good
> thing. This is incorrect.

No, we don't assume that "simply not retrying frames is a good thing".
The particular patch to which you are referring is part of a series of
patches still under development and test and is already obsolete.

In particular, the bug we were stomping in that thread involved
excessive retries in the packet aggregation queue on the ath9k driver,
where a ping at distance, was taking 1.6 seconds to get there.

http://www.bufferbloat.net/issues/216 - I note there was a lot of
confusing activity around this bug as this was the final piece of a
solution to why my mesh network in Nica went to h*ll in rain, and I
was trapped in a hotel at the time.

=46ar worse ping times have been observed in the field - 20+ seconds, o=
r
more - and as most internet protocols were designed with a little over
a lunar diameter in mind at most (~2 seconds of latency) - induced
latency of over a certain point is a very bad thing as it introduces
major problems/timeouts in what we now call the 'ANT' protocols -
DHCP, DNS, ARP, ND, etc - as well as begin to serious muck with the
servo mechanisms within TCP itself.

Please note that ping is merely a diagnostic - all sorts of packets
are exhibiting unbounded latency across most wireless standards.

Retrying wireless frames with bounded latency is a good thing.
Dropping packets to signal congestion is a good thing, also. Knowing
when to drop a packet is a very good thing. Preserving all packets, no
matter the cost, leads to RFC970.

> TCP's congestion algorithm is designed to
> help with the network conditions, not the dynamic PHY conditions.

Agreed, although things like TCP westwood and the earlier vegas,
attempt to also measure latencies more dynamically.

Also, I have always been an advocate of using "split tcp" when making
the jump to from wired to wireless.

>The
> dyanmic PHY conditions are handled through a slew of different means:
>
> =A0* Rate control
> =A0* Adaptive Noise Immunity effort
>
> Rate control is addressed either in firmware or by the driver.
> Typically rate control algorithms use some sort of metrics to do best
> guess at what rate a frame should be transmitted at. Minstrel was the
> first to say -- ahhh the hell with it, I give up and simply do trial
> and error and keep using the most reliable one but keep testing
> different rates as you go on. You fixate on the best one by using
> EWMA.

Which I like, very much.

I note that the gargoyle traffic shaper attempts to use the number of
packets in a conntracked connection as a measure of the TCP
mice/elephant transition to determine what traffic class the stream
should be in.

It cannot, however, detect a elephant/mouse transition, and perhaps
if there was also EWMA in conntrack, it may help the shaping problem
somewhat.

The concepts of "TCP mice and elephants" are well established in the
literature (see google), however the concept of an 'Ant' is not, it's
a new usage we have tried to establish to raise the importance of
lower latency needed, system critical packets on local wireless lans.

> What I was arguing early was that perhaps the same approach can be
> taken for the latency issues under the assumption the resolution is
> queue size and software retries. In fact this same principle might be
> able to be applicable to the aggregation segment size as well.

EWMA time and feedback to higher layers, of how long it takes packets
to make a given next-hop destination

Also somehow passing up the stack that 'this (wireless-n) destination
can handle an aggregate of 32 packets or XX bytes', and this
destination (g or b), can't, would make
applying higher level traffic shaping and fairness algorithms such as
SFB, RED, SFQ, HSFC, actually somewhat useful.

There is also the huge weight of wireless multicast packets on
wireless-n, which can be well over 300x1 vs normal packets at present,
to somehow account for throughout the stack. It only takes a little
multicast to mess up your whole day.

> Now, ANI is specific to hardware and does adjustments on hardware
> based on some known metrics. Today we have fixed thresholds for these
> but I wouldn't be surprised if taking minstrel-like guesses and doing
> trial and error and EWMA based fixation would help here as well.

In this 80 minute discussion of the interaction of wireless stack
between myself and felix feitkau, we attempt to summarize all the work
re bufferbloat and wireless specific to the ath9k done to date, and in
the last 10 minutes or so, speculate as to further solutions,based on
and expanding on andrew's input from the previous week.

http://huchra.bufferbloat.net/~d/talks/felix/

There will be a transcript available soon.

=46elix has (as of this morning) already implemented pieces of what we =
discussed.

There is an earlier discussion with Andrew McGregor, as well as
transcript, here:

http://huchra.bufferbloat.net/~d/talks/andrew/

The transcriptionist struggles mightily with the acronyms and I
haven't got around to trying to fix it yet. I'd like very much to
capture andrew's descriptions of how minstrel actually works and one
day fold all this stuff together, along with how power management
actually works on wireless, etc, so more people internalize how
wireless really works.





--
Dave T=E4ht
http://www.bufferbloat.net
