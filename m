From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP delayed ACK heuristic
Date: Tue, 18 Dec 2012 09:54:28 -0800
Message-ID: <50D0ADD4.7030903@hp.com>
References: <270756364.27707018.1355842632348.JavaMail.root@redhat.com> <2088500005.27728019.1355843484620.JavaMail.root@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:13489 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab2LRRye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 12:54:34 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2012 08:39 AM, David Laight wrote:
> There are problems with only implementing the acks
> specified by RFC1122.
>
> I've seen problems when the sending side is doing (I think)
> 'slow start' with Nagle disabled.
> The sender would only send 4 segments before waiting for an
> ACK - even when it had more than a full sized segment waiting.
> Sender was Linux 2.6.something (probably low 20s).
> I changed the application flow to send data in the reverse
> direction to avoid the problem.
> That was on a ~0 delay local connection - which means that
> there is almost never outstanding data, and the 'slow start'
> happened almost all the time.
> Nagle is completely the wrong algorithm for the data flow.

If Nagle was already disabled, why the last sentence?  And from your 
description, even if Nagle were enabled, I would think that it was 
remote ACK+cwnd behaviour getting in your way, not Nagle, given that 
Nagle is to be decided on a user-send by user-send basis and release 
queued data (to the mercies of other heuristics) when it gets to be an 
MSS-worth.

The joys of intertwined heuristics I suppose.

Personally, I would love for there to be a way to have a cwnd's 
byte-limit's-worth of small segments outstanding at one time - it would 
make my netperf-life much easier as I could get rid of the netperf-level 
congestion window intended to keep successive requests (with Nagle 
already disabled) from getting coalesced by cwnd in a "burst-mode" test. 
* And perhaps make things nicer for the test when there is the 
occasional retransmission.  I used to think that netperf was just 
"unique" in that regard, but it sounds like you have an actual 
application looking to do that??

rick jones

* because I am trying to (ab)use the burst mode TCP_RR test for a 
maximum packets per second through the stack+NIC measurement that isn't 
also a context  switching benchmark. But I cannot really come-up with a 
real-world rationale to support further cwnd behaviour changes. 
Allowing a byte-limit-cwnd's worth of single-byte-payload TCP segments 
could easily be seen as being rather anti-social :)  And 
forcing/maintaining the original segment boundaries in retransmissions 
for small packets isn't such a hot idea either.
