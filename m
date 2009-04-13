From: Paul Smith <paul@mad-scientist.net>
Subject: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying to
	ifenslave a second interface to my bond
Date: Mon, 13 Apr 2009 17:15:48 -0400
Message-ID: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:51871 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751279AbZDMWHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 18:07:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all; I'm hoping someone can point me in the right direction.  I have
a Broadcom NetXen II BCM5708S network card (bnx2) and a Broadcom NetXen
5714S network card (tg3).  If I use either one by itself, it works fine.
However, I want to bond them as active-active, and I can't use mode=4
because there are other devices on the network which don't support it.
So, I create the bond interface with:

        # modprobe bonding mode=6 miimon=200 xmit_hash_policy=layer2
        
        Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
        bonding: xor_mode param is irrelevant in mode adaptive load balancing
        bonding: In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (0 msec) is incompatible with the forwarding delay time of the switch

This seems to work fine.  Then I bring up the interface with ifconfig
and I get:

        bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
                  inet addr:10.0.9.46  Bcast:10.0.15.255  Mask:255.255.240.0
                  UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
                  RX packets:0 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:0 
                  RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Then I enslave one of my ethernet cards (it doesn't appear to matter
which one I enslave first), and that works fine as well:

        # ifenslave bond0 eth2
        bnx2: eth2: using MSI
        bonding: bond0: enslaving eth2 as an active interface with a down link.
        bnx2: eth2 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
        bonding: bond0: link status definitely up for interface eth2.
        bonding: bond0: making interface eth2 the new active one.
        bonding: bond0: first active interface up!
        
        # ifconfig eth2
        eth2      Link encap:Ethernet  HWaddr 00:06:72:00:01:01  
                  UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
                  RX packets:9 errors:0 dropped:0 overruns:0 frame:0
                  TX packets:36 errors:0 dropped:0 overruns:0 carrier:0
                  collisions:0 txqueuelen:1000 
                  RX bytes:696 (696.0 B)  TX bytes:2669 (2.6 KiB)
                  Interrupt:17 Memory:da000000-da012800 

I check bond0 and it's correctly inherited the MAC from this new
interface.  If I stop here I can just use this interface and everything
is great.  Similarly if I create a bond and only enslave the tg3
interface.  But of course, a bond with just one interface isn't doing
much for me :-)

As soon as I try to ifenslave the second interface, Badness Ensues:

        # ifenslave bond0 eth0
        ------------[ cut here ]------------
        WARNING: at linux/kernel/sched.c:4303 local_bh_enable_ip+0x2c/0xc0()
        Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
        Pid: 1552, comm: ifenslave Not tainted 2.6.27.18-WR3.0bg_small #1
        
        Call Trace:
         [<ffffffff8023be34>] warn_on_slowpath+0x64/0xb0
         [<ffffffff8028654a>] get_page_from_freelist+0x30a/0x640
         [<ffffffff8041497a>] __dev_get_by_name+0x9a/0xc0
         [<ffffffff80419a66>] dev_ethtool+0xd46/0x11c0
         [<ffffffff8027fc7a>] find_get_page+0x9a/0xe0
         [<ffffffff802800c3>] find_lock_page+0x23/0x80
         [<ffffffff8024233c>] local_bh_enable_ip+0x2c/0xc0
         [<ffffffffa00ad780>] bond_alb_set_mac_address+0x2a0/0x2f0 [bonding]
         [<ffffffff80416d26>] dev_set_mac_address+0x56/0x80
         [<ffffffff80418013>] dev_ioctl+0x343/0x5e0
         [<ffffffff8045c43b>] devinet_ioctl+0x29b/0x7b0
         [<ffffffff80406df1>] sock_ioctl+0x71/0x260
         [<ffffffff802bddff>] vfs_ioctl+0x2f/0xb0
         [<ffffffff802be0e3>] do_vfs_ioctl+0x263/0x2e0
         [<ffffffff802bddff>] vfs_ioctl+0x2f/0xb0
         [<ffffffff802be217>] sys_ioctl+0xb7/0x100
         [<ffffffff802eb2a3>] dev_ifsioc+0x73/0x2c0
         [<ffffffff802eaf9a>] ethtool_ioctl+0x9a/0xa0
         [<ffffffff802ebfa3>] compat_sys_ioctl+0x113/0x3c0
         [<ffffffff8022ad52>] ia32_syscall_done+0x0/0xa
        BUG: scheduling while atomic: ifenslave/1552/0x10000000
        Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
        Pid: 1552, comm: ifenslave Not tainted 2.6.27.18-WR3.0bg_small #1
        
        Call Trace:
         [<ffffffff8049b53a>] schedule+0xea/0x336
         [<ffffffff8020e619>] show_trace_log_lvl+0x39/0x80
         [<ffffffff8049b04b>] printk+0xc0/0xd5
         [<ffffffff8049b432>] preempt_schedule+0x32/0x50
         [<ffffffff8020e5b3>] dump_trace_extended+0x4f3/0x500
         [<ffffffff8020e5d0>] dump_trace+0x10/0x20
         [<ffffffff8020e634>] show_trace_log_lvl+0x54/0x80
         [<ffffffff8049ae36>] dump_stack+0x69/0x6f
         [<ffffffff8023be34>] warn_on_slowpath+0x64/0xb0
         [<ffffffff8028654a>] get_page_from_freelist+0x30a/0x640
         [<ffffffff8041497a>] __dev_get_by_name+0x9a/0xc0
         [<ffffffff80419a66>] dev_ethtool+0xd46/0x11c0
         [<ffffffff8027fc7a>] find_get_page+0x9a/0xe0
         [<ffffffff802800c3>] find_lock_page+0x23/0x80
         [<ffffffff8024233c>] local_bh_enable_ip+0x2c/0xc0
         [<ffffffffa00ad780>] bond_alb_set_mac_address+0x2a0/0x2f0 [bonding]
         [<ffffffff80416d26>] dev_set_mac_address+0x56/0x80
         [<ffffffff80418013>] dev_ioctl+0x343/0x5e0
         [<ffffffff8045c43b>] devinet_ioctl+0x29b/0x7b0
         [<ffffffff80406df1>] sock_ioctl+0x71/0x260
         [<ffffffff802bddff>] vfs_ioctl+0x2f/0xb0
         [<ffffffff802be0e3>] do_vfs_ioctl+0x263/0x2e0
         [<ffffffff802bddff>] vfs_ioctl+0x2f/0xb0
         [<ffffffff802be217>] sys_ioctl+0xb7/0x100
         [<ffffffff802eb2a3>] dev_ifsioc+0x73/0x2c0
         [<ffffffff802eaf9a>] ethtool_ioctl+0x9a/0xa0
         [<ffffffff802ebfa3>] compat_sys_ioctl+0x113/0x3c0
         [<ffffffff8022ad52>] ia32_syscall_done+0x0/0xa

        ---[ end trace ff7f0219c6745dff ]---

I can't access the console anymore (typing does nothing) but if I let it
sit there, it will periodically complain further:

        BUG: soft lockup - CPU#2 stuck for 61s! [ifenslave:1552]
        Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
        CPU 2:
        Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
        Pid: 1552, comm: ifenslave Tainted: G        W 2.6.27.18-WR3.0bg_small #1
        RIP: 0010:[<ffffffff8036773f>]  [<ffffffff8036773f>] __write_lock_failed+0xf/0x20
        RSP: 0000:ffff88046fb71c80  EFLAGS: 00000206
        RAX: ffff88046fb71fd8 RBX: ffff88046e115200 RCX: 0000000000000001
        RDX: 0000000000000101 RSI: ffff88046e0be400 RDI: ffff88046e1156b0
        RBP: 0000000000000000 R08: ffff88046fb88c70 R09: 0000000000000000
        R10: 00000000e1281e79 R11: 0000000000000001 R12: ffff88046e115680
        R13: ffff88046fb71c18 R14: ffff88046c79df00 R15: ffff88046e0be400
        FS:  0000000000000000(0000) GS:ffff88046f805880(0063) knlGS:00000000f7f126c0
        CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
        CR2: 000000004cd11000 CR3: 000000046c734000 CR4: 00000000000006e0
        DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
        DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
        
        Call Trace:
         [<ffffffff8049d5d4>] _write_lock_bh+0x24/0x30
         [<ffffffffa00ad759>] bond_alb_set_mac_address+0x279/0x2f0 [bonding]
         [<ffffffff80416d26>] dev_set_mac_address+0x56/0x80
         [<ffffffff80418013>] dev_ioctl+0x343/0x5e0
         [<ffffffff8045c43b>] devinet_ioctl+0x29b/0x7b0
         [<ffffffff80406df1>] sock_ioctl+0x71/0x260
         [<ffffffff802bddff>] vfs_ioctl+0x2f/0xb0
         [<ffffffff802be0e3>] do_vfs_ioctl+0x263/0x2e0
         [<ffffffff802bddff>] vfs_ioctl+0x2f/0xb0
         [<ffffffff802be217>] sys_ioctl+0xb7/0x100
         [<ffffffff802eb2a3>] dev_ifsioc+0x73/0x2c0
         [<ffffffff802eaf9a>] ethtool_ioctl+0x9a/0xa0
         [<ffffffff802ebfa3>] compat_sys_ioctl+0x113/0x3c0
         [<ffffffff8022ad52>] ia32_syscall_done+0x0/0xa

<a little bit later>

        ------------[ cut here ]------------
        WARNING: at /linux/net/sched/sch_generic.c:219 dev_watchdog+0x22e/0x240()
        NETDEV WATCHDOG: eth2 (bnx2): transmit timed out
        Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
        Pid: 0, comm: swapper Tainted: G        W 2.6.27.18-WR3.0bg_small #1
        
        Call Trace:
         <IRQ>  [<ffffffff8023bd7d>] warn_slowpath+0xcd/0x120
         [<ffffffff802575ba>] hrtimer_interrupt+0x16a/0x1d0
         [<ffffffff8022f20e>] resched_task+0x4e/0x80
         [<ffffffff802a7ca2>] __slab_free+0xb2/0x380
         [<ffffffff802a7ca2>] __slab_free+0xb2/0x380
         [<ffffffff8035eca9>] __next_cpu+0x19/0x30
         [<ffffffff8023185c>] find_busiest_group+0x1dc/0x960
         [<ffffffff8022e870>] load_balance_fair+0xa0/0x130
         [<ffffffff80364e21>] strlcpy+0x41/0x50
         [<ffffffff80426fee>] dev_watchdog+0x22e/0x240
         [<ffffffff80426dc0>] dev_watchdog+0x0/0x240
         [<ffffffff80247207>] run_timer_softirq+0x157/0x230
         [<ffffffff8025a407>] getnstimeofday+0x57/0xe0
         [<ffffffff80242603>] __do_softirq+0xe3/0x210
         [<ffffffff8020d91c>] call_softirq+0x1c/0x30
         [<ffffffff8020ff75>] do_softirq+0x35/0x70
         [<ffffffff802416b5>] irq_exit+0x45/0x60
         [<ffffffff8021dc09>] smp_apic_timer_interrupt+0x149/0x1b0
         [<ffffffff8020d366>] apic_timer_interrupt+0x66/0x70
         <EOI>  [<ffffffff80214f5c>] mwait_idle+0x3c/0x50
         [<ffffffff8020b4b9>] cpu_idle+0x79/0x100
        
        ---[ end trace 7a134222da5adb1b ]---

I've tried all kinds of things, as I alluded to above: switching the
order, adding sleeps (before invoking ifenslave etc.), bringing up the
slave interfaces before I enslave or not, power-cycling, etc. but
nothing seems to make a difference; as soon as I bond the second
interface the whole thing goes south.

In my googling I haven't found too much, but I did find this:

        https://bugzilla.redhat.com/show_bug.cgi?id=251902#c25

which is a comment added to a different bug.  Although the trace doesn't
match the original bug, it does resemble my trace (but I'm not using
Xen)  However, the Red Hat engineer (rightly) requested that a new bug
be filed for this and I haven't been able to find that new bug (if it
was ever filed).

I've also pulled the latest GIT tree and looked at the differences
between the drivers/net/bond/bond_alb.c but didn't see anything that
looked like it related to this (but, I'm not versed in the kernel code
so it's quite possible I missed it).  I checked differences between
bond_main.c etc. as well but, again, nothing jumped at me.  Since I'm
working on an embedded system it will be somewhat painful to try to
build the latest kernel to test in this environment, but I could do it
if someone believes that it might be fixed there.

Anyone have any thoughts about what might be going on, or what my next
steps should be?  I'm stumped :-(

-- 
Paul Smith <paul@mad-scientist.net>


