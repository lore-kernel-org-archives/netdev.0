From: Ross Vandegrift <ross@kallisti.us>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Thu, 7 Feb 2008 14:44:46 -0500
Message-ID: <20080207194446.GA25463@kallisti.us>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205192559.GA10573@kallisti.us> <20080205201106.GB26150@one.firstfloor.org> <20080205212335.GA11287@kallisti.us> <20080206085357.GA1402@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kallisti.us ([67.59.168.233]:34932 "EHLO kallisti.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbYBGTqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 14:46:04 -0500
Content-Disposition: inline
In-Reply-To: <20080206085357.GA1402@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 09:53:57AM +0100, Andi Kleen wrote:
> That would be useful yes -- for different bandwidths.

My initial test is end-to-end 1000Mbps, but I've got a few different
packet rates.

> If the young/old heuristics do not work well enough anymore most
> likely we should try readding RED to the syn queue again. That used
> to be pretty effective in the early days. I don't quite remember why
> Linux didn't end up using it in fact.

I'm running juno-z with 2, 4, & 8 threads of syn flood to port 80.
wireshark measures 2 threads at 350pps, 4 threads at 750pps, and 8
threads at 1200pps.  Under no SYN flood, the server handles 750 HTTP
requests per second, measured via httping in flood mode.

With a default tcp_max_syn_backlog of 1024, I can trivially prevent
any inbound client connections with 2 threads of syn flood.
Enabling tcp_syncookies brings the connection handling back up to 725
fetches per second.

If I raise the backlog to 16384, 4 threads gives me about 650 legit
requests per sec.  Going to 8 threads makes connections very unreliable - a
handful will get through every 15 to 20 seconds.  Again,
tcp_syncookies returns performance almost totally back to normal.

Cranking juno-z to the max generates me about 16kpps.  Any syn backlog
is easily overwhelmed and nothing gets through.  tcp_syncookies gets
me back to 650 requests per second.

At these levels the CPU impact of tcp_syncookies is nothing.  I can't
measure a difference.  In the real world, a 16kpps syn flood is small.
People with a distributed botnet can easily get to the hundreds of
thousands, and I have seen over million packets per second of SYN flood.


BTW, I can trigger a soft lockup BUG when I restart apache to change the
backlog during the 16kpps test-case:

BUG: soft lockup detected on CPU#1!
 [<c044d1ec>] softlockup_tick+0x96/0xa4
 [<c042ddb0>] update_process_times+0x39/0x5c
 [<c04196f7>] smp_apic_timer_interrupt+0x5b/0x6c
 [<c04059bf>] apic_timer_interrupt+0x1f/0x24
 [<c045007b>] taskstats_exit_send+0x152/0x371
 [<c05c007b>] netlink_kernel_create+0x5/0x11c
 [<c05a7415>] reqsk_queue_alloc+0x32/0x81
 [<c05a5aca>] lock_sock+0x8e/0x96
 [<c05ce8c4>] inet_csk_listen_start+0x17/0x106
 [<c05e720f>] inet_listen+0x3c/0x5f
 [<c05a3e55>] sys_listen+0x4a/0x66
 [<c05a4f4d>] sys_socketcall+0x98/0x19e
 [<c0407ef7>] do_syscall_trace+0xab/0xb1
 [<c0404eff>] syscall_call+0x7/0xb
 =======================
BUG: soft lockup detected on CPU#3!
 [<c044d1ec>] softlockup_tick+0x96/0xa4
 [<c042ddb0>] update_process_times+0x39/0x5c
 [<c04196f7>] smp_apic_timer_interrupt+0x5b/0x6c
 [<c04059bf>] apic_timer_interrupt+0x1f/0x24
 [<c045007b>] taskstats_exit_send+0x152/0x371
 [<c05c007b>] netlink_kernel_create+0x5/0x11c
 [<c05a7415>] reqsk_queue_alloc+0x32/0x81
 [<c05a5aca>] lock_sock+0x8e/0x96
 [<c05ce8c4>] inet_csk_listen_start+0x17/0x106
 [<c05e720f>] inet_listen+0x3c/0x5f
 [<c05a3e55>] sys_listen+0x4a/0x66
 [<c05a4f4d>] sys_socketcall+0x98/0x19e
 [<c0407ef7>] do_syscall_trace+0xab/0xb1
 [<c0404eff>] syscall_call+0x7/0xb
 =======================







-- 
Ross Vandegrift
ross@kallisti.us

"The good Christian should beware of mathematicians, and all those who
make empty prophecies. The danger already exists that the mathematicians
have made a covenant with the devil to darken the spirit and to confine
man in the bonds of Hell."
	--St. Augustine, De Genesi ad Litteram, Book II, xviii, 37
