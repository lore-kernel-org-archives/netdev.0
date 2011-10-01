From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Sat, 01 Oct 2011 17:13:27 -0400
Message-ID: <6.2.5.6.2.20111001171315.05c08c30@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:35874 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab1JAVQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Oct 2011 17:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resend, accidently pasted HTML that VGER bounced]

At Sat 14:41:06 EST 10/1/2011 -0400, Willy Tarreau wrote:
>Just a suggestion, instead of measuring CPU usage
>at a given load, could you check what maximal load
>you can achieve?

Did do that and mentioned it in one of my replies.
Essentially the same result, see comment below.

>It is very possible that CPU
>usage report is not accurate. We observed this in
>a number of situations, especially in high packet
>rate environments where the usage is a sum of many
>micro-measurements.

Thanks for the suggestion Willy.

I'm completely on top of the CPU accounting
aliasing problem.  The playback server sends
data in pulses on one-millisecond boundaries
due to the behavior of nsleep() when used to
pace a log playback.  The receiving system
clock drifts at a rate that is about 60 PPM
different than the transmitting server clock
(according to 'ntpd' synced to within 20 micro-
seconds of a local CDMA time server), and so the
histogram accounting on clock tick intervals
gradually drifts such that CPU displayed by 'top'
and 'vmstat' is actually a varying slice of the
millisecond interval pulse profile.  Takes
about 60 seconds for the alias sample
window to drift through the entire pulse.

Turns out if one understands the effect it
adds some value to the recorded CPU statistics.
One can see that the kernel CPU peak arrives
immediately and decays while the user CPU
peak follow somewhere between 150 and 250
microseconds after the kernel peak.
Makes perfect sense as at the start of the
pulse the packets are being processed in the
kernel and are then handed off to the application.

Anyway the test run is 20 minutes long so the
values reported here are accurate due to
the averaging-out of the aliasing effect.

As mentioned in one of my posts, do also run
at close to 100% utilization where the 
aliasing effect does not distort results.
Outcome is the same as the 50% load runs
except that the code runs 20% more efficiently
at full due to batching of packets with
fewer interrupts and context switches.

>Also, I did not notice any indication on the load
>level you were reaching (packets per second and
>bandwidth).

20% bandwidth and 50k pps on four links for
half-load test, 200k pps total

40% bandwidth and 100k pps on four links for
full-load test, 400k pps total

>Have you compared the interrupt rate?
>It is possible that they differ between the two
>kernels, for instance because the NIC auto-adapts
>instead of being throttled to a given rate. This
>can have a significant impact on measurements and
>performance.

The interrupt rates are about the same.  Ran
the test with the exact same 'e1000e' driver
compiled from the Intel SourceForge version.
Native 'e1000e' runs something like 0.5%
better.

-----

Willy, Sorry your e-mail was blocked.  Forgot
to turn off the non-US country block I use
to limit spam.  It's off now and I'll keep
it off for a couple of days. 
