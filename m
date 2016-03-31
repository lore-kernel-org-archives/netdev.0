From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 11:15:21 +0200
Message-ID: <56FCEAA9.5060509@suse.cz>
References: <755ee9ec1f6d2229be41806964b372548e4b7586.1459382574.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, mkubecek@suse.cz,
	sasha.levin@oracle.com, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36387 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbcCaJPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 05:15:25 -0400
Received: by mail-wm0-f68.google.com with SMTP id 20so21803300wmh.3
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 02:15:24 -0700 (PDT)
In-Reply-To: <755ee9ec1f6d2229be41806964b372548e4b7586.1459382574.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2016, 02:13 AM, Daniel Borkmann wrote:
> Sasha Levin reported a suspicious rcu_dereference_protected() warning
> found while fuzzing with trinity that is similar to this one:
> 
>   [   52.765684] net/core/filter.c:2262 suspicious rcu_dereference_protected() usage!
>   [   52.765688] other info that might help us debug this:
>   [   52.765695] rcu_scheduler_active = 1, debug_locks = 1
>   [   52.765701] 1 lock held by a.out/1525:
>   [   52.765704]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816a64b7>] rtnl_lock+0x17/0x20
>   [   52.765721] stack backtrace:
>   [   52.765728] CPU: 1 PID: 1525 Comm: a.out Not tainted 4.5.0+ #264
>   [...]
>   [   52.765768] Call Trace:
>   [   52.765775]  [<ffffffff813e488d>] dump_stack+0x85/0xc8
>   [   52.765784]  [<ffffffff810f2fa5>] lockdep_rcu_suspicious+0xd5/0x110
>   [   52.765792]  [<ffffffff816afdc2>] sk_detach_filter+0x82/0x90
>   [   52.765801]  [<ffffffffa0883425>] tun_detach_filter+0x35/0x90 [tun]
>   [   52.765810]  [<ffffffffa0884ed4>] __tun_chr_ioctl+0x354/0x1130 [tun]
>   [   52.765818]  [<ffffffff8136fed0>] ? selinux_file_ioctl+0x130/0x210
>   [   52.765827]  [<ffffffffa0885ce3>] tun_chr_ioctl+0x13/0x20 [tun]
>   [   52.765834]  [<ffffffff81260ea6>] do_vfs_ioctl+0x96/0x690
>   [   52.765843]  [<ffffffff81364af3>] ? security_file_ioctl+0x43/0x60
>   [   52.765850]  [<ffffffff81261519>] SyS_ioctl+0x79/0x90
>   [   52.765858]  [<ffffffff81003ba2>] do_syscall_64+0x62/0x140
>   [   52.765866]  [<ffffffff817d563f>] entry_SYSCALL64_slow_path+0x25/0x25
> 
> Same can be triggered with PROVE_RCU (+ PROVE_RCU_REPEATEDLY) enabled
> from tun_attach_filter() when user space calls ioctl(tun_fd, TUN{ATTACH,
> DETACH}FILTER, ...) for adding/removing a BPF filter on tap devices.
> 
> Since the fix in f91ff5b9ff52 ("net: sk_{detach|attach}_filter() rcu
> fixes") sk_attach_filter()/sk_detach_filter() now dereferences the
> filter with rcu_dereference_protected(), checking whether socket lock
> is held in control path.
> 
> Since its introduction in 994051625981 ("tun: socket filter support"),
> tap filters are managed under RTNL lock from __tun_chr_ioctl(). Thus the
> sock_owned_by_user(sk) doesn't apply in this specific case and therefore
> triggers the false positive.
> 
> Extend the BPF API with __sk_attach_filter()/__sk_detach_filter() pair
> that is used by tap filters and pass in lockdep_rtnl_is_held() for the
> rcu_dereference_protected() checks instead.

It seems to be gone with this patch here.

thanks,
-- 
js
suse labs
