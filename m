From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Tue, 18 Aug 2009 19:40:01 +0200
Message-ID: <4A8AE771.1070308@tvk.rwth-aachen.de>
References: <4A8155AE.7000707@tvk.rwth-aachen.de>
 <20090813.160839.127192632.davem@davemloft.net>
 <4A8553AD.2000601@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0908181514560.10654@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:62733 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759409AbZHRRkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 13:40:02 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOL00HG32EQEMB0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 18 Aug 2009 19:40:02 +0200 (CEST)
In-reply-to: <alpine.DEB.2.00.0908181514560.10654@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, 14 Aug 2009, Damian Lukowski wrote:
> 
>>> Longer than 80 columns, and use an inline function instead
>>> of a macro in order to get proper type checking.
>>> [...]
>>> Do not break up the function local variables with spurious new lines
>>> like this, please.
>>> [...]
>>> The indentation and tabbing is messed up in all of the code you are
>>> adding, please fix it up to be consistent with the surrounding code
>>> and the rest of the TCP stack.
>>>
>>> Do not use C++ style // comments.
>>
>> Better?
> 
> Please, include the changelog message on resubmits too next time.

I'm sorry, which message do you mean? I used plain diff without GIT or
anything.

>> +        if ((code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH) ||
>> +            seq != tp->snd_una  || !icsk->icsk_retransmits ||
>> +            !icsk->icsk_backoff)
> 
> I'd recommend you break this into two if()\nbreak's, one for filtering
> other icmps and other for filtering mismatching against the socket's state.

Ok.

>> +        icsk->icsk_backoff--;
>> +        icsk->icsk_rto >>= 1;
> 
> Are you absolute sure that we don't go to zero here when phase of the
> moon is just right? I'd put a max(..., 1) guard there.

Well, the retransmission timer doubles icsk_rto whenever it increases
icsk_backoff, so we should reach the original icsk_rto, when
icsk_backoff becomes zero.

>> +        skb_r = skb_peek(&sk->sk_write_queue);
> 
> tcp_write_queue_head(sk)

Ok.
> 
>> +        BUG_ON(!skb_r);
>> +
>> +        if (sock_owned_by_user(sk)) {
>> +            /* Deferring retransmission clocked by ICMP
>> +             * due to locked socket. */
>> +            inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>> +            min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
> 
> ??? (besides having indent wrong). What makes you think HZ/2 is right
> value if icsk_rto is large?

To be honest, I have taken over the code from my predecessor and didn't
question this part. When thinking about it, I would remove this block
completely. Will bad things happen, if I mess with the timer, when the
socket is locked?

>> +            TCP_RTO_MAX);
> 
> Perhaps you lack here something to exit?
> 
>> +        }
>> +
>> +        if (tcp_time_stamp - TCP_SKB_CB(skb_r)->when >
>> +            inet_csk(sk)->icsk_rto) {
> 
> icsk->icsk_rto !?!
> 
>> +            /* RTO revert clocked out retransmission. */
>> +            tcp_retransmit_skb(sk, skb_r);
> 
> This is plain wrong, tcp_sock counters will get messed up if
> TCPCB_SACKED_RETRANS is already set while calling tcp_retransmit_skb. As
> a sidenote, it would be probably useful to move the check + clear of
> that bit before doing the retransmission to some common place one day.

What, if I call tcp_retransmit_timer() manually instead? Will there
still be problems with SACK?

>> +            inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>> +                          icsk->icsk_rto, TCP_RTO_MAX);
> 
> RFC 2988, step 5.5 missing? Have you verified this patch for real?

Thats the whole point of the draft. If consecutive retransmissions
trigger fitting ICMPs, the RTO value is not doubled, but remains
constant. So you can have a retransmission schedule of
t, t+r, t+2r, t+3r, t+4r,  t+5r  ...
instead of
t, t+r, t+3r, t+7r, t+15r, t+31r ...

I can show you trace plots of patched an unpatched TCP, if you like.
Should I attach files in the mails, or better post hyperlinks to them?

>> +        } else {
>> +            /* RTO revert shortened timer. */
>> +            inet_csk_reset_xmit_timer(
>> +                sk, ICSK_TIME_RETRANS,
>> +                icsk->icsk_rto-
>> +                (tcp_time_stamp-TCP_SKB_CB(skb_r)->when),
> 
> Spacing.
> 
>> +                TCP_RTO_MAX);
>> +        }
>> +
> 
> How about:
> 
>         u32 remaining;
> 
>         remaining = icsk->icsk_rto - min(icsk->icsk_rto,
>                          tcp_time_stamp - TCP_SKB_CB(skb_r)->when));
>         if (!remaining) {
>             tcp_retransmit_skb(...);
>             remaining = icsk->icsk_rto;
>         }
>         inet_csk_reset_xmit_timer(..., remaining);

Seems to be ok, but isn't tcp_retransmit_timer(...) better?

>> -        if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
>> +        if (retrans_overstepped(sk, sysctl_tcp_retries1)) {
> 
> ??? Could you justify these changes and explain their relation to the
> draft and icmp messages? If not, please drop them and try with proper
> description and description for them in a separate patch. I fail to see
> what you're trying to achieve here. You just ended up redefining the
> sysctl meaning too I think...

Well, you're quite right. RFCs specify timeouts in dimensions of time
(seconds, minutes, etc.), but Linux specifies timeouts in form of
numbers of retransmissions. One can do this, as long as the
retransmission schedule (exponential backoff in RFC case) is known. But
with this patch, the schedule can be completely different. In the
"worst" case, the time intervals between consecutive retransmission
probes are constant, leading to a TCP timeout after few seconds, instead
of several minutes.
What I did here, is to calculate the TCP timeout as if the schedule were
still an exponential backoff, given the allowed number of
retransmissions. It is possible, that TCP will now retransmit many more
times than tcp_retries indicates, but the duration until the TCP
connection times out, is more or less equivalent to unpatched TCP with
same tcp_retries values.
So, whenever some control block uses count values, but means time
values, I have to replace the control block appropriately; and that's
what retrans_overstepped() is supposed to do.

Thanks for your help, so far
 Damian
