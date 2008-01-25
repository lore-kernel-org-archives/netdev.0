From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: bluetooth : lockdep warning on rfcomm
Date: Fri, 25 Jan 2008 13:37:39 +0800
Message-ID: <a8e1da0801242137m64c9cb08m898b9eb1bfaaf710@mail.gmail.com>
References: <a8e1da0801231902x5ab7691bq5a30e839f6c8cb71@mail.gmail.com>
	<a8e1da0801240125x6c65a4bfva24ff50cef890eba@mail.gmail.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	David Miller <davem@davemloft.net>, bluez-devel@lists.sf.net
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a8e1da0801240125x6c65a4bfva24ff50cef890eba@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Jan 24, 2008 5:25 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
>
> On Jan 24, 2008 11:02 AM, Dave Young <hidave.darkstar@gmail.com> wrote:
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 2.6.24-rc8-mm1 #8
> > ---------------------------------------------
> > bluepush/3213 is trying to acquire lock:
> >  (sk_lock-AF_BLUETOOTH){--..}, at: [<f8978c80>]
> > l2cap_sock_bind+0x40/0x100 [l2cap]
> >
> > but task is already holding lock:
> >  (sk_lock-AF_BLUETOOTH){--..}, at: [<f894a31e>]
> > rfcomm_sock_connect+0x3e/0xe0 [rfcomm]
> >
> > other info that might help us debug this:
> > 2 locks held by bluepush/3213:
> >  #0:  (sk_lock-AF_BLUETOOTH){--..}, at: [<f894a31e>]
> > rfcomm_sock_connect+0x3e/0xe0 [rfcomm]
> >  #1:  (rfcomm_mutex){--..}, at: [<f8947556>] rfcomm_dlc_open+0x26/0x60 [rfcomm]
> >
> > stack backtrace:
> > Pid: 3213, comm: bluepush Not tainted 2.6.24-rc8-mm1 #8
> >  [<c0132128>] ? printk+0x18/0x20
> >  [<c0154437>] print_deadlock_bug+0xc7/0xe0
> >  [<c01544bc>] check_deadlock+0x6c/0x80
> >  [<c01548fc>] validate_chain+0x14c/0x320
> >  [<c0156221>] __lock_acquire+0x1c1/0x730
> >  [<c0156d89>] lock_acquire+0x79/0xb0
> >  [<f8978c80>] ? l2cap_sock_bind+0x40/0x100 [l2cap]
> >  [<c03c05f5>] lock_sock_nested+0x55/0x70
> >  [<f8978c80>] ? l2cap_sock_bind+0x40/0x100 [l2cap]
> >  [<f8978c80>] l2cap_sock_bind+0x40/0x100 [l2cap]
> >  [<c03bdb4a>] kernel_bind+0xa/0x10
> >  [<f8947afc>] rfcomm_session_create+0x4c/0x110 [rfcomm]
> >  [<f8947509>] __rfcomm_dlc_open+0x129/0x150 [rfcomm]
> >  [<f8947568>] rfcomm_dlc_open+0x38/0x60 [rfcomm]
> >  [<f894a396>] rfcomm_sock_connect+0xb6/0xe0 [rfcomm]
> >  [<c03bcd39>] sys_connect+0x99/0xd0
> >  [<c010f509>] ? cache_add_dev+0x39/0x1a0
> >  [<c015323d>] ? put_lock_stats+0xd/0x30
> >  [<c01532c0>] ? lock_release_holdtime+0x60/0x80
> >  [<c018e86c>] ? fget+0x7c/0x100
> >  [<c0156b97>] ? __lock_release+0x47/0x70
> >  [<c018e86c>] ? fget+0x7c/0x100
> >  [<c02611b7>] ? copy_from_user+0x37/0x70
> >  [<c03bd855>] sys_socketcall+0xa5/0x230
> >  [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
> >  [<c010501b>] ? restore_nocheck+0x12/0x15
> >
>
> While fixing this issue, another locking dependency confused me. Are
> rfcomm_dev_lock and &d->lock in same lock class?
>
> The warnings as following:
>
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.24-rc8-mm1 #8
> -------------------------------------------------------
> krfcommd/2912 is trying to acquire lock:
>  (rfcomm_dev_lock){-.--}, at: [<f89d5bf2>]
> rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>
> but task is already holding lock:
>  (&d->lock){--..}, at: [<f89d15d3>] __rfcomm_dlc_close+0x43/0xd0 [rfcomm]
>
> which lock already depends on the new lock.

Answer to myself, the reason is that lockdep think this as a lock order problem.

in rfcomm_device_add the lock order is :
        rfcomm_dev_lock --> dlc lock
but in __rfcomm_dlc_close is :
        dlc lock --> rfcomm_dev_lock (-> state_change->rfcomm_dev_get)

>
>
> the existing dependency chain (in reverse order) is:
>
> -> #1 (&d->lock){--..}:
>        [<c0153b13>] add_lock_to_list+0x33/0x70
>        [<c01545a3>] check_prev_add+0xd3/0x200
>        [<f89d5311>] rfcomm_dev_add+0x191/0x300 [rfcomm]
>        [<c0154765>] check_prevs_add+0x95/0xe0
>        [<c01549ef>] validate_chain+0x23f/0x320
>        [<c0156221>] __lock_acquire+0x1c1/0x730
>        [<c0155539>] mark_held_locks+0x39/0x80
>        [<c0156d89>] lock_acquire+0x79/0xb0
>        [<f89d5311>] rfcomm_dev_add+0x191/0x300 [rfcomm]
>        [<c0436749>] _spin_lock+0x39/0x80
>        [<f89d5311>] rfcomm_dev_add+0x191/0x300 [rfcomm]
>        [<f89d5b10>] rfcomm_dev_data_ready+0x0/0x50 [rfcomm]
>        [<f89d5311>] rfcomm_dev_add+0x191/0x300 [rfcomm]
>        [<f89d565e>] rfcomm_create_dev+0x6e/0x100 [rfcomm]
>        [<c03c05fa>] lock_sock_nested+0x5a/0x70
>        [<f89d5ae3>] rfcomm_dev_ioctl+0x33/0x60 [rfcomm]
>        [<f89d4c8c>] rfcomm_sock_ioctl+0x2c/0x50 [rfcomm]
>        [<c03bc001>] sock_ioctl+0xc1/0x220
>        [<c03bbf40>] sock_ioctl+0x0/0x220
>        [<c019a366>] vfs_ioctl+0x76/0x90
>        [<c019a616>] do_vfs_ioctl+0x56/0x140
>        [<c019a762>] sys_ioctl+0x62/0x70
>        [<c0104fba>] syscall_call+0x7/0xb
>        [<ffffffff>] 0xffffffff
>
> -> #0 (rfcomm_dev_lock){-.--}:
>        [<c0154504>] check_prev_add+0x34/0x200
>        [<c012a9ab>] default_wake_function+0xb/0x10
>        [<c0154765>] check_prevs_add+0x95/0xe0
>        [<c01549ef>] validate_chain+0x23f/0x320
>        [<c0156221>] __lock_acquire+0x1c1/0x730
>        [<c0156d89>] lock_acquire+0x79/0xb0
>        [<f89d5bf2>] rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>        [<c04361e9>] _read_lock+0x39/0x80
>        [<f89d5bf2>] rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>        [<f89d5bf2>] rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>        [<f89d15e8>] __rfcomm_dlc_close+0x58/0xd0 [rfcomm]
>        [<f89d2523>] rfcomm_recv_ua+0x73/0x140 [rfcomm]
>        [<f89d3151>] rfcomm_recv_frame+0x171/0x1e0 [rfcomm]
>        [<c0155659>] trace_hardirqs_on+0xb9/0x130
>        [<c0436a39>] _spin_unlock_irqrestore+0x39/0x70
>        [<f89d3447>] rfcomm_run+0xe7/0x590 [rfcomm]
>        [<c0120000>] hpet_legacy_next_event+0x20/0x50
>        [<f89d3360>] rfcomm_run+0x0/0x590 [rfcomm]
>        [<c0146e0c>] kthread+0x5c/0xa0
>        [<c0146db0>] kthread+0x0/0xa0
>        [<c0105c17>] kernel_thread_helper+0x7/0x10
>        [<ffffffff>] 0xffffffff
>
> other info that might help us debug this:
>
> 2 locks held by krfcommd/2912:
>  #0:  (rfcomm_mutex){--..}, at: [<f89d33db>] rfcomm_run+0x7b/0x590 [rfcomm]
>  #1:  (&d->lock){--..}, at: [<f89d15d3>] __rfcomm_dlc_close+0x43/0xd0 [rfcomm]
>
> stack backtrace:
> Pid: 2912, comm: krfcommd Not tainted 2.6.24-rc8-mm1 #8
>  [<c0132128>] ? printk+0x18/0x20
>  [<c0153cff>] print_circular_bug_tail+0x6f/0x80
>  [<c0154504>] check_prev_add+0x34/0x200
>  [<c012a9ab>] ? default_wake_function+0xb/0x10
>  [<c0154765>] check_prevs_add+0x95/0xe0
>  [<c01549ef>] validate_chain+0x23f/0x320
>  [<c0156221>] __lock_acquire+0x1c1/0x730
>  [<c0156d89>] lock_acquire+0x79/0xb0
>  [<f89d5bf2>] ? rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>  [<c04361e9>] _read_lock+0x39/0x80
>  [<f89d5bf2>] ? rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>  [<f89d5bf2>] rfcomm_dev_state_change+0x92/0x160 [rfcomm]
>  [<f89d15e8>] __rfcomm_dlc_close+0x58/0xd0 [rfcomm]
>  [<f89d2523>] rfcomm_recv_ua+0x73/0x140 [rfcomm]
>  [<f89d3151>] rfcomm_recv_frame+0x171/0x1e0 [rfcomm]
>  [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
>  [<c0436a39>] ? _spin_unlock_irqrestore+0x39/0x70
>  [<f89d3447>] rfcomm_run+0xe7/0x590 [rfcomm]
>  [<c0120000>] ? hpet_legacy_next_event+0x20/0x50
>  [<f89d3360>] ? rfcomm_run+0x0/0x590 [rfcomm]
>  [<c0146e0c>] kthread+0x5c/0xa0
>  [<c0146db0>] ? kthread+0x0/0xa0
>  [<c0105c17>] kernel_thread_helper+0x7/0x10
>  =======================
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
