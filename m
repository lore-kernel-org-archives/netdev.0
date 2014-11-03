From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: TCP NewReno and single retransmit
Date: Mon, 03 Nov 2014 14:38:05 -0200
Message-ID: <5457AF6D.6010105@redhat.com>
References: <544E93BD.50202@redhat.com> <CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com> <54521FD6.70403@redhat.com> <CAK6E8=dYfJw16Q0D40QD7RLr=wq=y+5W59zHmZ24L49OPS9O5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbaKCQiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 11:38:09 -0500
In-Reply-To: <CAK6E8=dYfJw16Q0D40QD7RLr=wq=y+5W59zHmZ24L49OPS9O5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31-10-2014 01:51, Yuchung Cheng wrote:
> On Thu, Oct 30, 2014 at 7:24 PM, Marcelo Ricardo Leitner
> <mleitner@redhat.com> wrote:
>> On 30-10-2014 00:03, Neal Cardwell wrote:
>>>
>>> On Mon, Oct 27, 2014 at 2:49 PM, Marcelo Ricardo Leitner
>>> <mleitner@redhat.com> wrote:
>>>>
>>>> Hi,
>>>>
>>>> We have a report from a customer saying that on a very calm connection,
>>>> like
>>>> having only a single data packet within some minutes, if this packet gets
>>>> to
>>>> be re-transmitted, retrans_stamp is only cleared when the next acked
>>>> packet
>>>> is received. But this may make we abort the connection too soon if this
>>>> next
>>>> packet also gets lost, because the reference for the initial loss is
>>>> still
>>>> for a big while ago..
>>>
>>> ...
>>>>
>>>> @@ -2382,31 +2382,32 @@ static inline bool tcp_may_undo(const struct
>>>> tcp_sock *tp)
>>>>    static bool tcp_try_undo_recovery(struct sock *sk)
>>>
>>> ...
>>>>
>>>>           if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
>>>>                   /* Hold old state until something *above* high_seq
>>>>                    * is ACKed. For Reno it is MUST to prevent false
>>>>                    * fast retransmits (RFC2582). SACK TCP is safe. */
> Or we can just remove this strange state-holding logic?
>
> I couldn't find such a "MUST" statement in RFC2582. RFC2582 section 3
> step 5 suggests exiting the recovery procedure when an ACK acknowledges
> the "recover" variable (== tp->high_seq - 1).
>
> Since we've called tcp_reset_reno_sack() before tcp_try_undo_recovery(),
> I couldn't see how false fast retransmits can be triggered without
> this state-holding.
>
> Any insights?

Nice one, me neither. Neal?

 From RFC2582, Section 5, Avoiding Multiple Fast Retransmits:

    Nevertheless, unnecessary Fast Retransmits can occur with Reno or
    NewReno TCP, particularly if a Retransmit Timeout occurs during Fast
    Recovery.  (This is illustrated for Reno on page 6 of [F98], and for
    NewReno on page 8 of [F98].)  With NewReno, the data sender remains
    in Fast Recovery until either a Retransmit Timeout, or *until all of
    the data outstanding when Fast Retransmit was entered has been
    acknowledged*.  Thus with NewReno, the problem of multiple Fast
    Retransmits from a single window of data can only occur after a
    Retransmit Timeout.

Bolding mark is mine. If I didn't miss anything, as that condition was met, we 
should be good to keep that cwnd reduction (required by section 3 step 5) and 
but get back to Open state right away.

Marcelo

>>>>                   tcp_moderate_cwnd(tp);
>>>> +               tp->retrans_stamp = 0;
>>>>                   return true;
>>>>           }
>>>>           tcp_set_ca_state(sk, TCP_CA_Open);
>>>>           return false;
>>>>    }
>>>>
>>>> We would still hold state, at least part of it.. WDYT?
>>>
>>>
>>> This approach sounds OK to me as long as we include a check of
>>> tcp_any_retrans_done(), as we do in the similar code paths (for
>>> motivation, see the comment above tcp_any_retrans_done()).
>>
>>
>> Yes, okay. I thought that this would be taken care of already by then but
>> reading the code again now after your comment, I can see what you're saying.
>> Thanks.
>>
>>> So it sounds fine to me if you change that one new line to the following
>>> 2:
>>>
>>> +  if (!tcp_any_retrans_done(sk))
>>> +    tp->retrans_stamp = 0;
>>
>>
>> Will do.
>>
>>> Nice catch!
>>
>>
>> A good part of it (including the diagram) was done by customer. :)
>> I'll post the patch as soon as we sync with them (credits).
>>
>> Marcelo
>>
>
