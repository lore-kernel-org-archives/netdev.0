From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Fri, 30 Jan 2009 15:03:30 -0500
Message-ID: <20090130200330.GA12659@hmsreliant.think-freely.org>
References: <49833DBC.7040607@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38967 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbZA3UDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 15:03:44 -0500
Content-Disposition: inline
In-Reply-To: <49833DBC.7040607@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 12:49:48PM -0500, Kenny Chang wrote:
> Hi all,
>
> We've been having some issues with multicast packet loss, we were wondering
> if anyone knows anything about the behavior we're seeing.
>
> Background: we use multicast messaging with lots of messages per sec for our
> work. We recently transitioned many of our systems from an Ubuntu Dapper Drake
> ia32 distribution to Ubuntu Hardy Heron x86_64. Since the transition, we've
> noticed much more multicast packet loss, and we think it's related to the
> transition. Our particular theory is that it's specifically a 32 vs 64-bit
> issue.
>
> We narrowed the problem down to the attached program (mcasttest.cc).  Run
> "mcasttest server" on one machine -- it'll send 500,000 messages small message
> to a multicast group, 50,000 messages per second.  If we run "mcasttest client"
> on another machine, it'll receive all those messages and print a count at the
> end of how many messages it sees. It almost never loses any messages. However,
> if we run 4 copies of the client on the same machine, receiving the same data,
> then the programs usually sees fewer than 500,000 messages. We're running with:
>
> for i in $(seq 1 4); do (./mcasttest client &); done
>
> We know this because the program prints a count, but dropped packets also
> show up in ifconfig's "RX packets" section.
>
> Things we're curious about: do other people see similar problems?  The tests
> we've done: we've tried this program on a bunch of different machines, all of
> which are running either dapper ia32 or hardy x86_64. Uniformly, the dapper
> machines have no problems but on certain machines, Hardy shows 
> significant loss. We did some experiments on a troubled machine, varying 
> the OS install, including mixed installations where the kernel was 64-bit 
> and the userspace was
> 32-bit. This is what we found:
>
> On machines that exhibit this problem, the ksoftirqd process seems to be  
> pegged to 100% CPU when receiving packets.
>
> Note: while we're on Ubuntu, we've tried this with other distros and have seen
> similar results, we just haven't tabulated them.
>
>> ----------------------------------------------------------------------------
>> userland | userland arch | kernel           | kernel arch | mode        
>>     
>> ----------------------------------------------------------------------------
>> Dapper   |            32 | 2.6.15-28-server |          32 | no packet loss
>> Dapper   |            32 | 2.6.22-generic   |          32 | no packet 
>> loss Dapper   |            32 | 2.6.22-server    |          32 | no 
>> packet loss Hardy    |            32 | 2.6.24-rt        |          32 | 
>> no packet loss
>> Hardy    |            32 | 2.6.24-generic   |          32 | ~5% packet loss
>> Hardy    |            32 | 2.6.24-server    |          32 | ~10% packet loss
>
>> Hardy    |            32 | 2.6.22-server    |          64 | no packet loss
>> Hardy    |            32 | 2.6.24-rt        |          64 | no packet loss
>> Hardy    |            32 | 2.6.24-generic   |          64 | 14% packet loss
>> Hardy    |            32 | 2.6.24-server    |          64 | 12% packet loss
>
>> Hardy    |            64 | 2.6.22-vanilla   |          64 | packet loss
>> Hardy    |            64 | 2.6.24-rt        |          64 | ~5% packet loss
>> Hardy    |            64 | 2.6.24-server    |          64 | ~30% packet loss
>> Hardy    |            64 | 2.6.24-generic   |          64 | ~5% packet loss
>> ----------------------------------------------------------------------------
>
> It's not exactly clear what exactly the problem is but dapper shows no 
> issues regardless of what we try. For hardy, userspace seem to matter:  
> 2.6.24-rt kernel shows no packet loss for 32&64bit kernels, as long as 
> the userspace is 32-bit.
>
> Kernel comments:
> 2.6.15-28-server: This is Ubuntu Dapper's stock kernel build.
> 2.6.24-*: This is Ubuntu Hardy's stock kernel.
> 2.6.22-{generic,server}: This is a custom, in-house kernel build, built for ia32.
> 2.6.22-vanilla: This is our custom, in-house kernel build, built for x86_64.
>
> We don't think it's related to our custom kernels, because the same phenomena
> show up with the Ubuntu stock kernels.
>
> Hardware:
>
> The benchmark machine We've been using is an Intel Xeon E5440 @2.83GHz
> dual-cpu quad-core with Broadcom NetXtreme II BCM5708 bnx2 networking.
>
> We've also tried AMD machines, as well as machines with Tigon3
> partno(BCM95704A6) tg3 network cards, they all show consistent behavior.
>
> Our hardy x86_64 server machines all appear to have this problem, new and old.
>
> On the other hand, a desktop with Intel Q6600 quad core 2.4GHz and Intel 82566DC GigE
> seem to work fine.
>
> All of the dapper ia32 machines have no trouble, even our older hardware.
>

Like Eric mentioned, I'd start with a latest kernel if at all possible.  If it
doesn't happen there, you're work is half over, you just need to figure out what
changed, and tell Canonical to backport it.

>From there, you can solve this like most packet loss issues are solved:

1) Determine if its a rx or tx packet loss.  From your comments above it sounds
like this is an rx side issue

2) Look at statistics from the hardware to the application.  Use ethtool &
/proc/net/dev to get hardware packet loss stats, /proc/net/snmp netstat -s to
get core network loss stats

3) Use those stats to identify where and why packets are getting dropped.
Posting some summary of that data here is something we can help with if need be

4) Determine how to reduce the loss (i.e. code change vs. tuning)

5) Lather, rinse repeat (given that eliminating a drop cause in one location
will likely increase througput, potentially putting strain on another location
in the code path, possibly leading to more drops elsewhere. 


You had mentioned that ifconfig was showing rx drops, which indicates that your
hardware rx buffer is likely overflowing.  Usually the best way to fix that is
to:

1) modify any available interrupt coalescing parameters on the driver such that
interrupts have less latency between packet arrival and assertion

2) increase (if possible) the napi weight (I think thats still the right term)
so that each napi poll interation receives more frames on the interface,
draining that queue more quickly.

Neil

