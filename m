From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netfilter: x_tables: fix kmemcheck warning.
Date: Sun, 24 Jul 2016 13:19:47 +0300
Message-ID: <f9ae7858-2796-9193-a01c-8129f92a31b0@cogentembedded.com>
References: <1469327475-9028-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:36413 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbcGXKTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 06:19:51 -0400
Received: by mail-lf0-f43.google.com with SMTP id g62so111187353lfe.3
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 03:19:50 -0700 (PDT)
In-Reply-To: <1469327475-9028-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/24/2016 5:31 AM, Tetsuo Handa wrote:

> kmemcheck complains that some of struct nf_hook_ops members allocated at
> xt_hook_ops_alloc() are not initialized before nf_register_net_hook() is
> called. Add __GFP_ZERO to initialize explicitly.
>
> [  367.411936] nf_conntrack version 0.5.0 (6144 buckets, 24576 max)
> [  367.458540] ip_tables: (C) 2000-2006 Netfilter Core Team
> [  367.463977] WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88003af7f300)
> [  367.465633] 00000000000000000000000000000000303f5381ffffffff0000000000000000
> [  367.468185]  u u u u u u u u u u u u u u u u i i i i i i i i u u u u u u u u
> [  367.470687]  ^
> [  367.471079] RIP: 0010:[<ffffffff814caa0f>]  [<ffffffff814caa0f>] nf_register_net_hook+0x2f/0x160
> [  367.472846] RSP: 0018:ffff88003f5abcb0  EFLAGS: 00010286
> [  367.473821] RAX: ffff88003adb73c0 RBX: ffff88003af7f300 RCX: 0000000000000000
> [  367.475122] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88003adb7400
> [  367.476485] RBP: ffff88003f5abcc8 R08: 0000000000000067 R09: 0000000000000000
> [  367.477764] R10: ffff88003adb83c0 R11: 0000000000000000 R12: ffffffff81876760
> [  367.479053] R13: ffff88003adb73c0 R14: 0000000000000003 R15: ffff88003af7f300
> [  367.480351] FS:  0000000000000000(0000) GS:ffffffff8182c000(0000) knlGS:0000000000000000
> [  367.482018] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  367.483069] CR2: ffff88003f404280 CR3: 000000003ad30000 CR4: 00000000001406f0
> [  367.484357]  [<ffffffff814cadec>] nf_register_net_hooks+0x3c/0xa0
> [  367.485617]  [<ffffffff8153328f>] ipt_register_table+0xef/0x130
> [  367.486765]  [<ffffffff81533ec1>] iptable_filter_table_init.part.1+0x51/0x70
> [  367.488125]  [<ffffffff81533f2a>] iptable_filter_net_init+0x2a/0x30
> [  367.489375]  [<ffffffff8148f58c>] ops_init+0x3c/0x130
> [  367.490410]  [<ffffffff8148f8c8>] register_pernet_operations+0x108/0x1c0
> [  367.491746]  [<ffffffff8148f9a3>] register_pernet_subsys+0x23/0x40
> [  367.492933]  [<ffffffff818d5e25>] iptable_filter_init+0x33/0x4b
> [  367.494053]  [<ffffffff8100041a>] do_one_initcall+0x4a/0x180
> [  367.495168]  [<ffffffff818981d0>] kernel_init_freeable+0x15b/0x201
> [  367.496332]  [<ffffffff8159eff9>] kernel_init+0x9/0x100
> [  367.497369]  [<ffffffff815a9c0f>] ret_from_fork+0x1f/0x40
> [  367.498449]  [<ffffffffffffffff>] 0xffffffffffffffff
> [  367.499523] Initializing XFRM netlink socket
> [  367.500404] NET: Registered protocol family 10
> [  367.501792] ip6_tables: (C) 2000-2006 Netfilter Core Team
> [  367.502971] NET: Registered protocol family 17
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/netfilter/x_tables.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index e0aa7c1..fc261fe 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1513,7 +1513,7 @@ xt_hook_ops_alloc(const struct xt_table *table, nf_hookfn *fn)
>  	if (!num_hooks)
>  		return ERR_PTR(-EINVAL);
>
> -	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
> +	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL | __GFP_ZERO);

    Why not just use kzalloc() or even kcalloc()?

[...]

MBR, Sergei
