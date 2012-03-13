From: Simon Kirby <sim@netnation.com>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 00:26:44 -0700
Message-ID: <20120313072643.GA32306@hostway.ca>
References: <20120310122725.GA31129@hostway.ca> <1331401490.2453.28.camel@edumazet-laptop> <1331402182.2453.30.camel@edumazet-laptop> <1331407221.2453.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:34570 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759367Ab2CMH0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 03:26:45 -0400
Content-Disposition: inline
In-Reply-To: <1331407221.2453.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 10, 2012 at 11:20:21AM -0800, Eric Dumazet wrote:

> Reported-by: Simon Kirby <sim@netnation.com>
> Bisected-by: Simon Kirby <sim@netnation.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/syncookies.c |   30 ++++++++++++++++--------------
>  net/ipv4/tcp_ipv4.c   |   10 +++++++---
>  2 files changed, 23 insertions(+), 17 deletions(-)
> 
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index 51fdbb4..eab2a7f 100644

While deploying this on top of 3.2.9, we hit what seems to be the bug
fixed by 4648dc97af9d496218a05353b0e442b3dfa6aaab in 3.3. I see 3.2.9 has
daef52bab1fd26e24e8e9578f8fb33ba1d0cb412, so maybe this is exposed in 3.2
now?

[ 1196.683749] WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x25a6/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3058 tcp_ack+0x209b/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x25a6/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3058 tcp_ack+0x209b/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x25a6/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3058 tcp_ack+0x209b/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x25a6/0x25f0()
[ 1196.687638] WARNING: at net/ipv4/tcp_input.c:3058 tcp_ack+0x209b/0x25f0()
[ 1196.716010] WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x25a6/0x25f0()
[ 1196.722262] WARNING: at net/ipv4/tcp_input.c:3058 tcp_ack+0x209b/0x25f0()
[ 1196.726111] WARNING: at net/ipv4/tcp_input.c:3439 tcp_ack+0x25a6/0x25f0()

net/ipv4/tcp_input.c:
     3438 #if FASTRETRANS_DEBUG > 0
---> 3439         WARN_ON((int)tp->sacked_out < 0);
     3440         WARN_ON((int)tp->lost_out < 0);
     3441         WARN_ON((int)tp->retrans_out < 0);
     3442         if (!tp->packets_out && tcp_is_sack(tp)) {
...
     3057         /* D. Check consistency of the current state. */
---> 3058         tcp_verify_left_out(tp);

Oops two seconds later, scrolled off console, didn't get written to disk
or remote syslog server, all we have is syslog-broadcasted Oops and Code
lines due to broken printk priorities:

Message from syslogd at Tue Mar 13 00:25:13 2012 ...
kernel: [ 1198.637303] Oops: 0000 [#1] SMP
...
kernel: [ 1198.640041] Code: f8 01 00 00 48 39 f9 49 89 ca 0f 84 cd 03 00 00 44 3b 67 40 79 28 e9 f7 04 00 00 66 90 4c 39 d1 0f 1f 44 00 00 0f 84 b2 03 00 00 <45> 3b 62 40 66 0f 1f 44 00 00 0f 88 a2 03 00 00 4c 89 d7 8b 87
kernel: [ 1198.640041] CR2: 0000000000000040
kernel: [ 1198.646208] Kernel panic - not syncing: Fatal exception in interrupt

(gdb) find /b 0, +1000000000, 0x45,0x3b,0x62,0x40,0x66,0x0f,0x1f,0x44,0x00,0x00
0x66594e <tcp_sacktag_write_queue+958>
(gdb) disass /m tcp_sacktag_write_queue
...
1709                    if (after(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
   0x0000000000665933 <+931>:   cmp    0x40(%rdi),%r12d
   0x0000000000665937 <+935>:   jns    0x665961 <tcp_sacktag_write_queue+977>
   0x0000000000665939 <+937>:   jmpq   0x665e35 <tcp_sacktag_write_queue+2213>
   0x000000000066593e <+942>:   xchg   %ax,%ax
-> 0x000000000066594e <+958>:   cmp    0x40(%r10),%r12d
   0x0000000000665952 <+962>:   nopw   0x0(%rax,%rax,1)
   0x0000000000665958 <+968>:   js     0x665d00 <tcp_sacktag_write_queue+1904>
   0x000000000066595e <+974>:   mov    %r10,%rdi

This only happened on one of the 30 or so servers I had just deployed it to.

Simon-
