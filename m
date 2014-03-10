From: Grant Grundler <grundler@google.com>
Subject: usbnet: driver_info->stop required to stop USB interrupts?
Date: Mon, 10 Mar 2014 11:33:19 -0700
Message-ID: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c32c366d0ab904f444d6e1
Cc: Freddy Xin <freddy@asix.com.tw>, linux-usb@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:42428 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbaCJSdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 14:33:19 -0400
Received: by mail-oa0-f52.google.com with SMTP id l6so7264203oag.25
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 11:33:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c32c366d0ab904f444d6e1
Content-Type: text/plain; charset=UTF-8

I've trying to unravel a page fault panic I've run into a few times
while testing load/unload of asix driver with ChromeOS 3.8.11 based
kernel.  I'm running into this crash on both ARM and X86. Panic output
below is from Exynos 5422 system. Test script attached.

My _guess_ is usbnet_stop() is racing with a USB interrupt from the
device and loses. First glance at the stack trace implies the
interrupt handler is trying to access something that has previously
been released.

usbnet_stop() calls driver_info->stop() if provided by the driver.  If
my guess above is correct, does that mean "stop()" call is expected
(required?) to stop interrupts coming from that USB device?
Or is something else supposed to stop RX (or other USB) traffic?

ax88179_178a.c appears to be the only usbnet driver that provides a
.stop call and was able to complete 10K iterations. asix driver
completes 200-5000 iterations before failing for different causes.

thanks,
grant

----invoke the reload_asix script and monitor test ---
scp reload_asix $T:/tmp
for i in `seq 10000`; do echo -n "RELOAD $i  " ; ssh $T ".
/tmp/reload_asix eth0 100_full" ; J=$? ; if [ $J -eq 255 ] ; then echo
" SSH timeout" ; break ; fi ; ssh $T "cat /var/log/reload-asix.out" ;
if [ $J -ne 0 ] ; then echo "  ERROR $J" ; fi ; sleep 3 ; done | tee
~/reload-AX88772-$IP-04.out

---- tombstone from Exynos 5422 on asix driver unload ----
...
[28488.367522] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[28488.380574] asix 1-1:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0xCDE1
[28493.308354] usbcore: deregistering interface driver asix
[28493.310775] asix 1-1:1.0 eth0: unregister 'asix'
usb-xhci-hcd.4.auto-1, ASIX AX88772 USB 2.0 Ethernet
[28494.369787] usbcore: registered new interface driver asix
[28494.725186] asix 1-1:1.0 eth0: register 'asix' at
usb-xhci-hcd.4.auto-1, ASIX AX88772 USB 2.0 Ethernet,
c8:d7:19:d8:0b:d3
[28494.725262] usb 1-1: authorized to connect
[28495.545485] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[28497.455518] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[28497.466586] asix 1-1:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0xCDE1
[28502.302851] usbcore: deregistering interface driver asix
[28502.308652] asix 1-1:1.0 eth0: unregister 'asix'
usb-xhci-hcd.4.auto-1, ASIX AX88772 USB 2.0 Ethernet
[28502.308717] Unable to handle kernel paging request at virtual
address e24cb004
[28502.308739] pgd = ea514000
[28502.308753] [e24cb004] *pgd=4241141e(bad)
[28502.308782] Internal error: Oops: 8000000d [#1] SMP ARM
[28502.308795] Modules linked in: asix(-) uvcvideo videobuf2_vmalloc
i2c_dev uinput exynos_gsc v4l2_mem2mem btmrvl_sdio sbs_9018(C)
mwifiex_sdio mwifiex btmrvl s5p_mfc videobuf2_core zram(C) bluetooth
videobuf2_dma_contig videobuf2_memops rtc_s3c zuse cfg80211
nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables usbnet
joydev [last unloaded: asix]
[28502.308998] CPU: 0    Tainted: G         C    (3.8.11 #6)
[28502.309016] PC is at 0xe24cb004
[28502.309039] LR is at __wake_up_common+0x5c/0x88
[28502.309058] pc : [<e24cb004>]    lr : [<c014f848>]    psr: 80000093
[28502.309058] sp : ef10be10  ip : e24cb004  fp : ef10be3c
[28502.309076] r10: e1a0c00d  r9 : 00000000  r8 : 00000003
[28502.309091] r7 : 00000000  r6 : 00000001  r5 : e92d3ff4  r4 : ea409d14
[28502.309106] r3 : 00000000  r2 : 00000000  r1 : 00000003  r0 : c060ced4
[28502.309122] Flags: Nzcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM
Segment kernel
[28502.309138] Control: 10c5387d  Table: 4a51406a  DAC: 00000015
[28502.309153] Process ksoftirqd/0 (pid: 3, stack limit = 0xef10a240)
[28502.309168] Stack: (0xef10be10 to 0xef10c000)
[28502.309186] be00:                                     00000000
ea409d04 40000013 00000001
[28502.309209] be20: 00000003 00000000 00000100 3f6fdf7c ef10be6c
ef10be40 c0151c08 c014f7f8
[28502.309231] be40: 00000000 ef10be50 c0529a44 ea5ac540 00000000
ea5ac64c 00000000 00000000
[28502.309254] be60: ef10be8c ef10be70 bf00a0e4 c0151bcc bf009fa4
ea5ac6bc ea5ac6c0 c084c790
[28502.309277] be80: ef10beb4 ef10be90 c012bcb4 bf009fb0 c012bc1c
ef10a038 00000001 c090209c
[28502.309300] bea0: 00000006 c09795c0 ef10bf04 ef10beb8 c012b348
c012bc28 c0934314 ef10a000
[28502.309322] bec0: 00000001 ef10a020 00000000 00000000 04208040
0000000a ef10bf04 00000000
[28502.309345] bee0: c0934314 ef10a000 00000001 ef10a020 00000000
00000000 ef10bf1c ef10bf08
[28502.309368] bf00: c012b48c c012b234 c012b44c ef056d00 ef10bf44
ef10bf20 c014f204 c012b458
[28502.309391] bf20: ef101e48 00000000 ef056d00 c014f098 00000000
00000000 ef10bfac ef10bf48
[28502.309413] bf40: c01455b4 c014f0a4 00000001 00000000 ef056d00
00000000 00030003 dead4ead
[28502.309436] bf60: ffffffff ffffffff ef10bf68 ef10bf68 00000000
00000000 dead4ead ffffffff
[28502.309459] bf80: ffffffff ef10bf84 ef10bf84 271ae517 ef101e48
c01454ec 00000000 00000000
[28502.309480] bfa0: 00000000 ef10bfb0 c0106118 c01454f8 00000000
00000000 00000000 00000000
[28502.309500] bfc0: 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[28502.309520] bfe0: 00000000 00000000 00000000 00000000 00000013
00000000 00000000 00000000
[28502.309532] Backtrace:
[28502.309565] [<c014f848>] (__wake_up_common+0x5c/0x88) from
[<c0151c08>] (__wake_up+0x48/0x5c)
[28502.309597] [<c0151c08>] (__wake_up+0x48/0x5c) from [<bf00a0e4>]
(usbnet_bh+0x140/0x210 [usbnet])
[28502.309631] [<bf00a0e4>] (usbnet_bh+0x140/0x210 [usbnet]) from
[<c012bcb4>] (tasklet_action+0x98/0xf4)
[28502.309663] [<c012bcb4>] (tasklet_action+0x98/0xf4) from
[<c012b348>] (__do_softirq+0x120/0x224)
[28502.309692] [<c012b348>] (__do_softirq+0x120/0x224) from
[<c012b48c>] (run_ksoftirqd+0x40/0x60)
[28502.309719] [<c012b48c>] (run_ksoftirqd+0x40/0x60) from
[<c014f204>] (smpboot_thread_fn+0x16c/0x184)
[28502.309746] [<c014f204>] (smpboot_thread_fn+0x16c/0x184) from
[<c01455b4>] (kthread+0xc8/0xd8)
[28502.309775] [<c01455b4>] (kthread+0xc8/0xd8) from [<c0106118>]
(ret_from_fork+0x14/0x20)
[28502.309795] Code: 00000000 00000000 00000000 00000000 (00000000)
[28502.309815] ---[ end trace 980060b6dbaf7494 ]---
[28502.324123] Kernel panic - not syncing: Fatal exception in interrupt
[28502.324160] CPU1: stopping
[28502.324170] Backtrace:
[28502.324193] [<c010d3d0>] (unwind_backtrace+0x0/0x118) from
[<c060914c>] (dump_stack+0x28/0x30)
[28502.324208] [<c060914c>] (dump_stack+0x28/0x30) from [<c010bcb8>]
(handle_IPI+0xf0/0x170)
[28502.324221] [<c010bcb8>] (handle_IPI+0xf0/0x170) from [<c0100430>]
(gic_handle_irq+0x68/0x70)
[28502.324235] [<c0100430>] (gic_handle_irq+0x68/0x70) from
[<c0105c80>] (__irq_svc+0x40/0x50)
[28502.324244] Exception stack(0xea409cf0 to 0xea409d38)
[28502.324253] 9ce0:                                     00000002
ea5ac6c0 00000003 00000001
[28502.324264] 9d00: ea5ac6bc ea5ac6c0 bf31d788 ea5ac6e0 00200200
00000000 00000000 ea409d4c
[28502.324273] 9d20: 00000000 ea409d38 c012af58 c012af80 20000013 ffffffff
[28502.324288] [<c0105c80>] (__irq_svc+0x40/0x50) from [<c012af80>]
(tasklet_kill+0x78/0x8c)
[28502.324307] [<c012af80>] (tasklet_kill+0x78/0x8c) from [<bf00a950>]
(usbnet_stop+0x110/0x178 [usbnet])
[28502.324325] [<bf00a950>] (usbnet_stop+0x110/0x178 [usbnet]) from
[<c053368c>] (__dev_close_many+0xa8/0xcc)
[28502.324339] [<c053368c>] (__dev_close_many+0xa8/0xcc) from
[<c05337bc>] (dev_close_many+0x98/0x118)
[28502.324353] [<c05337bc>] (dev_close_many+0x98/0x118) from
[<c0535348>] (rollback_registered_many+0xd4/0x204)
[28502.324367] [<c0535348>] (rollback_registered_many+0xd4/0x204) from
[<c0537c6c>] (unregister_netdevice_queue+0x98/0xf4)
[28502.324381] [<c0537c6c>] (unregister_netdevice_queue+0x98/0xf4)
from [<c0537cf0>] (unregister_netdev+0x28/0x30)
[28502.324395] [<c0537cf0>] (unregister_netdev+0x28/0x30) from
[<bf009610>] (usbnet_disconnect+0x8c/0xe4 [usbnet])
[28502.324412] [<bf009610>] (usbnet_disconnect+0x8c/0xe4 [usbnet])
from [<c04266f4>] (usb_unbind_interface+0x70/0x170)
[28502.324429] [<c04266f4>] (usb_unbind_interface+0x70/0x170) from
[<c03c8648>] (__device_release_driver+0xac/0xf8)
[28502.324443] [<c03c8648>] (__device_release_driver+0xac/0xf8) from
[<c03c8c70>] (driver_detach+0x94/0xbc)
[28502.324455] [<c03c8c70>] (driver_detach+0x94/0xbc) from
[<c03c81b0>] (bus_remove_driver+0x78/0xc4)
[28502.324467] [<c03c81b0>] (bus_remove_driver+0x78/0xc4) from
[<c03c92c8>] (driver_unregister+0x54/0x78)
[28502.324480] [<c03c92c8>] (driver_unregister+0x54/0x78) from
[<c0425b4c>] (usb_deregister+0x6c/0xd4)
[28502.324495] [<c0425b4c>] (usb_deregister+0x6c/0xd4) from
[<bf31c82c>] (cleanup_module+0x14/0x7e8 [asix])
[28502.324518] [<bf31c82c>] (cleanup_module+0x14/0x7e8 [asix]) from
[<c0177c88>] (sys_delete_module+0x1c4/0x254)
[28502.324532] [<c0177c88>] (sys_delete_module+0x1c4/0x254) from
[<c0106080>] (ret_fast_syscall+0x0/0x30)
[28502.324547] CPU3: stopping
[28502.324565] Backtrace:
[28502.324610] [<c010d3d0>] (unwind_backtrace+0x0/0x118) from
[<c060914c>] (dump_stack+0x28/0x30)
[28502.324637] [<c060914c>] (dump_stack+0x28/0x30) from [<c010bcb8>]
(handle_IPI+0xf0/0x170)
[28502.324664] [<c010bcb8>] (handle_IPI+0xf0/0x170) from [<c0100430>]
(gic_handle_irq+0x68/0x70)
[28502.324692] [<c0100430>] (gic_handle_irq+0x68/0x70) from
[<c0105e00>] (__irq_usr+0x40/0x60)
[28502.324708] Exception stack(0xed205fb0 to 0xed205ff8)
[28502.324726] 5fa0:                                     00000000
00000100 00000099 ffffff67
[28502.324747] 5fc0: b859b140 b84dc8c0 00000100 00000000 00000000
00000000 00000000 00000001
[28502.324767] 5fe0: b292a5a1 abbbdf08 b5fbbded b292a5a0 80000030 ffffffff
[28502.324781] CPU2: stopping
[28502.324794] Backtrace:
[28502.324822] [<c010d3d0>] (unwind_backtrace+0x0/0x118) from
[<c060914c>] (dump_stack+0x28/0x30)
[28502.324848] [<c060914c>] (dump_stack+0x28/0x30) from [<c010bcb8>]
(handle_IPI+0xf0/0x170)
[28502.324873] [<c010bcb8>] (handle_IPI+0xf0/0x170) from [<c0100430>]
(gic_handle_irq+0x68/0x70)
[28502.324897] [<c0100430>] (gic_handle_irq+0x68/0x70) from
[<c0105c80>] (__irq_svc+0x40/0x50)
[28502.324912] Exception stack(0xed357e38 to 0xed357e80)
[28502.324928] 7e20:
    c097c000 00000000
[28502.324951] 7e40: 00000000 c195c195 c0a0df48 c097f820 00000c01
000003fe b6e01d95 ea587800
[28502.324974] 7e60: 00000064 ed357e8c ed357e80 ed357e80 c060db6c
c060db70 60000013 ffffffff
[28502.324999] [<c0105c80>] (__irq_svc+0x40/0x50) from [<c060db70>]
(_raw_spin_unlock_irq+0x1c/0x20)
[28502.325027] [<c060db70>] (_raw_spin_unlock_irq+0x1c/0x20) from
[<c0125484>] (do_syslog+0x36c/0x5f0)
[28502.325058] [<c0125484>] (do_syslog+0x36c/0x5f0) from [<c02546fc>]
(kmsg_read+0x3c/0x64)
[28502.325089] [<c02546fc>] (kmsg_read+0x3c/0x64) from [<c02484f0>]
(proc_reg_read+0x90/0xa4)
[28502.325117] [<c02484f0>] (proc_reg_read+0x90/0xa4) from
[<c01f88a8>] (vfs_read+0xb8/0x148)
[28502.325143] [<c01f88a8>] (vfs_read+0xb8/0x148) from [<c01f8ae0>]
(sys_read+0x5c/0xa4)
[28502.325168] [<c01f8ae0>] (sys_read+0x5c/0xa4) from [<c0106080>]
(ret_fast_syscall+0x0/0x30)
[28502.325184] task_migration_notifier = c0936778
[28502.325207] page containing tmn: c0936758: 00000001 00000000
dead4ead ffffffff
[28502.325228] page containing tmn: c0936768: ffffffff c093676c
c093676c 00000000
[28502.325248] page containing tmn: c0936778: 00000000 dead4ead
ffffffff ffffffff
[28502.325267] page containing tmn: c0936788: 00000000 c014f914
c014f8f0 00000000
[28502.325286] page containing tmn: c0936798: 00000000 00000000
00000000 00000000
[28502.325301] page containing tmn: c09367a8: 00000000
[28502.325329] CPU0 PC: <c011c828> exynos5_panic_notify+0x54/0xb0

--001a11c32c366d0ab904f444d6e1
Content-Type: application/octet-stream; name=reload_asix
Content-Disposition: attachment; filename=reload_asix
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hsm1a48q0

IyEvYmluL2Jhc2ggLXgKIwojIDEpIGVkaXQgRVRIIHZhcmlhYmxlIHRvIG1hdGNoIHRhcmdldCBt
YWNoaW5lCiMgMikgc2NwIHJlbG9hZF9hc2l4IHJvb3RAJElQOi90bXAKIyAzKSBzZXQgVD0icm9v
dEAkSVAiCiMKIyB0aGVuIGludm9rZSBvbiBhICJob3N0IiBtYWNoaW5lIChpbiBjaHJvb3QpIHdp
dGg6CiMgZm9yIGkgaW4gYHNlcSAxMDAwMGA7IGRvCiMJZWNobyAtbiAiUkVMT0FEICRpICAiCiMJ
c3NoICRUICcuIC90bXAvcmVsb2FkX2FzaXggZXRoMCAxMDBfZnVsbCcKIwlKPSQ/IDsgaWYgWyAk
SiAtZXEgMjU1IF0gOyB0aGVuIGVjaG8gIiAgU1NIIHRpbWVvdXQiIDsgYnJlYWsgOyBmaQojCXNz
aCAkVCAiY2F0IC90bXAvcmVsb2FkLWFzaXgub3V0IgojCWlmIFsgJEogLW5lIDAgXSA7IHRoZW4g
ZWNobyAiICBFUlJPUiAkSiIgOyBmaQojCXNsZWVwIDMKIyBkb25lIHwgdGVlIHJlbG9hZF9hc2l4
LWxvb3Aub3V0CgpFVEg9IiQxIgoKRFJJVkVSPSQoZXRodG9vbCAtaSAkRVRIIHwgYXdrICcvZHJp
dmVyOi8geyBwcmludCAkMiB9JykKCiMgZS5nLiBMSU5LU1A9IjEwMDBfZnVsbCIgb3IgIjEwMF9m
dWxsIgojICIkKGNhdCAvc3lzL2NsYXNzL25ldC8kRVRIL3NwZWVkKV8kKGNhdCAvc3lzL2NsYXNz
L25ldC8kRVRIL2R1cGxleCkiCiMgV2UgY2FuJ3QgcmVhZCBpdCBoZXJlIHNpbmNlIGN1cnJlbnQg
c3RhdGUgbWlnaHQgYmUgd2VkZ2VkIGZyb20KIyBwcmV2aW91cyBpdGVyYXRpb24uIFRvZ2dsaW5n
IGF1dGhvcml6ZWQgZmllbGQgbWlnaHQgZml4IGl0LgpMSU5LU1A9IiQyIgoKIyBhc3N1bWluZyBv
bmx5IG9uZSBBU0lYIGRldmljZSBpcyBwbHVnZ2VkIGluLi4ucmVhbGx5IHdhbnQgdG8ga2V5IG9m
ZiAkRVRICkFVVEg9JChmaW5kIC9zeXMvZGV2aWNlcyAtbmFtZSBtYW51ZmFjdHVyZXIgfCB4YXJn
cyBmZ3JlcCAtbCBBU0lYIHwgc2VkICdzL21hbnVmYWN0dXJlci9hdXRob3JpemVkLycpCgojIHJl
ZGlyZWN0IGFsbCBvdXRwdXQgdG8gYSBmaWxlLiBTU0ggbWlnaHQgZHJvcC4KIyBleGVjID4gL3Rt
cC9gZGF0ZSAgLS1yZmMtMzMzOT1kYXRlYC1yZWxvYWQtJCQub3V0IDI+JjEKZXhlYyA+IC92YXIv
bG9nL3JlbG9hZC0kRFJJVkVSLm91dCAyPiYxCgplY2hvIC1uICIkKGRhdGUgKyIlWSVtJWQlSCVN
JVMiKSIKCm1hYz0iJChjYXQgL3N5cy9jbGFzcy9uZXQvJEVUSC9hZGRyZXNzKSIKaXA9IiQoaWZj
b25maWcgJEVUSCB8IGF3ayAnL2luZXQgLyB7IHByaW50ICQyfScpIgpybW1vZCAkRFJJVkVSCgoj
IHNpZGUgZWZmZWN0IG9mIGF1dGgvZGVhdXRoIGlzIGEgVVNCIHJlc2V0IG9uIHJlY29ubmVjdC4g
OikKZWNobyAwID4gJEFVVEgKc2xlZXAgMQoKbW9kcHJvYmUgJERSSVZFUgoKZWNobyAxID4gJEFV
VEgKc2xlZXAgMQoKbWFjMj0iJChjYXQgL3N5cy9jbGFzcy9uZXQvJEVUSC9hZGRyZXNzKSIKaWYg
WyAiJG1hYyIgIT0gIiRtYWMyIiBdIDsgdGhlbgoJZWNobyAiICBNQUMgbWlzbWF0Y2ggYmVmb3Jl
IGxpbms6ICRtYWMgIT0gJG1hYzIgIHJlcmVhZDogJChjYXQgL3N5cy9jbGFzcy9uZXQvJEVUSC9h
ZGRyZXNzKSIKCWV4aXQgMjU0CmZpCgpsZXQgaT0wCmw9Ik5VTEwiCndoaWxlIFsgIiRsIiAhPSAi
JExJTktTUCIgLWEgICRpIC1sdCA2MCBdIDsgZG8KCXNsZWVwIDEKCWxldCBpKz0xCglsPSIkKGNh
dCAvc3lzL2NsYXNzL25ldC8kRVRIL3NwZWVkKV8kKGNhdCAvc3lzL2NsYXNzL25ldC8kRVRIL2R1
cGxleCkiCmRvbmUKCnByaW50ZiAiICBMSU5LICVzICglZCBzZWMpIiAiJGwiICRpCgptYWMyPSIk
KGNhdCAvc3lzL2NsYXNzL25ldC8kRVRIL2FkZHJlc3MpIgppZiBbICIkbWFjIiAhPSAiJG1hYzIi
IF0gOyB0aGVuCgllY2hvCgllY2hvICIgIE1BQyBtaXNtYXRjaCBhZnRlciBsaW5rOiAkbWFjICE9
ICRtYWMyICByZXJlYWQ6ICQoY2F0IC9zeXMvY2xhc3MvbmV0LyRFVEgvYWRkcmVzcykiCglleGl0
IDI1MwpmaQoKaWYgWyAiJGwiICE9ICIkTElOS1NQIiBdIDsgdGhlbgoJZXhpdCAyNTIKZmkKCmxl
dCBpPTAKaXAyPSIgIgp3aGlsZSBbICRpIC1sdCA2MCBdIDsgZG8KICAgc2xlZXAgMQogICBsZXQg
aSs9MQogICAKICAgaXAyPSIkKGlmY29uZmlnICRFVEggfCBhd2sgJy9pbmV0IC8geyBwcmludCAk
Mn0nKSIKICAgaWYgWyAiJGlwIiA9ICIkaXAyIiBdIDsgdGhlbgogICAgICBwcmludGYgIiAgSVAg
JXMgKCVkIFNlYylcbiIgJGlwICRpCiAgICAgIGV4aXQgMAogICBmaQpkb25lCgpleGl0IDI1MQo=
--001a11c32c366d0ab904f444d6e1--
