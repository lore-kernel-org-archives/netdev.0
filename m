From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Sun, 5 Apr 2009 14:14:22 +1030
Message-ID: <200904051314.23170.rusty@rustcorp.com.au>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <200904011638.45135.rusty@rustcorp.com.au> <49D391F5.4080700@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38433 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726AbZDEDoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2009 23:44:32 -0400
In-Reply-To: <49D391F5.4080700@codemonkey.ws>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 02 April 2009 02:40:29 Anthony Liguori wrote:
> Rusty Russell wrote:
> > As you point out, 350-450 is possible, which is still bad, and it's at least
> > partially caused by the exit to userspace and two system calls.  If virtio_net
> > had a backend in the kernel, we'd be able to compare numbers properly.
> 
> I doubt the userspace exit is the problem.  On a modern system, it takes 
> about 1us to do a light-weight exit and about 2us to do a heavy-weight 
> exit.  A transition to userspace is only about ~150ns, the bulk of the 
> additional heavy-weight exit cost is from vcpu_put() within KVM.

Just to inject some facts, servicing a ping via tap (ie host->guest then
guest->host response) takes 26 system calls from one qemu thread, 7 from
another (see strace below). Judging by those futex calls, multiple context
switches, too.

> If you were to switch to another kernel thread, and I'm pretty sure you 
> have to, you're going to still see about a 2us exit cost.

He switches to another thread, too, but with the right infrastructure (ie.
skb data destructors) we could skip this as well.  (It'd be interesting to
see how virtual-bus performed on a single cpu host).

Cheers,
Rusty.

Pid 10260:
12:37:40.245785 select(17, [4 6 8 14 16], [], [], {0, 996000}) = 1 (in [6], left {0, 992000}) <0.003995>
12:37:40.250226 read(6, "\0\0\0\0\0\0\0\0\0\0RT\0\0224V*\211\24\210`\304\10\0E\0"..., 69632) = 108 <0.000051>
12:37:40.250462 write(1, "tap read: 108 bytes\n", 20) = 20 <0.000197>
12:37:40.250800 ioctl(7, 0x4008ae61, 0x7fff8cafb3a0) = 0 <0.000223>
12:37:40.251149 read(6, 0x115c6ac, 69632) = -1 EAGAIN (Resource temporarily unavailable) <0.000019>
12:37:40.251292 write(1, "tap read: -1 bytes\n", 19) = 19 <0.000085>
12:37:40.251488 clock_gettime(CLOCK_MONOTONIC, {1554, 633304282}) = 0 <0.000020>
12:37:40.251604 clock_gettime(CLOCK_MONOTONIC, {1554, 633413793}) = 0 <0.000019>
12:37:40.251717 futex(0xb81360, 0x81 /* FUTEX_??? */, 1) = 1 <0.001222>
12:37:40.253037 select(17, [4 6 8 14 16], [], [], {1, 0}) = 1 (in [16], left {1, 0}) <0.000026>
12:37:40.253196 read(16, "\16\0\0\0\0\0\0\0\376\377\377\377\0\0\0\0\0\0\0\0\0\0\0"..., 128) = 128 <0.000022>
12:37:40.253324 rt_sigaction(SIGALRM, NULL, {0x406d50, ~[KILL STOP RTMIN RT_1], SA_RESTORER, 0x7f1a842430f0}, 8) = 0 <0.000018>
12:37:40.253477 write(5, "\0", 1)       = 1 <0.000022>
12:37:40.253585 read(16, 0x7fff8cb09440, 128) = -1 EAGAIN (Resource temporarily unavailable) <0.000020>
12:37:40.253687 clock_gettime(CLOCK_MONOTONIC, {1554, 635496181}) = 0 <0.000019>
12:37:40.253798 writev(6, [{"\0\0\0\0\0\0\0\0\0\0", 10}, {"*\211\24\210`\304RT\0\0224V\10\0E\0\0T\255\262\0\0@\1G"..., 98}], 2) = 108 <0.000062>
12:37:40.253993 ioctl(7, 0x4008ae61, 0x7fff8caff460) = 0 <0.000161>
12:37:40.254263 clock_gettime(CLOCK_MONOTONIC, {1554, 636077540}) = 0 <0.000019>
12:37:40.254380 futex(0xb81360, 0x81 /* FUTEX_??? */, 1) = 1 <0.000394>
12:37:40.254861 select(17, [4 6 8 14 16], [], [], {1, 0}) = 1 (in [4], left {1, 0}) <0.000022>
12:37:40.255001 read(4, "\0", 512)      = 1 <0.000021>
12:37:40.255109 read(4, 0x7fff8cb092d0, 512) = -1 EAGAIN (Resource temporarily unavailable) <0.000018>
12:37:40.255211 clock_gettime(CLOCK_MONOTONIC, {1554, 637020677}) = 0 <0.000019>
12:37:40.255314 clock_gettime(CLOCK_MONOTONIC, {1554, 637123483}) = 0 <0.000019>
12:37:40.255416 timer_gettime(0, {it_interval={0, 0}, it_value={0, 0}}) = 0 <0.000018>
12:37:40.255524 timer_settime(0, 0, {it_interval={0, 0}, it_value={0, 14000000}}, NULL) = 0 <0.000021>
12:37:40.255635 clock_gettime(CLOCK_MONOTONIC, {1554, 637443915}) = 0 <0.000019>
12:37:40.255739 clock_gettime(CLOCK_MONOTONIC, {1554, 637547001}) = 0 <0.000018>
12:37:40.255847 select(17, [4 6 8 14 16], [], [], {1, 0}) = 1 (in [16], left {0, 988000}) <0.014303>

Pid 10262:
12:37:40.252531 clock_gettime(CLOCK_MONOTONIC, {1554, 634339051}) = 0 <0.000018>
12:37:40.252631 timer_gettime(0, {it_interval={0, 0}, it_value={0, 17549811}}) = 0 <0.000021>
12:37:40.252750 timer_settime(0, 0, {it_interval={0, 0}, it_value={0, 250000}}, NULL) = 0 <0.000024>
12:37:40.252868 ioctl(11, 0xae80, 0)    = 0 <0.001171>
12:37:40.254128 futex(0xb81360, 0x80 /* FUTEX_??? */, 2) = 0 <0.000270>
12:37:40.254490 ioctl(7, 0x4008ae61, 0x4134bee0) = 0 <0.000019>
12:37:40.254598 futex(0xb81360, 0x81 /* FUTEX_??? */, 1) = 0 <0.000017>
12:37:40.254693 ioctl(11, 0xae80 <unfinished ...>

fd:
lrwx------ 1 root root 64 2009-04-05 12:31 0 -> /dev/pts/1 
lrwx------ 1 root root 64 2009-04-05 12:31 1 -> /dev/pts/1 
lrwx------ 1 root root 64 2009-04-05 12:35 10 -> /home/rusty/qemu-images/ubuntu-8.10                                                                            
lrwx------ 1 root root 64 2009-04-05 12:35 11 -> anon_inode:kvm-vcpu            
lrwx------ 1 root root 64 2009-04-05 12:35 12 -> socket:[31414]                 
lrwx------ 1 root root 64 2009-04-05 12:35 13 -> socket:[31416]                 
lrwx------ 1 root root 64 2009-04-05 12:35 14 -> anon_inode:[eventfd]           
lrwx------ 1 root root 64 2009-04-05 12:35 15 -> anon_inode:[eventfd]           
lrwx------ 1 root root 64 2009-04-05 12:35 16 -> anon_inode:[signalfd]          
lrwx------ 1 root root 64 2009-04-05 12:31 2 -> /dev/pts/1                      
lr-x------ 1 root root 64 2009-04-05 12:31 3 -> /dev/kvm
lr-x------ 1 root root 64 2009-04-05 12:35 4 -> pipe:[31406]
l-wx------ 1 root root 64 2009-04-05 12:35 5 -> pipe:[31406]
lrwx------ 1 root root 64 2009-04-05 12:35 6 -> /dev/net/tun
lrwx------ 1 root root 64 2009-04-05 12:35 7 -> anon_inode:kvm-vm
lrwx------ 1 root root 64 2009-04-05 12:35 8 -> anon_inode:[signalfd]
lrwx------ 1 root root 64 2009-04-05 12:35 9 -> /tmp/vl.OL1kd9 (deleted)
