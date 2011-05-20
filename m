From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Fri, 20 May 2011 03:27:37 -0700
Message-ID: <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
	<20110518.152653.1486764697527722925.davem@davemloft.net>
	<BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
	<20110518.155200.801089483916944725.davem@davemloft.net>
	<20110518202025.GC4175@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, tsunanet@gmail.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518202025.GC4175@nuttenaction>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 1:20 PM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * David Miller | 2011-05-18 15:52:00 [-0400]:
>
>>I've already changed the initial TCP congestion window in Linux to 10
>>without some stupid draft being fully accepted.
>>
>>I'll just as easily accept right now a patch right now which lowers
>>the initial RTO to 1 second and adds the 3 second RTO fallback.
>
> I like the idea to make the initial RTO a knob because we in a isolat=
ed MANET
> environment have a RTT larger then 1 second. Especially the link laye=
r setup
> procedure over several hops demand some time-costly setup time. After=
 that the
> RTT is <1 second. The current algorithm works great for us. So this R=
TO change
> will be counterproductive: it will always trigger a needless timeout.
>
> The main problem for us is that Google at all pushing their view of I=
nternet
> with a lot of pressure. The same is true for the IETF IW adjustments,=
 which is
> unsuitable for networks which operates at a bandwidth characteristic =
some
> years ago. The _former_ conservative principle "TCP over everything" =
is
> forgotten.

Not sure how our various parameter tuning proposals deviate from the "T=
CP over
everything" principle?

Note that the design goal of rfc2988bis is to try to benefit 98% of
traffic while
keeping any negative impact to the remaining 2% at a minimum. This is w=
hy we
limit the use of < 3sec initRTO to at most once. This way the negative =
impact
of the 1sec initRTO to a path with RTT > 1sec is limited mostly to one
additional,
small, spuriously retransmitted SYN or SYN-ACK pkt, and the unnecessary
reduction of IW to 1 segment.

We actually thought about removing the IW reduction part but unfortunat=
ely the
text belongs to a different rfc5681, which is at a higher maturity
level ("draft-standard")
than rfc2988 hence can't be done as part of rfc2988bis. Anyway I have
since added
the recommendation to the IW10 draft. See draft-ietf-tcpm-initcwnd-01.t=
xt.

The bottom line is the damage of rfc2988bis to any network with
initRTT > 1sec is
limited to one spurious retransmitted SYN/SYN-ACK. In the current Linux=
 code,
the SYN/SYN-ACK retransmit is forgotten on the passive open side by the=
 time
3WHS is completed so there is nothing needed to be done. But for the ac=
tive
open side SYN retransmit will cause not long IW to be reduced to 1, but=
 also
reduction of ssthresh, which is not part of rfc5681 so some more work i=
s needed.
I can provide a patch (or work with tsuna) to ensure a correct fix is m=
ade.

Jerry

>
> Hagen
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
