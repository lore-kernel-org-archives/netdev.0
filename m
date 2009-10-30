From: apetlund@simula.no
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Fri, 30 Oct 2009 16:27:56 +0100
Message-ID: <781045240b680074ca84c99ab6e13ea0.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Andreas Petlund" <apetlund@simula.no>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Arnd Hannemann" <hannemann@nets.rwth-aachen.de>,
	"Netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	"David Miller" <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932446AbZJ3P17@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 29 Oct 2009, apetlund@simula.no wrote:
>
>> > Andreas Petlund a =E9crit :
>> >
>> >> The removal of exponential backoff on a general basis has been
investigated and discussed already, for instance here:
>> >> http://ccr.sigcomm.org/online/?q=3Dnode/416
>> >> Such steps are, however considered drastic, and I agree that caut=
ion
>> must be made to thoroughly investigate the effects of such changes. =
The
changes introduced by the proposed patches, however, are not
>> default
>> >> behaviour, but an option for applications that suffer from the
thin-stream TCP increased retransmission latencies. They will, as
>> such,
>> not affect all streams. In addition, the changes will only be active=
 for
>> >> streams which are perpetually thin or in the early phase of
expanding
>> their cwnd. Also, experiments performed on congested bottlenecks wit=
h
tail-drop queues show very little (if any at all) effect on goodput for
the modified scenario compared to a scenario with unmodified TCP
streams.
>> >> Graphs both for latency-results and fairness tests can be found
here:
>> http://folk.uio.no/apetlund/lktmp/
>> >
>> > There should be a limit to linear timeouts, to say ... no more tha=
n 6
>> retransmits
>> > (eventually tunable), then switch to exponential backoff. Maybe yo=
ur
>> patch
>> > already implement such heuristic ?
>> The limitation you suggest to the linear timeouts makes very good
sense.
>> Our experiments performed on the Internet indicate that it is extrem=
ely
rare that more than 6 retransmissions are needed to recover. It is not
included in the current patch, so I will include this in the next
iteration.
>
> I've heard that BSD would use linear for first three and then
exponential
> but this is based on some gossip (which could well turn out to be a
myth)
> rather than checking it out myself. But if it is true, it certainly
hasn't
> been that devastating.
>> > True link collapses do happen, it would be good if not all streams
>> wakeup
>> > in the same
>> > second and make recovery very slow.
>> >
>> Each stream will have its own schedule for wakeup, so such events wi=
ll
still be subject to coincidence. The timer granularity of the TCP
wakeup
>> timer will also influence how many streams will wake at the same tim=
e. The
>> experiments we have performed on severely congested bottlenecks (lin=
k
above) indicate that the modifications will not create a large negative
effect. In fact, when goodput is drastically reduced due to severe
overload, regular TCP and the LT and dupACK modifications seem to
perform
>> nearly identically. Other scenarios may exist where different effect=
s can
>> be observed, and I am open to suggestions for further testing.
>
> Could you point out where exactly where the goodput results? ...I onl=
y
seem to find latency results which is not exactly the same. I don't
except
> some that is in order of what Nagle talks (32kbps -> 40bps irc) but
10-50%
> goodput reduction over a relatively short period of time (until RTTs =
top
RTOs once again preventing spurious RTOs and thus also segment
duplication
> due to retransmissions ceases).

The plot can be found here:
http://folk.uio.no/apetlund/lktmp/n-vs-n-fairness.pdf
I'm sorry that I didn't explain at once, as the parameters and setup is
not obvious. The boxplot shows aggregate throughput of all the unmodifi=
ed,
greedy TCP New Reno streams when competing with thin streams using TCP =
New
Reno, linear timeouts, modified dupACK, RDB (which is not included  thi=
s
patch set) and the combination of all the modifications. The streams
compete for a 1Mbps bottleneck that use tc with a tail-dropping queue t=
o
limit bandwidth and netem to create loss and delay.
The RTT for the test is 100ms and the packet interarrival time for the
thin streams are 85ms.

> Were these results obtained with Linux, and if so what was FRTO set t=
o?

The results are from our Linux implementation of the mechanisms. FRTO w=
as
disabled and Nagle was disabled for all test sets.

>> > Thats too easy to accept possibly dangerous features with the excu=
se
>> of
>> saying
>> > "It wont be used very much", because you cannot predict the future=
=2E
>> I agree that it is no argument to say that it won't be used much; in=
deed,
>> my hope is that it will be used much. However, our experiments indic=
ate no
>> negative effects while showing a large improvement on retransmission
latency for the scenario in question. I therefore think that the option
for such an improvement should be made available for time-dependent
thin-stream applications.
>
> Everyone can right away tell that most RTOs are not due to extreme
congestion, so some linear back off seems sensible when dupACK feedback
is lacking for some reason. Of course it is a tradeoff as there's that
chance for getting 1/(n+1) goodput only (where n is the number of linea=
r
steps) step if RTOs were spurious (and without FRTO even more
unnecessary
> retransmission will be triggered so in fact even could be slightly wo=
rse
in theory). But that to happen in the first place requires of course
this
> RTT > RTO situation which is hard to see to be a persisting state.

Actually, we have found the low number of packets in flight to be a
persisting state in a large amount of applications that are interactive=
 or
time-dependent. Some examples can be found in the table linked to below=
:

http://folk.uio.no/apetlund/lktmp/thin_apps_table.pdf

It seems that human interaction, sensor networks, and several other
scenarios that are not inherently greedy will produce a steady trickle =
of
data segments that fall into the "thin-stream" category and stays there=
=2E

Regards,
Andreas
