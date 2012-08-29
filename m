From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Wed, 29 Aug 2012 10:25:34 -0700
Message-ID: <CAFbMe2PG90X7s6s970+XK3X0Jvzx4p6vhvM+JQCwtULPvs1QLw@mail.gmail.com>
References: <1345724123.5904.756.camel@edumazet-glaptop>
	<50362407.9070805@linlab.net>
	<1345726185.5904.835.camel@edumazet-glaptop>
	<20120824.134231.41073001349178209.davem@davemloft.net>
	<20120825084819.GD430@linlab.net>
	<CAFbMe2Pgjbttt+Z3RQ9KL05=GHqZYk5ubNH2G1-EUn_f_RBaEQ@mail.gmail.com>
	<1346230305.2522.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Bergmann <alex@linlab.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346230305.2522.15.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric,

On Wed, Aug 29, 2012 at 1:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-08-28 at 21:34 -0700, H.K. Jerry Chu wrote:
>
>> IMHO 31secs seem a little short. Why not change it to 6 as well because 63
>> secs still beats 93secs with 3sec initRTO and 5 retries.
>>
>> Jerry
>>
>
> My rationale was that such increase were going to amplify SYN attacks
> impact by 20% (if we count number of useless SYNACK sent)

IMHO the main damage caused by SYN attack is DOS resulted from bogus
SYNs clogging the listener queue. I guess you've had numbers showing
that generating so many SYNACKs in response to bogus SYNs can be costly
too. But each bogus SYN that expires earlier will open up space sooner in the
listener queue for more bogus SYN so I'm not sure which one can induced
more damage.

Also if syn-cookie is enabled, it will dwarf the cost from
retransmitting SYN-ACK,
right?

>
> If the active side sends SYN packets for 180 seconds, do we really want
> to also send SYNACKS for additional 100 seconds ?

You have a good point. (I remember some folks in the past even question with
retransmitting SYN why SYN-ACK retransmit is necessary, other than for expedient
recovery purpose.)

But it probably matter slightly more for TCP Fast Open (the server
side patch has
been completed and will be posted soon, after I finish breaking it up
into smaller
pieces for ease of review purpose), when a full socket will be created with data
passed to the app upon a valid SYN+data. Dropping a fully functioning socket
won't be the same as dropping a request_sock unknown to the app and letting
the other side retransmitting SYN (w/o data this time).

>
> Sure, RFC numbers are what they are, but in practice, I doubt someone
> will really miss the extra SYNACK sent after ~32 seconds, since it would
> matter only for the last SYN attempted.

I'd slightly prefer 1 extra retry plus longer wait time just to make
TCP Fast Open
a little more robust (even though the app protocol is required to be
idempotent).
But this is not a showstopper.

Thanks,

Jerry

>
>
>
