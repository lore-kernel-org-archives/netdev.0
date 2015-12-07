From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: (4.3.0) r8152: deadlock related to runtime suspend?
Date: Mon, 7 Dec 2015 10:37:55 +0100
Message-ID: <20151207093755.GA4283@al>
References: <20151205105912.GA1766@al>
 <56654D56.3080402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, hayeswang@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lu Baolu <baolu.lu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56654D56.3080402@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 05:11:50PM +0800, Lu Baolu wrote:
> Hi Peter,
> 
> Have you ever tried disabling auto-pm? Did things go smoothly if auto-pm is disabled?
> 
> I always disable usb auto-pm in below way.
> 
> # echo on | tee /sys/bus/usb/devices/*/power/control
> # echo on > /sys/bus/pci/devices/<bus_name>/power/control
> 
> Thanks,
> Baolu

Hi Baolu,

The deadlock does not seem to occur with auto-PM disabled, but that is a
workaround for the issue. The hang can always be reproduced under this
test:

 - Start a QEMU VM, passing through the USB adapter
 - This VM boots to a busybox shell with no other services running or
   udev magic (to reduce interference).
 - Enable runtime PM for all devices by default (see script below)
 - From the console, invoke "ip link set eth1 up" (eth0 is a virtio
   adapter).

    # somewhere in /init after mounting filesystems
    echo /sbin/hotplug > /proc/sys/kernel/hotplug
    echo auto | tee  /sys/bus/pci/devices/*/power/control \
        /sys/bus/usb/devices/*/power/control >/dev/null

    #!/bin/sh
    # /sbin/hotplug
    path="/sys/$DEVPATH/power/control"
    [ -e "$path" ] || return
    newval=auto
    read status < "$path"
    if [ "x$status" != "x$newval" ]; then
        echo "$DEVPATH: $status -> $newval" >/dev/kmsg
        echo $newval > "$path"
    fi

With "auto", the ip command hangs (a trace can be found on the bottom of
this mail). With "on", it does not.

If I keep a loop spinning that invokes `ethtool eth1`, the command
returns immediately without issues (presumably because the device is not
suspended through runtime PM).

Under some circumstances I get a lockdep warning (when trying to bring
an interface down if I remember correctly). Its trace can be found on
the bottom of this mail.

I'll keep testing. For the lockdep warning, my initial guess is that
calling schedule_delayed_work_sync under tp->lock is a bad idea because
scheduled work can execute and try to claim tp->lock too.

Maybe there are two different lockup cases here, I'll keep testing.

Kind regards,
Peter

> On 12/05/2015 06:59 PM, Peter Wu wrote:
> > Hi,
> >
> > I rarely use a Realtek USB 3.0 Gigabit Ethernet adapter (vid/pid
> > 0bda:8153), but when I did last night, it resulted in a lockup of
> > processes doing networking ("ip link", "ping", "ethtool", ...).
> >
> > A (few) minute(s) before that event, I noticed that there was no network
> > connectivity (ping hung) which was somehow solved by invoking "ethtool
> > eth1" (triggering runtime pm wakeup?). This same trick did not work at
> > the next event. Invoking "ethtool eth1", "ip link", etc. hung completely
> > and interrupt (^C) did not work at all.
> >
> > Since that did not work, I pulled the USB adapter and re-inserted it,
> > hoping it would reset things. That did not work at all, there was a
> > "usb disconnect" message, but no further driver messages.
> >
> > Fast forward an hour, and it has become a disaster. I have terminated
> > and killed many programs via SysRq but am still unable to get a stable
> > system that does not hang on network I/O. Even the suspend process
> > fails so in the end I attempted to shutdown the system. After half an
> > hour after getting the poweroff message, I issued SysRq + B to reboot
> > (since SysRq + O did not shut down either).
> >
> > Attached are logs with various various backtraces from SysRq and failed
> > suspend. Let me know if you need more information!
> >
> > By the way, often I have to rmmod xhci and re-insert it, otherwise
> > plugging it in does not result in a detection. A USB 2.0 port does not
> > have this problem (runtime PM is enabled for all devices). This is the
> > USB 3.0 port:
> >
> >     02:00.0 USB controller [0c03]: NEC Corporation uPD720200 USB 3.0
> >     Host Controller [1033:0194] (rev 03)
> 

-- 

lockdep splat from the bare machine:

    ======================================================
    [ INFO: possible circular locking dependency detected ]
    4.3.0-custom #1 Tainted: G           O   
    -------------------------------------------------------
    kworker/0:1/38 is trying to acquire lock:
     (&tp->control){+.+.+.}, at: [<ffffffffa05d3544>] rtl8152_resume+0x24/0x130 [r8152]

    but task is already holding lock:
     ((&(&tp->schedule)->work)){+.+.+.}, at: [<ffffffff8107819c>] process_one_work+0x15c/0x660

    which lock already depends on the new lock.


    the existing dependency chain (in reverse order) is:

    -> #1 ((&(&tp->schedule)->work)){+.+.+.}:

    [<ffffffff810b17d3>] lock_acquire+0xc3/0x1d0
           [<ffffffff8107751d>] flush_work+0x3d/0x290
           [<ffffffff810791ae>] __cancel_work_timer+0xfe/0x1c0
           [<ffffffff810792a3>] cancel_delayed_work_sync+0x13/0x20
           [<ffffffffa05d0dea>] rtl8152_set_speed+0x2a/0x260 [r8152]
           [<ffffffffa05d4a26>] rtl8152_open+0x396/0x4f0 [r8152]
           [<ffffffff81567ebf>] __dev_open+0xaf/0x120
           [<ffffffff815681ad>] __dev_change_flags+0x9d/0x160
           [<ffffffff81568299>] dev_change_flags+0x29/0x70
           [<ffffffff8157785a>] do_setlink+0x5ba/0xb00
           [<ffffffff81578469>] rtnl_newlink+0x5a9/0x8a0
           [<ffffffff81576bb4>] rtnetlink_rcv_msg+0x84/0x210
           [<ffffffff81599ab7>] netlink_rcv_skb+0x97/0xb0
           [<ffffffff81576b1a>] rtnetlink_rcv+0x2a/0x40
           [<ffffffff8159943e>] netlink_unicast+0x1be/0x2d0
           [<ffffffff8159983b>] netlink_sendmsg+0x2eb/0x3a0
           [<ffffffff81545428>] sock_sendmsg+0x38/0x50
           [<ffffffff81545d42>] ___sys_sendmsg+0x292/0x2a0
           [<ffffffff81546cc2>] __sys_sendmsg+0x42/0x80
           [<ffffffff81546d12>] SyS_sendmsg+0x12/0x20
           [<ffffffff816707d7>] entry_SYSCALL_64_fastpath+0x12/0x6f

    -> #0 (&tp->control){+.+.+.}:
           [<ffffffff810b0ed7>] __lock_acquire+0x1a47/0x1a50
           [<ffffffff810b17d3>] lock_acquire+0xc3/0x1d0
           [<ffffffff8166c0a7>] mutex_lock_nested+0x67/0x3c0
           [<ffffffffa05d3544>] rtl8152_resume+0x24/0x130 [r8152]
           [<ffffffff814d735f>] usb_resume_interface.isra.6+0x9f/0x100
           [<ffffffff814d75fa>] usb_resume_both+0x6a/0x130
           [<ffffffff814d869a>] usb_runtime_resume+0x1a/0x20
           [<ffffffff814602c2>] __rpm_callback+0x32/0x70
           [<ffffffff8146035f>] rpm_callback+0x5f/0x80
           [<ffffffff81460c4b>] rpm_resume+0x4db/0x7d0
           [<ffffffff81460b0c>] rpm_resume+0x39c/0x7d0
           [<ffffffff8146211e>] __pm_runtime_resume+0x4e/0x80
           [<ffffffff814d7112>] usb_autopm_get_interface+0x22/0x60
           [<ffffffffa05d4cf0>] rtl_work_func_t+0x40/0x3ee [r8152]
           [<ffffffff8107822d>] process_one_work+0x1ed/0x660
           [<ffffffff810786ee>] worker_thread+0x4e/0x450
           [<ffffffff8107f13f>] kthread+0xef/0x110
           [<ffffffff81670b4f>] ret_from_fork+0x3f/0x70

    other info that might help us debug this:

     Possible unsafe locking scenario:

           CPU0                    CPU1
           ----                    ----
      lock((&(&tp->schedule)->work));
                                   lock(&tp->control);
                                   lock((&(&tp->schedule)->work));
      lock(&tp->control);

     *** DEADLOCK ***

    2 locks held by kworker/0:1/38:
     #0:  ("events"){.+.+.+}, at: [<ffffffff8107819c>] process_one_work+0x15c/0x660
     #1:  ((&(&tp->schedule)->work)){+.+.+.}, at: [<ffffffff8107819c>] process_one_work+0x15c/0x660

    stack backtrace:
    CPU: 0 PID: 38 Comm: kworker/0:1 Tainted: G           O    4.3.0-custom #1
    Hardware name: CLEVO CO.                        B7130                           /B7130                           , BIOS 6.00 08/27/2010
    Workqueue: events rtl_work_func_t [r8152]
     ffffffff8264d7d0 ffff8802321ff950 ffffffff8134cdac ffffffff8264d7d0
     ffff8802321ff990 ffffffff810adbb3 ffff8802321ff9e0 ffff8802320e50b8
     0000000000000002 0000000000000001 ffff8802320e50e0 ffff8802320e4880
    Call Trace:
     [<ffffffff8134cdac>] dump_stack+0x4e/0x82
     [<ffffffff810adbb3>] print_circular_bug+0x1e3/0x250
     [<ffffffff810b0ed7>] __lock_acquire+0x1a47/0x1a50
     [<ffffffff810c505d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
     [<ffffffff810b17d3>] lock_acquire+0xc3/0x1d0
     [<ffffffffa05d3544>] ? rtl8152_resume+0x24/0x130 [r8152]
     [<ffffffffa05d3544>] ? rtl8152_resume+0x24/0x130 [r8152]
     [<ffffffff8166c0a7>] mutex_lock_nested+0x67/0x3c0
     [<ffffffffa05d3544>] ? rtl8152_resume+0x24/0x130 [r8152]
     [<ffffffff8166d7be>] ? mutex_unlock+0xe/0x10
     [<ffffffff814d8680>] ? usb_runtime_suspend+0x70/0x70
     [<ffffffffa05d3544>] rtl8152_resume+0x24/0x130 [r8152]
     [<ffffffff814d735f>] usb_resume_interface.isra.6+0x9f/0x100
     [<ffffffff814d75fa>] usb_resume_both+0x6a/0x130
     [<ffffffff814d869a>] usb_runtime_resume+0x1a/0x20
     [<ffffffff814602c2>] __rpm_callback+0x32/0x70
     [<ffffffff8146035f>] rpm_callback+0x5f/0x80
     [<ffffffff814d8680>] ? usb_runtime_suspend+0x70/0x70
     [<ffffffff81460c4b>] rpm_resume+0x4db/0x7d0
     [<ffffffff81460b0c>] rpm_resume+0x39c/0x7d0
     [<ffffffff8146211e>] __pm_runtime_resume+0x4e/0x80
     [<ffffffff814d7112>] usb_autopm_get_interface+0x22/0x60
     [<ffffffffa05d4cf0>] rtl_work_func_t+0x40/0x3ee [r8152]
     [<ffffffff8107822d>] process_one_work+0x1ed/0x660
     [<ffffffff8107819c>] ? process_one_work+0x15c/0x660
     [<ffffffff810786ee>] worker_thread+0x4e/0x450
     [<ffffffff810786a0>] ? process_one_work+0x660/0x660
     [<ffffffff8107f13f>] kthread+0xef/0x110
     [<ffffffff8107f050>] ? kthread_create_on_node+0x200/0x200
     [<ffffffff81670b4f>] ret_from_fork+0x3f/0x70
     [<ffffffff8107f050>] ? kthread_create_on_node+0x200/0x200

Hung task message in the VM after "ip link set eth1 up"

    INFO: task kworker/1:1:27 blocked for more than 60 seconds.
          Not tainted 4.4.0-rc3-rtlwifi+ #9
    "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
    kworker/1:1     D ffff88000de8bca0     0    27      2 0x00000000
    Workqueue: events linkwatch_event
     ffff88000de8bca0 ffff88000de78808 000000000de8bc98 ffff88000dcd0000
     ffff88000de78000 ffff88000de8c000 0000000000000246 ffffffff81ceb428
     ffff88000de78000 00000000ffffffff ffff88000de8bcb8 ffffffff8173a23c
    Call Trace:
     [<ffffffff8173a23c>] schedule+0x3c/0x90
     [<ffffffff8173a2a5>] schedule_preempt_disabled+0x15/0x20
     [<ffffffff8173b9dc>] mutex_lock_nested+0x16c/0x390
     [<ffffffff815c9cd7>] ? rtnl_lock+0x17/0x20
     [<ffffffff815c9cd7>] ? rtnl_lock+0x17/0x20
     [<ffffffff815c9cd7>] rtnl_lock+0x17/0x20
     [<ffffffff815cd80e>] linkwatch_event+0xe/0x30
     [<ffffffff810c22f7>] process_one_work+0x1f7/0x640
     [<ffffffff810c226c>] ? process_one_work+0x16c/0x640
     [<ffffffff810c278e>] worker_thread+0x4e/0x450
     [<ffffffff810c2740>] ? process_one_work+0x640/0x640
     [<ffffffff810c2740>] ? process_one_work+0x640/0x640
     [<ffffffff810c97c2>] kthread+0xf2/0x110
     [<ffffffff810c96d0>] ? __kthread_parkme+0x90/0x90
     [<ffffffff81740bbf>] ret_from_fork+0x3f/0x70
     [<ffffffff810c96d0>] ? __kthread_parkme+0x90/0x90
    3 locks held by kworker/1:1/27:
     #0:  ("events"){.+.+.+}, at: [<ffffffff810c226c>] process_one_work+0x16c/0x640
     #1:  ((linkwatch_work).work){+.+...}, at: [<ffffffff810c226c>] process_one_work+0x16c/0x640
     #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff815c9cd7>] rtnl_lock+0x17/0x20
