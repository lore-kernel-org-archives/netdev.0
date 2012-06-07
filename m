From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Thu, 07 Jun 2012 10:51:20 -0700
Message-ID: <4FD0EA18.3090606@hp.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F3C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:23546 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923Ab2FGRvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 13:51:22 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F3C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Does this delaying of acks have a detrimental effect on the
> sending end?
> I've seen very bad interactions between delayed acks and
> (I believe) the 'slow start' code on connections with
> one-directional data, Nagle disabled and very low RTT.
>
> What I saw was the sender sending 4 data packets, then
> sitting waiting for an ack - in spite of accumulating
> several kB of data to send.
>
> Delaying acks further will only make this worse.

At least two stacks have a reasonable ACK avoidance heuristic.  Those 
would be HP-UX and Solaris (Mac OS 9 had one as well, IIRC).  The 
heuristics are rather similar because the two TCP stacks share a common 
ancestor.  I used to interact with HP-UX's regularly, my statements will 
be based on that, and an assumption Solaris is similar.

Both attempt to divine what the senders' congestion window happens to be 
and be certain to send an ACK before that is exhausted.  So, at the 
start of a connection, there will be the usual, more rapid 
ACKnowledgement.  As things happen "normally" then the number of 
segments per ACK increases until it hits a configurable limit.  There 
are conditions which will cut the limit in half on a given connection - 
one is the sending of an ACK via the standalone ACK timer (this is from 
memory, so may be a bit off).  There are probably a few other conditions 
that drop the limit by half.  The heuristic attempts to learn in each 
connection what the reasonable limit on ACK avoidance might be so there 
isn't a per-connection control, just the global controls via ndd.  As 
conditions causing the limit to be cut in half arise, the connection 
naturally and irrevocably falls back to the usual "ack-every-other" 
behaviour.

When there is little to no packet loss, and a rather regular stream of 
data, this works rather well indeed.  For example in a LAN or Data 
Center.  You can run netperf TCP_STREAM with the limit at the default, 
and with the limit set to two and see the considerable difference in 
service demand on either side.

This may not work well when the sender has a congestion window growth 
heuristic different from what the ACK avoidance heuristic assumes.  If I 
recall correctly, the heuristic in HP-UX assumes the sender grows cwnd 
by the number of bytes/segments ACKnowledged. If the sender grows the 
cwnd by only one segment per ACK rather than by the bytes ACKnowldeged 
by the ACK the growth of the cwnd will be slowed.  In a LAN that may be 
papered-over a bit, but it will become quite noticable in a higher RTT 
environment.  Probably not as noticable for a sufficiently short 
connection, or a long one, but will be for ones in the middle.  The 
short connection doesn't need much cwnd in the first place, and the 
heuristic works its way up to avoiding ACKs, and the long one will be 
long enough to have the ACK avoidance heuristic gravitate down to 
ack-every-other.

rick jones
