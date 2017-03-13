From: Petr Vorel <petr.vorel@gmail.com>
Subject: Re: [PATCH 1/1] r8152: fix NULL pointer dereference in r8152_poll
Date: Mon, 13 Mar 2017 22:57:14 +0100
Message-ID: <20170313215714.n2p6j4nxtpxbheaj@dell5510>
References: <20170313124727.4681-1-petr.vorel@gmail.com>
 <1489411084.28631.78.camel@edumazet-glaptop3.roam.corp.google.com>
 <1489411184.28631.80.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170313153745.wu7cf254obh2x2gn@dell5510>
 <1489419849.28631.85.camel@edumazet-glaptop3.roam.corp.google.com>
 <1489420001.28631.87.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: Petr Vorel <petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36119 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdCMV5S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 17:57:18 -0400
Received: by mail-wr0-f194.google.com with SMTP id l37so21685204wrc.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 14:57:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489420001.28631.87.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Unfortunately this doesn't work. Code in r8152.c doesn't use
> > > local_bh_enable()/local_bh_disable(). I tried to lock it with
> > > spin_lock_bh()/spin_unlock_bh() and with mutex_lock()/mutex_unlock()
> > > but neither work.

> > The local_bh_disable() / local_bh_enable() definitely is the right
> > answer to the issue you described.

> > It does not matter what code in r8152.c currently does.

> > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=8cf699ec849f4ca1413cea01289bd7d37dbcc626


> You also have to protect other napi_schedule(), like the ones in
> rtl_work_func_t() or rtl8152_post_reset()

I've tested that before :-). I'll be more precise what "not working" means: it fixes
invalid pointer issue, but kernel crashes for different reason:

 ...
Call Trace:
 <IRQ>
 net_rx_action+0x23c/0x3f0
 __do_softirq+0x104/0x2e1
 ? usb_runtime_suspend+0x70/0x70 [usbcore]
 do_softirq_own_stack+8x1c/0x30
 </IRQ>
 do_softirq.part.18+0x41/0x50
 __local_bh_enable_ip+0x88/0xa0
 rtl8152_resume+0xe2/0x1a0 [r8152]
 usb_resume_interface.isra.60x99/0xf0 [usbcore]
 usb_resume_both+0x6a/0x130 [usbcore]
 __rpm_callback+0xb9/0x1f0
 rpm_callback+Ox5f/0x80
 ? usb_runtime_suspend+0x70/0x70 [usbcore]
 usb_resume+0x495/0x6b0
 ? update_load_avg+Ox79/0x520
 ? update_load_avg+Ox79/0x520
 ? refcount_dec_and_test+0x11/0x20
 __pm_runtime_resume+0x3f/0x60
 usb_autoresume_device+0x23/0x50 [usbcore]
 usb_dev_open+0xe7/0x250 [usbcore]
 chrdev_open+0xa1/0x200
 do_dentry_open+0x20a/0x2f0
 ? cdev_put+0x30/0x30
 vfs_open+0x4c/0x70
 ? may_open+0x9b/0x100
 path_openat+0x5ec/0x1430
 do_filp_open+0x7e/0xe0
 ? __vfs_write+0x28/0x140
 ? __alloc_fd+0xb2/0x160
 do_sys_open+0x123/0x200
 SyS_open+0x1e/0x20
 entry_SYSCALL_64_fastpath+0x1e/0xad
 ...
 Kernel panic - not syncing: Fatal exception in interrupt
 ...

Patch: http://pastebin.com/Uejjc0Bh (I don't post patch here, as it's not working).


Kind regards,
Petr
