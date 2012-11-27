From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP and reordering
Date: Tue, 27 Nov 2012 10:00:58 -0800
Message-ID: <50B4FFDA.1050808@hp.com>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com> <50B4F2DA.8020206@hp.com> <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Saku Ytti <saku@ytti.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:32163 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812Ab2K0SBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 13:01:00 -0500
In-Reply-To: <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/2012 09:15 AM, Saku Ytti wrote:
> On 27 November 2012 19:05, Rick Jones <rick.jones2@hp.com> wrote:
>
>> Packet reordering is supposed to be the exception, not the rule.
>> Links which habitually/constantly introduce reordering are, in my
>> opinion, broken. Optimizing for them would be optimizing an error
>> case.
>
> TCP used to be friendly to reordering before fast retransmit
> optimization was implemented.

It remained "friendly" to reordering even after fast retransmit was 
implemented - just not to particularly bad reordering.

And friendly is somewhat relative.  Even before fast retransmit came to 
be, TCP would immediately ACK each out-of-order segment.

> It seems like minimal complexity in TCP algorithm and would
> dynamically work correctly depending on situation. It is rather slim
> comfort that network should work, when it does not, and you cannot
> affect it.

It is probably considered an "ancient" text these days, but one of the 
chapter intros for The Mythical Man Month includes a quote from Ovid:

adde parvum parvo magnus acervus erit

which if recollection serves the book translated as:

add little to little and soon there will be a big pile.

> But if the complexity is higher than I expect, then I fully agree,
> makes no sense to add it. Reason why reordering can happen in modern
> MPLS network is that you have to essentially duck type your traffic,
> and sometimes you duck type them wrong and you are then calculating
> ECMP on incorrect values, causing packets inside flow to take
> different ports.

I appreciate that one may not always have "access" and there can be 
layer 8 and layer 9 issues involved, but if incorrect typing is the root 
cause of the reordering, treating root cause rather than the symptom is 
what should happen.  How many kludges, no matter how angelic, can fit in 
a TCP implementation?

For other reasons (CPU utilization) various stacks (HP-UX, Solaris, some 
versions of MacOS) have had explicit ACK-avoidance heuristics.  They 
would back-off from ack-every-other to back-every-N, N >> 2.  The 
heuristics worked quite well in LAN environments and on bulk flows (eg 
FTP, ttcp, netperf TCP_STREAM), not necessarily as well in other 
environments.   One (very necessary) part of the heuristic in those is 
to go back to ack-every-other when necessary.  That keyed off the 
standalone ACK timer - if that ever fired the current avoidance count 
would go back to 2, and the max allowed would be half what it was 
before.  However, that took a non-trivial performance hit when there was 
  "tail-drop" and something that wasn't a continuous stream of traffic - 
the tail got dropped, nothing to cause out-of-order to force immediate 
ACKs.  (*) Standalone ACK timer is then the only thing getting us back 
out which means idleness.  I worked a number of "WAN performance 
problems" involving one of those stacks where part of the solution was 
turning down the limits on the ack avoidance heuristic by a considerable 
quantity.  (And I say this as someone with a fondness for the schemes)

I cannot say with certainty your idea would have the same problems but 
as you look to work-out a solution to propose as a patch, you will have 
to keep that in mind.

rick

* yes, the same holds true for a non-ack-avoiding setup, the heuristic 
simply made it worse - especially if the sender wanted to send but had 
gotten limited by cwnd - the ACK(s) of the head of that chunk of data 
were "avoided" and so wouldn't open the cwnd which might then allow 
futher segments to enable detection of the dropped segments.  Even 
without losses it also tended to interact poorly with sending TCPs which 
wantend to increase the congestion window by one MSS for each ACK rather 
than based on the quantity of bytes covered by the ACK.
