From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: hung task while plugging in cfg80211
Date: Thu, 25 Jul 2013 10:51:16 -0400
Message-ID: <20130725105116.043a6b9c@corrin.poochiereds.net>
References: <20130712074911.01b5945a@corrin.poochiereds.net>
	<20130724095911.GA1637@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>, rjones-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130724095911.GA1637-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Jul 2013 11:59:12 +0200
Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Fri, Jul 12, 2013 at 07:49:11AM -0400, Jeff Layton wrote:
> > I updated the kernel on my rawhide KVM guest, and noticed that the
> > ethernet interface wasn't coming up at all. While poking around, I saw
> > this stack trace pop up:
> > 
> > Jul 12 07:29:25 rawhide kernel: [  241.156196] INFO: task modprobe:501 blocked for more than 120 seconds.
> > Jul 12 07:29:25 rawhide kernel: [  241.157222] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > Jul 12 07:29:25 rawhide kernel: [  241.158379] modprobe        D ffff880118c526e0  4584   501    500 0x00000080
> > Jul 12 07:29:25 rawhide kernel: [  241.159458]  ffff8800d10c3ba8 0000000000000046 00000000001d5300 ffff8800d10c3fd8
> > Jul 12 07:29:25 rawhide kernel: [  241.160644]  ffff8800d10c3fd8 00000000001d5300 ffff8800d2ae4dc0 ffff8800d2ae4dc0
> > Jul 12 07:29:25 rawhide kernel: [  241.161875]  ffffffff81d0bfa0 ffffffff81d0bfa8 ffffffff00000000 ffffffff81d0bff0
> > Jul 12 07:29:25 rawhide kernel: [  241.163096] Call Trace:
> > Jul 12 07:29:25 rawhide kernel: [  241.163460]  [<ffffffff817377e9>] schedule+0x29/0x70
> > Jul 12 07:29:25 rawhide kernel: [  241.164235]  [<ffffffff817392ad>] rwsem_down_write_failed+0xed/0x1a0
> > Jul 12 07:29:25 rawhide kernel: [  241.165489]  [<ffffffff810bb600>] ? update_cpu_load_active+0xb0/0xb0
> > Jul 12 07:29:25 rawhide kernel: [  241.166267]  [<ffffffff8137d503>] call_rwsem_down_write_failed+0x13/0x20
> > Jul 12 07:29:25 rawhide kernel: [  241.166760]  [<ffffffff81736aad>] ? down_write+0x9d/0xb2
> > Jul 12 07:29:25 rawhide kernel: [  241.167189]  [<ffffffff8162d975>] ? genl_lock_all+0x15/0x30
> > Jul 12 07:29:25 rawhide kernel: [  241.167603]  [<ffffffff8162d975>] genl_lock_all+0x15/0x30
> 
> I reproduced that on qemu-kvm with rawhide LiveCD. Below more
> information gathered using sysrq:
> 
> (qemu) [ 2458.110724] SysRq : Show Locks Held
> [ 2458.111347] 
> [ 2458.111347] Showing all locks held in the system:
> [ 2458.111347] 1 lock held by NetworkManager/582:
> [ 2458.111347]  #0:  (cb_lock){++++++}, at: [<ffffffff8162bc79>] genl_rcv+0x19/0x40
> [ 2458.111347] 1 lock held by modprobe/603:
> [ 2458.111347]  #0:  (cb_lock){++++++}, at: [<ffffffff8162baa5>] genl_lock_all+0x15/0x30
> [ 2458.111347] 
> [ 2458.111347] =============================================
> [ 2458.111347] 
> 
> (qemu) sendkey alt-sysrq-w
> (qemu) [ 2461.579457] SysRq : Show Blocked State
> [ 2461.580103]   task                        PC stack   pid father
> [ 2461.580103] NetworkManager  D ffff880034b84500  4040   582      1 0x00000080
> [ 2461.580103]  ffff8800197ff720 0000000000000046 00000000001d5340 ffff8800197fffd8
> [ 2461.580103]  ffff8800197fffd8 00000000001d5340 ffff880019631700 7fffffffffffffff
> [ 2461.580103]  ffff8800197ff880 ffff8800197ff878 ffff880019631700 ffff880019631700
> [ 2461.580103] Call Trace:
> [ 2461.580103]  [<ffffffff817355f9>] schedule+0x29/0x70
> [ 2461.580103]  [<ffffffff81731ad1>] schedule_timeout+0x1c1/0x360
> [ 2461.580103]  [<ffffffff810e69eb>] ? mark_held_locks+0xbb/0x140
> [ 2461.580103]  [<ffffffff817377ac>] ? _raw_spin_unlock_irq+0x2c/0x50
> [ 2461.580103]  [<ffffffff810e6b6d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
> [ 2461.580103]  [<ffffffff81736398>] wait_for_completion_killable+0xe8/0x170
> [ 2461.580103]  [<ffffffff810b7fa0>] ? wake_up_state+0x20/0x20
> [ 2461.580103]  [<ffffffff81095825>] call_usermodehelper_exec+0x1a5/0x210
> [ 2461.580103]  [<ffffffff817362ed>] ? wait_for_completion_killable+0x3d/0x170
> [ 2461.580103]  [<ffffffff81095cc3>] __request_module+0x1b3/0x370
> [ 2461.580103]  [<ffffffff810e6b6d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
> [ 2461.580103]  [<ffffffff8162c5c9>] ctrl_getfamily+0x159/0x190
> [ 2461.580103]  [<ffffffff8162d8a4>] genl_family_rcv_msg+0x1f4/0x2e0
> [ 2461.580103]  [<ffffffff8162d990>] ? genl_family_rcv_msg+0x2e0/0x2e0
> [ 2461.580103]  [<ffffffff8162da1e>] genl_rcv_msg+0x8e/0xd0
> [ 2461.580103]  [<ffffffff8162b729>] netlink_rcv_skb+0xa9/0xc0
> [ 2461.580103]  [<ffffffff8162bc88>] genl_rcv+0x28/0x40
> [ 2461.580103]  [<ffffffff8162ad6d>] netlink_unicast+0xdd/0x190
> [ 2461.580103]  [<ffffffff8162b149>] netlink_sendmsg+0x329/0x750
> [ 2461.580103]  [<ffffffff815db849>] sock_sendmsg+0x99/0xd0
> [ 2461.580103]  [<ffffffff810bb58f>] ? local_clock+0x5f/0x70
> [ 2461.580103]  [<ffffffff810e96e8>] ? lock_release_non_nested+0x308/0x350
> [ 2461.580103]  [<ffffffff815dbc6e>] ___sys_sendmsg+0x39e/0x3b0
> [ 2461.580103]  [<ffffffff810565af>] ? kvm_clock_read+0x2f/0x50
> [ 2461.580103]  [<ffffffff810218b9>] ? sched_clock+0x9/0x10
> [ 2461.580103]  [<ffffffff810bb2bd>] ? sched_clock_local+0x1d/0x80
> [ 2461.580103]  [<ffffffff810bb448>] ? sched_clock_cpu+0xa8/0x100
> [ 2461.580103]  [<ffffffff810e33ad>] ? trace_hardirqs_off+0xd/0x10
> [ 2461.580103]  [<ffffffff810bb58f>] ? local_clock+0x5f/0x70
> [ 2461.580103]  [<ffffffff810e3f7f>] ? lock_release_holdtime.part.28+0xf/0x1a0
> [ 2461.580103]  [<ffffffff8120fec9>] ? fget_light+0xf9/0x510
> [ 2461.580103]  [<ffffffff8120fe0c>] ? fget_light+0x3c/0x510
> [ 2461.580103]  [<ffffffff815dd1d2>] __sys_sendmsg+0x42/0x80
> [ 2461.580103]  [<ffffffff815dd222>] SyS_sendmsg+0x12/0x20
> [ 2461.580103]  [<ffffffff81741ad9>] system_call_fastpath+0x16/0x1b
> [ 2461.580103] modprobe        D ffff88000f2c8000  4632   603    602 0x00000080
> [ 2461.580103]  ffff88000f04fba8 0000000000000046 00000000001d5340 ffff88000f04ffd8
> [ 2461.580103]  ffff88000f04ffd8 00000000001d5340 ffff8800377d4500 ffff8800377d4500
> [ 2461.580103]  ffffffff81d0b260 ffffffff81d0b268 ffffffff00000000 ffffffff81d0b2b0
> [ 2461.580103] Call Trace:
> [ 2461.580103]  [<ffffffff817355f9>] schedule+0x29/0x70
> [ 2461.580103]  [<ffffffff81736d4d>] rwsem_down_write_failed+0xed/0x1a0
> [ 2461.580103]  [<ffffffff810bb200>] ? update_cpu_load_active+0x10/0xb0
> [ 2461.580103]  [<ffffffff8137b473>] call_rwsem_down_write_failed+0x13/0x20
> [ 2461.580103]  [<ffffffff8173492d>] ? down_write+0x9d/0xb2
> [ 2461.580103]  [<ffffffff8162baa5>] ? genl_lock_all+0x15/0x30
> [ 2461.580103]  [<ffffffff8162baa5>] genl_lock_all+0x15/0x30
> [ 2461.580103]  [<ffffffff8162cbb3>] genl_register_family+0x53/0x1f0
> [ 2461.580103]  [<ffffffffa01dc000>] ? 0xffffffffa01dbfff
> [ 2461.580103]  [<ffffffff8162d650>] genl_register_family_with_ops+0x20/0x80
> [ 2461.580103]  [<ffffffffa01dc000>] ? 0xffffffffa01dbfff
> [ 2461.580103]  [<ffffffffa017fe84>] nl80211_init+0x24/0xf0 [cfg80211]
> [ 2461.580103]  [<ffffffffa01dc000>] ? 0xffffffffa01dbfff
> [ 2461.580103]  [<ffffffffa01dc043>] cfg80211_init+0x43/0xdb [cfg80211]
> [ 2461.580103]  [<ffffffff810020fa>] do_one_initcall+0xfa/0x1b0
> [ 2461.580103]  [<ffffffff8105cb93>] ? set_memory_nx+0x43/0x50
> [ 2461.580103]  [<ffffffff810f75af>] load_module+0x1c6f/0x27f0
> [ 2461.580103]  [<ffffffff810f2c90>] ? store_uevent+0x40/0x40
> [ 2461.580103]  [<ffffffff810f82c6>] SyS_finit_module+0x86/0xb0
> [ 2461.580103]  [<ffffffff81741ad9>] system_call_fastpath+0x16/0x1b
> [ 2461.580103] Sched Debug Version: v0.10, 3.11.0-0.rc1.git4.1.fc20.x86_64 #1
> 
> So call user space to load cfg80211 module (alias
> net-pf-16-proto-16-family-nl80211) from ctrl_getfamily() with read taken
> cb_lock semaphore. That deadlock in modprobe process in
> genl_register_family() when try to down_write cb_lock.
> 
> This is consequence of commit:
> 
> commit fb4e156886ce6e8309e912d8b370d192330d19d3
> Author: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Date:   Sun Apr 28 16:22:06 2013 -0700
> 
>     nl80211: Add generic netlink module alias for cfg80211/nl80211
> 
> I prepared a possible fix for that (patch below), but I'm not sure if it
> do right thing, it can cause other oddity, please test (with
> CONFIG_LOCKDEP compiled). I think I would prefer rather remove
> autoloading genetlink modules from kernel or use just one lock
> in instead of two cb_lock & genl_mutex .
> 
> Stanislaw
> 
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 2fd6dbe..1076fe1 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -877,8 +877,10 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
>  #ifdef CONFIG_MODULES
>  		if (res == NULL) {
>  			genl_unlock();
> +			up_read(&cb_lock);
>  			request_module("net-pf-%d-proto-%d-family-%s",
>  				       PF_NETLINK, NETLINK_GENERIC, name);
> +			down_read(&cb_lock);
>  			genl_lock();
>  			res = genl_family_find_byname(name);
>  		}

The patch above fixes the problem for me. I'll leave it to others to
decide whether it's the best approach.

Thanks!
-- 
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
