From: Kenny Chang <kchang@athenacr.com>
Subject: Multicast packet loss
Date: Fri, 30 Jan 2009 12:49:48 -0500
Message-ID: <49833DBC.7040607@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.95.46.209] ([64.95.46.209]:1491 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752255AbZA3SJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 13:09:24 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id ADAE24D5CB
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 12:49:48 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We've been having some issues with multicast packet loss, we were wondering
if anyone knows anything about the behavior we're seeing.

Background: we use multicast messaging with lots of messages per sec for our
work. We recently transitioned many of our systems from an Ubuntu Dapper Drake
ia32 distribution to Ubuntu Hardy Heron x86_64. Since the transition, we've
noticed much more multicast packet loss, and we think it's related to the
transition. Our particular theory is that it's specifically a 32 vs 64-bit
issue.

We narrowed the problem down to the attached program (mcasttest.cc).  Run
"mcasttest server" on one machine -- it'll send 500,000 messages small message
to a multicast group, 50,000 messages per second.  If we run "mcasttest client"
on another machine, it'll receive all those messages and print a count at the
end of how many messages it sees. It almost never loses any messages. However,
if we run 4 copies of the client on the same machine, receiving the same data,
then the programs usually sees fewer than 500,000 messages. We're running with:

for i in $(seq 1 4); do (./mcasttest client &); done

We know this because the program prints a count, but dropped packets also
show up in ifconfig's "RX packets" section.

Things we're curious about: do other people see similar problems?  The tests
we've done: we've tried this program on a bunch of different machines, all of
which are running either dapper ia32 or hardy x86_64. Uniformly, the dapper
machines have no problems but on certain machines, Hardy shows significant loss. 
We did some experiments on a troubled machine, varying the OS install, 
including mixed installations where the kernel was 64-bit and the userspace was
32-bit. This is what we found:

On machines that exhibit this problem, the ksoftirqd process seems to be 
pegged to 100% CPU when receiving packets.

Note: while we're on Ubuntu, we've tried this with other distros and have seen
similar results, we just haven't tabulated them.

> ----------------------------------------------------------------------------
> userland | userland arch | kernel           | kernel arch | mode           
> ----------------------------------------------------------------------------
> Dapper   |            32 | 2.6.15-28-server |          32 | no packet loss
> Dapper   |            32 | 2.6.22-generic   |          32 | no packet loss 
> Dapper   |            32 | 2.6.22-server    |          32 | no packet loss 
> Hardy    |            32 | 2.6.24-rt        |          32 | no packet loss
> Hardy    |            32 | 2.6.24-generic   |          32 | ~5% packet loss
> Hardy    |            32 | 2.6.24-server    |          32 | ~10% packet loss

> Hardy    |            32 | 2.6.22-server    |          64 | no packet loss
> Hardy    |            32 | 2.6.24-rt        |          64 | no packet loss
> Hardy    |            32 | 2.6.24-generic   |          64 | 14% packet loss
> Hardy    |            32 | 2.6.24-server    |          64 | 12% packet loss

> Hardy    |            64 | 2.6.22-vanilla   |          64 | packet loss
> Hardy    |            64 | 2.6.24-rt        |          64 | ~5% packet loss
> Hardy    |            64 | 2.6.24-server    |          64 | ~30% packet loss
> Hardy    |            64 | 2.6.24-generic   |          64 | ~5% packet loss
> ----------------------------------------------------------------------------

It's not exactly clear what exactly the problem is but dapper shows no issues 
regardless of what we try. For hardy, userspace seem to matter: 
2.6.24-rt kernel shows no packet loss for 32&64bit kernels, as long as the userspace 
is 32-bit.

Kernel comments:
2.6.15-28-server: This is Ubuntu Dapper's stock kernel build.
2.6.24-*: This is Ubuntu Hardy's stock kernel.
2.6.22-{generic,server}: This is a custom, in-house kernel build, built for ia32.
2.6.22-vanilla: This is our custom, in-house kernel build, built for x86_64.

We don't think it's related to our custom kernels, because the same phenomena
show up with the Ubuntu stock kernels.

Hardware:

The benchmark machine We've been using is an Intel Xeon E5440 @2.83GHz
dual-cpu quad-core with Broadcom NetXtreme II BCM5708 bnx2 networking.

We've also tried AMD machines, as well as machines with Tigon3
partno(BCM95704A6) tg3 network cards, they all show consistent behavior.

Our hardy x86_64 server machines all appear to have this problem, new and old.

On the other hand, a desktop with Intel Q6600 quad core 2.4GHz and Intel 82566DC GigE
seem to work fine.

All of the dapper ia32 machines have no trouble, even our older hardware.


Thanks,
Kenny Chang
Athena Capital Research


