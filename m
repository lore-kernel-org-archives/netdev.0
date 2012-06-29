From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Kernel oops in at76c50x-usb
Date: Fri, 29 Jun 2012 16:27:10 -0500
Message-ID: <4FEE1DAE.10509@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes,

This particular oops is seen for at76c50x-usb on a PPC, but I have seen a 
similar oops for b43legacy, and i thought there was one earlier in the wireless 
ML, but I could not find it just now.

This particular oops does not always occur. Usually, the machine just freezes.

The dmesg dump is:

=============================================================

[  156.231550] Unable to handle kernel paging request for data at address 0x0000004c
[  156.231571] Faulting instruction address: 0xc0342e98
[  156.231594] Oops: Kernel access of bad area, sig: 11 [#1]
[  156.231599] PowerMac
[  156.231692] Modules linked in: at76c50x_usb nfs lockd fscache auth_rpcgss 
nfs_acl sunrpc uinput cpufreq_userspace cpufreq_conservative cpufreq_ondemand 
cpufreq_stats cpufreq_powersave bluetooth fuse loop firewire_sbp2 arc4 b43 
mac80211 cfg80211 rfkill rng_core ssb mmc_core pcmcia evdev yenta_socket 
pcmcia_rsrc pcmcia_core ext4 mbcache jbd2 crc16 ohci_hcd ehci_hcd usbcore 
firewire_ohci sungem firewire_core sungem_phy crc_itu_t sr_mod cdrom usb_common 
nls_base [last unloaded: scsi_wait_scan]
[  156.231703] NIP: c0342e98 LR: e25121ac CTR: c0342e80
[  156.231715] REGS: df869e00 TRAP: 0300   Not tainted  (3.5.0-rc4-wl+)
[  156.231732] MSR: 00001032 <ME,IR,DR,RI>  CR: 42000042  XER: 20000000
[  156.231738] DAR: 0000004c, DSISR: 40000000
[  156.231804] TASK = df859b00[5] 'kworker/u:0' THREAD: df868000
[  156.231804] GPR00: e25121ac df869eb0 df859b00 00000000 df858db0 df858db0 
1d0be361 00000000
[  156.231804] GPR08: 00000000 00000001 73635f72 0000004c c0342e80 00000000 
018bd137 0197dda0
[  156.231804] GPR16: 018bd55a 0196ecb8 018ee7d4 018bd538 ffbc1280 018bcd5b 
00000001 c05830d4
[  156.231804] GPR24: c05e46d8 00000000 00000001 00000001 de8cd460 debde9c8 
df869ec8 debde300
[  156.231840] NIP [c0342e98] __netif_schedule+0x18/0x78
[  156.231967] LR [e25121ac] ieee80211_propagate_queue_wake+0x100/0x14c [mac80211]
[  156.231972] Call Trace:
[  156.231986] [df869eb0] [c0342ee0] __netif_schedule+0x60/0x78 (unreliable)
[  156.232025] [df869ec0] [e25121ac] ieee80211_propagate_queue_wake+0x100/0x14c 
[mac80211]
[  156.232065] [df869f00] [e25123bc] ieee80211_wake_queues_by_reason+0x3c/0x7c 
[mac80211]
[  156.232096] [df869f20] [e29a2178] at76_dwork_hw_scan+0x184/0x1a8 [at76c50x_usb]
[  156.232123] [df869f50] [c0057d04] process_one_work+0x2a4/0x45c
[  156.232136] [df869f80] [c0058358] worker_thread+0x244/0x3d4
[  156.232153] [df869fb0] [c005d168] kthread+0x88/0x8c
[  156.232174] [df869ff0] [c000fa58] kernel_thread+0x4c/0x68
[  156.232180] Instruction dump:
[  156.232200] 83810010 83a10014 83c10018 83e1001c 38210020 4e800020 9421fff0 
7c0802a6
[  156.232219] 3963004c 39200001 90010014 93e1000c <7c005828> 7c0a4b78 7d40592d 
40a2fff4
[  156.232232] ---[ end trace 11d3cd4cb4a4faf3 ]---
[  156.232236]
[  156.232401] Unable to handle kernel paging request for data at address 0xfffffffc
[  156.232411] Faulting instruction address: 0xc005cb48

=============================================================
The objdump listing and the source for the routine in question follows:

=============================================================

00001600 <__netif_schedule>:
__netif_schedule():
     1600:       94 21 ff f0     stwu    r1,-16(r1)
     1604:       7c 08 02 a6     mflr    r0
     1608:       39 63 00 4c     addi    r11,r3,76
     160c:       39 20 00 01     li      r9,1
     1610:       90 01 00 14     stw     r0,20(r1)
     1614:       93 e1 00 0c     stw     r31,12(r1)
     1618:       7c 00 58 28     lwarx   r0,0,r11
     161c:       7c 0a 4b 78     or      r10,r0,r9
     1620:       7d 40 59 2d     stwcx.  r10,0,r11
     1624:       40 a2 ff f4     bne-    1618 <__netif_schedule+0x18>
     1628:       70 00 00 01     andi.   r0,r0,1
     162c:       40 a2 00 38     bne+    1664 <__netif_schedule+0x64>
     1630:       7f e0 00 a6     mfmsr   r31
     1634:       57 e9 04 5e     rlwinm  r9,r31,0,17,15
     1638:       7d 20 01 24     mtmsr   r9
     163c:       90 03 00 44     stw     r0,68(r3)
     1640:       3d 20 00 00     lis     r9,0
     1644:       38 03 00 44     addi    r0,r3,68
     1648:       39 29 00 00     addi    r9,r9,0
     164c:       81 69 00 04     lwz     r11,4(r9)
     1650:       90 6b 00 00     stw     r3,0(r11)
     1654:       38 60 00 02     li      r3,2
     1658:       90 09 00 04     stw     r0,4(r9)
     165c:       48 00 00 01     bl      165c <__netif_schedule+0x5c>
     1660:       7f e0 01 24     mtmsr   r31
     1664:       80 01 00 14     lwz     r0,20(r1)
     1668:       83 e1 00 0c     lwz     r31,12(r1)
     166c:       38 21 00 10     addi    r1,r1,16
     1670:       7c 08 03 a6     mtlr    r0
     1674:       4e 80 00 20     blr

static inline void __netif_reschedule(struct Qdisc *q)
{
         struct softnet_data *sd;
         unsigned long flags;

         local_irq_save(flags);
         sd = &__get_cpu_var(softnet_data);
         q->next_sched = NULL;
         *sd->output_queue_tailp = q;
         sd->output_queue_tailp = &q->next_sched;
         raise_softirq_irqoff(NET_TX_SOFTIRQ);
         local_irq_restore(flags);
}

void __netif_schedule(struct Qdisc *q)
{
         if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state))
                 __netif_reschedule(q);
}
EXPORT_SYMBOL(__netif_schedule);

===================================================


My PPC instruction decoding skills are poor, but I think the crash is happening 
at offset 1660. In addition, the routine is about to exit.

Thanks,

Larry
