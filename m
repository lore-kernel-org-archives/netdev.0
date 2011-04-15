From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net: Automatic IRQ siloing for network devices
Date: Fri, 15 Apr 2011 23:54:29 +0100
Message-ID: <1302908069.2845.29.camel@bwh-desktop>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3770 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab1DOXCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:02:36 -0400
In-Reply-To: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> Automatic IRQ siloing for network devices
> 
> At last years netconf:
> http://vger.kernel.org/netconf2010.html
> 
> Tom Herbert gave a talk in which he outlined some of the things we can do to
> improve scalability and througput in our network stack
> 
> One of the big items on the slides was the notion of siloing irqs, which is the
> practice of setting irq affinity to a cpu or cpu set that was 'close' to the
> process that would be consuming data.  The idea was to ensure that a hard irq
> for a nic (and its subsequent softirq) would execute on the same cpu as the
> process consuming the data, increasing cache hit rates and speeding up overall
> throughput.
> 
> I had taken an idea away from that talk, and have finally gotten around to
> implementing it.  One of the problems with the above approach is that its all
> quite manual.  I.e. to properly enact this siloiong, you have to do a few things
> by hand:
> 
> 1) decide which process is the heaviest user of a given rx queue 
> 2) restrict the cpus which that task will run on
> 3) identify the irq which the rx queue in (1) maps to
> 4) manually set the affinity for the irq in (3) to cpus which match the cpus in
> (2)
[...]

This presumably works well with small numbers of flows and/or large
numbers of queues.  You could scale it up somewhat by manipulating the
device's flow hash indirection table, but that usually only has 128
entries.  (Changing the indirection table is currently quite expensive,
though that could be changed.)

I see RFS and accelerated RFS as the only reasonable way to scale to
large numbers of flows.  And as part of accelerated RFS, I already did
the work for mapping CPUs to IRQs (note, not the other way round).  If
IRQ affinity keeps changing then it will significantly undermine the
usefulness of hardware flow steering.

Now I'm not saying that your approach is useless.  There is more
hardware out there with flow hashing than with flow steering, and there
are presumably many systems with small numbers of active flows.  But I
think we need to avoid having two features that conflict and a
requirement for administrators to make a careful selection between them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

