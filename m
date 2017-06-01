From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: Oops with commit 6d18c73 bridge: start hello_timer when enabling
 KERNEL_STP in br_stp_start
Date: Thu, 1 Jun 2017 14:34:08 +0200 (CEST)
Message-ID: <alpine.LFD.2.20.1706011415500.1688@schleppi>
References: <alpine.LFD.2.20.1705311816090.1727@schleppi>  <CADvbK_c_bXnPL5NdADj=aCv8f-A0wPKdUmQJqm=XDRf0rizXcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        Haidong Li <haili@redhat.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Ivan Vecera <cera@cera.cz>,
        Stephen Hemminger <stephen@networkplumber.org>,
        network dev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_c_bXnPL5NdADj=aCv8f-A0wPKdUmQJqm=XDRf0rizXcA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Jun 2017, Xin Long wrote:
> On Thu, Jun 1, 2017 at 12:32 AM, Sebastian Ott
> <sebott@linux.vnet.ibm.com> wrote:
> > [...]
> I couldn't see any bridge-related thing here, and it couldn't be reproduced
> with virbr0 (stp=1) on my box (on both s390x and x86_64), I guess there
> is something else in you machine.
> 
> With the latest upstream kernel, can you remove libvirt (virbr0) and boot your
> machine normally, then:
> # brctl addbr br0
> # ip link set br0 up
> # brctl stp br0 on
> 
> to check if it will still hang.

Nope. That doesn't hang.


> If it can't be reproduced in this way, pls add this on your kernel:
> 
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -178,9 +178,11 @@ static void br_stp_start(struct net_bridge *br)
>                 br->stp_enabled = BR_KERNEL_STP;
>                 br_debug(br, "using kernel STP\n");
> 
> +               WARN_ON(1);
>                 /* To start timers on any ports left in blocking */
>                 mod_timer(&br->hello_timer, jiffies + br->hello_time);
>                 br_port_state_selection(br);
> +               pr_warn("hello timer start done\n");
>         }
> 
>         spin_unlock_bh(&br->lock);
> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
> index 60b6fe2..c98b3e5 100644
> --- a/net/bridge/br_stp_timer.c
> +++ b/net/bridge/br_stp_timer.c
> @@ -40,7 +40,7 @@ static void br_hello_timer_expired(unsigned long arg)
>         if (br->dev->flags & IFF_UP) {
>                 br_config_bpdu_generation(br);
> 
> -               if (br->stp_enabled == BR_KERNEL_STP)
> +               if (br->stp_enabled != BR_USER_STP)
>                         mod_timer(&br->hello_timer,
>                                   round_jiffies(jiffies + br->hello_time));
> 
> 
> let's see if it hangs when starting the timer. Thanks.

No hang either:

[  134.018104] ------------[ cut here ]------------
[  134.018144] WARNING: CPU: 1 PID: 1339 at net/bridge/br_stp_if.c:181 br_stp_set_enabled+0x154/0x2b0 [bridge]
[  134.018149] Modules linked in: bridge stp llc rdma_ucm ib_ucm ib_uverbs [...]
[  134.018257] CPU: 1 PID: 1339 Comm: brctl Not tainted 4.12.0-rc3-00011-gf511c0b-dirty #587
[  134.018262] Hardware name: IBM 2827 H66 705 (LPAR)
[  134.018266] task: 00000000d141c100 task.stack: 00000000d1430000
[  134.018271] Krnl PSW : 0704f00180000000 000003ff802bc4c4 (br_stp_set_enabled+0x154/0x2b0 [bridge])
[  134.018286]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:3 PM:0 RI:0 EA:3
[  134.018294] Krnl GPRS: 00000000c5eae501 00000000000005dc 0000000000000bb8 0000000000000001
[  134.018298]            000003ff802bc42c 00000000d1433c78 0000000000000001 00000000d3ad2d60
[  134.018303]            0000000000000002 000003ff802c21a8 00000000d3ad2d60 00000000fffffffe
[  134.018308]            00000000d1671738 00000000000026a0 000003ff802bc42c 00000000d1433c38
[  134.018320] Krnl Code: 000003ff802bc4b4: e54ca9180001        mvhi    2328(%r10),1
                          000003ff802bc4ba: c00400000000        brcl    0,3ff802bc4ba
                         #000003ff802bc4c0: a7f40001            brc     15,3ff802bc4c2
                         >000003ff802bc4c4: c418ffffb5aa        lgrl    %r1,3ff802b3018
                          000003ff802bc4ca: 4120ac10            la      %r2,3088(%r10)
                          000003ff802bc4ce: e33010000004        lg      %r3,0(%r1)
                          000003ff802bc4d4: e330a8d80008        ag      %r3,2264(%r10)
                          000003ff802bc4da: c0e5ffffbc8b        brasl   %r14,3ff802b3df0
[  134.018374] Call Trace:
[  134.018384] ([<000003ff802bc42c>] br_stp_set_enabled+0xbc/0x2b0 [bridge])
[  134.018393]  [<000003ff802c21d2>] set_stp_state+0x2a/0x40 [bridge] 
[  134.018402]  [<000003ff802c0f30>] store_bridge_parm+0xa8/0xf8 [bridge] 
[  134.018410]  [<00000000004012f2>] kernfs_fop_write+0x132/0x208 
[  134.018417]  [<000000000036088e>] __vfs_write+0x36/0x140 
[  134.018422]  [<0000000000361b54>] vfs_write+0xbc/0x1a0 
[  134.018427]  [<000000000036323e>] SyS_write+0x66/0xc0 
[  134.018434]  [<00000000008ccc80>] system_call+0xc4/0x28c 
[  134.018438] 5 locks held by brctl/1339:
[  134.018443]  #0:  (sb_writers#5){.+.+.+}, at: [<0000000000361b3e>] vfs_write+0xa6/0x1a0
[  134.018462]  #1:  (&of->mutex){+.+.+.}, at: [<0000000000401372>] kernfs_fop_write+0x1b2/0x208
[  134.018478]  #2:  (s_active#116){.+.+.+}, at: [<000000000040137e>] kernfs_fop_write+0x1be/0x208
[  134.018496]  #3:  (rtnl_mutex){+.+.+.}, at: [<000003ff802c0f08>] store_bridge_parm+0x80/0xf8 [bridge]
[  134.018517]  #4:  (&(&br->lock)->rlock){+.....}, at: [<000003ff802bc42c>] br_stp_set_enabled+0xbc/0x2b0 [bridge]
[  134.018537] Last Breaking-Event-Address:
[  134.018546]  [<000003ff802bc4c0>] br_stp_set_enabled+0x150/0x2b0 [bridge]
[  134.018551] ---[ end trace 0fc342e82de9b3d7 ]---
[  134.018638] hello timer start done


In the system dump I observed that 3 cpus are within mod_timer (different
timers) and spin for some lock (one of them is the console driver which
explains the missing messages).

Using a different config with object debugging enabled I got this
interesting output:
[   18.759850] virbr0: port 1(virbr0-nic) entered disabled state
[   18.825885] ODEBUG: free active (active state 0) object type: timer_list hint: br_hello_timer_expired+0x0/0xb8 [bridge]
[   18.826081] ------------[ cut here ]------------
[   18.826085] WARNING: CPU: 1 PID: 519 at lib/debugobjects.c:289 debug_print_object+0xb0/0xd0
[   18.826087] Modules linked in: bridge stp llc rng_core ghash_s390 prng [...]
[   18.826118] CPU: 1 PID: 519 Comm: libvirtd Not tainted 4.12.0-rc3-00002-g475ef2f #359
[   18.826120] Hardware name: IBM 2827 H66 705 (LPAR)
[   18.826123] task: 000000006dca4100 task.stack: 000000006e7b0000
[   18.826125] Krnl PSW : 0404d00180000000 00000000006420d0 (debug_print_object+0xb0/0xd0)
[   18.826131]            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 RI:0 EA:3
[   18.826135] Krnl GPRS: ffffffffffffffe9 0000000080000001 000000000000006b 0000000000a973f4
[   18.826138]            0000000000292296 0000000000000000 0000000000a8cca2 0000000001e3bf18
[   18.826140]            0000000001e3bf10 0000000069c4e2a8 0000000069c4c2a8 0000000000ab2f48
[   18.826143]            0000000000cc6f18 000000006fce91a8 00000000006420cc 000000006e7b3ad0
[   18.826152] Krnl Code: 00000000006420c0: c02000242a65        larl    %r2,ac758a
           00000000006420c6: c0e5ffe280c1       brasl   %r14,292248
          #00000000006420cc: a7f40001           brc     15,6420ce
          >00000000006420d0: c41d0032960a       lrl     %r1,c94ce4
           00000000006420d6: e340f0e80004       lg      %r4,232(%r15)
           00000000006420dc: a71a0001           ahi     %r1,1
           00000000006420e0: eb6ff0a80004       lmg     %r6,%r15,168(%r15)
           00000000006420e6: c41f003295ff       strl    %r1,c94ce4
[   18.826177] Call Trace:
[   18.826180] ([<00000000006420cc>] debug_print_object+0xac/0xd0)
[   18.826183]  [<00000000006431ba>] __debug_check_no_obj_freed+0xca/0x258 
[   18.826185]  [<0000000000319a44>] kfree+0x264/0x410 
[   18.826188]  [<00000000006a8e46>] device_release+0x76/0xb0 
[   18.826191]  [<000000000060e67e>] kobject_put+0xde/0x1d8 
[   18.826194]  [<00000000007bd14e>] netdev_run_todo+0x2be/0x2d0 
[   18.826201]  [<000003ff8096b762>] br_del_bridge+0x82/0x98 [bridge] 
[   18.826208]  [<000003ff8096d750>] br_ioctl_deviceless_stub+0x100/0x140 [bridge] 
[   18.826211]  [<000000000078e562>] sock_ioctl+0x1a2/0x2f0 
[   18.826214]  [<000000000035dc3c>] do_vfs_ioctl+0x714/0x7a8 
[   18.826217]  [<000000000035dd4c>] SyS_ioctl+0x7c/0xb0 
[   18.826220]  [<00000000008f2300>] system_call+0xc4/0x274 
[   18.826222] INFO: lockdep is turned off.
[   18.826224] Last Breaking-Event-Address:
[   18.826227]  [<00000000006420cc>] debug_print_object+0xac/0xd0
[   18.826230] ---[ end trace 765b1870ef16b23f ]---

Regards,
Sebastian
