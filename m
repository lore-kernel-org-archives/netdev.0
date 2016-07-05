From: Mason <slash.tmp@free.fr>
Subject: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Tue, 5 Jul 2016 15:33:34 +0200
Message-ID: <577BB72E.3020904@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>
To: linux-pm <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I was testing suspend/resume sequences where the suspend operation
fails and returns without having suspended the platform.

# echo mem > /sys/power/state
[   90.322264] PM: Syncing filesystems ... done.
[   90.328758] Freezing user space processes ... (elapsed 0.001 seconds) done.
[   90.337092] Double checking all user space processes after OOM killer disable... (elapsed 0.000 seconds)
[   90.346765] Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
[   90.355357] Suspending console(s) (use no_console_suspend to debug)
[   90.364590] PM: suspend of devices complete after 2.068 msecs
[   90.365554] PM: late suspend of devices complete after 0.954 msecs
[   90.366223] PM: noirq suspend of devices complete after 0.662 msecs
[   90.366227] Disabling non-boot CPUs ...
[   90.379004] CPU1: shutdown
[   90.412661] Enabling non-boot CPUs ...
[   90.450385] CPU1 is up
[   90.450979] PM: noirq resume of devices complete after 0.584 msecs
[   90.451672] PM: early resume of devices complete after 0.667 msecs
[   90.453149] nb8800 26000.ethernet eth0: Link is Down
[   90.453264] PM: resume of devices complete after 1.583 msecs
[   90.508180] Restarting tasks ... done.
-sh: echo: write error: Input/output error
[   93.860411] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx

(The error message is expected, as my suspend routine returns -EIO
on failure.)

I left the system to idle at the prompt; then 5 minutes later,
the system printed the following trace.

[  400.718491] ------------[ cut here ]------------
[  400.723175] WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155 inet_sock_destruct+0x1c4/0x1dc
[  400.731582] Modules linked in:
[  400.734689] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.7.0-rc6-00010-gd07031bdc433 #1
[  400.742646] Hardware name: Sigma Tango DT
[  400.746671] Backtrace: 
[  400.749141] [<c010b974>] (dump_backtrace) from [<c010bb70>] (show_stack+0x18/0x1c)
[  400.756747]  r7:60000113 r6:c080ea84 r5:00000000 r4:c080ea84
[  400.762454] [<c010bb58>] (show_stack) from [<c02e9fe4>] (dump_stack+0x80/0x94)
[  400.769722] [<c02e9f64>] (dump_stack) from [<c011bfc8>] (__warn+0xec/0x104)
[  400.776717]  r7:00000009 r6:c05e3fbc r5:00000000 r4:00000000
[  400.782417] [<c011bedc>] (__warn) from [<c011c098>] (warn_slowpath_null+0x28/0x30)
[  400.790022]  r9:dfbdd4e0 r8:0000000a r7:c0801de8 r6:df6f9514 r5:df5df144 r4:df5df040
[  400.797825] [<c011c070>] (warn_slowpath_null) from [<c0463c04>] (inet_sock_destruct+0x1c4/0x1dc)
[  400.806661] [<c0463a40>] (inet_sock_destruct) from [<c03e9c60>] (__sk_destruct+0x28/0xe0)
[  400.814878]  r7:c0801de8 r6:df6f9514 r5:df5df040 r4:df5df1ec
[  400.820584] [<c03e9c38>] (__sk_destruct) from [<c016f230>] (rcu_process_callbacks+0x488/0x59c)
[  400.829237]  r5:00000000 r4:00000000
[  400.832836] [<c016eda8>] (rcu_process_callbacks) from [<c01207e4>] (__do_softirq+0x138/0x264)
[  400.841402]  r10:c08020a0 r9:40000001 r8:00000101 r7:c0800000 r6:c08020a4 r5:00000009
[  400.849285]  r4:00000000
[  400.851829] [<c01206ac>] (__do_softirq) from [<c0120c04>] (irq_exit+0xc8/0x104)
[  400.859172]  r10:c0801f10 r9:df402400 r8:00000001 r7:00000000 r6:00000013 r5:00000000
[  400.867053]  r4:c0735428
[  400.869601] [<c0120b3c>] (irq_exit) from [<c0162610>] (__handle_domain_irq+0x88/0xf4)
[  400.877473] [<c0162588>] (__handle_domain_irq) from [<c01014ac>] (gic_handle_irq+0x50/0x94)
[  400.885865]  r10:dfffcdc0 r9:e0803100 r8:e0802100 r7:c0801f10 r6:e080210c r5:c080277c
[  400.893747]  r4:c080eca0 r3:c0801f10
[  400.897342] [<c010145c>] (gic_handle_irq) from [<c010c694>] (__irq_svc+0x54/0x90)
[  400.904861] Exception stack(0xc0801f10 to 0xc0801f58)
[  400.909936] 1f00:                                     00000000 00000000 0000826a c0117c80
[  400.918156] 1f20: c0800000 c08024f8 c0802494 c081e2d6 c05b954c c07268c0 dfffcdc0 c0801f6c
[  400.926376] 1f40: c0801f70 c0801f60 c01086b0 c01086b4 60000013 ffffffff
[  400.933020]  r9:c07268c0 r8:c05b954c r7:c0801f44 r6:ffffffff r5:60000013 r4:c01086b4
[  400.940826] [<c0108674>] (arch_cpu_idle) from [<c0155f54>] (default_idle_call+0x28/0x34)
[  400.948960] [<c0155f2c>] (default_idle_call) from [<c0156088>] (cpu_startup_entry+0x128/0x17c)
[  400.957620] [<c0155f60>] (cpu_startup_entry) from [<c04a3f54>] (rest_init+0x8c/0x90)
[  400.965400]  r7:ffffffff r4:00000002
[  400.969005] [<c04a3ec8>] (rest_init) from [<c0700cb4>] (start_kernel+0x310/0x31c)
[  400.976522]  r5:c081e4c0 r4:00000001
[  400.980121] [<c07009a4>] (start_kernel) from [<8000807c>] (0x8000807c)
[  400.986716] ---[ end trace f8deb50d1b3d3c7a ]---


Did I implement something incorrectly?

Regards.
