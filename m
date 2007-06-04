From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: iperf: performance regression (was b44 driver problem?)
Date: Mon, 4 Jun 2007 09:59:24 -0700
Message-ID: <20070604095924.651d91c8@freepuppy>
References: <20070525172431.60affaca@freepuppy>
	<200705281944.05030.maxi@daemonizer.de>
	<1180380230.3657.3.camel@chaos>
	<200706031826.06891.maxi@daemonizer.de>
	<1180939188.4404.5.camel@chaos>
	<20070604090918.42386fbb@freepuppy>
	<1180974958.4404.24.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Ulrich Drepper <drepper@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60126 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755719AbXFDRNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 13:13:52 -0400
In-Reply-To: <1180974958.4404.24.camel@chaos>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 04 Jun 2007 18:35:58 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Mon, 2007-06-04 at 09:09 -0700, Stephen Hemminger wrote:
> > > > I did the test with an 2.6.22-rc3-git4 kernel and the p54 driver built 
> > > > external as module. 
> > > 
> > > Can you look at iperf to figure out, whether it does some weird timer
> > > stuff (high frequency interval timer or such) ? Either check the code or
> > > strace it.
> >
> > It is the receiver doing a tight loop doing gettimeofday/recv calls.
> > 
> > 
> > sendto(-1227715616, 0xc, 3085438964, 0, {...}, 3067249832) = 0
> > gettimeofday({1180973726, 981615}, NULL) = 0
> > gettimeofday({1180973726, 981751}, NULL) = 0
> > futex(0x8055c64, 0x5 /* FUTEX_??? */, 1) = 1
> > futex(0x8055c90, FUTEX_WAKE, 1) = 0
> > recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
> > gettimeofday({1180973726, 982754}, NULL) = 0
> > recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
> > gettimeofday({1180973726, 983790}, NULL) = 0
> 
> Well, gettimeofday() is not affected by the highres code, but
> 
> > nanosleep({0, 0}, NULL) = 0
> > nanosleep({0, 0}, NULL) = 0
> 
> is. The nanosleep call with a relative timeout of 0 returns immediately
> with highres enabled, while it sleeps at least until the next tick
> arrives when highres is off. Are there more of those stupid sleeps in
> the code ?

GLIBC pthread_mutex does it, YES it is a problem!
Looks like the old behavior is required for ABI compatibility.

iperf server has several threads. One thread is using pthread_mutex_lock
to wait for the other thread.  It looks like pthread_mutex_lock is using
nanosleep as yield().

Multi-thread strace shows how this could kill performance.
These are with old 2.6.20 kernel that doesn't have the problem:

sendto(-1210930208, 0xc, 3085438964, 0, {...}, 3084035240) = 0
socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 3
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4)         = 0
bind(3, {sa_family=AF_INET, sin_port=htons(5001), sin_addr=inet_addr("0.0.0.0")}, 16)   = 0
listen(3, 5)                            = 0
futex(0x8055c64, 0x5 /* FUTEX_??? */, 1) = 1
accept(3, {sa_family=AF_INET, sin_port=htons(49973), sin_addr=inet_addr("192.168.0.14")}, [16]) = 4
getsockname(4, {sa_family=AF_INET, sin_port=htons(5001), sin_addr=inet_addr("192.168.0.12")}, [16]) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 24, 0) = 24
mmap2(NULL, 8392704, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb6528000
mprotect(0xb6528000, 4096, PROT_NONE)   = 0
clone(child_stack=0xb6d284a4, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID|CLONE_DETACHED, parent_tidptr=0xb6d28bd8, {entry_number:6, base_addr:0xb6d28b90, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}, child_tidptr=0xb6d28bd8) = 5622
accept(3, 0x8058b98, [128]) = ? ERESTARTSYS (To be restarted)

==============

sendto(-1219322912, 0xc, 3085438964, 0, {...}, 3075642536) = 0
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055d30, FUTEX_WAKE, 1) = 1
futex(0x8055c64, FUTEX_WAIT, 1, NULL) = 0
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055d30, FUTEX_WAKE, 1)         = 1
futex(0x8055c90, FUTEX_WAKE, 1)         = 0
getsockopt(3, SOL_SOCKET, SO_RCVBUF, [87380], [4]) = 0
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fb0000
write(1, "--------------------------------"..., 61) = 61
write(1, "Server listening on TCP port 500"..., 34) = 34
write(1, "TCP window size: 85.3 KByte (def"..., 38) = 38
write(1, "--------------------------------"..., 61) = 61
nanosleep({0, 0}, NULL)                 = 0
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055d30, FUTEX_WAKE, 1)         = 1
futex(0x8055c64, FUTEX_WAIT, 3, NULL) = 0
futex(0x8055c90, FUTEX_WAIT, 2, NULL)         = -1 EAGAIN (Resource temporarily unavailable)
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1)                               = 1
futex(0x8055d30, FUTEX_WAKE, 1)                          = 0
futex(0x8055c90, FUTEX_WAKE, 1)                               = 0
write(1, "[  4] local 192.168.0.12 port 50"..., 74)                          = 74
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL)                      = 0
nanosleep({0, 0}, NULL)                           = 0
nanosleep({0, 0}, NULL) = 0

...

nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL)                 = 0
write(1, "[  4]  0.0-30.2 sec    336 MByte"..., 50)                     = 50
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055d30, FUTEX_WAKE, 1) = 0
futex(0x8055c64, FUTEX_WAIT, 5, NULL) = -1 EINTR (Interrupted system call)

===============

sendto(-1227715616, 0xc, 3085438964, 0, {...}, 3067249832) = 0
gettimeofday({1180973726, 981615}, NULL) = 0
gettimeofday({1180973726, 981751}, NULL) = 0
futex(0x8055c64, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055c90, FUTEX_WAKE, 1) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 982754}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 983790}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
gettimeofday({1180973726, 984355}, NULL) = 0
recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192

...

gettimeofday({1180973757, 172338}, NULL) = 0
recv(4, "45678901234567890123456789012345"..., 8192, 0) = 1448
gettimeofday({1180973757, 172437}, NULL) = 0
recv(4, "23456789012345678901234567890123"..., 8192, 0) = 1448
gettimeofday({1180973757, 172576}, NULL) = 0
recv(4, "01234567890123456789012345678901"..., 8192, 0) = 1632
gettimeofday({1180973757, 172752}, NULL) = 0
recv(4, "", 8192, 0)                    = 0
gettimeofday({1180973757, 172797}, NULL) = 0
gettimeofday({1180973757, 172817}, NULL) = 0
nanosleep({0, 0}, NULL) = 0
nanosleep({0, 0}, NULL)                 = 0
close(4)                     = 0
futex(0x8055d04, 0x5 /* FUTEX_??? */, 1) = 1
futex(0x8055d30, FUTEX_WAKE, 1) = 0
_exit(0)                                = ?



