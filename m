From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH net-next 2/2] tcp: add CDG congestion control
Date: Mon, 8 Jun 2015 16:58:32 +0200
Message-ID: <CA++eYdtvah5WJR0j0XXw7F-=3K+zbSNeW_z8WYa++gNQb0_Y_A@mail.gmail.com>
References: <1433451703-7516-1-git-send-email-kennetkl@ifi.uio.no>
	<1433451703-7516-2-git-send-email-kennetkl@ifi.uio.no>
	<CAK6E8=d5y_yhJVODtHy9=G0QPekrgEvXpt1aVsYMdMefXdarTQ@mail.gmail.com>
	<CA++eYduZ0-NL_5j7SdzPUsGeF8KJHTV1-gzd2R3_z0qqgsD7sw@mail.gmail.com>
	<CAK6E8=fYAwT27-foN7_CDbgYzBckgTxb0snQr8XxZ33+3wF=KA@mail.gmail.com>
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
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35411 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbFHO6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 10:58:33 -0400
Received: by wgme6 with SMTP id e6so105621596wgm.2
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 07:58:32 -0700 (PDT)
In-Reply-To: <CAK6E8=fYAwT27-foN7_CDbgYzBckgTxb0snQr8XxZ33+3wF=KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 6, 2015 at 7:01 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Fri, Jun 5, 2015 at 1:23 PM, Kenneth Klette Jonassen
> <kennetkl@ifi.uio.no> wrote:
>>> nice patch. I would like to review it more thoroughly but I have some
>>> quick comments.
>>>
>>> given that cdg didn't include hystart. it'd be nice to have a module knob to
>>> enable and disable hystart for experiments.
>>
>> We could include a knob to disable PRR for delay backoffs as well.
>> Neither are/were available in FreeBSD.
> Seems to belong to a different bigger change to make PRR option for CC
> in general? or is it easy to do in CDG locally?

Yes, I agree. A global option is probably the better alternative. We
could use it to experiment with PRR's effects in other CCs etc.

>
> Understood. My previous comment was not clear: while the shadow_wnd
> can be over the clamp, it's fine because we always clamp the cwnd in
> tcp_reno_cong_avoid()?
>
> In the future if we want to dump shadow_wnd via TCP_CC_INFO, it'll
> be good to know the real value, not the clamped one set by apps.

Ah ok. Yes, we do not need to clamp shadow_wnd in cong_avoid(). We can
change it to only deal with integer overflow instead.

>>>> +       /* If non-ECN: */
>>>> +       if (tp->prior_ssthresh) {
>>> no need to check prior_ssthresh here b/c it's checked in
>>> tcp_undo_cwnd_reduction() already.
>>
>> If we get ECE from the receiver (ECN signal), then cwnd undo is disabled.
>>
>> The above check ensures that the loss tolerance heuristic can only be
>> used if cwnd undo is possible.
>>
>> As an alternative, perhaps ssthresh could be extended with a  second
>> parameter to indicate why it was invoked:
>> ssthresh(sk, TCP_SIGNAL_LOSS)
>> ssthresh(sk, TCP_SIGNAL_ECN)
>> ssthresh(sk, TCP_SIGNAL_PRIVATE)
>>
>> Then tcp_cdg_ssthresh could do:
>> iff signal == TCP_SIGNAL_LOSS && use_tolerance, use loss tolerance heuristic.
>> iff signal == TCP_SIGNAL_PRIVATE, calculate delay backoff cwnd
> maybe passing the ack "flag" is good enough?
>

On second thought, this touches a lot of code for a small benefit.

Is it okay if we just do:
bool is_ecn = (tp->prior_ssthresh == 0);
?
