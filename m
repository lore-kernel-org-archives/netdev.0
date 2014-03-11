From: Grant Grundler <grundler@google.com>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 11 Mar 2014 10:31:48 -0700
Message-ID: <CANEJEGv77PnbLZsyOdTevXjij-_wLSq4uGCnSjnAwN9OK8m3Yg@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Julius Werner <jwerner@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:42232 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaCKRbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 13:31:49 -0400
Received: by mail-oa0-f48.google.com with SMTP id m1so8899327oag.21
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 10:31:48 -0700 (PDT)
In-Reply-To: <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 7:53 PM, Julius Werner <jwerner@chromium.org> wrote:
> I think usbnet_stop() raced with the dev->bh tasklet, which by itself
> might not be a problem (usbnet_stop() later kills the tasklet itself,
> so it should expect that it can be running before that). The issue is
> that it calls usbnet_terminate_urbs() before that, which temporarily
> installs a waitqueue in dev->wait in order to be able to wait on the
> tasklet to run and finish up some queues. The waiting itself looks
> okay, but the access to 'dev->wait' is totally unprotected and can
> race arbitrarily. I think in this case usbnet_bh() managed to succeed
> it's dev->wait check just before usbnet_terminate_urbs() sets it back
> to NULL. The latter then finishes and the waitqueue_t structure on its
> stack gets overwritten by other functions halfway through the
> wake_up() call in usbnet_bh().

Awesome - thanks Julius! :)

FWIW, I've reproduced this on "Samsung Chromebook" (Exynos 5250) with
AX88772 USB dongle using the instructions I posted before (ie bouncing
the USB port with reload_asix script).

cheers,
grant

[23231.533805] asix 3-1:1.0 eth0: link up, 1000Mbps, full-duplex, lpa 0xCDE1
[23235.755652] usbcore: deregistering interface driver asix
[23235.761722] asix 3-1:1.0 eth0: unregister 'asix'
usb-12110000.usb-1, ASIX AX88178 USB 2.0 Ethernet
[23235.761763] Unable to handle kernel paging request at virtual
address e24cb004
[23235.761771] pgd = ebf70000
[23235.761777] [e24cb004] *pgd=6241141e(bad)
[23235.761792] Internal error: Oops: 8000000d [#1] SMP ARM
[23235.761798] Modules linked in: asix(-) exynos_gsc v4l2_mem2mem
isl29018(C) sbs_battery i2c_dev uinput mwifiex_sdio mwifiex
btmrvl_sdio btmrvl s5p_mfc videobuf2_dma_contig rtc_s3c bluetooth
zram(C) zsmalloc(C) fuse cfg80211 nf_conntrack_ipv6 nf_defrag_ipv6
ip6table_filter ip6_tables uvcvideo videobuf2_core videobuf2_vmalloc
videobuf2_memops usbnet joydev [last unloaded: asix]
[23235.761898] CPU: 0    Tainted: G         C    (3.8.11 #25)
[23235.761906] PC is at 0xe24cb004
[23235.761916] LR is at __wake_up_common+0x5c/0x88
[23235.761924] pc : [<e24cb004>]    lr : [<c014f870>]    psr: 80000093
[23235.761924] sp : ef0e3e10  ip : e24cb004  fp : ef0e3e3c
[23235.761931] r10: e1a0c00d  r9 : 00000000  r8 : 00000003
[23235.761938] r7 : 00000000  r6 : 00000001  r5 : e92d3ff4  r4 : eab13d14
[23235.761943] r3 : 00000000  r2 : 00000000  r1 : 00000003  r0 : c060d0f4
[23235.761951] Flags: Nzcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM
Segment kernel
[23235.761957] Control: 10c5387d  Table: 6bf7006a  DAC: 00000015
[23235.761964] Process ksoftirqd/0 (pid: 3, stack limit = 0xef0e2240)
[23235.761970] Stack: (0xef0e3e10 to 0xef0e4000)
[23235.761977] 3e00:                                     00000000
eab13d04 40000013 00000001
[23235.761986] 3e20: 00000003 00000000 00000100 3f6fdf7c ef0e3e6c
ef0e3e40 c0151c30 c014f820
[23235.761994] 3e40: 00000000 ef0e3e50 c052861c edaddd40 00000000
edadde4c 00000000 00000000
[23235.762001] 3e60: ef0e3e8c ef0e3e70 bf00a0e4 c0151bf4 bf009fa4
edaddebc edaddec0 c084c790
[23235.762009] 3e80: ef0e3eb4 ef0e3e90 c012bcb4 bf009fb0 c012bc1c
ef0e2038 00000009 c090209c
[23235.762016] 3ea0: 00000006 c09790c0 ef0e3f04 ef0e3eb8 c012b348
c012bc28 c0934324 ef0e2000
[23235.762024] 3ec0: 00000001 ef0e2020 00000000 00000000 04208040
00000005 c0153f94 00000000
[23235.762032] 3ee0: c0934324 ef0e2000 00000001 ef0e2020 00000000
00000000 ef0e3f1c ef0e3f08
[23235.762039] 3f00: c012b48c c012b234 c012b44c ef0409c0 ef0e3f44
ef0e3f20 c014f22c c012b458
[23235.762046] 3f20: ef0dde48 00000000 ef0409c0 c014f0c0 00000000
00000000 ef0e3fac ef0e3f48
[23235.762054] 3f40: c01455b4 c014f0cc 00000001 00000000 ef0409c0
00000000 00030003 dead4ead
[23235.762061] 3f60: ffffffff ffffffff ef0e3f68 ef0e3f68 00000000
00000000 dead4ead ffffffff
[23235.762068] 3f80: ffffffff ef0e3f84 ef0e3f84 271ae517 ef0dde48
c01454ec 00000000 00000000
[23235.762075] 3fa0: 00000000 ef0e3fb0 c0106118 c01454f8 00000000
00000000 00000000 00000000
[23235.762082] 3fc0: 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[23235.762089] 3fe0: 00000000 00000000 00000000 00000000 00000013
00000000 f77e7f69 e1459824
[23235.762094] Backtrace:
[23235.762107] [<c014f870>] (__wake_up_common+0x5c/0x88) from
[<c0151c30>] (__wake_up+0x48/0x5c)
[23235.762121] [<c0151c30>] (__wake_up+0x48/0x5c) from [<bf00a0e4>]
(usbnet_bh+0x140/0x210 [usbnet])
[23235.762135] [<bf00a0e4>] (usbnet_bh+0x140/0x210 [usbnet]) from
[<c012bcb4>] (tasklet_action+0x98/0xf4)
[23235.762148] [<c012bcb4>] (tasklet_action+0x98/0xf4) from
[<c012b348>] (__do_softirq+0x120/0x224)
[23235.762160] [<c012b348>] (__do_softirq+0x120/0x224) from
[<c012b48c>] (run_ksoftirqd+0x40/0x60)
[23235.762170] [<c012b48c>] (run_ksoftirqd+0x40/0x60) from
[<c014f22c>] (smpboot_thread_fn+0x16c/0x184)
[23235.762180] [<c014f22c>] (smpboot_thread_fn+0x16c/0x184) from
[<c01455b4>] (kthread+0xc8/0xd8)
[23235.762191] [<c01455b4>] (kthread+0xc8/0xd8) from [<c0106118>]
(ret_from_fork+0x14/0x20)
[23235.762200] Code: 0000efe8 00003f15 0000eff0 00000000 (0000f004)
[23235.762209] ---[ end trace 3ad68dc3731b37c5 ]---
[23235.766529] Kernel panic - not syncing: Fatal exception in interrupt
[23235.766539] CPU1: stopping
[23235.766546] Backtrace:
[23235.766564] [<c010d3d0>] (unwind_backtrace+0x0/0x118) from
[<c060936c>] (dump_stack+0x28/0x30)
[23235.766577] [<c060936c>] (dump_stack+0x28/0x30) from [<c010bcb8>]
(handle_IPI+0xf0/0x170)
[23235.766588] [<c010bcb8>] (handle_IPI+0xf0/0x170) from [<c0100430>]
(gic_handle_irq+0x68/0x70)
[23235.766598] [<c0100430>] (gic_handle_irq+0x68/0x70) from
[<c0105c80>] (__irq_svc+0x40/0x50)
[23235.766605] Exception stack(0xeab13cf0 to 0xeab13d38)
[23235.766612] 3ce0:                                     00000002
edaddec0 00000003 00000001
[23235.766620] 3d00: edaddebc edaddec0 bfa78744 edaddee0 00200200
00000000 00000000 eab13d4c
[23235.766627] 3d20: 00000000 eab13d38 c012af58 c012af74 20000013 ffffffff
[23235.766639] [<c0105c80>] (__irq_svc+0x40/0x50) from [<c012af74>]
(tasklet_kill+0x6c/0x8c)
[23235.766653] [<c012af74>] (tasklet_kill+0x6c/0x8c) from [<bf00a950>]
(usbnet_stop+0x110/0x178 [usbnet])
[23235.766667] [<bf00a950>] (usbnet_stop+0x110/0x178 [usbnet]) from
[<c0532298>] (__dev_close_many+0xa8/0xcc)
[23235.766677] [<c0532298>] (__dev_close_many+0xa8/0xcc) from
[<c05323c8>] (dev_close_many+0x98/0x118)
[23235.766688] [<c05323c8>] (dev_close_many+0x98/0x118) from
[<c0533fcc>] (rollback_registered_many+0xd4/0x204)
[23235.766700] [<c0533fcc>] (rollback_registered_many+0xd4/0x204) from
[<c05368f0>] (unregister_netdevice_queue+0x98/0xf4)
[23235.766711] [<c05368f0>] (unregister_netdevice_queue+0x98/0xf4)
from [<c0536974>] (unregister_netdev+0x28/0x30)
[23235.766722] [<c0536974>] (unregister_netdev+0x28/0x30) from
[<bf009610>] (usbnet_disconnect+0x8c/0xe4 [usbnet])
[23235.766739] [<bf009610>] (usbnet_disconnect+0x8c/0xe4 [usbnet])
from [<c0425328>] (usb_unbind_interface+0x70/0x170)
[23235.766753] [<c0425328>] (usb_unbind_interface+0x70/0x170) from
[<c03c727c>] (__device_release_driver+0xac/0xf8)
[23235.766765] [<c03c727c>] (__device_release_driver+0xac/0xf8) from
[<c03c78a4>] (driver_detach+0x94/0xbc)
[23235.766775] [<c03c78a4>] (driver_detach+0x94/0xbc) from
[<c03c6de4>] (bus_remove_driver+0x78/0xc4)
[23235.766785] [<c03c6de4>] (bus_remove_driver+0x78/0xc4) from
[<c03c7efc>] (driver_unregister+0x54/0x78)
[23235.766796] [<c03c7efc>] (driver_unregister+0x54/0x78) from
[<c0424780>] (usb_deregister+0x6c/0xd4)
[23235.766807] [<c0424780>] (usb_deregister+0x6c/0xd4) from
[<bfa7782c>] (cleanup_module+0x14/0x7e8 [asix])
[23235.766827] [<bfa7782c>] (cleanup_module+0x14/0x7e8 [asix]) from
[<c0177cb0>] (sys_delete_module+0x1c4/0x254)
[23235.766838] [<c0177cb0>] (sys_delete_module+0x1c4/0x254) from
[<c0106080>] (ret_fast_syscall+0x0/0x30)
[23235.766846] task_migration_notifier = c0936790
[23235.766855] page containing tmn: c0936770: 00000001 00000000
dead4ead ffffffff
[23235.766863] page containing tmn: c0936780: ffffffff c0936784
c0936784 00000000
[23235.766871] page containing tmn: c0936790: 00000000 dead4ead
ffffffff ffffffff
[23235.766878] page containing tmn: c09367a0: 20202020 00000000
beab7861 c014f93c
[23235.766886] page containing tmn: c09367b0: c014f918 00000000
00000000 00000000
[23235.766892] page containing tmn: c09367c0: 00000000 00000000 00000000
[23235.766907] CPU0 PC: <c011c830> exynos5_panic_notify+0x5c/0xb0
