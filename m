From: Simon Kirby <sim@hostway.ca>
Subject: Re: Linux 3.1-rc9
Date: Wed, 2 Nov 2011 17:09:41 -0700
Message-ID: <20111103000941.GJ5971@hostway.ca>
References: <alpine.LFD.2.02.1110172237030.3240@ionos> <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins> <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca> <20111031173246.GA10614@hostway.ca> <20111102221023.GA27457@home.goodmis.org> <20111102230009.GB27457@home.goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111102230009.GB27457@home.goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2011 at 07:00:10PM -0400, Steven Rostedt wrote:

> On Wed, Nov 02, 2011 at 06:10:23PM -0400, Steven Rostedt wrote:
> > Thomas pointed me here.
> > 
> > On Mon, Oct 31, 2011 at 10:32:46AM -0700, Simon Kirby wrote:
> > > [104661.244767] 
> > > [104661.244767]  Possible unsafe locking scenario:
> > > [104661.244767]        
> > > [104661.244767]        CPU0                    CPU1
> > > [104661.244767]        ----                    ----
> > > [104661.244767]   lock(slock-AF_INET);
> > > [104661.244767]                                lock(slock-AF_INET);
> > > [104661.244767]                                lock(slock-AF_INET);
> > > [104661.244767]   lock(slock-AF_INET);
> > > [104661.244767] 
> > > [104661.244767]  *** DEADLOCK ***
> > > [104661.244767] 
> > 
> > Bah, I used the __print_lock_name() function to show the lock names in
> > the above, which leaves off the subclass number. I'll go write up a
> > patch that fixes that.
> > 
> 
> Simon,
> 
> If you are still triggering the bug. Could you do me a favor and apply
> the following patch. Just to make sure it fixes the confusing output
> from above.
> 
> Thanks,
> 
> -- Steve
> 
> 
> diff --git a/kernel/lockdep.c b/kernel/lockdep.c
> index 91d67ce..d821ac9 100644
> --- a/kernel/lockdep.c
> +++ b/kernel/lockdep.c
> @@ -490,16 +490,22 @@ void get_usage_chars(struct lock_class *class, char usage[LOCK_USAGE_CHARS])
>  	usage[i] = '\0';
>  }
>  
> -static int __print_lock_name(struct lock_class *class)
> +static void __print_lock_name(struct lock_class *class)
>  {
>  	char str[KSYM_NAME_LEN];
>  	const char *name;
>  
>  	name = class->name;
> -	if (!name)
> +	if (!name) {
>  		name = __get_key_name(class->key, str);
> -
> -	return printk("%s", name);
> +		printk("%s", name);
> +	} else {
> +		printk("%s", name);
> +		if (class->name_version > 1)
> +			printk("#%d", class->name_version);
> +		if (class->subclass)
> +			printk("/%d", class->subclass);
> +	}
>  }
>  
>  static void print_lock_name(struct lock_class *class)
> @@ -509,17 +515,8 @@ static void print_lock_name(struct lock_class *class)
>  
>  	get_usage_chars(class, usage);
>  
> -	name = class->name;
> -	if (!name) {
> -		name = __get_key_name(class->key, str);
> -		printk(" (%s", name);
> -	} else {
> -		printk(" (%s", name);
> -		if (class->name_version > 1)
> -			printk("#%d", class->name_version);
> -		if (class->subclass)
> -			printk("/%d", class->subclass);
> -	}
> +	printk(" (");
> +	__print_lock_name(class);
>  	printk("){%s}", usage);
>  }

Hello!

I am now able to reproduce on demand by just starting an "ab" from
another box and "ip route add blackhole <other machine>" on the target
box while the ab is running. The first time I tried this without your
patch, and got the trace I had before. With your patch, I got this:

[  366.198866] huh, entered softirq 3 NET_RX ffffffff81616560 preempt_count 00000102, exited with 00000103?
[  366.198981] 
[  366.198982] =================================
[  366.199118] [ INFO: inconsistent lock state ]
[  366.199189] 3.1.0-hw-lockdep+ #58
[  366.199259] ---------------------------------
[  366.199331] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[  366.199407] kworker/0:1/0 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  366.199480]  (slock-AF_INET){+.?...}, at: [<ffffffff8160738e>] sk_clone+0x10e/0x3e0
[  366.199773] {IN-SOFTIRQ-W} state was registered at:
[  366.199846]   [<ffffffff81098b7c>] __lock_acquire+0xcbc/0x2180
[  366.199973]   [<ffffffff8109a149>] lock_acquire+0x109/0x140
[  366.200096]   [<ffffffff816f842c>] _raw_spin_lock+0x3c/0x50
[  366.200220]   [<ffffffff8166eb6d>] udp_queue_rcv_skb+0x26d/0x4b0
[  366.200346]   [<ffffffff8166f4d3>] __udp4_lib_rcv+0x2f3/0x910
[  366.200470]   [<ffffffff8166fb05>] udp_rcv+0x15/0x20
[  366.200592]   [<ffffffff81644790>] ip_local_deliver_finish+0x100/0x2f0
[  366.200718]   [<ffffffff81644a0d>] ip_local_deliver+0x8d/0xa0
[  366.200841]   [<ffffffff81644033>] ip_rcv_finish+0x1a3/0x510
[  366.200965]   [<ffffffff81644612>] ip_rcv+0x272/0x2f0
[  366.201086]   [<ffffffff81613b87>] __netif_receive_skb+0x4d7/0x560
[  366.201211]   [<ffffffff81613ce0>] process_backlog+0xd0/0x1e0
[  366.201335]   [<ffffffff816166a0>] net_rx_action+0x140/0x2c0
[  366.201458]   [<ffffffff810640e8>] __do_softirq+0x138/0x250
[  366.201582]   [<ffffffff817030fc>] call_softirq+0x1c/0x30
[  366.201706]   [<ffffffff810153c5>] do_softirq+0x95/0xd0
[  366.202822]   [<ffffffff81063efd>] local_bh_enable+0xed/0x110
[  366.202822]   [<ffffffff81617a68>] dev_queue_xmit+0x1a8/0x8a0
[  366.202822]   [<ffffffff81621fca>] neigh_resolve_output+0x17a/0x220
[  366.202822]   [<ffffffff8164ab7c>] ip_finish_output+0x2ec/0x590
[  366.202822]   [<ffffffff8164aea8>] ip_output+0x88/0xe0
[  366.202822]   [<ffffffff81649b08>] ip_local_out+0x28/0x80
[  366.202822]   [<ffffffff81649b69>] ip_send_skb+0x9/0x40
[  366.202822]   [<ffffffff8166dce8>] udp_send_skb+0x108/0x370
[  366.202822]   [<ffffffff8167093c>] udp_sendmsg+0x7dc/0x920
[  366.202822]   [<ffffffff81678c4f>] inet_sendmsg+0xbf/0x120
[  366.202822]   [<ffffffff81602193>] sock_sendmsg+0xe3/0x110
[  366.202822]   [<ffffffff81602ab5>] sys_sendto+0x105/0x140
[  366.202822]   [<ffffffff81700e92>] system_call_fastpath+0x16/0x1b
[  366.202822] irq event stamp: 1175966
[  366.202822] hardirqs last  enabled at (1175964): [<ffffffff816f9174>] restore_args+0x0/0x30
[  366.202822] hardirqs last disabled at (1175965): [<ffffffff8106415d>] __do_softirq+0x1ad/0x250
[  366.202822] softirqs last  enabled at (1175966): [<ffffffff810641a6>] __do_softirq+0x1f6/0x250
[  366.202822] softirqs last disabled at (1175907): [<ffffffff817030fc>] call_softirq+0x1c/0x30
[  366.202822] 
[  366.202822] other info that might help us debug this:
[  366.202822]  Possible unsafe locking scenario:
[  366.202822] 
[  366.202822]        CPU0
[  366.202822]        ----
[  366.202822]   lock(slock-AF_INET);
[  366.202822]   <Interrupt>
[  366.202822]     lock(slock-AF_INET);
[  366.202822] 
[  366.202822]  *** DEADLOCK ***
[  366.202822] 
[  366.202822] 1 lock held by kworker/0:1/0:
[  366.202822]  #0:  (slock-AF_INET){+.?...}, at: [<ffffffff8160738e>] sk_clone+0x10e/0x3e0
[  366.202822] 
[  366.202822] stack backtrace:
[  366.202822] Pid: 0, comm: kworker/0:1 Not tainted 3.1.0-hw-lockdep+ #58
[  366.202822] Call Trace:
[  366.202822]  [<ffffffff81095f31>] print_usage_bug+0x241/0x310
[  366.202822]  [<ffffffff810964b4>] mark_lock+0x4b4/0x6c0
[  366.202822]  [<ffffffff81097300>] ? check_usage_forwards+0x110/0x110
[  366.202822]  [<ffffffff81096762>] mark_held_locks+0xa2/0x130
[  366.202822]  [<ffffffff816f9174>] ? retint_restore_args+0x13/0x13
[  366.202822]  [<ffffffff81096b0d>] trace_hardirqs_on_caller+0x13d/0x1c0
[  366.202822]  [<ffffffff813a60ee>] trace_hardirqs_on_thunk+0x3a/0x3f
[  366.202822]  [<ffffffff816f9174>] ? retint_restore_args+0x13/0x13
[  366.202822]  [<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
[  366.202822]  [<ffffffff8101b805>] ? mwait_idle+0x145/0x170
[  366.202822]  [<ffffffff81013156>] cpu_idle+0x96/0xf0
[  366.202822]  [<ffffffff816ef2eb>] start_secondary+0x1ca/0x1ff

...which of course is a different splat, so I ran it again:

[   49.028097] =======================================================
[   49.028244] [ INFO: possible circular locking dependency detected ]
[   49.028321] 3.1.0-hw-lockdep+ #58
[   49.028391] -------------------------------------------------------
[   49.028466] tcsh/2490 is trying to acquire lock:
[   49.028539]  (slock-AF_INET/1){+.-...}, at: [<ffffffff816676b7>] tcp_v4_rcv+0x867/0xc10
[   49.028882] 
[   49.028883] but task is already holding lock:
[   49.029018]  (slock-AF_INET){+.-...}, at: [<ffffffff8160738e>] sk_clone+0x10e/0x3e0
[   49.029310] 
[   49.029310] which lock already depends on the new lock.
[   49.029312] 
[   49.029513] 
[   49.029514] the existing dependency chain (in reverse order) is:
[   49.029653] 
[   49.029654] -> #1 (slock-AF_INET){+.-...}:
[   49.029986]        [<ffffffff8109a149>] lock_acquire+0x109/0x140
[   49.030115]        [<ffffffff816f842c>] _raw_spin_lock+0x3c/0x50
[   49.030242]        [<ffffffff8160738e>] sk_clone+0x10e/0x3e0
[   49.031959]        [<ffffffff8164f963>] inet_csk_clone+0x13/0x90
[   49.032008]        [<ffffffff816697d5>] tcp_create_openreq_child+0x25/0x4d0
[   49.032008]        [<ffffffff81667aa8>] tcp_v4_syn_recv_sock+0x48/0x2c0
[   49.032008]        [<ffffffff81669625>] tcp_check_req+0x335/0x4c0
[   49.032008]        [<ffffffff81666c8e>] tcp_v4_do_rcv+0x29e/0x460
[   49.032008]        [<ffffffff816676dc>] tcp_v4_rcv+0x88c/0xc10
[   49.032008]        [<ffffffff81644790>] ip_local_deliver_finish+0x100/0x2f0
[   49.032008]        [<ffffffff81644a0d>] ip_local_deliver+0x8d/0xa0
[   49.032008]        [<ffffffff81644033>] ip_rcv_finish+0x1a3/0x510
[   49.032008]        [<ffffffff81644612>] ip_rcv+0x272/0x2f0
[   49.032008]        [<ffffffff81613b87>] __netif_receive_skb+0x4d7/0x560
[   49.032008]        [<ffffffff81613ce0>] process_backlog+0xd0/0x1e0
[   49.032008]        [<ffffffff816166a0>] net_rx_action+0x140/0x2c0
[   49.032008]        [<ffffffff810640e8>] __do_softirq+0x138/0x250
[   49.032008]        [<ffffffff817030fc>] call_softirq+0x1c/0x30
[   49.032008]        [<ffffffff810153c5>] do_softirq+0x95/0xd0
[   49.032008]        [<ffffffff81063ded>] local_bh_enable_ip+0xed/0x110
[   49.032008]        [<ffffffff816f8ccf>] _raw_spin_unlock_bh+0x3f/0x50
[   49.032008]        [<ffffffff81605ca1>] release_sock+0x161/0x1d0
[   49.032008]        [<ffffffff8167911d>] inet_stream_connect+0x6d/0x2f0
[   49.032008]        [<ffffffff815ffe4b>] kernel_connect+0xb/0x10
[   49.032008]        [<ffffffff816addb6>] xs_tcp_setup_socket+0x2a6/0x4c0
[   49.032008]        [<ffffffff81078d29>] process_one_work+0x1e9/0x560
[   49.032008]        [<ffffffff81079433>] worker_thread+0x193/0x420
[   49.032008]        [<ffffffff81080496>] kthread+0x96/0xb0
[   49.032008]        [<ffffffff81703004>] kernel_thread_helper+0x4/0x10
[   49.032008] 
[   49.032008] -> #0 (slock-AF_INET/1){+.-...}:
[   49.032008]        [<ffffffff81099f00>] __lock_acquire+0x2040/0x2180
[   49.032008]        [<ffffffff8109a149>] lock_acquire+0x109/0x140
[   49.032008]        [<ffffffff816f83da>] _raw_spin_lock_nested+0x3a/0x50
[   49.032008]        [<ffffffff816676b7>] tcp_v4_rcv+0x867/0xc10
[   49.032008]        [<ffffffff81644790>] ip_local_deliver_finish+0x100/0x2f0
[   49.032008]        [<ffffffff81644a0d>] ip_local_deliver+0x8d/0xa0
[   49.032008]        [<ffffffff81644033>] ip_rcv_finish+0x1a3/0x510
[   49.032008]        [<ffffffff81644612>] ip_rcv+0x272/0x2f0
[   49.032008]        [<ffffffff81613b87>] __netif_receive_skb+0x4d7/0x560
[   49.032008]        [<ffffffff81615c44>] netif_receive_skb+0x104/0x120
[   49.032008]        [<ffffffff81615d90>] napi_skb_finish+0x50/0x70
[   49.032008]        [<ffffffff81616455>] napi_gro_receive+0xc5/0xd0
[   49.032008]        [<ffffffffa000ad50>] bnx2_poll_work+0x610/0x1560 [bnx2]
[   49.032008]        [<ffffffffa000bde6>] bnx2_poll+0x66/0x250 [bnx2]
[   49.032008]        [<ffffffff816166a0>] net_rx_action+0x140/0x2c0
[   49.032008]        [<ffffffff810640e8>] __do_softirq+0x138/0x250
[   49.032008]        [<ffffffff817030fc>] call_softirq+0x1c/0x30
[   49.032008]        [<ffffffff810153c5>] do_softirq+0x95/0xd0
[   49.032008]        [<ffffffff81063cbd>] irq_exit+0xdd/0x110
[   49.032008]        [<ffffffff81014b74>] do_IRQ+0x64/0xe0
[   49.032008]        [<ffffffff816f90b3>] ret_from_intr+0x0/0x1a
[   49.032008]        [<ffffffff8105f63f>] release_task+0x24f/0x4c0
[   49.032008]        [<ffffffff810601de>] wait_consider_task+0x92e/0xb90
[   49.032008]        [<ffffffff81060590>] do_wait+0x150/0x270
[   49.032008]        [<ffffffff81060751>] sys_wait4+0xa1/0xf0
[   49.032008]        [<ffffffff81700e92>] system_call_fastpath+0x16/0x1b
[   49.032008] 
[   49.032008] other info that might help us debug this:
[   49.032008] 
[   49.032008]  Possible unsafe locking scenario:
[   49.032008] 
[   49.032008]        CPU0                    CPU1
[   49.032008]        ----                    ----
[   49.032008]   lock(slock-AF_INET);
[   49.039565]                                lock(slock-AF_INET/1);
[   49.039565]                                lock(slock-AF_INET);
[   49.039565]   lock(slock-AF_INET/1);
[   49.039565] 
[   49.039565]  *** DEADLOCK ***
[   49.039565] 
[   49.039565] 3 locks held by tcsh/2490:
[   49.039565]  #0:  (slock-AF_INET){+.-...}, at: [<ffffffff8160738e>] sk_clone+0x10e/0x3e0
[   49.039565]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81613815>] __netif_receive_skb+0x165/0x560
[   49.039565]  #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff816446d0>] ip_local_deliver_finish+0x40/0x2f0
[   49.039565] 
[   49.039565] stack backtrace:
[   49.039565] Pid: 2490, comm: tcsh Not tainted 3.1.0-hw-lockdep+ #58
[   49.039565] Call Trace:
[   49.039565]  <IRQ>  [<ffffffff81097dab>] print_circular_bug+0x21b/0x330
[   49.039565]  [<ffffffff81099f00>] __lock_acquire+0x2040/0x2180
[   49.039565]  [<ffffffff8109a149>] lock_acquire+0x109/0x140
[   49.039565]  [<ffffffff816676b7>] ? tcp_v4_rcv+0x867/0xc10
[   49.039565]  [<ffffffff816f83da>] _raw_spin_lock_nested+0x3a/0x50
[   49.039565]  [<ffffffff816676b7>] ? tcp_v4_rcv+0x867/0xc10
[   49.039565]  [<ffffffff816676b7>] tcp_v4_rcv+0x867/0xc10
[   49.039565]  [<ffffffff816446d0>] ? ip_local_deliver_finish+0x40/0x2f0
[   49.039565]  [<ffffffff81644790>] ip_local_deliver_finish+0x100/0x2f0
[   49.039565]  [<ffffffff816446d0>] ? ip_local_deliver_finish+0x40/0x2f0
[   49.039565]  [<ffffffff81644a0d>] ip_local_deliver+0x8d/0xa0
[   49.039565]  [<ffffffff81644033>] ip_rcv_finish+0x1a3/0x510
[   49.039565]  [<ffffffff81644612>] ip_rcv+0x272/0x2f0
[   49.039565]  [<ffffffff81613b87>] __netif_receive_skb+0x4d7/0x560
[   49.039565]  [<ffffffff81613815>] ? __netif_receive_skb+0x165/0x560
[   49.039565]  [<ffffffff81615c44>] netif_receive_skb+0x104/0x120
[   49.039565]  [<ffffffff81615b63>] ? netif_receive_skb+0x23/0x120
[   49.039565]  [<ffffffff816161cb>] ? dev_gro_receive+0x29b/0x380
[   49.039565]  [<ffffffff816160c2>] ? dev_gro_receive+0x192/0x380
[   49.039565]  [<ffffffff81615d90>] napi_skb_finish+0x50/0x70
[   49.039565]  [<ffffffff81616455>] napi_gro_receive+0xc5/0xd0
[   49.039565]  [<ffffffffa000ad50>] bnx2_poll_work+0x610/0x1560 [bnx2]
[   49.039565]  [<ffffffffa000bde6>] bnx2_poll+0x66/0x250 [bnx2]
[   49.039565]  [<ffffffff816166a0>] net_rx_action+0x140/0x2c0
[   49.039565]  [<ffffffff810640e8>] __do_softirq+0x138/0x250
[   49.039565]  [<ffffffff817030fc>] call_softirq+0x1c/0x30
[   49.039565]  [<ffffffff810153c5>] do_softirq+0x95/0xd0
[   49.039565]  [<ffffffff81063cbd>] irq_exit+0xdd/0x110
[   49.039565]  [<ffffffff81014b74>] do_IRQ+0x64/0xe0
[   49.039565]  [<ffffffff816f90b3>] common_interrupt+0x73/0x73
[   49.039565]  <EOI>  [<ffffffff810944fd>] ? trace_hardirqs_off+0xd/0x10
[   49.039565]  [<ffffffff816f864f>] ? _raw_write_unlock_irq+0x2f/0x50
[   49.039565]  [<ffffffff816f864b>] ? _raw_write_unlock_irq+0x2b/0x50
[   49.039565]  [<ffffffff8105f63f>] release_task+0x24f/0x4c0
[   49.039565]  [<ffffffff8105f414>] ? release_task+0x24/0x4c0
[   49.039565]  [<ffffffff810601de>] wait_consider_task+0x92e/0xb90
[   49.039565]  [<ffffffff81096b0d>] ? trace_hardirqs_on_caller+0x13d/0x1c0
[   49.039565]  [<ffffffff81060590>] do_wait+0x150/0x270
[   49.039565]  [<ffffffff81096b9d>] ? trace_hardirqs_on+0xd/0x10
[   49.039565]  [<ffffffff81060751>] sys_wait4+0xa1/0xf0
[   49.039565]  [<ffffffff8105e9b0>] ? wait_noreap_copyout+0x150/0x150
[   49.039565]  [<ffffffff81700e92>] system_call_fastpath+0x16/0x1b
[   49.045277] huh, entered softirq 3 NET_RX ffffffff81616560 preempt_count 00000102, exited with 00000103?

Did that help? I'm not sure if that's what you wanted to see...

Simon-
