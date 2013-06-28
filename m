From: Cody P Schafer <devel-lists@codyps.com>
Subject: Re: [PATCH v4 net-next] net: poll/select low latency socket support
Date: Thu, 27 Jun 2013 17:25:54 -0700
Message-ID: <51CCD812.5090408@codyps.com>
References: <20130624072751.26134.78163.stgit@ladj378.jer.intel.com> <20130624072803.26134.41593.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130624072803.26134.41593.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/24/2013 12:28 AM, Eliezer Tamir wrote:
> select/poll busy-poll support.
...
> diff --git a/fs/select.c b/fs/select.c
> index 8c1c96c..79b876e 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -400,6 +402,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>   	poll_table *wait;
>   	int retval, i, timed_out = 0;
>   	unsigned long slack = 0;
> +	unsigned int ll_flag = POLL_LL;
> +	u64 ll_time = ll_end_time();
>
>   	rcu_read_lock();
>   	retval = max_select_fd(n, fds);
> @@ -750,6 +768,8 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
>   	ktime_t expire, *to = NULL;
>   	int timed_out = 0, count = 0;
>   	unsigned long slack = 0;
> +	unsigned int ll_flag = POLL_LL;
> +	u64 ll_time = ll_end_time();
>
>   	/* Optimise the no-wait case */
>   	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
> diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
> index fcc7c36..5bf2b3a 100644
> --- a/include/net/ll_poll.h
> +++ b/include/net/ll_poll.h
> @@ -38,17 +39,18 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
>
>   /* we can use sched_clock() because we don't care much about precision
>    * we only care that the average is bounded
> + * we don't mind a ~2.5% imprecision so <<10 instead of *1000
> + * sk->sk_ll_usec is a u_int so this can't overflow
>    */
> -static inline u64 ll_end_time(struct sock *sk)
> +static inline u64 ll_sk_end_time(struct sock *sk)
>   {
> -	u64 end_time = ACCESS_ONCE(sk->sk_ll_usec);
> -
> -	/* we don't mind a ~2.5% imprecision
> -	 * sk->sk_ll_usec is a u_int so this can't overflow
> -	 */
> -	end_time = (end_time << 10) + sched_clock();
> +	return ((u64)ACCESS_ONCE(sk->sk_ll_usec) << 10) + sched_clock();
> +}
>
> -	return end_time;
> +/* in poll/select we use the global sysctl_net_ll_poll value */
> +static inline u64 ll_end_time(void)
> +{
> +	return ((u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10) + sched_clock();
>   }
>
>   static inline bool sk_valid_ll(struct sock *sk)
> @@ -62,10 +64,13 @@ static inline bool can_poll_ll(u64 end_time)
>   	return !time_after64(sched_clock(), end_time);
>   }
>
> +/* when used in sock_poll() nonblock is known at compile time to be true
> + * so the loop and end_time will be optimized out
> + */
>   static inline bool sk_poll_ll(struct sock *sk, int nonblock)
>   {
> +	u64 end_time = nonblock ? 0 : ll_sk_end_time(sk);
>   	const struct net_device_ops *ops;
> -	u64 end_time = ll_end_time(sk);
>   	struct napi_struct *napi;
>   	int rc = false;
>

I'm seeing warnings about using smp_processor_id() while preemptable 
(log included below) due to this patch. I expect the use of 
ll_end_time() -> sched_clock() here is triggering this.

Apologies if this has already been noted.
--

# [    3.114452] BUG: using smp_processor_id() in preemptible [00000000] 
code: sh/62
[    3.117970] caller is native_sched_clock+0x20/0x80
[    3.120303] CPU: 0 PID: 62 Comm: sh Not tainted 
3.10.0-rc6-dnuma-01032-g2d48d67 #21
[    3.123710] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[    3.128616]  0000000000000000 ffff880002b6baf0 ffffffff813c07d0 
ffff880002b6bb08
[    3.135055]  ffffffff811ff835 00000004d076eeed ffff880002b6bb20 
ffffffff81009ac0
[    3.137359]  0000000000000000 ffff880002b6bb30 ffffffff81009b29 
ffff880002b6bf40
[    3.138954] Call Trace:
[    3.139466]  [<ffffffff813c07d0>] dump_stack+0x19/0x1b
[    3.140559]  [<ffffffff811ff835>] debug_smp_processor_id+0xd5/0xf0
[    3.141831]  [<ffffffff81009ac0>] native_sched_clock+0x20/0x80
[    3.143031]  [<ffffffff81009b29>] sched_clock+0x9/0x10
[    3.144127]  [<ffffffff811033a6>] do_sys_poll+0x1f6/0x500
[    3.145239]  [<ffffffff81009b29>] ? sched_clock+0x9/0x10
[    3.146335]  [<ffffffff81009ac0>] ? native_sched_clock+0x20/0x80
[    3.147557]  [<ffffffff8106cf5d>] ? sched_clock_local+0x1d/0x90
[    3.148816]  [<ffffffff81009ac0>] ? native_sched_clock+0x20/0x80
[    3.150007]  [<ffffffff81009b29>] ? sched_clock+0x9/0x10
[    3.151090]  [<ffffffff8106cf5d>] ? sched_clock_local+0x1d/0x90
[    3.152419]  [<ffffffff81009ac0>] ? native_sched_clock+0x20/0x80
[    3.153638]  [<ffffffff81009ac0>] ? native_sched_clock+0x20/0x80
[    3.154865]  [<ffffffff81009b29>] ? sched_clock+0x9/0x10
[    3.155961]  [<ffffffff8106cf5d>] ? sched_clock_local+0x1d/0x90
[    3.157230]  [<ffffffff8106d128>] ? sched_clock_cpu+0xa8/0x100
[    3.158433]  [<ffffffff81101af0>] ? SyS_getdents64+0x110/0x110
[    3.159628]  [<ffffffff81009ac0>] ? native_sched_clock+0x20/0x80
[    3.160916]  [<ffffffff81009b29>] ? sched_clock+0x9/0x10
[    3.162003]  [<ffffffff8106cf5d>] ? sched_clock_local+0x1d/0x90
[    3.163207]  [<ffffffff8106d128>] ? sched_clock_cpu+0xa8/0x100
[    3.164427]  [<ffffffff81084b39>] ? get_lock_stats+0x19/0x60
[    3.165580]  [<ffffffff81084fbe>] ? put_lock_stats.isra.28+0xe/0x40
[    3.166856]  [<ffffffff813c2415>] ? __mutex_unlock_slowpath+0x105/0x1a0
[    3.168412]  [<ffffffff81087c55>] ? trace_hardirqs_on_caller+0x105/0x1d0
[    3.169944]  [<ffffffff81087d2d>] ? trace_hardirqs_on+0xd/0x10
[    3.171155]  [<ffffffff813c24b9>] ? mutex_unlock+0x9/0x10
[    3.172355]  [<ffffffff81251fd3>] ? tty_ioctl+0xa53/0xd40
[    3.173483]  [<ffffffff8108ae28>] ? lock_release_non_nested+0x308/0x350
[    3.174848]  [<ffffffff81089bd6>] ? __lock_acquire+0x3d6/0xb70
[    3.176087]  [<ffffffff81087c55>] ? trace_hardirqs_on_caller+0x105/0x1d0
[    3.177466]  [<ffffffff81101205>] ? do_vfs_ioctl+0x305/0x510
[    3.178629]  [<ffffffff813c6959>] ? sysret_check+0x22/0x5d
[    3.179764]  [<ffffffff81087c55>] ? trace_hardirqs_on_caller+0x105/0x1d0
[    3.181196]  [<ffffffff81103770>] SyS_poll+0x60/0xf0
[    3.182225]  [<ffffffff813c692d>] system_call_fastpath+0x1a/0x1f
