From: Li Yu <raise.sail@gmail.com>
Subject: [RFC] skbtrace: A trace infrastructure for networking subsystem
Date: Tue, 10 Jul 2012 14:07:50 +0800
Message-ID: <4FFBC6B6.2000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:44550 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab2GJGID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 02:08:03 -0400
Received: by pbbrp8 with SMTP id rp8so20448998pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 23:08:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  This RFC introduces to the tracing infrastructure for networking
subsystem and a workable prototype.

  I noticed that the blktrace indeed helps file system and block
subsystem developers a lot, even it could help them to find out some
problems in mm subsystem. However, the "networkers" don't have such
like good luck, although tcpdump is very very useful, but they still
often need to start investigation from limited exported statistics
counters, then may directly dig into source code to guess possible
solutions, then test their ideas, if good luck doesn't arrive, then
start another investigation-guess-test loop. It is a difficult
time-costly and hard to share experiences, report problem, many users
have not enough understanding for protocol stack internals, I saw some
"detailed reports" still do not carry useful information to solve problem.

  Unfortunately, the networking subsystem is rather performance
sensitive in kernel, so we can not add too detailed counters directly
here. In fact, Some folks already tried to add more statistics counters
for detailed performance measuration, e.g. RFC4898 and its
implementation Web10g project. Web10G is a great project for
researchers and engineers on TCP stack, which exports per-connection
details to userland by procfs or netlink interface. However, it tightly
depends on TCP and its implementation, other protocols implementation
need some duplicated works to archive same goal, and it also has some
measurable overhead (5% - 10% in my simple netperf TCP_STREAM
benchmark), I think it'd better that such powerful tracing or
instrumentation feature should be able to be off at runtime, and zero
overhead when it is off.

  So why we don't write a blktrace like utility for our sweet
networking subsystem? This just is it, "skbtrace", I hope it can:

1. Provide an extendable tracing infrastructure to support various
protocols instead of specific one.

2. Ability of runtime enable or disable and zero overhead when it
is off. I think that jump label optimized trace point is a good choice
to implement it.

3. Provide tracing details on per-connection/per-skb level. Please note
that skbtrace are not only for sk_buff tracing, but also can track
sockets events. Second, this also means we need some forms of filters,
otherwise we must will lost in tons of uninteresting trace data. I think
that BPF is one of good choices. But we need extend BPF to make it
can handle other data structures rather than skb.

   Above is my basic idea, below are details of current prototype
implementation.

   Like blktrace, skbtrace also are base on the tracepoints
infrastructure and relay file system, however, I do not implement any
tracers like blktrace, since I want to keep kernel side as simple (also
fast, I hope) as possible. Basically, the trace points just are
optimized conditional statements here, the slow path copies these
traced data to the ring buffer in relay file system. The parameters of
this relay file system can be tuned by some exported files in skbtrace
directory.

  There are three trace data files (channels) in relay file system for
each CPU, they represent above ring buffers that save kernel traced
data for different contexts respectively:

  (1) trace.hardirq.cpuN, saving trace data that come from hardirq
context.
  (2) trace.softirq.cpuN, saving trace data that come from softirq
context.
  (3) trace.syscall.cpuN, saving trace data that come from process
context.

  Each trace data will write into one of above channels, depend on which
context is trace point called. Each trace data is represented by a
skbtrace_block struct, the extended fields for specific protocols can be
append at end of it. For global order of trace data, this patch has an
64 bits atomic variable to generate sequence number of each generated
trace data. So userland utility is able to sort out of order trace data
across different channels or/and CPUs.

  For tracing filter feature, I selected BPF as core engine, so far, it
only can filter out sk_buff-based traces, I have a plan to extend BPF to
support other data structures. In fact, I ever wrote a custom filter
implemenation for TCP/IPv4 ago, this way needs to refactor each specific
protocol implemenation, I do not like and discard them.

  So far, I implemented some skbtrace trace points:

  (1) skb_rps_info.

         I ever saw that some buggy drivers (or firmwares?)
         always setup zero skb->rx_hash. And it seem that RPS
         hashing can not work well for some corner cases.

  (2) tcp_connection and icsk_connection.

	To track the basic TCP state migration, e.g. TCP_LISTEN.

  (3) tcp_sendlimit.

        Personally, I am interesting in reason of tcp_write_xmit()
        exits.

  (4) tcp_congestion.

       Oops, it is cwnd killer, isn't it?

  The userland utilties:

  (1) skbtrace, record raw trace data to regular disk files.
  (2) skbparse, parse raw trace data to human readable strings.
                this still need a lot of works, it just is a rough
		(but workable) demo for TCP/IPv4 yet.

  You can get source code at github:

	https://github.com/Rover-Yu/skbtrace-userland
	https://github.com/Rover-Yu/skbtrace-kernel

  The source code of skbtrace-kernel is based on net-next tree.

  Welcome for suggestions.

  Thanks.

Yu
