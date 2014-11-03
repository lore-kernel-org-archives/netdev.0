From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: TCP NewReno and single retransmit
Date: Mon, 03 Nov 2014 19:35:43 -0200
Message-ID: <5457F52F.8060002@redhat.com>
References: <544E93BD.50202@redhat.com>	<CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>	<54521FD6.70403@redhat.com>	<CAK6E8=dYfJw16Q0D40QD7RLr=wq=y+5W59zHmZ24L49OPS9O5A@mail.gmail.com>	<5457AF6D.6010105@redhat.com> <CADVnQykXpA_A87+bFOCdbb-QLTRf-5TEgspCzE-STO49N+6waw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376AbaKCVfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 16:35:48 -0500
In-Reply-To: <CADVnQykXpA_A87+bFOCdbb-QLTRf-5TEgspCzE-STO49N+6waw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-11-2014 18:08, Neal Cardwell wrote:
> On Mon, Nov 3, 2014 at 11:38 AM, Marcelo Ricardo Leitner
> <mleitner@redhat.com> wrote:
>> On 31-10-2014 01:51, Yuchung Cheng wrote:
>>>>>>            if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
>>>>>>                    /* Hold old state until something *above* high_seq
>>>>>>                     * is ACKed. For Reno it is MUST to prevent false
>>>>>>                     * fast retransmits (RFC2582). SACK TCP is safe. */
>>>
>>> Or we can just remove this strange state-holding logic?
>>>
>>> I couldn't find such a "MUST" statement in RFC2582. RFC2582 section 3
>>> step 5 suggests exiting the recovery procedure when an ACK acknowledges
>>> the "recover" variable (== tp->high_seq - 1).
>>>
>>> Since we've called tcp_reset_reno_sack() before tcp_try_undo_recovery(),
>>> I couldn't see how false fast retransmits can be triggered without
>>> this state-holding.
>>>
>>> Any insights?
>>
>>
>> Nice one, me neither. Neal?
>
> Since there are no literal IETF-style "MUST" statements in RFC2582, I
> think the "MUST" in the code here is expressing the design philosophy
> behind the author. :-)
>
> AFAICT the "Hold old state" code in tcp_try_undo_recovery() is a
> pretty reasonable implementation of a mechanism specified in NewReno
> RFCs to deal with the fundamental ambiguity between (1) dupacks for
> packets the receiver received above a hole above snd_una, and (2)
> dupacks for spurious retransmits below snd_una. I think the motivation
> behind the "Hold old state" code is to stay in Recovery so that we do
> not treat (2) dupacks as (1) dupacks.
>
> I find RFC 2582 not very clear on this point, and the newest NewReno
> RFC, RFC 6582, is also not so clear IMHO. But the RFC 3782 version of
> NewReno - https://tools.ietf.org/html/rfc3782 - has a reasonable
> discussion of this issue. There is a discussion in
> https://tools.ietf.org/html/rfc3782#section-11
> of this ambiguity:
>
>     There are two separate scenarios in which the TCP sender could
>     receive three duplicate acknowledgements acknowledging "recover" but
>     no more than "recover".  One scenario would be that the data sender
>     transmitted four packets with sequence numbers higher than "recover",
>     that the first packet was dropped in the network, and the following
>     three packets triggered three duplicate acknowledgements
>     acknowledging "recover".  The second scenario would be that the
>     sender unnecessarily retransmitted three packets below "recover", and
>     that these three packets triggered three duplicate acknowledgements
>     acknowledging "recover".  In the absence of SACK, the TCP sender is
>     unable to distinguish between these two scenarios.
>
> AFAICT RFC 3782 uses the term "recover" for the sequence number Linux
> calls tp->high_seq. The specification in RFC 3782 Sec 3 -
> https://tools.ietf.org/html/rfc3782#section-3 - of the criteria for
> entering Fast Recovery say that we shouldn't go into a new recovery if
> the cumulative ACK field doesn't cover more than high_seq/"recover":
>
>     1)  Three duplicate ACKs:
>         When the third duplicate ACK is received and the sender is not
>         already in the Fast Recovery procedure, check to see if the
>         Cumulative Acknowledgement field covers more than "recover".  If
>         so, go to Step 1A.  Otherwise, go to Step 1B.
>
>     1A) Invoking Fast Retransmit:
>         ...
>         In addition, record the highest sequence number transmitted in
>         the variable "recover", and go to Step 2.
>
>     1B) Not invoking Fast Retransmit:
>         ...
>
> The last few slides of this presentation by Sally Floyd also talk
> about this point:
>
>    http://www.icir.org/floyd/talks/newreno-Mar03.pdf

So by sticking with the recovery for a bit longer will help disambiguate the 3 
dupacks on high_seq, if they ever happen, and with that avoid re-entering Fast 
Retransmit if initial (2) happen. It's at the cost of leaving the fast 
retransmit an ack later but if (2) happens the impact would be much worse, AFAICS.

Cool, thanks Neal. If Yuchung is okay with it, I'll proceed with just zeroing 
that tstamp as initially proposed.

Marcelo
