From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH net-next 2/2] tcp: add CDG congestion control
Date: Fri, 5 Jun 2015 22:23:21 +0200
Message-ID: <CA++eYduZ0-NL_5j7SdzPUsGeF8KJHTV1-gzd2R3_z0qqgsD7sw@mail.gmail.com>
References: <1433451703-7516-1-git-send-email-kennetkl@ifi.uio.no>
	<1433451703-7516-2-git-send-email-kennetkl@ifi.uio.no>
	<CAK6E8=d5y_yhJVODtHy9=G0QPekrgEvXpt1aVsYMdMefXdarTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Neal Cardwell <ncardwell@google.com>,
	David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:32946 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbFEUXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 16:23:22 -0400
Received: by wgez8 with SMTP id z8so64670736wge.0
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 13:23:21 -0700 (PDT)
In-Reply-To: <CAK6E8=d5y_yhJVODtHy9=G0QPekrgEvXpt1aVsYMdMefXdarTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> nice patch. I would like to review it more thoroughly but I have some
> quick comments.
>
> given that cdg didn't include hystart. it'd be nice to have a module knob to
> enable and disable hystart for experiments.

We could include a knob to disable PRR for delay backoffs as well.
Neither are/were available in FreeBSD.

>> +       u32 now_us = local_clock() / NSEC_PER_USEC;
> now_us = mstamp_us_get();

The reason we went with u32 timestamps here instead of struct
skb_mstamp's is lack of sufficient space in struct cdg (using 2*4
bytes vs. 2*8 bytes).

There is no mstamp_us_get() in net-next? We could make one using
skb_mstamp_get(), but afaics the ACK train does not need stronger
clock guarantees than what local_clock() already offers (per-CPU
monotonicity).

>> +       if (tp->snd_cwnd < tp->snd_ssthresh)
>> +               tcp_cdg_hystart_update(sk);
> nit: reno and cubic slow starts w/ snd_cwnd == ssthresh. maybe keep
> this consistent?

I think the question is why tcp_cubic invokes HyStart when snd_cwnd == ssthresh?

Let us establish that HyStart is not a stand-alone slow start
algorithm. HyStart does not grow cwnd, but merely helps estimate a
ssthresh to avoid slow start overshoot.

If snd_cwnd == ssthresh, then HyStart's result is moot; we cannot
possibly overshoot less at that point. Imho, unconditionally invoking
HyStart in slow start only serves to mislead us into believing that it
is a slow start algorithm when it is not.


>> +       tcp_reno_cong_avoid(sk, ack, acked);

For the record, CDG still uses reno (i.e. slow start when snd_cwnd == ssthresh).

>> +
>> +       if (ca->shadow_wnd) {
>> +               ca->shadow_wnd += tp->snd_cwnd - prior_snd_cwnd;
>> +               if (ca->shadow_wnd > tp->snd_cwnd_clamp)
>> +                       ca->shadow_wnd = tp->snd_cwnd_clamp;
> Not sure why use snd_cwnd_clamp here. looks like it's applied in
> tcp_reno_cong_avoid().

The shadow window can be larger than snd_cwnd.

It behaves like the regular snd_cwnd, but it is immune to delay
backoffs. If loss occurs, presumably because of competing flows, the
shadow window behaves in a way that "undo" previous delay backoffs.

For example, assume cwnd = shadow = 20. A delay backoff reduces cwnd
to cwnd*0.7 = 14. A succeeding loss backoff would then reduce cwnd to
max(cwnd, shadow)*0.5 = 10, because shadow is still 20. (If we did not
have the shadow window, then the new cwnd after loss would have been
7.)


>> +        * Assume num_acked == 0 indicates RTT measurement from SACK.
>> +        */
> another heuristic to try is to look at tp->sacked_out. when it's
> positive the receiver should not be delaying acks (hopefully).
>

Hopefully. ;)

On pure SACK, num_acked == 0.
But if we get combined SACK + cumulative ACK of 1 segment, then num_acked is 1.

>> +       if (num_acked == 1 && ca->delack) {
So we should extend this check to be (num_acked == 1 && ca->delack &&
!tp->sacked_out).

Thank you for spotting this.


>> +       /* If non-ECN: */
>> +       if (tp->prior_ssthresh) {
> no need to check prior_ssthresh here b/c it's checked in
> tcp_undo_cwnd_reduction() already.

If we get ECE from the receiver (ECN signal), then cwnd undo is disabled.

The above check ensures that the loss tolerance heuristic can only be
used if cwnd undo is possible.

As an alternative, perhaps ssthresh could be extended with a  second
parameter to indicate why it was invoked:
ssthresh(sk, TCP_SIGNAL_LOSS)
ssthresh(sk, TCP_SIGNAL_ECN)
ssthresh(sk, TCP_SIGNAL_PRIVATE)

Then tcp_cdg_ssthresh could do:
iff signal == TCP_SIGNAL_LOSS && use_tolerance, use loss tolerance heuristic.
iff signal == TCP_SIGNAL_PRIVATE, calculate delay backoff cwnd
...
