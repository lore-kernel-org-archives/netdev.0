From: Joshua Emele <jemele@gmail.com>
Subject: Re: [PATCH net] sky2: Do not deadlock on sky2_hw_down
Date: Thu, 25 May 2017 13:21:58 -0700
Message-ID: <CALH_86T3YW=VOCACJ+659GxZQQLtVafRpUTqQagWUdcsPDPH=A@mail.gmail.com>
References: <20170524224353.124692-1-jemele@gmail.com> <20170525105458.539dedba@xeon-e3>
Reply-To: jemele@acm.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Joshua Emele <jemele@google.com>,
        Mirko Lindner <mlindner@marvell.com>,
        linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36142 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036738AbdEYUWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 16:22:00 -0400
In-Reply-To: <20170525105458.539dedba@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 10:54 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> On Wed, 24 May 2017 15:43:18 -0700
> Joshua Emele <jemele@gmail.com> wrote:
>
> > From: Joshua Emele <jemele@google.com>
> >
> > The sky2_hw_down uses sky2_tx_complete to free pending frames stuck in
> > the HW queue. Because sky2_hw_down can be called from a process context,
> > the call to u64_stats_update_begin can result in deadlock.
> >
> > Because the statistics do not require update as part of the sky2_hw_down
> > sequence, prevent the update to avoid the deadlock.
> >
> > [18198.003900] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> > [18198.009931] ifconfig/11604 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > [18198.015348]  (&syncp->seq#2){+.?...}, at: [<805ed440>] sky2_hw_down+0x370/0x428
> > [18198.022827] {IN-SOFTIRQ-W} state was registered at:
> > [18198.027723]   [<801729a0>] lock_acquire+0x78/0x98
> > [18198.032484]   [<805ed048>] sky2_tx_complete+0x1a8/0x230
> > [18198.037760]   [<805f2718>] sky2_poll+0x7cc/0xfa8
> > [18198.042425]   [<807692f8>] net_rx_action+0x200/0x330
> > [18198.047447]   [<80129f64>] __do_softirq+0x130/0x31c
> > [18198.052369]   [<8012a4a0>] irq_exit+0xc8/0x13c
> > [18198.056836]   [<8017e398>] __handle_domain_irq+0x84/0xf8
> > [18198.062180]   [<80101564>] gic_handle_irq+0x58/0xb8
> > [18198.067086]   [<8010d838>] __irq_usr+0x58/0x80
> > [18198.071557]   [<76e178ae>] 0x76e178ae
> > [18198.075247] irq event stamp: 2109
> > [18198.078568] hardirqs last  enabled at (2109): [<8012a2cc>] __local_bh_enable_ip+0x90/0x110
> > [18198.086860] hardirqs last disabled at (2107): [<8012a27c>] __local_bh_enable_ip+0x40/0x110
> > [18198.095150] softirqs last  enabled at (2108): [<805ed368>] sky2_hw_down+0x298/0x428
> > [18198.102832] softirqs last disabled at (2106): [<805ed284>] sky2_hw_down+0x1b4/0x428
> > [18198.110515]
> >                other info that might help us debug this:
> > [18198.117048]  Possible unsafe locking scenario:
> >
> > [18198.122974]        CPU0
> > [18198.125425]        ----
> > [18198.127876]   lock(&syncp->seq#2);
> > [18198.131332]   <Interrupt>
> > [18198.133955]     lock(&syncp->seq#2);
> > [18198.137585]
> >                 *** DEADLOCK ***
> >
> > [18198.143517] 1 lock held by ifconfig/11604:
> > [18198.147618]  #0:  (rtnl_mutex){+.+.+.}, at: [<8077e874>] rtnl_lock+0x18/0x20
> > [18198.154772]
> >                stack backtrace:
> > [18198.159143] CPU: 1 PID: 11604 Comm: ifconfig Not tainted 4.8.17 #1
> > [18198.165331] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> > [18198.171864] Backtrace:
> > [18198.174353] [<8010c634>] (dump_backtrace) from [<8010c828>] (show_stack+0x18/0x1c)
> > [18198.181931]  r6:60070093 r5:00000000 r4:80e23248 r3:00000000
> > [18198.187682] [<8010c810>] (show_stack) from [<8041edc4>] (dump_stack+0xb4/0xe8)
> > [18198.194924] [<8041ed10>] (dump_stack) from [<801700cc>] (print_usage_bug+0x1dc/0x2d0)
> > [18198.202762]  r10:edec55c0 r9:80bd1178 r8:81649598 r7:00000006 r6:edec5a90 r5:80fb09f4
> > [18198.210686]  r4:edec55c0 r3:00000002
> > [18198.214311] [<8016fef0>] (print_usage_bug) from [<80170348>] (mark_lock+0x188/0x6c4)
> > [18198.222059]  r9:00000000 r8:00000004 r7:edec55c0 r6:00000006 r5:edec5a90 r4:8016f44c
> > [18198.229903] [<801701c0>] (mark_lock) from [<801714ac>] (__lock_acquire+0xb90/0x1c70)
> > [18198.237653]  r10:edec55c0 r9:00000000 r8:edec5aa4 r7:00000004 r6:00000001 r5:00000000
> > [18198.245573]  r4:000001cd r3:00000001
> > [18198.249192] [<8017091c>] (__lock_acquire) from [<801729a0>] (lock_acquire+0x78/0x98)
> > [18198.256940]  r10:00000001 r9:000006d0 r8:00000000 r7:00000001 r6:805ed440 r5:60070013
> > [18198.264860]  r4:00000000
> > [18198.267428] [<80172928>] (lock_acquire) from [<805ed048>] (sky2_tx_complete+0x1a8/0x230)
> > [18198.275523]  r7:ee2d9dfc r6:00000000 r5:ee2d9dc0 r4:00000000
> > [18198.281266] [<805ecea0>] (sky2_tx_complete) from [<805ed440>] (sky2_hw_down+0x370/0x428)
> > [18198.289360]  r10:ee2cac00 r9:000006d0 r8:ee2d9dc0 r7:f0d40aa8 r6:00000001 r5:00000d48
> > [18198.297281]  r4:00000000
> > [18198.299850] [<805ed0d0>] (sky2_hw_down) from [<805efed8>] (sky2_close+0xac/0x11c)
> > [18198.307337]  r10:ee838600 r9:00000000 r8:00000000 r7:00001003 r6:ee2d9dc0 r5:00000000
> > [18198.315258]  r4:ee2cac00
> > [18198.317830] [<805efe2c>] (sky2_close) from [<8076a310>] (__dev_close_many+0xc4/0x118)
> > [18198.325664]  r7:00001003 r6:00001042 r5:eb047df8 r4:ee2d9800
> > [18198.331404] [<8076a24c>] (__dev_close_many) from [<8076ab24>] (__dev_close+0x30/0x48)
> > [18198.339240]  r5:00000001 r4:ee2d9800
> > [18198.342866] [<8076aaf4>] (__dev_close) from [<8076dbac>] (__dev_change_flags+0x90/0x154)
> > [18198.350970] [<8076db1c>] (__dev_change_flags) from [<8076dc90>] (dev_change_flags+0x20/0x50)
> > [18198.359412]  r8:00000000 r7:00008914 r6:00001003 r5:ee2d9948 r4:ee2d9800 r3:00000014
> > [18198.367264] [<8076dc70>] (dev_change_flags) from [<807f06d0>] (devinet_ioctl+0x724/0x818)
> > [18198.375448]  r8:ffffffff r7:00008914 r6:ee2cae0c r5:7ed799ac r4:eb047e80 r3:00000014
> > [18198.383291] [<807effac>] (devinet_ioctl) from [<807f2e98>] (inet_ioctl+0x19c/0x1c8)
> > [18198.390951]  r10:edfc3b80 r9:eb046000 r8:00000004 r7:ee724b40 r6:7ed799ac r5:ee724b60
> > [18198.398872]  r4:00008914
> > [18198.401446] [<807f2cfc>] (inet_ioctl) from [<8074a234>] (sock_ioctl+0x158/0x300)
> > [18198.408860] [<8074a0dc>] (sock_ioctl) from [<80239770>] (do_vfs_ioctl+0x98/0xa3c)
> > [18198.416348]  r7:8023a150 r6:00000004 r5:ee724b60 r4:7ed799ac
> > [18198.422087] [<802396d8>] (do_vfs_ioctl) from [<8023a150>] (SyS_ioctl+0x3c/0x64)
> > [18198.429401]  r10:00000000 r9:eb046000 r8:00000004 r7:00008914 r6:edfc3b80 r5:7ed799ac
> > [18198.437326]  r4:edfc3b80
> > [18198.439895] [<8023a114>] (SyS_ioctl) from [<80107ee0>] (ret_fast_syscall+0x0/0x1c)
> > [18198.447469]  r8:80108084 r7:00000036 r6:00000004 r5:7ed799ac r4:7ed79b20 r3:31687465
> >
> > Signed-off-by: Joshua Emele <jemele@google.com>
>
> This problem was introduced by the "better version of seqcount".  The original
> version which is the raw_XXX version does not have any locking.
>
> Sigh. The point of u64_stats_update_begin/end was that they are supposed to be lock less.
> What architecture are you using that has such a broken version which uses locks?
>

I'm using a Gatework 5304 Ventana, which is an imx6q
(CONFIG_SOC_IMX6Q) single board computer (
http://trac.gateworks.com/wiki/ventana).
