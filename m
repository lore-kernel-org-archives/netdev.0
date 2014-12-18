From: =?UTF-8?B?RXJpayBBbGFww6TDpA==?= <erik.alapaa@gmail.com>
Subject: bugreport: Netdev watchdog timeout on wwan0 and soft lockup CPU #0,
 huawei E3276 modem always fails on GSM UDP up/downlink
Date: Thu, 18 Dec 2014 07:30:13 +0100
Message-ID: <CAByO_s1P+XNv4TWOdn3XxJcLhpbm+PhuZfWSC+kRyhBoY2_Q5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:50741 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbaLRGaU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 01:30:20 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so1838362obc.4
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 22:30:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disclaimer: This involves a mobile (cellular) (GSM/WCDMA/LTE) modem, bu=
t since
the crash involves netdev watchdog and a soft lockup of CPU #0 (see
trace below),
I post here. If doing so is not appropriate, I apologize beforehand.

Problem: up/dowlink UDP with iperf3 over GSM crashes Huawei E3276 USB
modem on 32-bit Debian-stable (wheezy) with 3.13 kernel and newer
kernels. Error also seen on 64-bit machines/Linux kernels.

Keywords: huawei_cdc_ncm, GSM, cdc-wdm, wwan0, netdev watchdog

Detailed problem description: Sending/receiving UDP 100+100kbit/s
up-and-downlink UDP traffic with 2 iperf3 processes over a Huawei
E3276 USB modem in GSM mode (GSM RAT) *always* fails after 3-15
minutes. Modem disconnects and kernel log shows 'NETDEV WATCHDOG:
wwan0 (huawei_cdc_ncm): transmit queue 0 timed out'. Also causes a soft
lockup of CPU #0.

Reproduced on a range of real and virtualized systems, all running Debi=
an
or Kubuntu Linux with Linux kernel supporting the modem (3.13 and highe=
r).
Output below is from a debian-jessie (unstable) system with custom-buil=
t dbg
kernel, but debian wheezy (stable) also reproduces same bug.

A clean way to reproduce is to use a clean debian wheezy install and
only adding iperf3 and a 3.16 kernel from debian-unstable.

At the end of this post I paste an excerpt from kern.log, if more logs
etc are needed I can provide them.

Command line of test application (showing uplink iperf UDP/GSM,
downlink is the same but with -R switch):

'./iperf3 -B <MODEM DHCP ADDR> -u -t 3600 -i 5 -p 5503 -b 100K -c <IP
ADDR OF IPERF SERVER>'

Distribution: debian-unstable

Kernel version: 3.16.7, vanilla debian unstable 3.17.0-trunk-686-pae,
3.17.2. All kernels that support the E3276 modem (kernels from 3.13
and upward) seem to fail.

Kernel modules: huawei_cdc_ncm, cdc_ncm, cdc_wdm, usb_wwan

Modem firmware version: 21.436.03.00.00

Lsusb showing modem/vendor id:
Bus 003 Device 027: ID 12d1:1506 Huawei Technologies Co., Ltd. E398
LTE/UMTS/GSM Modem/Networkcard

Output of lsb_release -a:
Distributor ID: Debian
Description:    Debian GNU/Linux 8.0 (jessie)
Release:        8.0
Codename:       jessie


Additional info: E3276 modem seems to be stable in Windows, so it may
be an issue with the huawei_cdc_ncm driver in Linux. But it may still
be a modem hw/firmware issue, and the netdev watchdog timeout on wwan0
could be caused by modem firmware crash. Modem also works much better
in Linux when using 3G (WCDMA) or 4G (LTE) instead of 2G (GSM).

Merry Christmas,

/Erik Alap=C3=A4=C3=A4

Excerpt from kern.log:

Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877612] ------------[ cut
here ]------------
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877647] WARNING: CPU: 0 PID:
0 at /build/linux-n7UL8Q/linux-3.17.4/net/sched/sch_generic.c:264
dev_watchdog+0x1ec/0x200()
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877649] NETDEV WATCHDOG:
wwan0 (huawei_cdc_ncm): transmit queue 0 timed out
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877650] Modules linked in:
huawei_cdc_ncm nls_utf8 udf isofs crc_itu_t ppdev lp rfcomm bnep
binfmt_misc uinput nfsd auth_rpcgss oid_registry nfs_acl nfs lockd
fscache sunrpc loop cdc_wdm option usb_storage usb_wwan cdc_ncm
usbserial usbnet snd_ens1371 snd_seq_midi snd_seq_midi_event
snd_rawmidi ecb btusb bluetooth rfkill snd_ac97_codec snd_pcm snd_seq
snd_seq_device snd_timer snd coretemp soundcore psmouse vmw_balloon
ac97_bus serio_raw crc32_pclmul aesni_intel aes_i586 xts lrw gf128mul
ablk_helper cryptd evdev gameport pcspkr parport_pc parport vmwgfx
shpchp ttm drm_kms_helper drm i2c_piix4 i2c_core processor thermal_sys
vmw_vmci button battery ac ext4 crc16 mbcache jbd2 sr_mod cdrom sg
ata_generic hid_generic usbhid hid sd_mod crc_t10dif crct10dif_common
crc32c_intel floppy ehci_pci uhci_hcd ehci_hcd pcnet32 mii usbcore
usb_common ata_piix mptspi scsi_transport_spi mptscsih mptbase libata
scsi_mod [last unloaded: huawei_cdc_ncm]
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877768] CPU: 0 PID: 0 Comm:
swapper/0 Not tainted 3.17.0-trunk-686-pae #1 Debian 3.17.4-1~exp1
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877769] Hardware name:
VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform,
BIOS 6.00 07/31/2013
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877770]  00000000 de409ef4
c149bcff de409f04 c10598a8 c15d8868 de409f20 00000000
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877772]  c15d88a4 00000108
c13de8bc 00000108 c13de8bc 00000009 db25b800 fff09a96
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877773]  fffffb7e de409f0c
c10598f3 00000009 de409f04 c15d8868 de409f20 de409f40
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877775] Call Trace:
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877780]  [<c149bcff>] ?
dump_stack+0x3e/0x4e
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877785]  [<c10598a8>] ?
warn_slowpath_common+0x88/0xa0
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877787]  [<c13de8bc>] ?
dev_watchdog+0x1ec/0x200
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877788]  [<c13de8bc>] ?
dev_watchdog+0x1ec/0x200
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877789]  [<c10598f3>] ?
warn_slowpath_fmt+0x33/0x40
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877790]  [<c13de8bc>] ?
dev_watchdog+0x1ec/0x200
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877796]  [<c10acb20>] ?
call_timer_fn+0x30/0x100
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877799]  [<c108ccf7>] ?
__wake_up+0x37/0x50
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877801]  [<c10a7a1f>] ?
rcu_report_qs_rnp+0xbf/0x100
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877802]  [<c13de6d0>] ?
dev_graft_qdisc+0x70/0x70
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877804]  [<c10ae476>] ?
run_timer_softirq+0x186/0x250
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877805]  [<c13de6d0>] ?
dev_graft_qdisc+0x70/0x70
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877807]  [<c105d43c>] ?
__do_softirq+0xec/0x240
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877809]  [<c105d350>] ?
cpu_callback+0x180/0x180
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877844]  [<c1011a06>] ?
do_softirq_own_stack+0x26/0x30
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877845]  <IRQ>  [<c105d705>]
? irq_exit+0x95/0xa0
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877849]  [<c14a2138>] ?
smp_apic_timer_interrupt+0x38/0x50
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877850]  [<c14a187c>] ?
apic_timer_interrupt+0x34/0x3c
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877863]  [<c104b822>] ?
native_safe_halt+0x2/0x10
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877866]  [<c101873c>] ?
default_idle+0x1c/0xa0
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877868]  [<c1018ece>] ?
arch_cpu_idle+0xe/0x10
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877869]  [<c108d653>] ?
cpu_startup_entry+0x303/0x340
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877871]  [<c108cb6f>] ?
__wake_up_locked+0x1f/0x30
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877873]  [<c16a5ab8>] ?
start_kernel+0x38d/0x393
Dec 15 13:12:10 vmw-wheezy kernel: [ 4336.877874] ---[ end trace
07cf0823922200f7 ]---
Dec 15 13:12:20 vmw-wheezy kernel: [ 4346.939769] option1 ttyUSB0: GSM
modem (1-port) converter now disconnected from ttyUSB0
Dec 15 13:12:20 vmw-wheezy kernel: [ 4346.939779] option 2-1:1.0:
device disconnected
Dec 15 13:12:20 vmw-wheezy kernel: [ 4346.940770] option1 ttyUSB1: GSM
modem (1-port) converter now disconnected from ttyUSB1
Dec 15 13:12:20 vmw-wheezy kernel: [ 4346.940777] option 2-1:1.1:
device disconnected
Dec 15 13:12:20 vmw-wheezy kernel: [ 4346.941098] huawei_cdc_ncm
2-1:1.2 wwan0: unregister 'huawei_cdc_ncm' usb-0000:02:03.0-1, Huawei
CDC NCM device
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884677] NMI watchdog: BUG:
soft lockup - CPU#0 stuck for 24s! [usb-storage:7203]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884683] Modules linked in:
huawei_cdc_ncm nls_utf8 udf isofs crc_itu_t ppdev lp rfcomm bnep
binfmt_misc uinput nfsd auth_rpcgss oid_registry nfs_acl nfs lockd
fscache sunrpc loop cdc_wdm option usb_storage usb_wwan cdc_ncm
usbserial usbnet snd_ens1371 snd_seq_midi snd_seq_midi_event
snd_rawmidi ecb btusb bluetooth rfkill snd_ac97_codec snd_pcm snd_seq
snd_seq_device snd_timer snd coretemp soundcore psmouse vmw_balloon
ac97_bus serio_raw crc32_pclmul aesni_intel aes_i586 xts lrw gf128mul
ablk_helper cryptd evdev gameport pcspkr parport_pc parport vmwgfx
shpchp ttm drm_kms_helper drm i2c_piix4 i2c_core processor thermal_sys
vmw_vmci button battery ac ext4 crc16 mbcache jbd2 sr_mod cdrom sg
ata_generic hid_generic usbhid hid sd_mod crc_t10dif crct10dif_common
crc32c_intel floppy ehci_pci uhci_hcd ehci_hcd pcnet32 mii usbcore
usb_common ata_piix mptspi scsi_transport_spi mptscsih mptbase libata
scsi_mod [last unloaded: huawei_cdc_ncm]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884740] CPU: 0 PID: 7203
Comm: usb-storage Tainted: G        W      3.17.0-trunk-686-pae #1
Debian 3.17.4-1~exp1
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884742] Hardware name:
VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform,
BIOS 6.00 07/31/2013
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884744] task: dbfc4ab0 ti:
db27a000 task.ti: db27a000
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884778] EIP:
0060:[<c14a064f>] EFLAGS: 00000286 CPU: 0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884783] EIP is at
_raw_spin_unlock_irqrestore+0xf/0x20
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884785] EAX: 00000286 EBX:
00000000 ECX: 00000000 EDX: 00000286
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884786] ESI: 00000000 EDI:
db12c400 EBP: db27bb34 ESP: db27bb34
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884787]  DS: 007b ES: 007b
=46S: 00d8 GS: 00e0 SS: 0068
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884789] CR0: 80050033 CR2:
b77c5000 CR3: 1d4fb000 CR4: 001407f0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884837] Stack:
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884838]  db27bbe0 e09f41e3
11c37a72 0000000d dbfc4af4 dbfc4af4 0000647d db27bb8c
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884841]  e0806090 e0806054
db120001 00000006 dcf70ce0 00000004 e0806050 00000001
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884844]  00000286 db12c624
0000000d 00000001 dfff5648 d5472700 de400040 db27bbe0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884847] Call Trace:
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884858]  [<e09f41e3>] ?
ehci_hub_control+0xf3/0xc80 [ehci_hcd]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884893]  [<c1167b9d>] ?
__kmalloc+0x37d/0x3f0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884896]  [<c1081ec2>] ?
set_next_entity+0x52/0x70
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884898]  [<c1087d0d>] ?
pick_next_task_fair+0x8ed/0xa30
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884929]  [<e08d9659>] ?
usb_hcd_submit_urb+0x339/0x9d0 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884947]  [<c100e6dc>] ?
__switch_to+0x11c/0x480
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884954]  [<c10accd3>] ?
lock_timer_base.isra.39+0x23/0x50
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884960]  [<e08db5ee>] ?
usb_start_wait_urb+0x4e/0x140 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884965]  [<e08db787>] ?
usb_control_msg+0xa7/0xe0 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884967]  [<c149de4e>] ?
wait_for_completion_timeout+0x8e/0xe0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884972]  [<e08cec40>] ?
set_port_feature+0x50/0x60 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884982]  [<e08d067e>] ?
hub_port_reset+0x9e/0x600 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884984]  [<c115f17a>] ?
dma_pool_free+0x2a/0x100
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884988]  [<e09eb9f1>] ?
qh_destroy+0x61/0xa0 [ehci_hcd]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884992]  [<e08d0c56>] ?
hub_port_init+0x76/0xcb0 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884996]  [<e09f284d>] ?
ehci_endpoint_disable+0x2d/0x1c0 [ehci_hcd]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.884999]  [<c107d5bb>] ?
try_to_wake_up+0x13b/0x2d0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885004]  [<e08d19b9>] ?
usb_reset_and_verify_device+0x129/0x730 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885006]  [<c1073792>] ?
__blocking_notifier_call_chain+0x42/0x60
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885007]  [<c10737cf>] ?
blocking_notifier_call_chain+0x1f/0x30
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885009]  [<c149e3f0>] ?
mutex_lock+0x10/0x30
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885014]  [<e08d20ce>] ?
usb_reset_device+0x10e/0x280 [usbcore]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885019]  [<e0ed7644>] ?
usb_stor_Bulk_transport+0x194/0x3e0 [usb_storage]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885021]  [<e0ed7de0>] ?
usb_stor_port_reset+0x50/0x60 [usb_storage]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885023]  [<e0ed7e60>] ?
usb_stor_invoke_transport+0x70/0x4c0 [usb_storage]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885025]  [<c107b07e>] ?
check_preempt_curr+0x6e/0x80
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885027]  [<c107b0a8>] ?
ttwu_do_wakeup+0x18/0x140
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885029]  [<c149e1c5>] ?
wait_for_completion_interruptible+0x95/0x180
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885031]  [<c107d7b0>] ?
wake_up_state+0x10/0x10
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885034]  [<e0ed93cf>] ?
usb_stor_control_thread+0x13f/0x230 [usb_storage]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885037]  [<c108cb6f>] ?
__wake_up_locked+0x1f/0x30
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885039]  [<e0ed9290>] ?
usb_stor_disconnect+0xc0/0xc0 [usb_storage]
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885041]  [<c1072808>] ?
kthread+0xa8/0xc0
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885044]  [<c14a0e41>] ?
ret_from_kernel_thread+0x21/0x30
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885046]  [<c1072760>] ?
kthread_create_on_node+0x110/0x110
Dec 15 13:12:57 vmw-wheezy kernel: [ 4383.885047] Code: 5b 5e 5f 5d c3
80 43 04 01 fb 90 8d 74 26 00 eb e5 31 c0 eb e8 90 90 90 90 90 90 90
55 89 e5 3e 8d 74 26 00 80 00 01 89 d0 50 9d <8d> 74 26 00 5d c3 8d 74
26 00 8d bc 27 00 00 00 00 55 89 e5 3e
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.380743] usb 2-1: USB
disconnect, device number 4
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.380789] option 2-1:1.0: GSM
modem (1-port) converter detected
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.381527] usb 2-1: GSM modem
(1-port) converter now attached to ttyUSB0
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.381547] option 2-1:1.1: GSM
modem (1-port) converter detected
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.382038] usb 2-1: GSM modem
(1-port) converter now attached to ttyUSB1
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.382117] option1 ttyUSB0: GSM
modem (1-port) converter now disconnected from ttyUSB0
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.382122] option 2-1:1.0:
device disconnected
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.382159] option1 ttyUSB1: GSM
modem (1-port) converter now disconnected from ttyUSB1
Dec 15 13:12:59 vmw-wheezy kernel: [ 4385.382163] option 2-1:1.1:
device disconnected
Dec 15 13:19:17 vmw-wheezy kernel: [ 4763.866455] usbcore:
deregistering interface driver huawei_cdc_ncm
Dec 15 13:19:21 vmw-wheezy kernel: [ 4767.064010] usbcore: registered
new interface driver huawei_cdc_ncm
=EF=BF=BC
