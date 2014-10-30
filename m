From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: TCP NewReno and single retransmit
Date: Thu, 30 Oct 2014 09:24:06 -0200
Message-ID: <54521FD6.70403@redhat.com>
References: <544E93BD.50202@redhat.com> <CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759273AbaJ3LYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 07:24:12 -0400
In-Reply-To: <CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-10-2014 00:03, Neal Cardwell wrote:
> On Mon, Oct 27, 2014 at 2:49 PM, Marcelo Ricardo Leitner
> <mleitner@redhat.com> wrote:
>> Hi,
>>
>> We have a report from a customer saying that on a very calm connection, like
>> having only a single data packet within some minutes, if this packet gets to
>> be re-transmitted, retrans_stamp is only cleared when the next acked packet
>> is received. But this may make we abort the connection too soon if this next
>> packet also gets lost, because the reference for the initial loss is still
>> for a big while ago..
> ...
>> @@ -2382,31 +2382,32 @@ static inline bool tcp_may_undo(const struct
>> tcp_sock *tp)
>>   static bool tcp_try_undo_recovery(struct sock *sk)
> ...
>>          if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
>>                  /* Hold old state until something *above* high_seq
>>                   * is ACKed. For Reno it is MUST to prevent false
>>                   * fast retransmits (RFC2582). SACK TCP is safe. */
>>                  tcp_moderate_cwnd(tp);
>> +               tp->retrans_stamp = 0;
>>                  return true;
>>          }
>>          tcp_set_ca_state(sk, TCP_CA_Open);
>>          return false;
>>   }
>>
>> We would still hold state, at least part of it.. WDYT?
>
> This approach sounds OK to me as long as we include a check of
> tcp_any_retrans_done(), as we do in the similar code paths (for
> motivation, see the comment above tcp_any_retrans_done()).

Yes, okay. I thought that this would be taken care of already by then but 
reading the code again now after your comment, I can see what you're saying. 
Thanks.

> So it sounds fine to me if you change that one new line to the following 2:
>
> +  if (!tcp_any_retrans_done(sk))
> +    tp->retrans_stamp = 0;

Will do.

> Nice catch!

A good part of it (including the diagram) was done by customer. :)
I'll post the patch as soon as we sync with them (credits).

Marcelo
