From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: order 7 allocations from xt_recent
Date: Thu, 03 Jan 2013 08:55:04 -0800
Message-ID: <1357232104.21409.25175.camel@edumazet-glaptop>
References: <20130103164315.GA18908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, h.reindl@thelounge.net,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:62769 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab3ACQzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 11:55:08 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so7051500dae.35
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 08:55:07 -0800 (PST)
In-Reply-To: <20130103164315.GA18908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 11:43 -0500, Dave Jones wrote:
> We had a report from a user that shows this code trying
> to do enormous allocations, which isn't going to work too well..
> 
> iptables: page allocation failure: order:7, mode:0xc0d0
> Pid: 2822, comm: iptables Not tainted 3.6.10-2.fc17.x86_64 #1
> Call Trace:
>  [<ffffffff8113130b>] warn_alloc_failed+0xeb/0x150
>  [<ffffffff81616576>] ? __alloc_pages_direct_compact+0x17e/0x190
>  [<ffffffff81135196>] __alloc_pages_nodemask+0x736/0x990
>  [<ffffffff811710e0>] alloc_pages_current+0xb0/0x120
>  [<ffffffff8113022a>] __get_free_pages+0x2a/0x80
>  [<ffffffff811786d9>] kmalloc_order_trace+0x39/0xb0
>  [<ffffffff8117ae3a>] __kmalloc+0x16a/0x1a0
>  [<ffffffff8118aa7c>] ? mem_cgroup_bad_page_check+0x1c/0x30
>  [<ffffffff81134563>] ? get_page_from_freelist+0x453/0x950
>  [<ffffffffa007696e>] recent_mt_check.isra.6+0x16e/0x2c0 [xt_recent]
>  [<ffffffffa0076b4b>] recent_mt_check_v0+0x6b/0xa0 [xt_recent]
>  [<ffffffff8153fdda>] xt_check_match+0xaa/0x1e0
>  [<ffffffff8153f3ab>] ? xt_find_match+0x11b/0x130
>  [<ffffffff8153f3ab>] ? xt_find_match+0x11b/0x130
>  [<ffffffff8159257c>] check_match+0x3c/0x50
>  [<ffffffff81593ccb>] translate_table+0x39b/0x5b0
>  [<ffffffff815956f3>] do_ipt_set_ctl+0x133/0x200
>  [<ffffffff8153e10b>] nf_setsockopt+0x6b/0x90
>  [<ffffffff8161f236>] ? _raw_spin_lock_bh+0x16/0x40
>  [<ffffffff8154e41f>] ip_setsockopt+0x8f/0xa0
>  [<ffffffff8156f49d>] raw_setsockopt+0x1d/0x30
>  [<ffffffff814fcf14>] sock_common_setsockopt+0x14/0x20
>  [<ffffffff814fc23c>] sys_setsockopt+0x7c/0xe0
>  [<ffffffff816270e9>] system_call_fastpath+0x16/0x1b
> 
> which looks like it's this..
> 
>         t = kzalloc(sizeof(*t) + sizeof(t->iphash[0]) * ip_list_hash_size,
>                     GFP_KERNEL);
> 
> Which is initialised thus..
> 
>         ip_list_hash_size = 1 << fls(ip_list_tot);
> 
> And ip_list_tot is 10000 in this case. Hmm ?
> 
> 
> Complete report and setup described in his bug report at https://bugzilla.redhat.com/show_bug.cgi?id=890715
> 
> 	Dave
> 

Yes, we had a report and a patch :

http://comments.gmane.org/gmane.linux.network/248216

I'll send it in a more formal way.

Thanks
