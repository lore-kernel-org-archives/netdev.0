From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] locking, percpu counters: introduce separate lock
	classes
Date: Mon, 29 Dec 2008 15:14:17 +0100
Message-ID: <20081229141417.GA1493@elte.hu>
References: <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au> <20081229115827.GA441@elte.hu> <20081229120132.GA10363@gondor.apana.org.au> <20081229121626.GF9628@elte.hu> <20081229123819.GA18321@elte.hu> <20081229124444.GA20306@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:41098 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699AbYL2OOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 09:14:40 -0500
Content-Disposition: inline
In-Reply-To: <20081229124444.GA20306@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> > hm, even with the revert i got the splat below. So some other commits 
> > are causing this too?
> 
> in any case, i picked up and tidied up Peter's annotation patch - see it 
> below. Chances are that this plus the revert will do the trick - and 
> that's what i'm testing now in tip/master.

my testing efforts today are not particularly dominated by luck :-)

Below is the latest splat that i got with Peter's patch plus the revert of 
dd24c00191 applied.

	Ingo

[   78.679386] 
[   78.679389] =================================
[   78.680039] [ INFO: inconsistent lock state ]
[   78.680039] 2.6.28-tip-03885-g44c31d5-dirty #13188
[   78.680039] ---------------------------------
[   78.680039] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
[   78.680039] ssh/4054 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   78.680039]  (key#8){-+..}, at: [<c042710e>] __percpu_counter_add+0x52/0x7a
[   78.680039] {softirq-on-W} state was registered at:
[   78.680039]   [<c0163e6e>] __lock_acquire+0x288/0xa93
[   78.680039]   [<c01646d6>] lock_acquire+0x5d/0x7a
[   78.680039]   [<c0ae0473>] _spin_lock+0x20/0x2f
[   78.680039]   [<c042710e>] __percpu_counter_add+0x52/0x7a
[   78.680039]   [<c09c3e2f>] percpu_counter_add+0xf/0x12
[   78.680039]   [<c09c50ef>] tcp_v4_init_sock+0xe5/0xea
[   78.680039]   [<c09d10d5>] inet_create+0x277/0x2a4
[   78.680039]   [<c095e5d0>] __sock_create+0xfd/0x159
[   78.680039]   [<c095e673>] sock_create+0x29/0x2e
[   78.680039]   [<c095e844>] sys_socket+0x31/0x5f
[   78.680039]   [<c095ef20>] sys_socketcall+0x56/0x16a
[   78.680039]   [<c011bff5>] sysenter_do_call+0x12/0x35
[   78.680039]   [<ffffffff>] 0xffffffff
[   78.680039] irq event stamp: 16094
[   78.680039] hardirqs last  enabled at (16094): [<c0188987>] free_hot_cold_page+0x117/0x123
[   78.680039] hardirqs last disabled at (16093): [<c01888e0>] free_hot_cold_page+0x70/0x123
[   78.680039] softirqs last  enabled at (16022): [<c09b817f>] tcp_close+0x2bd/0x2d6
[   78.680039] softirqs last disabled at (16045): [<c014a6a8>] do_softirq+0x3f/0x57
[   78.680039] 
[   78.680039] other info that might help us debug this:
[   78.680039] 4 locks held by ssh/4054:
[   78.680039]  #0:  (rcu_read_lock){..--}, at: [<c096bb18>] net_rx_action+0x61/0x1a8
[   78.680039]  #1:  (rcu_read_lock){..--}, at: [<c096904d>] netif_receive_skb+0xda/0x312
[   78.680039]  #2:  (rcu_read_lock){..--}, at: [<c09aeb24>] ip_local_deliver_finish+0x42/0x1c3
[   78.680039]  #3:  (slock-AF_INET/1){-+..}, at: [<c09c597a>] tcp_v4_rcv+0x1f5/0x4e2
[   78.680039] 
[   78.680039] stack backtrace:
[   78.680039] Pid: 4054, comm: ssh Not tainted 2.6.28-tip-03885-g44c31d5-dirty #13188
[   78.680039] Call Trace:
[   78.680039]  [<c0162c1d>] valid_state+0x12a/0x13d
[   78.680039]  [<c016343c>] mark_lock+0x109/0x313
[   78.680039]  [<c0163e01>] __lock_acquire+0x21b/0xa93
[   78.680039]  [<c0164660>] ? __lock_acquire+0xa7a/0xa93
[   78.680039]  [<c0163353>] ? mark_lock+0x20/0x313
[   78.680039]  [<c01646d6>] lock_acquire+0x5d/0x7a
[   78.680039]  [<c042710e>] ? __percpu_counter_add+0x52/0x7a
[   78.680039]  [<c0ae0473>] _spin_lock+0x20/0x2f
[   78.680039]  [<c042710e>] ? __percpu_counter_add+0x52/0x7a
[   78.680039]  [<c042710e>] __percpu_counter_add+0x52/0x7a
[   78.680039]  [<c09c3e2f>] percpu_counter_add+0xf/0x12
[   78.680039]  [<c09c5005>] tcp_v4_destroy_sock+0xe7/0xec
[   78.680039]  [<c09b5ea5>] inet_csk_destroy_sock+0x90/0xe8
[   78.680039]  [<c09b7ebf>] tcp_done+0x66/0x69
[   78.680039]  [<c09c716a>] tcp_time_wait+0x18f/0x199
[   78.680039]  [<c09c13d3>] ? tcp_send_ack+0x85/0x8d
[   78.680039]  [<c09bc712>] tcp_fin+0x7f/0x10a
[   78.680039]  [<c09bd012>] tcp_data_queue+0x1c4/0x7ff
[   78.680039]  [<c014e5c9>] ? mod_timer+0x35/0x39
[   78.680039]  [<c09bc49e>] ? tcp_urg+0xe/0x174
[   78.680039]  [<c0961986>] ? sk_reset_timer+0x14/0x22
[   78.680039]  [<c09bff27>] tcp_rcv_state_process+0x7ce/0x807
[   78.680039]  [<c09c4d8d>] tcp_v4_do_rcv+0x156/0x197
[   78.680039]  [<c09c5c13>] tcp_v4_rcv+0x48e/0x4e2
[   78.680039]  [<c09aec02>] ip_local_deliver_finish+0x120/0x1c3
[   78.680039]  [<c09aef21>] ip_local_deliver+0x5b/0x64
[   78.680039]  [<c09aea68>] ip_rcv_finish+0x26d/0x283
[   78.680039]  [<c09aee83>] ? ip_rcv+0x1de/0x221
[   78.680039]  [<c09aee92>] ip_rcv+0x1ed/0x221
[   78.680039]  [<c0969252>] netif_receive_skb+0x2df/0x312
[   78.680039]  [<c096953d>] napi_gro_receive+0x1bd/0x1c5
[   78.680039]  [<c01637ac>] ? trace_hardirqs_on_caller+0x10a/0x15f
[   78.680039]  [<c096b604>] process_backlog+0x6c/0x8d
[   78.680039]  [<c096bb85>] net_rx_action+0xce/0x1a8
[   78.680039]  [<c014a5d6>] __do_softirq+0x94/0x127
[   78.680039]  [<c014a6a8>] do_softirq+0x3f/0x57
[   78.680039]  [<c014ab0b>] irq_exit+0x4c/0x83
[   78.680039]  [<c011df67>] do_IRQ+0x97/0xb0
[   78.680039]  [<c011c5ec>] common_interrupt+0x2c/0x34
[   93.926827] cc1 used greatest stack depth: 5332 bytes left
