From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Tue, 10 Jan 2017 10:24:36 -0800
Message-ID: <CAA93jw7jBCFLGgMbBbDcUGwSRS5uWnLQU0w-T4UxEQOyQdiUgA@mail.gmail.com>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
 <1483706872.4089.8.camel@sipsolutions.net> <8836daaa-9638-4502-d079-fd428595f822@nbd.name>
 <1483710841.12677.1.camel@sipsolutions.net> <22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
 <20170107145516.GE3134@otheros> <1483949336.17582.3.camel@sipsolutions.net>
 <6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de> <20170109212345.GA5513@otheros>
 <20170109133032.221f8669@xeon-e3> <20170110041816.GJ5513@otheros>
 <1484045763.1014.0.camel@sipsolutions.net> <CAA93jw6+P8um7TxDCYgJ=SJfFzpskboR7njgudMb3NR4JZ34BA@mail.gmail.com>
 <99c01ce6-d80c-790e-25e5-157be31aee9a@nbd.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Johannes Berg <johannes@sipsolutions.net>,
        =?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "M. Braun" <michael-dev@fami-braun.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Felix Fietkau <nbd@nbd.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <99c01ce6-d80c-790e-25e5-157be31aee9a@nbd.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2017 at 9:23 AM, Felix Fietkau <nbd@nbd.name> wrote:
> On 2017-01-10 18:17, Dave Taht wrote:
>> In the case of wifi I have 3 issues with this line of thought.
>>
>> multicast in wifi has generally supposed to be unreliable. This makes
>> it reliable. reliability comes at a cost -
>>
>> multicast is typically set at a fixed low rate today. unicast is
>> retried at different rates until it succeeds - for every station
>> listening. If one station is already at the lowest rate, the total
>> cost of the transmit increases, rather than decreases.
>>
>> unicast gets block acks until it succeeds. Again, more delay.
>>
>> I think there is something like 31 soft-retries in the ath9k driver....
> If I remember correctly, hardware retries are counted here as well.

I chopped this to something more reasonable but never got around to
quantifying it, so never pushed the patch. I figured I'd measure ATF
in a noisy environment (which I'd be doing now if it weren't for
https://bugs.lede-project.org/index.php?do=3Ddetails&task_id=3D368 )
first.

>> what happens to diffserv markings here? for unicast CS1 goes into the
>> BE queue, CS6, the VO queue. Do we go from one flat queue for all of
>> multicast to punching it through one of the hardware queues based on
>> the diffserv mark now with this patch?

I meant CS1=3DBK here. Tracing the path through the bridge code made my
head hurt, I can go look at some aircaps to see if the mcast->unicast
conversion respects those markings or not (my vote is *not*).

>> I would like it if there was a way to preserve the unreliability
>> (which multiple mesh protocols depend on), send stuff with QoSNoack,
>> etc - or dynamically choose (based on the rates of the stations)
>> between conventional multicast and unicast.
>>
>> Or - better, IMHO, keep sending multicast as is but pick the best of
>> the rates available to all the listening stations for it.

> The advantage of the multicast-to-unicast conversion goes beyond simply
> selecting a better rate - aggregation matters a lot as well, and that is
> simply incompatible with normal multicast.

Except for the VO queue which cannot aggregate. And for that matter,
using any other hardware queue than BE tends to eat a txop that would
otherwise possibly be combined with an aggregate.

(and the VI queue has always misbehaved, long on my todo list)

> Some multicast streams use lots of small-ish packets, the airtime impact
> of those is vastly reduced, even if the transmission has to be
> duplicated for a few stations.

The question was basically how far up does it scale. Arguably, for a
very few, well connected stations, this patch would help. For a
network with more - and more badly connected stations, I think it
would hurt.

What sorts of multicast traffic are being observed that flood the
network sufficiently to be worth optimizing out? arp? nd? upnp? mdns?
uftp? tv?

(my questions above are related to basically trying to setup a sane
a/b test, I've been building up a new testbed in noisy environment to
match the one I have in a quiet one, and don't have any "good" mcast
tests defined. Has anyone done an a/b test of this code with some
repeatable test already?)

(In my observations... The only truly heavy creator of a multicast
"burp" has tended to be upnp and mdns on smaller networks. Things like
nd and arp get more problematic as the number of stations go up also.
I can try things like abusing vlc or uftp to see what happens?)

I certainly agree multicast is a "problem" (I've seen 20-80% or more
of a given wifi network eaten by multicast) but I'm not convinced that
making it reliable, aggregatable unicast scales much past
basement-level testing of a few "good" stations, and don't know which
protocols are making it worse, the worst, in typical environments.
Certainly apple gear puts out a lot of multicast.

...

As best as I recall a recommendation in the 802.11-2012 standard was
that multicast packets be rate-limited so that you'd have a fixed
amount of crap after each beacon sufficient to keep the rest of the
unicast traffic flowing rapidly, instead of dumping everything into a
given beacon transmit.

That, combined with (maybe) picking the "best" union of known rates
per station, was essentially the strategy I'd intended[1] to pursue
for tackling the currently infinite wifi multicast queue - fq the
entries, have a fairly short queue (codel is not the best choice here)
drop from head, and limit the number of packets transmitted per beacon
to spread them out. That would solve the issue for sparse multicast
(dhcp etc), and smooth out the burps from bigger chunks while
impacting conventional unicast minimally.

There's also the pursuit of less multicast overall at least in some protoco=
ls

https://tools.ietf.org/html/draft-ietf-dnssd-hybrid-05


>
> - Felix


[1] but make-wifi-fast has been out of funding since august

--=20
Dave T=C3=A4ht
Let's go make home routers and wifi faster! With better software!
http://blog.cerowrt.org
