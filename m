From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: Killing sk->sk_callback_lock
Date: Mon, 16 Jun 2008 22:01:13 -0600
Message-ID: <4856FEC9.BA47.005A.0@novell.com>
References: <484F43A3020000760003F543@lucius.provo.novell.com>
 <4856C12F020000C700039679@lucius.provo.novell.com>
 <20080616.185328.85842051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <herbert@gondor.apana.org.au>, <chuck.lever@oracle.com>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Patrick Mullaney" <PMullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinclair.provo.novell.com ([137.65.248.137]:3790 "EHLO
	sinclair.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbYFQEBG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 00:01:06 -0400
In-Reply-To: <20080616.185328.85842051.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On Mon, Jun 16, 2008 at  9:53 PM, in message
<20080616.185328.85842051.davem@davemloft.net>, David Miller
<davem@davemloft.net> wrote: 
> From: "Patrick Mullaney" <pmullaney@novell.com>
> Date: Mon, 16 Jun 2008 19:38:23 -0600
> 
>> The overhead I was trying to address was scheduler overhead.
> 
> Neither Herbert nor I are convinced of this yet, and you have
> to show us why you think this is the problem and not (in
> our opinion) the more likely sk_callback_lock overhead.

Please bear with us.  It is not our intent to be annoying, but we are perhaps doing a poor job of describing the actual nature of the issue we are seeing.

To be clear on how we got to this point: We are tasked with improving the performance of our particular kernel configuration.  We observed that our configuration was comparatively poor at UDP performance, so we started investigating why.  We instrumented the kernel using various tools (lockdep, oprofile, logdev, etc), and observed two wakeups for every packet that was received while running a multi-threaded netperf UDP throughput benchmark on some 8-core boxes.

A common pattern would emerge during analysis of the instrumentation data: An arbitrary client thread would block on the wait-queue waiting for a UDP packet.  It would of course initially block because there were no packets available.  It would then wake up, check the queue, see that there are still no packets available, and go back to sleep.  It would then wake up again a short time later, find a packet, and return to userspace.

This seemed odd to us, so we investigated further to see if an improvement was lurking or whether this was expected.  We traced back the source of each wakeup to be coming from 1) the wmem/nospace code, and 2) from the rx-wakeup code from the softirq.  First the softirq would process the tx-completions which would wake_up() the wait-queue for NOSPACE signaling.  Since the client was waiting for a packet on the same wait-queue, this was where the first wakeup came from.  Then later the softirq finally pushed an actual packet to the queue, and the client was once again re-awoken via the same overloaded wait-queue.  This time it would successfully find a packet and return to userspace.

Since the client does not care about wmem/nospace in the UDP rx path, yet the two events share a single wait-queue, the first wakeup was completely wasted.  It just causes extra scheduling activity that does not help in any way (and is quite expensive in the grand-scheme of things).  Based on this lead, Pat devised a solution which eliminates the extra wake-up() when there are no clients waiting for that particular NOSPACE event.  With his patch applied, we observed two things:

1) We now had 1 wake-up per packet, instead of 2 (decreasing context switching rates by ~50%)
2) overall UDP throughput performance increased by ~25%

This was true even without the presence of our instrumentation, so I don't think we can chalk up the "double-wake" analysis as an anomaly caused by the presence of the instrumentation itself.  Based on that, it would at least appear that the odd behavior w.r.t. the phantom wakeup does indeed hinder performance.  This is not to say that the locking issues you highlight are not also an issue.  But note that we have no evidence to suggest this particular phenomenon it is related in any way to the locking (in fact, sk_callback_lock was not showing up at all on the lockdep radar for this particular configuration, indicating a low contention rate).

So by all means, if there are improvements to the locking that can be made, thats great!  But fixing the locking will not likely address this scheduler overhead that Pat refers to IMO.  They would appear to be orthogonal issues.  I will keep an open mind, but the root-cause seems to be either the tendency of the stack code to overload the wait-queue, or the fact that UDP sockets do not dynamically manage the NOSPACE state flags.  From my perspective, I am not married to any one particular solution as long as the fundamental "phantom wakeup" problem is addressed.

HTH

Regards,
-Greg


