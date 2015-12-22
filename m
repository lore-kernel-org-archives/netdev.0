From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: suspicious RCU usage (netlink/rhashtable)
Date: Tue, 22 Dec 2015 15:51:19 -0500
Message-ID: <CAEfhGiwEhWqwtbAhbaVCEohePUyUC+f-Ap6b4oHk1Mdkg+ZKUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	David Miller <davem@davemloft.net>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35509 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782AbbLVUvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:51:22 -0500
Received: by mail-lf0-f65.google.com with SMTP id z124so13517795lfa.2
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 12:51:21 -0800 (PST)
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com. [209.85.217.172])
        by smtp.gmail.com with ESMTPSA id h82sm6024747lfh.27.2015.12.22.12.51.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 12:51:19 -0800 (PST)
Received: by mail-lb0-f172.google.com with SMTP id sv6so30432280lbb.0
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 12:51:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 3:45 PM, Dave Jones <davej@codemonkey.org.uk> wrote:
> ===============================
> [ INFO: suspicious RCU usage. ]
> 4.4.0-rc6-think+ #1 Not tainted
> -------------------------------
> lib/rhashtable.c:522 suspicious rcu_dereference_protected() usage!
>
> other info that might help us debug this:
>
>
> rcu_scheduler_active = 1, debug_locks = 0
> 2 locks held by trinity-c1/3652:
>  #0:  (&p->lock){+.+.+.}, at: [<ffffffff9a3335a7>] seq_read+0xd7/0x900
>  #1:  (&(&ht->lock)->rlock){+.+...}, at: [<ffffffff9a56f29d>] rhashtable_walk_init+0x9d/0x170
>
> stack backtrace:
> CPU: 0 PID: 3652 Comm: trinity-c1 Not tainted 4.4.0-rc6-think+ #1
>  ffffffff9af6ac60 000000003fc014d4 ffff8800cff779e0 ffffffff9a548da1
>  ffff880459b8b700 ffff8800cff77a10 ffffffff9a131068 ffff8800cdd32c48
>  ffff880464af8000 ffff8800cdd32c58 ffff880464af8160 ffff8800cff77a48
> Call Trace:
>  [<ffffffff9a548da1>] dump_stack+0x4e/0x7d
>  [<ffffffff9a131068>] lockdep_rcu_suspicious+0xf8/0x110
>  [<ffffffff9a56f363>] rhashtable_walk_init+0x163/0x170
>  [<ffffffff9ab54399>] netlink_walk_start+0x49/0x90
>  [<ffffffff9ab54ad0>] netlink_seq_start+0x40/0x90
>  [<ffffffff9a33368f>] seq_read+0x1bf/0x900
>  [<ffffffff9a3334d0>] ? seq_lseek+0x1b0/0x1b0
>  [<ffffffff9a2a37b0>] ? __might_fault+0xe0/0xf0
>  [<ffffffff9a2a3757>] ? __might_fault+0x87/0xf0
>  [<ffffffff9a2f91a9>] ? rw_copy_check_uvector+0x139/0x170
>  [<ffffffff9a3ab78f>] proc_reg_read+0x7f/0xc0
>  [<ffffffff9a2f6a70>] do_loop_readv_writev+0xe0/0x110
>  [<ffffffff9a3ab710>] ? proc_reg_write+0xc0/0xc0
>  [<ffffffff9a2f7c2b>] do_readv_writev+0x38b/0x3c0
>  [<ffffffff9a3ab710>] ? proc_reg_write+0xc0/0xc0
>  [<ffffffff9a2f78a0>] ? vfs_write+0x260/0x260
>  [<ffffffff9a12ecc5>] ? __lock_is_held+0x25/0xd0
>  [<ffffffff9a133d73>] ? mark_held_locks+0x23/0xc0
>  [<ffffffff9a25b1ba>] ? context_tracking_exit.part.5+0x2a/0x50
>  [<ffffffff9a133f96>] ? trace_hardirqs_on_caller+0x186/0x280
>  [<ffffffff9a13409d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff9a2f7cb6>] vfs_readv+0x56/0x70
>  [<ffffffff9a2f967d>] SyS_preadv+0x15d/0x180
>  [<ffffffff9a2f9520>] ? SyS_writev+0x1a0/0x1a0
>  [<ffffffff9a002017>] ? trace_hardirqs_on_thunk+0x17/0x19
>  [<ffffffff9aceb4d7>] entry_SYSCALL_64_fastpath+0x12/0x6b

I was actually just looking at this as well (though a slightly
different stack).  The issue is with: c6ff5268293e rhashtable: Fix
walker list corruption

It changed the lock acquired in rhashtable_walk_init to use the new
spinlock, but the rht_dereference macro expects the mutex.  I was
still trying to track down which repository this change came in
through, though...
