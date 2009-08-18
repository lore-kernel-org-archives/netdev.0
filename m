From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Wed, 19 Aug 2009 01:56:56 +0200
Message-ID: <4A8B3FC8.9080707@tvk.rwth-aachen.de>
References: <4A8155AE.7000707@tvk.rwth-aachen.de>
 <20090813.160839.127192632.davem@davemloft.net>
 <4A8553AD.2000601@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0908181514560.10654@wel-95.cs.helsinki.fi>
 <4A8AE771.1070308@tvk.rwth-aachen.de>
 <Pine.LNX.4.64.0908190012400.13065@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:52084 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392AbZHRX44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 19:56:56 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOL006VHJUW3M30@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 19 Aug 2009 01:56:56 +0200 (CEST)
In-reply-to: <Pine.LNX.4.64.0908190012400.13065@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, 18 Aug 2009, Damian Lukowski wrote:
> 
>>> On Fri, 14 Aug 2009, Damian Lukowski wrote:
>>>
>>>>> Longer than 80 columns, and use an inline function instead
>>>>> of a macro in order to get proper type checking.
>>>>> [...]
>>>>> Do not break up the function local variables with spurious new lines
>>>>> like this, please.
>>>>> [...]
>>>>> The indentation and tabbing is messed up in all of the code you are
>>>>> adding, please fix it up to be consistent with the surrounding code
>>>>> and the rest of the TCP stack.
>>>>>
>>>>> Do not use C++ style // comments.
>>>> Better?
>>> Please, include the changelog message on resubmits too next time.
>> I'm sorry, which message do you mean? I used plain diff without GIT or
>> anything.
> 
> In the original mail you had some description about the patch, I was 
> thinking of quoting something out of it but it was missing so I didn't 
> bother copying. But more importantly, would Dave Miller want to apply the 
> patch of yours, he would need that description and it saves work for him 
> to have the description in every resubmit "duplicated" (one usually just 
> gets a boomerang mail asking for the description which is similarly 
> wasting his time).

Ok, I will fully quote previous messages now. Just wanted to avoid
redundancy. Anyway, as long as the draft is not accepted as RFC, the
patch will violate current standards, so I doubt, Dave would like to
apply it soon. :)

> 
>>>> +        icsk->icsk_backoff--;
>>>> +        icsk->icsk_rto >>= 1;
>>> Are you absolute sure that we don't go to zero here when phase of the
>>> moon is just right? I'd put a max(..., 1) guard there.
>> Well, the retransmission timer doubles icsk_rto whenever it increases
>> icsk_backoff, so we should reach the original icsk_rto, when
>> icsk_backoff becomes zero.
> 
> This is a false assumption. Take a look into the formula, there's a 
> cap how far icsk_rto goes but icsk_backoff keeps increasing. In fact, 
> there would probably be a need to set some other lower bound than 1, 
> TCP_RTO_MIN would probably be more appropriate for this.

*sigh* I should have seen that. I would like to preserve the initial rto
value and not work with RTO_MIN. First, I have thought about storing the
initial rto in another state variable. But what, if we simply
recalculate the value?:
###
	icsk->icsk_backoff--;
-	icsk->icsk_rto >>= 1;
+	tcp_set_rto(sk);
+	icsk->icsk_rto <<= icsk->icsk_backoff;
+	tcp_bound_rto(sk);
###

>>>> +        BUG_ON(!skb_r);
>>>> +
>>>> +        if (sock_owned_by_user(sk)) {
>>>> +            /* Deferring retransmission clocked by ICMP
>>>> +             * due to locked socket. */
>>>> +            inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>>>> +            min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
>>> ??? (besides having indent wrong). What makes you think HZ/2 is right
>>> value if icsk_rto is large?
>> To be honest, I have taken over the code from my predecessor and didn't
>> question this part.
> 
> But you did Signoff that regardless, so you should know ;-).

Only because checkpatch.pl didn't like it otherwise. :)

> 
>> When thinking about it, I would remove this block
>> completely. Will bad things happen, if I mess with the timer, when the
>> socket is locked?
> 
> I've no idea without looking into all the details but I think this needs 
> to be moved slightly later anyway into the imminent expiry branch and the 
> timeout value needs to be copied from tcp_write_timer instead of using 
> that bogus formula.
> 
>>>> +            TCP_RTO_MAX);
>>> Perhaps you lack here something to exit?
>>>
>>>> +        }
>>>> +
>>>> +        if (tcp_time_stamp - TCP_SKB_CB(skb_r)->when >
>>>> +            inet_csk(sk)->icsk_rto) {
>>> icsk->icsk_rto !?!
>>>
>>>> +            /* RTO revert clocked out retransmission. */
>>>> +            tcp_retransmit_skb(sk, skb_r);
>>> This is plain wrong, tcp_sock counters will get messed up if
>>> TCPCB_SACKED_RETRANS is already set while calling tcp_retransmit_skb. As
>>> a sidenote, it would be probably useful to move the check + clear of
>>> that bit before doing the retransmission to some common place one day.
>> What, if I call tcp_retransmit_timer() manually instead? Will there
>> still be problems with SACK?
> 
> SACK is fine then, and I took a quick look into the other stuff which 
> seemed to be quite ok too but it was just a quick glance, but then you 
> certainly must delay the RTO if sock_owned_by_user(sk) is true like 
> tcp_write_timer does. Tcp_retransmit_timer would also deal with the 
> missing step 5.5 btw. I'm not sure if you like all the things that will 
> happen in the tcp_enter_loss though, especially the undo_marker clearing 
> might not please you, or is at best, sub-optimal in a certain scenario.
> 
>>>> +            inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>>>> +                          icsk->icsk_rto, TCP_RTO_MAX);
>>> RFC 2988, step 5.5 missing? Have you verified this patch for real?
>> Thats the whole point of the draft. If consecutive retransmissions
>> trigger fitting ICMPs, the RTO value is not doubled, but remains
>> constant.
> 
> No, either the draft is wrong or the implementation. 5.5 step should be 
> applied. Now you end up decreasing RTO per icmp which causes imminent 
> retransmission instead of keeping it "constant". Effectively, step 4, 5, 6 
> (halves like you do), 7 -> R, R is 5.4-5.6 and 5.5 increases RTO again 
> because the timer _expired_ here even though we did short-circuit it 
> instead of setting a zero timer and using the normal procedure (which in 
> itself is ok approach, no need to force timer to expire).
> 
>> So you can have a retransmission schedule of
>> t, t+r, t+2r, t+3r, t+4r,  t+5r  ...
>> instead of
>> t, t+r, t+3r, t+7r, t+15r, t+31r ...
> 
> Sure, but that's not what happens, instead you will get this series:
> 
> t, t+r, (t+r)/2, (t+r)/4, ...
> 
> ...disclaimer: it might be off-by-something somewhere but I hope you get 
> my point anyway.

It seems to me, that we focus on different things. From the TCP code's
point of view, RFC2988 step 5.5 is of course executed, because timeouts
still trigger tcp_retransmit_timer(), which doubles the RTO at the end.
But from the network's point of view, there is no doubling, but constant
intervals between retransmissions.
The following happens with patched TCP (not considering RTO_MAX):
t:		Connectivity breaks, rto is r
t+r:		First RTO fires, SND.UNA is retransmitted by
		tcp_retransmit_timer() and rto := 2rto
		Now it is rto == 2r
t+r+epsilon:	ICMP unreach arrives from a router.
		The patch sets rto := rto/2
		Now it is rto == r
t+2r:		Second RTO fires, SND.UNA is retransmitted by
		tcp_retransmit_timer() and rto := 2rto
		Now it is rto == 2r
		Assume, that this retransmission did not trigger
		any ICMP message.
t+4r:		Third RTO fires, SND.UNA is retransmitted by
		tcp_retransmit_timer() and rto := 2rto
		Now it is rto == 4r
		Assume, that this retransmission did not trigger
		any ICMP message.
t+8r:		Fourth RTO fires, SND.UNA is retransmitted by
		tcp_retransmit_timer() and rto := 2rto
		Now it is rto == 8r
t+8r+epsilon:	ICMP unreach arrives from a router.
		The patch sets rto := rto/2
		Now it is rto == 4r
t+12r:		Fifth RTO fires ...


>> I can show you trace plots of patched an unpatched TCP, if you like.
>> Should I attach files in the mails, or better post hyperlinks to them?
> 
> Sure, but they must not be from a trivial case but the rto must 
> "flunctuate" 

How should they fluctuate? RTO is doubled by tcp_retransmit_timer() no
matter what happens, and it is halved by the the patch, if an
appropriate ICMP packet has been received.

> and the expirys must be using the "imminent" branch for it
> to count for me as a proof that you did it right.

I'm not sure what you mean.

Still, hyperlinks or attachments?

> 
>>> How about:
>>>
>>>         u32 remaining;
>>>
>>>         remaining = icsk->icsk_rto - min(icsk->icsk_rto,
>>>                          tcp_time_stamp - TCP_SKB_CB(skb_r)->when));
>>>         if (!remaining) {
>>>             tcp_retransmit_skb(...);
>>>             remaining = icsk->icsk_rto;
>>>         }
>>>         inet_csk_reset_xmit_timer(..., remaining);
>> Seems to be ok, but isn't tcp_retransmit_timer(...) better?
> 
> Yeah, that's mostly fine I guess (at least in meaning of "safe").
> 
>>>> -        if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
>>>> +        if (retrans_overstepped(sk, sysctl_tcp_retries1)) {
>>> ??? Could you justify these changes and explain their relation to the
>>> draft and icmp messages? If not, please drop them and try with proper
>>> description and description for them in a separate patch. I fail to see
>>> what you're trying to achieve here. You just ended up redefining the
>>> sysctl meaning too I think...
>> Well, you're quite right. RFCs specify timeouts in dimensions of time
>> (seconds, minutes, etc.), but Linux specifies timeouts in form of
>> numbers of retransmissions. One can do this, as long as the
>> retransmission schedule (exponential backoff in RFC case) is known. But
>> with this patch, the schedule can be completely different. In the
>> "worst" case, the time intervals between consecutive retransmission
>> probes are constant, leading to a TCP timeout after few seconds, instead
>> of several minutes.
>> What I did here, is to calculate the TCP timeout as if the schedule were
>> still an exponential backoff, given the allowed number of
>> retransmissions. It is possible, that TCP will now retransmit many more
>> times than tcp_retries indicates, but the duration until the TCP
>> connection times out, is more or less equivalent to unpatched TCP with
>> same tcp_retries values.
>> So, whenever some control block uses count values, but means time
>> values, I have to replace the control block appropriately; and that's
>> what retrans_overstepped() is supposed to do.
> 
> I can understand your point, however, this is independent thing which 
> should not be mixed with the other part of the change. So in future 
> provide them as a two patch series. ...And expect some to not like this 
> kind of change.

Ok.
