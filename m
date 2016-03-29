From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf: net/core/filter.c:2115 suspicious rcu_dereference_protected()
 usage!
Date: Tue, 29 Mar 2016 15:55:01 +0200
Message-ID: <56FA8935.8030109@iogearbox.net>
References: <56CB29D5.9090000@oracle.com> <20160329125823.GB15048@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, ast@plumgrid.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51613 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbcC2NzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:55:11 -0400
In-Reply-To: <20160329125823.GB15048@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ dropping my old email address ]

On 03/29/2016 02:58 PM, Michal Kubecek wrote:
> On Mon, Feb 22, 2016 at 10:31:33AM -0500, Sasha Levin wrote:
>>
>> I've hit the following warning while fuzzing with trinity inside a kvmtool guest
>> running the latest -next kernel:
>>
>> [ 1343.104588] ===============================
>> [ 1343.104591] [ INFO: suspicious RCU usage. ]
>> [ 1343.104619] 4.5.0-rc4-next-20160219-sasha-00026-g7978205-dirty #2978 Not tainted
>> [ 1343.104624] -------------------------------
>> [ 1343.104635] net/core/filter.c:2115 suspicious rcu_dereference_protected() usage!
>> [ 1343.104641]
>> [ 1343.104641] other info that might help us debug this:
>> [ 1343.104641]
>> [ 1343.104650]
>> [ 1343.104650] rcu_scheduler_active = 1, debug_locks = 0
>> [ 1343.104660] 1 lock held by syz-executor/17916:
>> [ 1343.104784] #0: (rtnl_mutex){+.+.+.}, at: rtnl_lock (net/core/rtnetlink.c:71)
>> [ 1343.104789]
>> [ 1343.104789] stack backtrace:
>> [ 1343.104820] CPU: 1 PID: 17916 Comm: trinity-c8 Not tainted 4.5.0-rc4-next-20160219-sasha-00026-g7978205-dirty #2978
>> [ 1343.104868]  1ffff10036968f44 ffff8801b4b47aa8 ffffffffa23d9a9d ffffffff00000001
>> [ 1343.104891]  fffffbfff5c2a630 0000000041b58ab3 ffffffffadb3a8f2 ffffffffa23d9905
>> [ 1343.104914]  0000000000000000 ffff8801b5419b40 fffffbfff7596522 0000000000000001
>> [ 1343.104919] Call Trace:
>> [ 1343.104985] dump_stack (lib/dump_stack.c:53)
>> [ 1343.105060] lockdep_rcu_suspicious (kernel/locking/lockdep.c:4282)
>> [ 1343.105093] sk_detach_filter (net/core/filter.c:2114 (discriminator 5))
>> [ 1343.105193] tun_detach_filter (drivers/net/tun.c:1808 (discriminator 7))
>> [ 1343.105238] __tun_chr_ioctl (drivers/net/tun.c:2133)
>> [ 1343.105370] tun_chr_ioctl (drivers/net/tun.c:2161)
>> [ 1343.105407] do_vfs_ioctl (fs/ioctl.c:44 fs/ioctl.c:674)
>> [ 1343.105506] SyS_ioctl (fs/ioctl.c:689 fs/ioctl.c:680)
>> [ 1343.105542] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:200)
>
> Looks like sk_detach_filter() wants the socket to be owned which neither
> tun_detach_filter() does not do, unlike sock_setsockopt(). Could you
> check if the patch below helps?
>
> I'm also not really sure if it is safe to ignore return value of
> sk_detach_filter() and just sets tun->filter_attached to false - but
> it's not really clear what should be done if one of the calls fails
> after some succeeded.

Wrt return value, afaik SOCK_FILTER_LOCKED cannot be set for tun devs, so we
should be okay.

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index afdf950617c3..7417d7c20bab 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1818,11 +1818,13 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
>   static void tun_detach_filter(struct tun_struct *tun, int n)
>   {
>   	int i;
> -	struct tun_file *tfile;
>
>   	for (i = 0; i < n; i++) {
> -		tfile = rtnl_dereference(tun->tfiles[i]);
> -		sk_detach_filter(tfile->socket.sk);
> +		struct sock *sk = rtnl_dereference(tun->tfiles[i])->socket.sk;
> +
> +		lock_sock(sk);
> +		sk_detach_filter(sk);
> +		release_sock(sk);
>   	}
>
>   	tun->filter_attached = false;
>

In tun case, the control path for tun_attach_filter() and tun_detach_filter()
is under RTNL lock (held in __tun_chr_ioctl()).

So in the BPF core the rcu_dereference_protected(<sk_filter>, sock_owned_by_user(sk))
looks like a false positive in this specific use case to me, that we should probably
just silence.

Running the filter via sk_filter() in tun device happens under rcu_read_lock(),
so the dereference and assignment pair seems okay to me.

Was wondering whether we should convert this to unattached BPF filter, but this
would break with existing expectations from sk_filter() (e.g. security modules).
