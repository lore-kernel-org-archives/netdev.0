From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Patch 0/5] Network Drop Monitor
Date: Tue, 3 Mar 2009 10:06:37 -0800
Message-ID: <20090303100637.31a5dac7@nehalam>
References: <20090303165747.GA1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41544 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047AbZCCSGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 13:06:44 -0500
In-Reply-To: <20090303165747.GA1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Mar 2009 11:57:47 -0500
Neil Horman <nhorman@tuxdriver.com> wrote:

> 
> Create Network Drop Monitoring service in the kernel
> 
> A few weeks ago I posted an RFC requesting some feedback on a proposal that I
> had to enhance our ability to monitor the Linux network stack for dropped
> packets.  This patchset is the result of that RFC and its feedback.
> 
> Overview:
> 
> The Linux networking stack, from a users point of view suffers from four
> shortcommings:
> 
> 1) Consolidation: The ability to detect dropped network packets is spread out
> over several proc file interfaces and various other utilities (tc,
> /proc/net/dev, snmp, etc)
> 
> 2) Clarity: The ability to discern which statistics reflect dropped packets is
> not always clear
> 
> 3) Ambiguity: The ability to understand the root cause of a lost packet is not
> always clear (some stats are incremented at multiple points in the kernel for
> subtly different reasons)
> 
> 4) Performance: Interrogating all of these interface as they currently exist
> requires a polling operation, and potentially requires the serialization of
> various kernel operations, which can result in performance degradation.
> 
> Proposed solution: dropwatch
> 
> My proposed solution consists of 4 primary aspects:
> 
> A) A hook into kfree_skb to detect dropped packets.  Based on feedback from the
> earlier RFC, there are relatively few places in the kernel where packets are
> dropped because they have been successfully received or send (for lack of a
> better term, end-of-line points).  The remaining calls to kfree_skb are made
> because there is something wrong and the packet must be discarded.  I've split
> kfree_skb into two calls: kfree_skb and kfree_skb_clean.  The later is simply a
> pass through to __kfree_skb, while the former adds a trace hook to capture a
> pointer to the skb and the location of the call.
> 
> B) A trace hook to monitor the trace point in (A).  this records the locations
> at which frames were dropped, and saves them for periodic reporting.
> 
> C) A netlink protocol to both control the enabling/disabling of the trace hook
> in (B) and to deliver information on drops to interested applications in user
> space
> 
> D) A user space application to listen for drop alerts from (C) and report them
> to an adminstrator/save them for later analysis/etc.  I've implmented the start
> of this application, which relies on this patch set here:
> https://fedorahosted.org/dropwatch/
> 
> 
> Implementation Notes:
> 
> About the only out-of the ordinary aspects I'd like to call attention to at this
> point are:
> 
> 1) The trace point.  I know that tracepoints are currently a controversial
> subject, and that their need was discussed briefly during the RFC.  I elected to
> use a tracepoint here, simply because I felt like I was re-inventing the wheel
> otherwise.  In order to implement this feature, I needed an ability to record
> when kfree_skb was called in certain places who's performance impact would be 0
> when the feature wasn't configured into the kernel, and when it was configured,
> but disabled.  Given that anything else I used or wrote myself to hook into this
> point in the kernel would be a partial approximation of what tracepoints already
> offer, I think its preferable to go with a tracepoint here, simply because its
> good use of existing function.
> 
> 2) The configuration messages in the netlink protocol are just a placeholder
> right now.  I'm ok with that, given that the dropwatch user app doesn't have
> code to configure anything yet anyway (it just turns the service off/on and
> listens for drops right now).  I figure I'll implment configuration messages in
> the app and kernel in parallel.
> 
> 3) Performance.  I'm not sure of the best way to model the performance here, but
> I disassembled the code in question, and the point at which we hook kfree_skb,
> this patch set only adds a conditional branch to the path, which is optimized
> for the not-taken case (the case in which the service is disabled), so adding
> this feature is as close to a zero impact as it can be when the service is
> disabled.  Likewise, when tracepoints are not configured in the kernel, the
> tracepoint (which is defined as a macro) is preprocessed away, making the
> performance impact zero.  That leave the case in which the service is enabled.
> While I don't have specific numbers, I can say that the trace path is lockless
> and per-cpu, and should run O(n) where n is the number of recordable drop points
> (default is 64).  Sendingi/allocation of frames to userspace is done in the 
> context of keventd, with a timer for hysteresis, to keep the number of sends
> lower and consolidate drop information.  So performance should be reasonably
> good there.  Again, no hard numbers, but I've monitored drops by passing udp
> traffic through localhost with netcat and SIGSTOP-ing the receiver.  Console and
> ssh access remained very responsive
> 
> 
> Ok, so thats it, hope it meets with everybodys approval!
> Regards
> Neil
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

It would be good to have a way to mask off certain tracepoints.
For example, if running performance test and after measuring number
of packets dropped in TX queue overflow, only see others.
