From: Dave Taht <dave.taht@gmail.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 10:03:54 -0800
Message-ID: <CAA93jw56T32c7NN6Ttnbda6v5mciQhdhD50nC_SoXW8nFti+8g@mail.gmail.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.37647.979237.40802@gargle.gargle.HOWL>
	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<21121.575.539384.948990@gargle.gargle.HOWL>
	<52810800.9020402@openwrt.org>
	<1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd@openwrt.org>,
	Sujith Manoharan <sujith@msujith.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:43207 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979Ab3KKSDz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:03:55 -0500
Received: by mail-wg0-f51.google.com with SMTP id m15so475074wgh.30
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 10:03:54 -0800 (PST)
In-Reply-To: <1384191515.16391.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 9:38 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Mon, 2013-11-11 at 17:38 +0100, Felix Fietkau wrote:
>> On 2013-11-11 17:13, Sujith Manoharan wrote:
>> > Eric Dumazet wrote:
>> >> We have many choices.
>> >>
>> >> 1) Add back a minimum of ~128 K of outstanding bytes per TCP sess=
ion,
>> >>    so that buggy drivers can sustain 'line rate'.
>> >>
>> >>    Note that with 100 concurrent TCP streams, total amount of byt=
es
>> >>    queued on the NIC is 12 MB.
>> >>    And pfifo_fast qdisc will drop packets anyway.
>> >>
>> >>    Thats what we call 'BufferBloat'
>> >>
>> >> 2) Try lower values like 64K. Still bufferbloat.
>> >>
>> >> 3) Fix buggy drivers, using a proper logic, or shorter timers (mv=
neta
>> >> case for example)
>> >>
>> >> 4) Add a new netdev attribute, so that well behaving NIC drivers =
do not
>> >> have to artificially force TCP stack to queue too many bytes in
>> >> Qdisc/NIC queues.
>> >
>> > I think the quirks of 802.11 aggregation should be taken into acco=
unt.
>> > I am adding Felix to this thread, who would have more to say on la=
tency/bufferbloat
>> > with wireless drivers.

As I just got dropped in the middle of this convo, I tend to think
that the mac80211 questions is should be handled in it's own thread as
this conversation seemed to be about a certain ethernet driver's
flaws.

>> I don't think this issue is about something as simple as timer handl=
ing
>> for tx completion (or even broken/buggy drivers).
>>
>> There's simply no way to make 802.11 aggregation work well and have
>> similar tx completion latency characteristics as Ethernet devices.

I don't quite share all of felix's pessimism. It will tend to be
burstier, yes, but I felt that would not look that much different than
napi -> BQL.

>> 802.11 aggregation reduces the per-packet airtime overhead by combin=
ing
>> multiple packets into one transmission (saving a lot of time getting=
 a
>> tx opportunity, transmitting the PHY header, etc.), which makes the
>> 'line rate' heavily depend on the amount of buffering.

making aggregation work well is key to fixing wifi worldwide.
Presently aggregation performance is pretty universally terrible under
real loads and tcp.

(looking further ahead, getting multi-user mimo to work in 802.11ac
would also be helpful but I'm not even sure the IEEE figured that out
yet. Ath10k hw2 do it?)

> How long a TX packet is put on hold hoping a following packet will
> come ?
>
>
>
>> Aggregating multiple packets into one transmission also causes extra
>> packet loss, which is compensated by retransmission and reordering, =
thus
>> introducing additional latency.

I was extremely encouraged by Yucheng's presentation at ietf on some
vast improvements on managing re-ordering problems. I daydreamed that
it would become possible to eliminate the reorder buffer in lower
levels of the wireless stack(s?).

See slides and fantasize:

http://www.ietf.org/proceedings/88/slides/slides-88-iccrg-6.pdf

The rest of the preso was good, too.

I also thought the new pacing stuff would cause trouble in wifi and agg=
regation.

>> I don't think that TSQ can do a decent job of mitigating bufferbloat=
 on
>> 802.11n devices without a significant performance hit, so adding a n=
ew
>> netdev attribute might be a good idea.

I am not sure which part of what subsystem(s) is really under debate
here. TSQ limits the number of packets that can be outstanding in a
stream. The characteristics of a wifi connection (EDCA scheduling and
aggregated batching) play merry hell with TCP assumptions. The recent
work on fixing TSO offloads shows what can happen if that underlying
set of assumptions is fixed.

My overall take on this, tho, is to take the latest bits of  TSQ and
"fq" code, and go measure the effect on wifi stations rather than
discuss what layer is busted or what options need to be added to
netdev. Has anyone done that? I've been busy with 3.10.x

Personally I don't have much of a problem if TSQ hurts single stream
TCP throughput on wifi. I would vastly prefer aggregation to work
better for multiple streams with vastly smaller buffers than it does.
That would be a bigger win, overall.

> The netdev attribute would work, but might not work well if using a
> tunnel...

I am going to make some coffee and catch up. Please excuse whatever
noise I just introduced.

>
>
>



--=20
Dave T=E4ht

=46ixing bufferbloat with cerowrt: http://www.teklibre.com/cerowrt/subs=
cribe.html
