From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Wed, 19 Aug 2009 13:55:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0908190921210.18939@melkinkari.cs.Helsinki.FI>
References: <4A8155AE.7000707@tvk.rwth-aachen.de> <20090813.160839.127192632.davem@davemloft.net> <4A8553AD.2000601@tvk.rwth-aachen.de> <alpine.DEB.2.00.0908181514560.10654@wel-95.cs.helsinki.fi> <4A8AE771.1070308@tvk.rwth-aachen.de>
 <Pine.LNX.4.64.0908190012400.13065@melkinkari.cs.Helsinki.FI> <4A8B3FC8.9080707@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52306 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZHSKz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 06:55:26 -0400
In-Reply-To: <4A8B3FC8.9080707@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2009, Damian Lukowski wrote:

> Ok, I will fully quote previous messages now. Just wanted to avoid
> redundancy.

Full quoting is not what I meant, Dave explained what I meant in his mail.

> Anyway, as long as the draft is not accepted as RFC, the
> patch will violate current standards, so I doubt, Dave would like to
> apply it soon. :)

...Don't be too sure on that ;-).

> >>>> +        icsk->icsk_backoff--;
> >>>> +        icsk->icsk_rto >>= 1;
> >>> Are you absolute sure that we don't go to zero here when phase of the
> >>> moon is just right? I'd put a max(..., 1) guard there.
> >> Well, the retransmission timer doubles icsk_rto whenever it increases
> >> icsk_backoff, so we should reach the original icsk_rto, when
> >> icsk_backoff becomes zero.
> > 
> > This is a false assumption. Take a look into the formula, there's a 
> > cap how far icsk_rto goes but icsk_backoff keeps increasing. In fact, 
> > there would probably be a need to set some other lower bound than 1, 
> > TCP_RTO_MIN would probably be more appropriate for this.
> 
> *sigh* I should have seen that. I would like to preserve the initial rto
> value and not work with RTO_MIN. First, I have thought about storing the
> initial rto in another state variable. But what, if we simply
> recalculate the value?:
> ###
> 	icsk->icsk_backoff--;
> -	icsk->icsk_rto >>= 1;
> +	tcp_set_rto(sk);
> +	icsk->icsk_rto <<= icsk->icsk_backoff;
> +	tcp_bound_rto(sk);
> ###

Yes, this is sort of a problem. I'd recommend that you read through all 
icsk_rto readers and writers and see if recalculation can be done without 
getting into some problems.

> >>>> +        BUG_ON(!skb_r);
> >>>> +
> >>>> +        if (sock_owned_by_user(sk)) {
> >>>> +            /* Deferring retransmission clocked by ICMP
> >>>> +             * due to locked socket. */
> >>>> +            inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> >>>> +            min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
> >>> ??? (besides having indent wrong). What makes you think HZ/2 is right
> >>> value if icsk_rto is large?
> >> To be honest, I have taken over the code from my predecessor and didn't
> >> question this part.
> > 
> > But you did Signoff that regardless, so you should know ;-).
> 
> Only because checkpatch.pl didn't like it otherwise. :)

...And you dare to admit :-) ...It certainly has some other meaning beyond 
checkpatch complain, for future, please check and understand what it 
means that you add it there.

> >>>> +            inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> >>>> +                          icsk->icsk_rto, TCP_RTO_MAX);
> >>> RFC 2988, step 5.5 missing? Have you verified this patch for real?
> >> Thats the whole point of the draft. If consecutive retransmissions
> >> trigger fitting ICMPs, the RTO value is not doubled, but remains
> >> constant.
> > 
> > No, either the draft is wrong or the implementation. 5.5 step should be 
> > applied. Now you end up decreasing RTO per icmp which causes imminent 
> > retransmission instead of keeping it "constant". Effectively, step 4, 5, 6 
> > (halves like you do), 7 -> R, R is 5.4-5.6 and 5.5 increases RTO again 
> > because the timer _expired_ here even though we did short-circuit it 
> > instead of setting a zero timer and using the normal procedure (which in 
> > itself is ok approach, no need to force timer to expire).
> > 
> >> So you can have a retransmission schedule of
> >> t, t+r, t+2r, t+3r, t+4r,  t+5r  ...
> >> instead of
> >> t, t+r, t+3r, t+7r, t+15r, t+31r ...
> > 
> > Sure, but that's not what happens, instead you will get this series:
> > 
> > t, t+r, (t+r)/2, (t+r)/4, ...
> > 
> > ...disclaimer: it might be off-by-something somewhere but I hope you get 
> > my point anyway.
> 
> It seems to me, that we focus on different things. From the TCP code's
> point of view, RFC2988 step 5.5 is of course executed, because timeouts
> still trigger tcp_retransmit_timer(), which doubles the RTO at the end.

No and yes. For no: you artificially made tcp_retransmit_timer to not be 
called whenever the ICMP arrives at a point where RTO/2 step causes the 
timer to expire right away. But yes: if you change it to call 
tcp_retransmit_timer as we have discussed, 5.5 should be there (but that's 
not in original patch which I was commenting).

> But from the network's point of view, there is no doubling, but constant
> intervals between retransmissions.

Plain wrong, you would only end up halving as per icmp when the timing is 
right to produce the scenario I'm talking. Please show from the original 
patch

> The following happens with patched TCP (not considering RTO_MAX):
> t:		Connectivity breaks, rto is r
> t+r:		First RTO fires, SND.UNA is retransmitted by
> 		tcp_retransmit_timer() and rto := 2rto
> 		Now it is rto == 2r
> t+r+epsilon:	ICMP unreach arrives from a router.
> 		The patch sets rto := rto/2
> 		Now it is rto == r
> t+2r:		Second RTO fires, SND.UNA is retransmitted by
> 		tcp_retransmit_timer() and rto := 2rto
> 		Now it is rto == 2r
> 		Assume, that this retransmission did not trigger
> 		any ICMP message.
> t+4r:		Third RTO fires, SND.UNA is retransmitted by
> 		tcp_retransmit_timer() and rto := 2rto
> 		Now it is rto == 4r
> 		Assume, that this retransmission did not trigger
> 		any ICMP message.
> t+8r:		Fourth RTO fires, SND.UNA is retransmitted by
> 		tcp_retransmit_timer() and rto := 2rto
> 		Now it is rto == 8r
> t+8r+epsilon:	ICMP unreach arrives from a router.
> 		The patch sets rto := rto/2
> 		Now it is rto == 4r
> t+12r:		Fifth RTO fires ...

No, that was not the scenario I'm talking about. Let me try to explain:

> t:		Connectivity breaks, rto is r
> t+r:		First RTO fires, SND.UNA is retransmitted by
> 		tcp_retransmit_timer() and rto := 2rto
> 		Now it is rto == 2r
t+2r+epsilon:	ICMP unreach arrives from a router.
> 		The patch sets rto := rto/2
 		t+2r+epsilon > t+r+rto => call for retransmit in the icmp code
 		set rto = r
t+5/2r+epsilon ICMP unreach arrives from a router.
 		The patch sets rto := rto/2
 		t+5/2r+epsilon > t+something => call for retransmit
 		set rto = r/2
...

See, it's a downward spiral because nothing in the original patch takes 
care of the rto*2 (ie., step 5.5) when RTO is artificially _caused by_ the 
ICMP (ie., the halving does make expiry to happen right away, see draft 
step 7).

> >> I can show you trace plots of patched an unpatched TCP, if you like.
> >> Should I attach files in the mails, or better post hyperlinks to them?
> > 
> > Sure, but they must not be from a trivial case but the rto must 
> > "flunctuate" 
> 
> How should they fluctuate? RTO is doubled by tcp_retransmit_timer() no
> matter what happens, and it is halved by the the patch, if an
> appropriate ICMP packet has been received.

The original patch doesn't agree. If you'd have used tcp_retransmit_timer 
in the original I'd agree but you called for tcp_retransmit_skb(skb_r) 
and set the next rto yourself which wouldn't let tcp_retransmit_timer to 
run at all in the scenario I was talking about. But lets see the next 
version of the patch first and only then continue the discussion on this 
particular point about 5.5 (probably not then necessary anymore because
of a change we've discussed).

> > and the expirys must be using the "imminent" branch for it
> > to count for me as a proof that you did it right.
> 
> I'm not sure what you mean.

The case I'm talking about is the branch where we notice that after doing 
rto/2 the RTO is to be scheduled right away (see step 7 in the draft).

> Still, hyperlinks or attachments?

Either is fine, but large stuff as links. However, honestly I'm not that 
interest in them as I know that if you have the traces from the particular 
case I'm talking about, they would show the misbehavior (other cases 
work but they do not interest me at all). It would have been mostly just 
to convince you that this misbehavior is there, since my words didn't seem 
to make it :-). I propose we put this "proving" aside too for now since 
the changes we've already discussed should make this a non-issue anyway,
and therefore no need to waste time on that.


-- 
  i.
