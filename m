From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Fwd: Throughput regression with `tcp: refine
	TSO autosizing`
Date: Sun, 1 Feb 2015 00:45:45 -0800
Message-ID: <CAA93jw7=oTex0Mp-0ThvuDRUnfR0N8tzdOQ8DD7QYWphp1b=4w@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<54CB5D08.2070906@broadcom.com>
	<1422623975.21689.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<54CB8B69.1070807@broadcom.com>
	<CAA93jw5fqhz0Hiw74L2GXgtZ9JsMg+NtYydKxKzGDrvQcZn4hA@mail.gmail.com>
	<CAA93jw7b0E9jjQYXrEPzjLLC9j8xNC0TFYXpWVtgFameJaNBdw@mail.gmail.com>
	<1422741065.199624134@apps.rackspace.com>
	<CAPp0ZBb2nkA6Y0s=W0kw=zvyn0wi0NMBRsBCw_xcD61ScOmgQg@mail.gmail.com>
	<CAA_e5Z46Bu+zZZFzf_ejzA35Gw3g1_OG85yv6yd7MpbwZcE-nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7804337036320520136=="
Cc: dstanley@arubanetworks.com, Stig Thormodsrud <stig@ubnt.com>,
	netdev@vger.kernel.org, linux-wireless <linux-wireless@vger.kernel.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Derrick Pallas <pallas@meraki.com>, Matt Mathis <mattmathis@google.com>,
	cerowrt-devel@lists.bufferbloat.net, Kathy Giori <kgiori@qca.qualcomm.com>,
	Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>,
	Jonathan Morton <chromatix99@gmail.com>, Tim Shepard <shep@alum.mit.edu>,
	Avery Pennarun <apenwarr@google.com>
To: Andrew McGregor <andrewmcgr@gmail.com>
Return-path: <cerowrt-devel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAA_e5Z46Bu+zZZFzf_ejzA35Gw3g1_OG85yv6yd7MpbwZcE-nw@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/cerowrt-devel>,
	<mailto:cerowrt-devel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/cerowrt-devel>
List-Post: <mailto:cerowrt-devel@lists.bufferbloat.net>
List-Help: <mailto:cerowrt-devel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/cerowrt-devel>,
	<mailto:cerowrt-devel-request@lists.bufferbloat.net?subject=subscribe>
Sender: cerowrt-devel-bounces@lists.bufferbloat.net
Errors-To: cerowrt-devel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

--===============7804337036320520136==
Content-Type: multipart/alternative; boundary=089e0160b7c41e6c9c050e02dd19

--089e0160b7c41e6c9c050e02dd19
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

This convo ended up being cut from netdev due to containing HTML.

I'd really like to get started on finally fixing WiFi starting in April.

---------- Forwarded message ----------
From: "Andrew McGregor" <andrewmcgr@gmail.com>
Date: Feb 1, 2015 12:07 AM
Subject: Re: [Cerowrt-devel] Fwd: Throughput regression with `tcp: refine
TSO autosizing`
To: "Avery Pennarun" <apenwarr@google.com>
Cc: "David Reed" <dpreed@reed.com>, "Dave Taht" <dave.taht@gmail.com>, "Jim
Gettys" <jg@freedesktop.org>, "Tim Shepard" <shep@alum.mit.edu>, "Matt
Mathis" <mattmathis@google.com>, "Jesper Dangaard Brouer" <
jbrouer@redhat.com>, "Jonathan Morton" <chromatix99@gmail.com>, "
cerowrt-devel@lists.bufferbloat.net" <cerowrt-devel@lists.bufferbloat.net>

> I think I have a good idea how to do it, actually.  Or at least, I had a
design sketched out that was kind of plausible.
>
> In essence, we have a good way of controlling queues in the IP stack,
that being fq_codel.  But aggregating wifi drivers have to pull all the
traffic straight through that and queue it themselves, with a different
rotation policy and (at present) no AQM.
>
> Well, that can be fixed.  We need a transmission and aggregation
scheduler at the wifi layer that can do a per-station round-robin with a
time-based fairness policy, based on airtime.  This has to be in the wifi
layer because that's where rate selection policy is, and you can't
calculate airtime until you know the selected rate, the current success
probabilities, and how much aggregation you're going to do within your time
budget.  We need to be able to plug in per-flow and per-packet scheduling
and drop policies on top of that, to control scheduling of individual
packets into aggregates.
>
> We could also do the trick of assigning a target drop probability and
telling a Minstrel-like rate controller what drop probability we're after;
then you get the nice property that the transmission scheduler and rate
control are work-conserving and actually get faster when they get congested=
.
>
> There is also now the mathematics available to improve Minstrel, which is
about 80% of a truly optimal rate controller (interestingly, that math was
published in 2010, years after we did Minstrel; I had the intuition that it
was close to optimal but no way to do a proof).
>
> None of this is rocket science, but it is a pretty deep and complex
refactor of something that isn't the simplest code to start with.  That
said, I'd not expect it to be more than around 1k LoC, it's just going to
be a real bear to test.

I think the best path forward is to do proof of concept on the two open
enough drivers we have - the mt76 and ath9k.

A lot of what is needed to make rational decisions is simply not available
from closed firmwares.

> I do have the feeling that the people receiving this email ought to be
sufficient to fix the problem, if we can direct enough time to it; for
myself, I have to think quite hard as to whether this should be my 20%
project.

There needs to be focus and direct funding for quite a few people. Felix
for one. It would be nice to acquire half an engineer from each of multiple
companies making wireless products and chips in a linaro like fashion, also=
.

> On Sun, Feb 1, 2015 at 2:06 PM, Avery Pennarun <apenwarr@google.com>
wrote:
>>
>> I would argue that insofar as the bufferbloat project has made a
>> difference, it's because there was a very clear message and product:
>> - here's what sucks when you have bufferbloat
>> - here's how you can detect it
>> - here's how you can get rid of it
>> - by the way, here's which of your competitors are already beating you
at it.
>>
>> It turns out you don't need a standards org in order to push any of
>> the above things.  The IEEE exists to make sure things interop at the
>> MAC/PHY layer.  The IETF exists to make sure things interop at the
>> higher layers.  But bufferbloat isn't about interop, it's just a thing
>> that happens inside gateways, so it's not something you can really
>> write standards about.  It is something you can turn into a
>> competitive advantage (or disadvantage, if you're a straggler).
>>
>> ...but meanwhile, if we want to fix bufferbloat in wifi, nobody
>> actually knows how to do it, so we are still at steps 1 and 2.
>>
>> This is why we're funding Dave to continue work on netperf-wrappers.

I still don't have POs for the other 75% of me this year. It is comforting
to have got such a public  confirmation that I have at least this much
floor under me this year, tho.

>> Those diagrams of latency under load are pretty convincing.  The
>> diagrams of page load times under different levels of latency are even
>> more convincing.  First, we prove there's a problem and a way to
>> measure the problem.  Then hopefully more people will be interested in
>> solving it.

Well, a wall of shame might help, I guess. I have a ton of data on a dozen
products that is miserable to see and should be quite embarrassing for the
vendors.

I'd prefer to spend time trying to fix the darn problem more directly, but
I would expect this tool will be of use in tracking improvements.

>>
>> On Sat, Jan 31, 2015 at 4:51 PM,  <dpreed@reed.com> wrote:
>> > I think we need to create an Internet focused 802.11 working group tha=
t
>> > would be to the "OS wireless designers and IEEE 802.11 standards
groups" as
>> > the WHATML group was to W3C.
>> >
>> >
>> >
>> > W3C was clueless about the real world at the point WHATML was
created.  And
>> > WHATML was a "revenge of the real" against W3C - advancing a wide
variety of
>> > important practical innovations rather than attending endless standard=
s
>> > meetings with people who were not focused on solving actually importan=
t
>> > problems.
>> >
>> >
>> >
>> > It took a bunch of work to get WHATML going, and it offended W3C, who
became
>> > unhelpful.  But the approach actually worked - we now have a Web that
really
>> > uses browser-side expressivity and that would never have happened if
W3C
>> > were left to its own devices.
>> >
>> >
>> >
>> > The WiFi consortium was an attempt to wrest control of pragmatic
direction
>> > from 802.11 and the proprietary-divergence folks at Qualcomm, Broadcom=
,
>> > Cisco, etc.  But it failed, because it became thieves on a raft, more
>> > focused on picking each others' pockets than on actually addressing
the big
>> > issues.
>> >
>> >
>> >
>> > Jim has seen this play out in the Linux community around X.  Though
there
>> > are lots of interests who would benefit by moving the engineering ball
>> > forward, everyone resists action because it means giving up the chance
at
>> > dominance, and the central group is far too weak to do anything beyond
>> > adjudicating the worst battles.
>> >
>> >
>> >
>> > When I say "we" I definitely include myself (though my time is limited
due
>> > to other commitments and the need to support my family), but I would
only
>> > play with people who actually are committed to making stuff happen -
which
>> > includes raising hell with the vendors if need be, but also effective
>> > engineering steps that can achieve quick adoption.
>> >
>> >
>> >
>> > Sadly, and I think it is manageable at the moment, there are moves out
there
>> > being made to get the FCC to "protect" WiFi from "interference".  The
>> > current one was Marriott, who requested the FCC for a rule to make it
legal
>> > to disrupt and block use of WiFi in people's rooms in their hotels,
except
>> > with their access points.  This also needs some technical defense.  I
>> > believe any issues with WiFi performance in actual Marriott hotels are
due
>> > to bufferbloat in their hotel-wide systems, just as the issues with
GoGo are
>> > the same.  But it's possible that queueing problems in their own WiFi
gear
>> > are bad as well.
>> >
>> >
>> >
>> > I mention this because it is related, and to the layperson, or
>> > non-radio-knowledgeable executive, indistinguishable.  It will take
away the
>> > incentive to actually fix the 802.11 implementations to be better
>> > performing, making the problem seem to be a "management" issue that
can be
>> > solved by making WiFi less interoperable and less flexible by rules,
rather
>> > than by engineering.
>> >
>> >
>> >
>> > However, solving the problems of hotspot networks and hotel networks
are
>> > definitely "real world" issues, and quite along the same lines you
mention,
>> > Dave.  FQ is almost certainly a big deal both in WiFi and in the
>> > distribution networks behind WiFi. Co-existence is also a big deal
>> > (RTS/CTS-like mechanisms can go a long way to remediate hidden-termina=
l
>> > disruption of the basic protocols). Roaming and scaling need work as
well.
>> >
>> >
>> >
>> > It would even be a good thing to invent pragmatic ways to provide "low
rate"
>> > subnets and "high rate" subnets that can coexist, so that
compatibility with
>> > ancient "b" networks need not be maintained on all nets, at great cost
-
>> > just send beacons at a high rate, so that the "b" NICs can't see
them....
>> > but you need pragmatic stack implementations.
>> >
>> >
>> >
>> > But the engineering is not the only challenge. The other challenge is
to
>> > take the initiative and get stuff deployed.  In the case of
bufferbloat, the
>> > grade currently is a "D" for deployments, maybe a "D-".  Beautiful
technical
>> > work, but the economic/business/political side of things has been poor=
.
>> > Look at how slow IETF has been to achieve anything (the perfect is
truly the
>> > enemy of the good, and Dave Clark's "rough consensus and working code"
has
>> > been replaced by technocratic malaise, and what appears to me to be a
class
>> > of people who love traveling the world to a floating cocktail party
without
>> > getting anything important done).
>> >
>> >
>> >
>> > The problem with communications is that you can't just ship a product
with a
>> > new "feature", because the innovation only works if widely adopted.
Since
>> > there is no "Linux Desktop" (and Linus hates the idea, to a large
extent)
>> > Linux can't be the sole carrier of the idea.  You pretty much need iOS
and
>> > Android both to buy in or to provide a path for easy third-party
upgrades.
>> > How do you do that?  Well, that's where the WHATML-type approach is
>> > necessary.
>> >
>> >
>> >
>> > I don't know if this can be achieved, and there are lots of details to
be
>> > worked out.  But I'll play.

I'll play.

>> >
>> >
>> >
>> >
>> >
>> >
>> >
>> > On Saturday, January 31, 2015 4:05pm, "Dave Taht" <dave.taht@gmail.com=
>
>> > said:
>> >
>> > I would like to have somehow assembled all the focused resources to
make a
>> > go at fixing wifi, or at least having a f2f with a bunch of people in
the
>> > late march timeframe. This message of mine to linux-wireless bounced
for
>> > some reason and I am off to log out for 10 days, so...
>> > see relevant netdev thread also for ore details.
>> >
>> > ---------- Forwarded message ----------
>> > From: Dave Taht <dave.taht@gmail.com>
>> > Date: Sat, Jan 31, 2015 at 12:29 PM
>> > Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
>> > To: Arend van Spriel <arend@broadcom.com>
>> > Cc: linux-wireless <linux-wireless@vger.kernel.org>, Michal Kazior
>> > <michal.kazior@tieto.com>, Eyal Perry <eyalpe@dev.mellanox.co.il>,
Network
>> > Development <netdev@vger.kernel.org>, Eric Dumazet <
eric.dumazet@gmail.com>
>> >
>> >
>> > The wifi industry as a whole has vastly bigger problems than achieving
>> > 1500Mbits in a faraday cage on a single flow.
>> >
>> > I encourage you to try tests in netperf-wrapper that explicitly test
for
>> > latency under load, and in particular, the RTT_FAIR tests against 4 or
more
>> > stations on a single wifi AP. You will find the results very
depressing.
>> > Similarly, on your previous test series, a latency figure would have
been
>> > nice to have. I just did a talk at nznog, where I tested the local
wifi with
>> > less than ambits of throughput, and 3 seconds of latency, filmed here:
>> >
>> > https://plus.google.com/u/0/107942175615993706558/posts/CY8ew8MPnMt
>> >
>> > Do wish more folk were testing in the busy real world environments,
like
>> > coffee shops, cities... really, anywhere outside a faraday cage!
>> >
>> > I am not attending netconf - I was unable to raise funds to go, and th=
e
>> > program committee wanted something "new",
>> >
>> > instead of the preso I gave the IEEE 802.11 working group back in
september.
>> > (
>> >
http://snapon.lab.bufferbloat.net/~d/ieee802.11-sept-17-2014/11-14-1265-00-=
0wng-More-on-Bufferbloat.pdf
>> > )
>> >
>> > I was very pleased with the results of that talk - the day after I
gave it,
>> > the phrase "test for latency" showed up in a bunch of 802.11ax (the
next
>> > generation after ac) documents. :) Still, we are stuck with the train
wreck
>> > that is 802.11ac glommed on top of 802.11n, glommed on top of 802.11g,
in
>> > terms of queue management, terrible uses of airtime, rate control and
other
>> > stuff. Aruba and Meraki, in particular took a big interest in what I'd
>> > outlined in the preso above (we have a half dozen less well baked
ideas -
>> > that's just the easy stuff that can be done to improve wifi).  I gave =
a
>> > followup at meraki but I don't think that's online.
>> >
>> > Felix (nbd) is on vacation right now, as I am I. In fact I am going
>> > somewhere for a week totally lacking internet access.
>> >
>> > Presently the plan, with what budget (none) we have and time (very
little)
>> > we have is to produce a pair of proof of concept implementations for
per tid
>> > queuing (see relevant commit by nbd),  leveraging the new minstrel
stats,
>> > the new minstrel-blues stuff, and an aggregation aware codel with a
>> > calculated target based on the most recently active stations, and a
bunch of
>> > the other stuff outlined above at IEEE.
>> >
>> > It is my hope that this will start to provide accurate back pressure
(or
>> > sufficient lack thereof for TSQ), to also improve throughput while
still
>> > retaining low latency. But it is a certainty that we will run into mor=
e
>> > cross layer issues that will be a pita to resolve.
>> >
>> > If we can put together a meet up around or during ELC in california in
>> > march?
>> >
>> > I am really not terribly optimistic on anything other than the 2
chipsets we
>> > can hack on (ath9k, mt76). Negotiations to get qualcomm to open up
their
>> > ath10k firmware have thus far failed, nor has a ath10k-lite got
anywhere.
>> > Perhaps broadcom would be willing to open up their firmware
sufficiently to
>> > build in a better API?
>> >
>> > A bit more below.
>> >
>> >
>> > On Jan 30, 2015 5:59 AM, "Arend van Spriel" <arend@broadcom.com> wrote=
:
>> >>
>> >> On 01/30/15 14:19, Eric Dumazet wrote:
>> >>>
>> >>> On Fri, 2015-01-30 at 11:29 +0100, Arend van Spriel wrote:
>> >>>
>> >>>> Hi Eric,
>> >>>>
>> >>>> Your suggestions are still based on the fact that you consider
wireless
>> >>>> networking to be similar to ethernet, but as Michal indicated there
are
>> >>>> some fundamental differences starting with CSMA/CD versus CSMA/CA.
Also
>> >>>> the medium conditions are far from comparable.
>> >
>> > The analogy i now use for it is that switched ethernet is generally
your
>> > classic "dumbbell"
>> >
>> > topology. Wifi is more like a "taxi-stand" topology. If you think
about how
>> > people
>> >
>> > queue up at a taxi stand (and sometimes agree to share a ride), the
inter
>> > arrival
>> >
>> > and departure times of a taxi stand make for a better mental model.
>> >
>> > Admittedly, I seem to spend a lot of time, waiting for taxies, thinkin=
g
>> > about
>> >
>> > wifi.
>> >
>> >>> There is no shielding so
>> >>>> it needs to deal with interference and dynamically drops the link
rate
>> >>>> so transmission of packets can take several milliseconds. Then with
11n
>> >>>> they came up with aggregation with sends up to 64 packets in a
single
>> >>>> transmit over the air at worst case 6.5 Mbps (if I am not
mistaken). The
>> >>>> parameter value for tcp_limit_output_bytes of 131072 means that it
>> >>>> allows queuing for about 1ms on a 1Gbps link, but I hope you can se=
e
>> >>>> this is not realistic for dealing with all variances of the wireles=
s
>> >>>> medium/standard. I suggested this as topic for the wireless
workshop in
>> >>>> Otawa [1], but I can not attend there. Still hope that there will b=
e
>> >>>> some discussions to get more awareness.
>> >
>> > I have sometimes hoped that TSQ could be made more a function of the
>> >
>> > number of active flows exiting an interface, but eric tells me that's
>> > impossible.
>> >
>> > This is possibly another case where TSQ could use to be a callback
>> > function...
>> >
>> > but frankly I care not a whit about maximizing single flow tcp
throughput on
>> > wifi
>> >
>> > in a faraday cage.
>> >
>> >
>> >>>
>> >>> Ever heard about bufferbloat ?
>> >>
>> >>
>> >> Sure. I am trying to get awareness about that in our wireless
>> >> driver/firmware development teams. So bear with me.
>> >>
>> >>
>> >>> Have you read my suggestions and tried them ?
>> >>>
>> >>> You can adjust the limit per flow to pretty much you want. If you
need
>> >>> 64 packets, just do the math. If in 2018 you need 128 packets, do th=
e
>> >>> math again.
>> >>>
>> >>> I am very well aware that wireless wants aggregation, thank you.
>> >
>> > I note that a lot of people testing this are getting it backwards.
Usually
>> > it is the AP that is sending lots and lots of big packets, where the
return
>> > path is predominately acks from the station.
>> >
>> > I am not a huge fan of stretch acks, but certainly a little bit of
thinning
>> > doesn't bother me on the return path there.
>> >
>> > Going the other way, particularly in a wifi world that insists on
treating
>> > every packet as sacred (which I don't agree with at all), thinning
acks can
>> > help, but single stream throughput is of interest only on benchmarks,
FQing
>> > as much as possible all the flows destined the station in each
aggregate
>> > masks loss and reduces the need to protect everything so much.
>> >
>> >>
>> >> Sorry if I offended you. I was just giving these as example combined
with
>> >> effective rate usable on the medium to say that the bandwidth is more
>> >> dynamic in wireless and as such need dynamic change of queue depth.
Now this
>> >> can be done by making the fraction size as used in your suggestion
adaptive
>> >> to these conditions.
>> >
>> > Well... see above. Maybe this technique will do more of the right
thing,
>> > but... go test.
>> >
>> >
>> >>
>> >>> 131072 bytes of queue on 40Gbit is not 1ms, but 26 usec of queueing,
and
>> >>> we get line rate nevertheless.
>> >>
>> >>
>> >> I was saying it was about 1ms on *1Gbit* as the wireless TCP rates ar=
e
>> >> moving into that direction in 11ac.
>> >>
>> >>
>> >>> We need this level of shallow queues (BQL, TSQ), to get very precise
rtt
>> >>> estimations so that TCP has good entropy for its pacing, even in the
50
>> >>> usec rtt ranges.
>> >>>
>> >>> If we allowed 1ms of queueing, then a 40Gbit flow would queue 5
MBytes.
>> >>>
>> >>> This was terrible, because it increased cwnd and all sender queues t=
o
>> >>> insane levels.
>> >>
>> >>
>> >> Indeed and that is what we would like to address in our wireless
drivers.
>> >> I will setup some experiments using the fraction sizing and post my
>> >> findings. Again sorry if I offended you.
>> >
>> > You really, really, really need to test at rates below 50mbit and with
other
>> > stations, also while doing this. It's not going to be a linear curve.
>> >
>> >
>> >
>> >>
>> >> Regards,
>> >> Arend
>> >>
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >
>> >
>> >
>> > --
>> > Dave T=C3=A4ht
>> >
>> > thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
>
>

--089e0160b7c41e6c9c050e02dd19
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
This convo ended up being cut from netdev due to containing HTML.</p>
<p dir=3D"ltr">I&#39;d really like to get started on finally fixing WiFi st=
arting in April.</p>
<p dir=3D"ltr">---------- Forwarded message ----------<br>
From: &quot;Andrew McGregor&quot; &lt;<a href=3D"mailto:andrewmcgr@gmail.co=
m">andrewmcgr@gmail.com</a>&gt;<br>
Date: Feb 1, 2015 12:07 AM<br>
Subject: Re: [Cerowrt-devel] Fwd: Throughput regression with `tcp: refine T=
SO autosizing`<br>
To: &quot;Avery Pennarun&quot; &lt;<a href=3D"mailto:apenwarr@google.com">a=
penwarr@google.com</a>&gt;<br>
Cc: &quot;David Reed&quot; &lt;<a href=3D"mailto:dpreed@reed.com">dpreed@re=
ed.com</a>&gt;, &quot;Dave Taht&quot; &lt;<a href=3D"mailto:dave.taht@gmail=
.com">dave.taht@gmail.com</a>&gt;, &quot;Jim Gettys&quot; &lt;<a href=3D"ma=
ilto:jg@freedesktop.org">jg@freedesktop.org</a>&gt;, &quot;Tim Shepard&quot=
; &lt;<a href=3D"mailto:shep@alum.mit.edu">shep@alum.mit.edu</a>&gt;, &quot=
;Matt Mathis&quot; &lt;<a href=3D"mailto:mattmathis@google.com">mattmathis@=
google.com</a>&gt;, &quot;Jesper Dangaard Brouer&quot; &lt;<a href=3D"mailt=
o:jbrouer@redhat.com">jbrouer@redhat.com</a>&gt;, &quot;Jonathan Morton&quo=
t; &lt;<a href=3D"mailto:chromatix99@gmail.com">chromatix99@gmail.com</a>&g=
t;, &quot;<a href=3D"mailto:cerowrt-devel@lists.bufferbloat.net">cerowrt-de=
vel@lists.bufferbloat.net</a>&quot; &lt;<a href=3D"mailto:cerowrt-devel@lis=
ts.bufferbloat.net">cerowrt-devel@lists.bufferbloat.net</a>&gt;</p>
<p dir=3D"ltr">&gt; I think I have a good idea how to do it, actually.=C2=
=A0 Or at least, I had a design sketched out that was kind of plausible.<br=
>
&gt;<br>
&gt; In essence, we have a good way of controlling queues in the IP stack, =
that being fq_codel.=C2=A0 But aggregating wifi drivers have to pull all th=
e traffic straight through that and queue it themselves, with a different r=
otation policy and (at present) no AQM.<br>
&gt;<br>
&gt; Well, that can be fixed.=C2=A0 We need a transmission and aggregation =
scheduler at the wifi layer that can do a per-station round-robin with a ti=
me-based fairness policy, based on airtime.=C2=A0 This has to be in the wif=
i layer because that&#39;s where rate selection policy is, and you can&#39;=
t calculate airtime until you know the selected rate, the current success p=
robabilities, and how much aggregation you&#39;re going to do within your t=
ime budget.=C2=A0 We need to be able to plug in per-flow and per-packet sch=
eduling and drop policies on top of that, to control scheduling of individu=
al packets into aggregates.<br>
&gt;<br>
&gt; We could also do the trick of assigning a target drop probability and =
telling a Minstrel-like rate controller what drop probability we&#39;re aft=
er; then you get the nice property that the transmission scheduler and rate=
 control are work-conserving and actually get faster when they get congeste=
d.<br>
&gt;<br>
&gt; There is also now the mathematics available to improve Minstrel, which=
 is about 80% of a truly optimal rate controller (interestingly, that math =
was published in 2010, years after we did Minstrel; I had the intuition tha=
t it was close to optimal but no way to do a proof).<br>
&gt;<br>
&gt; None of this is rocket science, but it is a pretty deep and complex re=
factor of something that isn&#39;t the simplest code to start with.=C2=A0 T=
hat said, I&#39;d not expect it to be more than around 1k LoC, it&#39;s jus=
t going to be a real bear to test.</p>
<p dir=3D"ltr">I think the best path forward is to do proof of concept on t=
he two open enough drivers we have - the mt76 and ath9k.</p>
<p dir=3D"ltr">A lot of what is needed to make rational decisions is simply=
 not available from closed firmwares.</p>
<p dir=3D"ltr">&gt; I do have the feeling that the people receiving this em=
ail ought to be sufficient to fix the problem, if we can direct enough time=
 to it; for myself, I have to think quite hard as to whether this should be=
 my 20% project.</p>
<p dir=3D"ltr">There needs to be focus and direct funding for quite a few p=
eople. Felix for one. It would be nice to acquire half an engineer from eac=
h of multiple companies making wireless products and chips in a linaro like=
 fashion, also.</p>
<p dir=3D"ltr">&gt; On Sun, Feb 1, 2015 at 2:06 PM, Avery Pennarun &lt;<a h=
ref=3D"mailto:apenwarr@google.com">apenwarr@google.com</a>&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; I would argue that insofar as the bufferbloat project has made a<b=
r>
&gt;&gt; difference, it&#39;s because there was a very clear message and pr=
oduct:<br>
&gt;&gt; - here&#39;s what sucks when you have bufferbloat<br>
&gt;&gt; - here&#39;s how you can detect it<br>
&gt;&gt; - here&#39;s how you can get rid of it<br>
&gt;&gt; - by the way, here&#39;s which of your competitors are already bea=
ting you at it.<br>
&gt;&gt;<br>
&gt;&gt; It turns out you don&#39;t need a standards org in order to push a=
ny of<br>
&gt;&gt; the above things.=C2=A0 The IEEE exists to make sure things intero=
p at the<br>
&gt;&gt; MAC/PHY layer.=C2=A0 The IETF exists to make sure things interop a=
t the<br>
&gt;&gt; higher layers.=C2=A0 But bufferbloat isn&#39;t about interop, it&#=
39;s just a thing<br>
&gt;&gt; that happens inside gateways, so it&#39;s not something you can re=
ally<br>
&gt;&gt; write standards about.=C2=A0 It is something you can turn into a<b=
r>
&gt;&gt; competitive advantage (or disadvantage, if you&#39;re a straggler)=
.<br>
&gt;&gt;<br>
&gt;&gt; ...but meanwhile, if we want to fix bufferbloat in wifi, nobody<br=
>
&gt;&gt; actually knows how to do it, so we are still at steps 1 and 2.<br>
&gt;&gt;<br>
&gt;&gt; This is why we&#39;re funding Dave to continue work on netperf-wra=
ppers.</p>
<p dir=3D"ltr">I still don&#39;t have POs for the other 75% of me this year=
. It is comforting to have got such a public=C2=A0 confirmation that I have=
 at least this much floor under me this year, tho.</p>
<p dir=3D"ltr">&gt;&gt; Those diagrams of latency under load are pretty con=
vincing.=C2=A0 The<br>
&gt;&gt; diagrams of page load times under different levels of latency are =
even<br>
&gt;&gt; more convincing.=C2=A0 First, we prove there&#39;s a problem and a=
 way to<br>
&gt;&gt; measure the problem.=C2=A0 Then hopefully more people will be inte=
rested in<br>
&gt;&gt; solving it.</p>
<p dir=3D"ltr">Well, a wall of shame might help, I guess. I have a ton of d=
ata on a dozen products that is miserable to see and should be quite embarr=
assing for the vendors.</p>
<p dir=3D"ltr">I&#39;d prefer to spend time trying to fix the darn problem =
more directly, but I would expect this tool will be of use in tracking impr=
ovements.</p>
<p dir=3D"ltr">&gt;&gt;<br>
&gt;&gt; On Sat, Jan 31, 2015 at 4:51 PM,=C2=A0 &lt;<a href=3D"mailto:dpree=
d@reed.com">dpreed@reed.com</a>&gt; wrote:<br>
&gt;&gt; &gt; I think we need to create an Internet focused 802.11 working =
group that<br>
&gt;&gt; &gt; would be to the &quot;OS wireless designers and IEEE 802.11 s=
tandards groups&quot; as<br>
&gt;&gt; &gt; the WHATML group was to W3C.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; W3C was clueless about the real world at the point WHATML was=
 created.=C2=A0 And<br>
&gt;&gt; &gt; WHATML was a &quot;revenge of the real&quot; against W3C - ad=
vancing a wide variety of<br>
&gt;&gt; &gt; important practical innovations rather than attending endless=
 standards<br>
&gt;&gt; &gt; meetings with people who were not focused on solving actually=
 important<br>
&gt;&gt; &gt; problems.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; It took a bunch of work to get WHATML going, and it offended =
W3C, who became<br>
&gt;&gt; &gt; unhelpful.=C2=A0 But the approach actually worked - we now ha=
ve a Web that really<br>
&gt;&gt; &gt; uses browser-side expressivity and that would never have happ=
ened if W3C<br>
&gt;&gt; &gt; were left to its own devices.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; The WiFi consortium was an attempt to wrest control of pragma=
tic direction<br>
&gt;&gt; &gt; from 802.11 and the proprietary-divergence folks at Qualcomm,=
 Broadcom,<br>
&gt;&gt; &gt; Cisco, etc.=C2=A0 But it failed, because it became thieves on=
 a raft, more<br>
&gt;&gt; &gt; focused on picking each others&#39; pockets than on actually =
addressing the big<br>
&gt;&gt; &gt; issues.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Jim has seen this play out in the Linux community around X.=
=C2=A0 Though there<br>
&gt;&gt; &gt; are lots of interests who would benefit by moving the enginee=
ring ball<br>
&gt;&gt; &gt; forward, everyone resists action because it means giving up t=
he chance at<br>
&gt;&gt; &gt; dominance, and the central group is far too weak to do anythi=
ng beyond<br>
&gt;&gt; &gt; adjudicating the worst battles.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; When I say &quot;we&quot; I definitely include myself (though=
 my time is limited due<br>
&gt;&gt; &gt; to other commitments and the need to support my family), but =
I would only<br>
&gt;&gt; &gt; play with people who actually are committed to making stuff h=
appen - which<br>
&gt;&gt; &gt; includes raising hell with the vendors if need be, but also e=
ffective<br>
&gt;&gt; &gt; engineering steps that can achieve quick adoption.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Sadly, and I think it is manageable at the moment, there are =
moves out there<br>
&gt;&gt; &gt; being made to get the FCC to &quot;protect&quot; WiFi from &q=
uot;interference&quot;.=C2=A0 The<br>
&gt;&gt; &gt; current one was Marriott, who requested the FCC for a rule to=
 make it legal<br>
&gt;&gt; &gt; to disrupt and block use of WiFi in people&#39;s rooms in the=
ir hotels, except<br>
&gt;&gt; &gt; with their access points.=C2=A0 This also needs some technica=
l defense.=C2=A0 I<br>
&gt;&gt; &gt; believe any issues with WiFi performance in actual Marriott h=
otels are due<br>
&gt;&gt; &gt; to bufferbloat in their hotel-wide systems, just as the issue=
s with GoGo are<br>
&gt;&gt; &gt; the same.=C2=A0 But it&#39;s possible that queueing problems =
in their own WiFi gear<br>
&gt;&gt; &gt; are bad as well.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I mention this because it is related, and to the layperson, o=
r<br>
&gt;&gt; &gt; non-radio-knowledgeable executive, indistinguishable.=C2=A0 I=
t will take away the<br>
&gt;&gt; &gt; incentive to actually fix the 802.11 implementations to be be=
tter<br>
&gt;&gt; &gt; performing, making the problem seem to be a &quot;management&=
quot; issue that can be<br>
&gt;&gt; &gt; solved by making WiFi less interoperable and less flexible by=
 rules, rather<br>
&gt;&gt; &gt; than by engineering.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; However, solving the problems of hotspot networks and hotel n=
etworks are<br>
&gt;&gt; &gt; definitely &quot;real world&quot; issues, and quite along the=
 same lines you mention,<br>
&gt;&gt; &gt; Dave.=C2=A0 FQ is almost certainly a big deal both in WiFi an=
d in the<br>
&gt;&gt; &gt; distribution networks behind WiFi. Co-existence is also a big=
 deal<br>
&gt;&gt; &gt; (RTS/CTS-like mechanisms can go a long way to remediate hidde=
n-terminal<br>
&gt;&gt; &gt; disruption of the basic protocols). Roaming and scaling need =
work as well.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; It would even be a good thing to invent pragmatic ways to pro=
vide &quot;low rate&quot;<br>
&gt;&gt; &gt; subnets and &quot;high rate&quot; subnets that can coexist, s=
o that compatibility with<br>
&gt;&gt; &gt; ancient &quot;b&quot; networks need not be maintained on all =
nets, at great cost -<br>
&gt;&gt; &gt; just send beacons at a high rate, so that the &quot;b&quot; N=
ICs can&#39;t see them....<br>
&gt;&gt; &gt; but you need pragmatic stack implementations.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; But the engineering is not the only challenge. The other chal=
lenge is to<br>
&gt;&gt; &gt; take the initiative and get stuff deployed.=C2=A0 In the case=
 of bufferbloat, the<br>
&gt;&gt; &gt; grade currently is a &quot;D&quot; for deployments, maybe a &=
quot;D-&quot;.=C2=A0 Beautiful technical<br>
&gt;&gt; &gt; work, but the economic/business/political side of things has =
been poor.<br>
&gt;&gt; &gt; Look at how slow IETF has been to achieve anything (the perfe=
ct is truly the<br>
&gt;&gt; &gt; enemy of the good, and Dave Clark&#39;s &quot;rough consensus=
 and working code&quot; has<br>
&gt;&gt; &gt; been replaced by technocratic malaise, and what appears to me=
 to be a class<br>
&gt;&gt; &gt; of people who love traveling the world to a floating cocktail=
 party without<br>
&gt;&gt; &gt; getting anything important done).<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; The problem with communications is that you can&#39;t just sh=
ip a product with a<br>
&gt;&gt; &gt; new &quot;feature&quot;, because the innovation only works if=
 widely adopted.=C2=A0 Since<br>
&gt;&gt; &gt; there is no &quot;Linux Desktop&quot; (and Linus hates the id=
ea, to a large extent)<br>
&gt;&gt; &gt; Linux can&#39;t be the sole carrier of the idea.=C2=A0 You pr=
etty much need iOS and<br>
&gt;&gt; &gt; Android both to buy in or to provide a path for easy third-pa=
rty upgrades.<br>
&gt;&gt; &gt; How do you do that?=C2=A0 Well, that&#39;s where the WHATML-t=
ype approach is<br>
&gt;&gt; &gt; necessary.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I don&#39;t know if this can be achieved, and there are lots =
of details to be<br>
&gt;&gt; &gt; worked out.=C2=A0 But I&#39;ll play.</p>
<p dir=3D"ltr">I&#39;ll play. </p>
<p dir=3D"ltr">&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; On Saturday, January 31, 2015 4:05pm, &quot;Dave Taht&quot; &=
lt;<a href=3D"mailto:dave.taht@gmail.com">dave.taht@gmail.com</a>&gt;<br>
&gt;&gt; &gt; said:<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I would like to have somehow assembled all the focused resour=
ces to make a<br>
&gt;&gt; &gt; go at fixing wifi, or at least having a f2f with a bunch of p=
eople in the<br>
&gt;&gt; &gt; late march timeframe. This message of mine to linux-wireless =
bounced for<br>
&gt;&gt; &gt; some reason and I am off to log out for 10 days, so...<br>
&gt;&gt; &gt; see relevant netdev thread also for ore details.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; ---------- Forwarded message ----------<br>
&gt;&gt; &gt; From: Dave Taht &lt;<a href=3D"mailto:dave.taht@gmail.com">da=
ve.taht@gmail.com</a>&gt;<br>
&gt;&gt; &gt; Date: Sat, Jan 31, 2015 at 12:29 PM<br>
&gt;&gt; &gt; Subject: Re: Throughput regression with `tcp: refine TSO auto=
sizing`<br>
&gt;&gt; &gt; To: Arend van Spriel &lt;<a href=3D"mailto:arend@broadcom.com=
">arend@broadcom.com</a>&gt;<br>
&gt;&gt; &gt; Cc: linux-wireless &lt;<a href=3D"mailto:linux-wireless@vger.=
kernel.org">linux-wireless@vger.kernel.org</a>&gt;, Michal Kazior<br>
&gt;&gt; &gt; &lt;<a href=3D"mailto:michal.kazior@tieto.com">michal.kazior@=
tieto.com</a>&gt;, Eyal Perry &lt;<a href=3D"mailto:eyalpe@dev.mellanox.co.=
il">eyalpe@dev.mellanox.co.il</a>&gt;, Network<br>
&gt;&gt; &gt; Development &lt;<a href=3D"mailto:netdev@vger.kernel.org">net=
dev@vger.kernel.org</a>&gt;, Eric Dumazet &lt;<a href=3D"mailto:eric.dumaze=
t@gmail.com">eric.dumazet@gmail.com</a>&gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; The wifi industry as a whole has vastly bigger problems than =
achieving<br>
&gt;&gt; &gt; 1500Mbits in a faraday cage on a single flow.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I encourage you to try tests in netperf-wrapper that explicit=
ly test for<br>
&gt;&gt; &gt; latency under load, and in particular, the RTT_FAIR tests aga=
inst 4 or more<br>
&gt;&gt; &gt; stations on a single wifi AP. You will find the results very =
depressing.<br>
&gt;&gt; &gt; Similarly, on your previous test series, a latency figure wou=
ld have been<br>
&gt;&gt; &gt; nice to have. I just did a talk at nznog, where I tested the =
local wifi with<br>
&gt;&gt; &gt; less than ambits of throughput, and 3 seconds of latency, fil=
med here:<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; <a href=3D"https://plus.google.com/u/0/107942175615993706558/=
posts/CY8ew8MPnMt">https://plus.google.com/u/0/107942175615993706558/posts/=
CY8ew8MPnMt</a><br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Do wish more folk were testing in the busy real world environ=
ments, like<br>
&gt;&gt; &gt; coffee shops, cities... really, anywhere outside a faraday ca=
ge!<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I am not attending netconf - I was unable to raise funds to g=
o, and the<br>
&gt;&gt; &gt; program committee wanted something &quot;new&quot;,<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; instead of the preso I gave the IEEE 802.11 working group bac=
k in september.<br>
&gt;&gt; &gt; (<br>
&gt;&gt; &gt; <a href=3D"http://snapon.lab.bufferbloat.net/~d/ieee802.11-se=
pt-17-2014/11-14-1265-00-0wng-More-on-Bufferbloat.pdf">http://snapon.lab.bu=
fferbloat.net/~d/ieee802.11-sept-17-2014/11-14-1265-00-0wng-More-on-Bufferb=
loat.pdf</a><br>
&gt;&gt; &gt; )<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I was very pleased with the results of that talk - the day af=
ter I gave it,<br>
&gt;&gt; &gt; the phrase &quot;test for latency&quot; showed up in a bunch =
of 802.11ax (the next<br>
&gt;&gt; &gt; generation after ac) documents. :) Still, we are stuck with t=
he train wreck<br>
&gt;&gt; &gt; that is 802.11ac glommed on top of 802.11n, glommed on top of=
 802.11g, in<br>
&gt;&gt; &gt; terms of queue management, terrible uses of airtime, rate con=
trol and other<br>
&gt;&gt; &gt; stuff. Aruba and Meraki, in particular took a big interest in=
 what I&#39;d<br>
&gt;&gt; &gt; outlined in the preso above (we have a half dozen less well b=
aked ideas -<br>
&gt;&gt; &gt; that&#39;s just the easy stuff that can be done to improve wi=
fi).=C2=A0 I gave a<br>
&gt;&gt; &gt; followup at meraki but I don&#39;t think that&#39;s online.<b=
r>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Felix (nbd) is on vacation right now, as I am I. In fact I am=
 going<br>
&gt;&gt; &gt; somewhere for a week totally lacking internet access.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Presently the plan, with what budget (none) we have and time =
(very little)<br>
&gt;&gt; &gt; we have is to produce a pair of proof of concept implementati=
ons for per tid<br>
&gt;&gt; &gt; queuing (see relevant commit by nbd),=C2=A0 leveraging the ne=
w minstrel stats,<br>
&gt;&gt; &gt; the new minstrel-blues stuff, and an aggregation aware codel =
with a<br>
&gt;&gt; &gt; calculated target based on the most recently active stations,=
 and a bunch of<br>
&gt;&gt; &gt; the other stuff outlined above at IEEE.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; It is my hope that this will start to provide accurate back p=
ressure (or<br>
&gt;&gt; &gt; sufficient lack thereof for TSQ), to also improve throughput =
while still<br>
&gt;&gt; &gt; retaining low latency. But it is a certainty that we will run=
 into more<br>
&gt;&gt; &gt; cross layer issues that will be a pita to resolve.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; If we can put together a meet up around or during ELC in cali=
fornia in<br>
&gt;&gt; &gt; march?<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I am really not terribly optimistic on anything other than th=
e 2 chipsets we<br>
&gt;&gt; &gt; can hack on (ath9k, mt76). Negotiations to get qualcomm to op=
en up their<br>
&gt;&gt; &gt; ath10k firmware have thus far failed, nor has a ath10k-lite g=
ot anywhere.<br>
&gt;&gt; &gt; Perhaps broadcom would be willing to open up their firmware s=
ufficiently to<br>
&gt;&gt; &gt; build in a better API?<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; A bit more below.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; On Jan 30, 2015 5:59 AM, &quot;Arend van Spriel&quot; &lt;<a =
href=3D"mailto:arend@broadcom.com">arend@broadcom.com</a>&gt; wrote:<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; On 01/30/15 14:19, Eric Dumazet wrote:<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; On Fri, 2015-01-30 at 11:29 +0100, Arend van Spriel w=
rote:<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt;&gt; Hi Eric,<br>
&gt;&gt; &gt;&gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt;&gt; Your suggestions are still based on the fact that=
 you consider wireless<br>
&gt;&gt; &gt;&gt;&gt;&gt; networking to be similar to ethernet, but as Mich=
al indicated there are<br>
&gt;&gt; &gt;&gt;&gt;&gt; some fundamental differences starting with CSMA/C=
D versus CSMA/CA. Also<br>
&gt;&gt; &gt;&gt;&gt;&gt; the medium conditions are far from comparable.<br=
>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; The analogy i now use for it is that switched ethernet is gen=
erally your<br>
&gt;&gt; &gt; classic &quot;dumbbell&quot;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; topology. Wifi is more like a &quot;taxi-stand&quot; topology=
. If you think about how<br>
&gt;&gt; &gt; people<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; queue up at a taxi stand (and sometimes agree to share a ride=
), the inter<br>
&gt;&gt; &gt; arrival<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; and departure times of a taxi stand make for a better mental =
model.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Admittedly, I seem to spend a lot of time, waiting for taxies=
, thinking<br>
&gt;&gt; &gt; about<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; wifi.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt;&gt; There is no shielding so<br>
&gt;&gt; &gt;&gt;&gt;&gt; it needs to deal with interference and dynamicall=
y drops the link rate<br>
&gt;&gt; &gt;&gt;&gt;&gt; so transmission of packets can take several milli=
seconds. Then with 11n<br>
&gt;&gt; &gt;&gt;&gt;&gt; they came up with aggregation with sends up to 64=
 packets in a single<br>
&gt;&gt; &gt;&gt;&gt;&gt; transmit over the air at worst case 6.5 Mbps (if =
I am not mistaken). The<br>
&gt;&gt; &gt;&gt;&gt;&gt; parameter value for tcp_limit_output_bytes of 131=
072 means that it<br>
&gt;&gt; &gt;&gt;&gt;&gt; allows queuing for about 1ms on a 1Gbps link, but=
 I hope you can see<br>
&gt;&gt; &gt;&gt;&gt;&gt; this is not realistic for dealing with all varian=
ces of the wireless<br>
&gt;&gt; &gt;&gt;&gt;&gt; medium/standard. I suggested this as topic for th=
e wireless workshop in<br>
&gt;&gt; &gt;&gt;&gt;&gt; Otawa [1], but I can not attend there. Still hope=
 that there will be<br>
&gt;&gt; &gt;&gt;&gt;&gt; some discussions to get more awareness.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I have sometimes hoped that TSQ could be made more a function=
 of the<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; number of active flows exiting an interface, but eric tells m=
e that&#39;s<br>
&gt;&gt; &gt; impossible.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; This is possibly another case where TSQ could use to be a cal=
lback<br>
&gt;&gt; &gt; function...<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; but frankly I care not a whit about maximizing single flow tc=
p throughput on<br>
&gt;&gt; &gt; wifi<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; in a faraday cage.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; Ever heard about bufferbloat ?<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Sure. I am trying to get awareness about that in our wire=
less<br>
&gt;&gt; &gt;&gt; driver/firmware development teams. So bear with me.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; Have you read my suggestions and tried them ?<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; You can adjust the limit per flow to pretty much you =
want. If you need<br>
&gt;&gt; &gt;&gt;&gt; 64 packets, just do the math. If in 2018 you need 128=
 packets, do the<br>
&gt;&gt; &gt;&gt;&gt; math again.<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; I am very well aware that wireless wants aggregation,=
 thank you.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I note that a lot of people testing this are getting it backw=
ards. Usually<br>
&gt;&gt; &gt; it is the AP that is sending lots and lots of big packets, wh=
ere the return<br>
&gt;&gt; &gt; path is predominately acks from the station.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I am not a huge fan of stretch acks, but certainly a little b=
it of thinning<br>
&gt;&gt; &gt; doesn&#39;t bother me on the return path there.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Going the other way, particularly in a wifi world that insist=
s on treating<br>
&gt;&gt; &gt; every packet as sacred (which I don&#39;t agree with at all),=
 thinning acks can<br>
&gt;&gt; &gt; help, but single stream throughput is of interest only on ben=
chmarks, FQing<br>
&gt;&gt; &gt; as much as possible all the flows destined the station in eac=
h aggregate<br>
&gt;&gt; &gt; masks loss and reduces the need to protect everything so much=
.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Sorry if I offended you. I was just giving these as examp=
le combined with<br>
&gt;&gt; &gt;&gt; effective rate usable on the medium to say that the bandw=
idth is more<br>
&gt;&gt; &gt;&gt; dynamic in wireless and as such need dynamic change of qu=
eue depth. Now this<br>
&gt;&gt; &gt;&gt; can be done by making the fraction size as used in your s=
uggestion adaptive<br>
&gt;&gt; &gt;&gt; to these conditions.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Well... see above. Maybe this technique will do more of the r=
ight thing,<br>
&gt;&gt; &gt; but... go test.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; 131072 bytes of queue on 40Gbit is not 1ms, but 26 us=
ec of queueing, and<br>
&gt;&gt; &gt;&gt;&gt; we get line rate nevertheless.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; I was saying it was about 1ms on *1Gbit* as the wireless =
TCP rates are<br>
&gt;&gt; &gt;&gt; moving into that direction in 11ac.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; We need this level of shallow queues (BQL, TSQ), to g=
et very precise rtt<br>
&gt;&gt; &gt;&gt;&gt; estimations so that TCP has good entropy for its paci=
ng, even in the 50<br>
&gt;&gt; &gt;&gt;&gt; usec rtt ranges.<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; If we allowed 1ms of queueing, then a 40Gbit flow wou=
ld queue 5 MBytes.<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; This was terrible, because it increased cwnd and all =
sender queues to<br>
&gt;&gt; &gt;&gt;&gt; insane levels.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Indeed and that is what we would like to address in our w=
ireless drivers.<br>
&gt;&gt; &gt;&gt; I will setup some experiments using the fraction sizing a=
nd post my<br>
&gt;&gt; &gt;&gt; findings. Again sorry if I offended you.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; You really, really, really need to test at rates below 50mbit=
 and with other<br>
&gt;&gt; &gt; stations, also while doing this. It&#39;s not going to be a l=
inear curve.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Regards,<br>
&gt;&gt; &gt;&gt; Arend<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; --<br>
&gt;&gt; &gt;&gt; To unsubscribe from this list: send the line &quot;unsubs=
cribe netdev&quot; in<br>
&gt;&gt; &gt;&gt; the body of a message to <a href=3D"mailto:majordomo@vger=
.kernel.org">majordomo@vger.kernel.org</a><br>
&gt;&gt; &gt;&gt; More majordomo info at=C2=A0 <a href=3D"http://vger.kerne=
l.org/majordomo-info.html">http://vger.kernel.org/majordomo-info.html</a><b=
r>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; --<br>
&gt;&gt; &gt; Dave T=C3=A4ht<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; thttp://<a href=3D"http://www.bufferbloat.net/projects/bloat/=
wiki/Upcoming_Talks">www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks=
</a><br>
&gt;<br>
&gt;</p>

--089e0160b7c41e6c9c050e02dd19--

--===============7804337036320520136==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============7804337036320520136==--
