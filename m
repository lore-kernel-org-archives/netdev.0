From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] pktgen: fix crash at module unload
Date: Wed, 09 May 2012 14:23:22 -0700
Message-ID: <874nrpyrp1.fsf@xmission.com>
References: <1336591268.12504.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51904 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466Ab2EIVXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 17:23:30 -0400
In-Reply-To: <1336591268.12504.62.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Wed, 09 May 2012 21:21:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> From: Eric Dumazet <edumazet@google.com>
>
> commit 7d3d43dab4e9 (net: In unregister_netdevice_notifier unregister
> the netdevices.) makes pktgen crashing at module unload.

Awesome an anceint race was flushed out.

> [  296.820578] BUG: spinlock bad magic on CPU#6, rmmod/3267
> [  296.820719]  lock: ffff880310c38000, .magic: ffff8803, .owner: <none>/-1, .owner_cpu: -1
> [  296.820943] Pid: 3267, comm: rmmod Not tainted 3.4.0-rc5+ #254
> [  296.821079] Call Trace:
> [  296.821211]  [<ffffffff8168a715>] spin_dump+0x8a/0x8f
> [  296.821345]  [<ffffffff8168a73b>] spin_bug+0x21/0x26
> [  296.821507]  [<ffffffff812b4741>] do_raw_spin_lock+0x131/0x140
> [  296.821648]  [<ffffffff8169188e>] _raw_spin_lock+0x1e/0x20
> [  296.821786]  [<ffffffffa00cc0fd>] __pktgen_NN_threads+0x4d/0x140 [pktgen]
> [  296.821928]  [<ffffffffa00ccf8d>] pktgen_device_event+0x10d/0x1e0 [pktgen]
> [  296.822073]  [<ffffffff8154ed4f>] unregister_netdevice_notifier+0x7f/0x100
> [  296.822216]  [<ffffffffa00d2a0b>] pg_cleanup+0x48/0x73 [pktgen]
> [  296.822357]  [<ffffffff8109528e>] sys_delete_module+0x17e/0x2a0
> [  296.822502]  [<ffffffff81699652>] system_call_fastpath+0x16/0x1b
>
> Fix this by deleting objects from pktgen_threads list before their
> freeing.

That seems reasonable.

Would it be easier to call unregister_netdevice_notifer before shutting
down the threads, so you don't have the weird cases to deal with during
shutdown?

It looks like pg_cleanup doesn't take the pktgen_thread_lock, so
I suspect that there are still races.


Eric


> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  net/core/pktgen.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index ffb5d38..f632abf 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -3762,6 +3762,7 @@ static void __exit pg_cleanup(void)
>  	list_for_each_safe(q, n, &pktgen_threads) {
>  		t = list_entry(q, struct pktgen_thread, th_list);
>  		kthread_stop(t->tsk);
> +		list_del(&t->th_list);
>  		kfree(t);
>  	}
>  
