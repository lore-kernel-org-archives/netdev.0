From: apetlund@simula.no
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Fri, 30 Oct 2009 16:23:43 +0100
Message-ID: <52481f5b4edfdbd96dcde46aed403fcf.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Arnd Hannemann" <hannemann@nets.rwth-aachen.de>,
	"Andreas Petlund" <apetlund@simula.no>,
	"William Allen Simpson" <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Christian Samsel" <christian.samsel@rwth-aachen.de>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:43818 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932349AbZJ3PXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 11:23:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 29 Oct 2009, Arnd Hannemann wrote:
>
>> Andreas Petlund schrieb:
>> > Den 28. okt. 2009 kl. 04.09 skrev William Allen Simpson:
>> >
>> >> Andreas Petlund wrote:
>> >>> +/* Determines whether this is a thin stream (which may suffer from
+ * increased latency). Used to trigger latency-reducing
mechanisms.
>> >>> + */
>> >>> +static inline unsigned int tcp_stream_is_thin(const struct
tcp_sock *tp)
>> >>> +{
>> >>> +	return tp->packets_out < 4;
>> >>> +}
>> >>> +
>> >> This bothers me a bit.  Having just looked at your Linux
>> presentation,
>> >> and not (yet) read your papers, it seems much of your justification was
>> >> with 1 packet per RTT.  Here, you seem to be concentrating on 4,
probably
>> >> because many implementations quickly ramp up to 4.
>> >>
>> >
>> > The limit of 4 packets in flight is based on the fact that less than
4
>> > packets in flight makes fast retransmissions impossible, thus
limiting
>> > the retransmit options to timeout-retransmissions. The criterion is
>> There is Limited Transmit! So this is generally not true.
>> > therefore as conservative as possible while still serving its
purpose.
>> > If further losses occur, the exponential backoff will increase
latency
>> > further. The concept of using this limit is also discussed in the
Internet draft for Early Retransmit by Allman et al.:
>> > http://www.icir.org/mallman/papers/draft-ietf-tcpm-early-rexmt-01.txt
>> This ID is covering exactly the cases which Limited Transmit does not
cover and works "automagically" without help of application. So why not
just implement this ID?
>
> I even gave some advise recently to one guy how to polish up the early
retransmit implementation of his. ...However, I think we haven't heard
from that since then... I added him as CC if he happens to have it
already
> done.
>
> It is actually so that patches 1+3 implement sort of an early
retransmit,
> just slightly more aggressive of it than what is given in ID but I find
the difference in the aggressiveness rather insignificant. ...Whereas
the
> RTO stuff is more questionable.
>

I share the opinion that the linear timeouts should be limited, and back
off exponentially after the limit, as Eric suggested. I believe this will
be a sufficient safety-valve for the black-hole scenario, although I would
like to run some tests.

As I wrote to Arnd, there are many similarities with the EFR approach and
what our patch does. The largest difference is that the thin-stream
patterns are identified as an indication of time dependent/interactive
apps. This is the reason why the proposed patch does not try to keep an
inflated cwnd open, but only focuses on the cases of few packets in
flight. The target is time-dependent/interactive applications, and as such
we don't want a generally enabled mechanism, but want to give the option
of enabling it only in the cases where they are most needed (in contrast
to a generally enabled "automagically" triggered EFR).

Below is a link to a table presenting some of the applications that we
have traced and analysed the packet interarrival times of:

http://folk.uio.no/apetlund/lktmp/thin_apps_table.pdf

We were surprised to see how many cases of "thin-stream" traffic patterns
were indicative of time-dependent/interactive apps.

Regards,
Andreas






