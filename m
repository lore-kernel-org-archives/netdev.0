From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: d80211 sysfs
Date: Sat, 8 Jul 2006 14:05:08 +0200
Message-ID: <a32f33a40607080505wd3c9200sdf50ff814fd5afb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:11128 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S964793AbWGHMFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 08:05:09 -0400
Received: by py-out-1112.google.com with SMTP id 57so426118pya
        for <netdev@vger.kernel.org>; Sat, 08 Jul 2006 05:05:09 -0700 (PDT)
To: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have recently updated the 80211 stack located in the rt2x00 CVS tree to
use the latest version of the stack from the dscape#devel git tree.
I also added the scanning patch from GertJan that was only available
in the dscape#main tree.

Since I didn't want to loose any tested because of the new field in
the net_device structure,
I have used the base_addr field instead and used the following access functions:

static inline void* get_80211_ptr(struct net_device *dev)
{
	return (void*)dev->base_addr;
}

static inline void set_80211_ptr(struct net_device *dev, void* ptr)
{
	dev->base_addr = (unsigned long)ptr;
}

But since this update my testers are reporting the following issue:

unmounting old /sys
INIT: version 2.86 booting
Welcome to Fedora Core
Press 'I' to enter interactive startup.
Setting clock (localtime): Tue Jul 4 21:59:40 BST 2006
[ OK ]
Starting udev: ------------[ cut here ]------------
kernel BUG at fs/sysfs/symlink.c:88!
invalid opcode: 0000 [#1]
SMP
last sysfs file: /class/usb_device/usbdev5.1/dev
Modules linked in: rt2500usb(U) 80211(U) tuner
snd_intel8x0 snd_ac97_codec snd_ac97_bus snd_seq_dummy
snd_seq_oss snd_seq_midi_event snd_seq ohci1394
ieee1394 saa7134 video_buf compat_ioctl32 v4l2_common
v4l1_compat ir_kbd_i2c ir_common snd_seq_device
ehci_hcd uhci_hcd 8139cp sg snd_pcm_oss snd_mixer_oss
videodev nvidia(U) snd_pcm 8139too mii snd_timer snd
e1000 soundcore snd_page_alloc i2c_i801 i2c_core
hw_random i82875p_edac edac_mc ext3 jbd ata_piix
sata_promise libata aic7xxx scsi_transport_spi sd_mod
scsi_mod
CPU: 2
EIP: 0060:[<c019bca4>] Tainted: P VLI
EFLAGS: 00010246 (2.6.16-1.2133_FC5smp #1)
EIP is at sysfs_create_link+0x17/0xd3
eax: f6f442fc ebx: f6f46470 ecx: f8d61cd2 edx: f6d8f090
esi: f8d61cd2 edi: f6f442fc ebp: 00000000 esp: f6c8cd50
ds: 007b es: 007b ss: 0068
Process modprobe (pid: 1722, threadinfo=f6c8c000
task=c33f95b0)
Stack: <0>f6d8f090 ffffffff ffffffff f6f46470 f6f44000
f6f442fc 00000000 f8d5ac59
f6f46470 f6d8f000 f6f44000 f8d4e982 00000000 00000000
f6f46470 f6f46460
00000010 f8ba4d80 f6f44000 f6f46468 14850001 dead4ead
d7851400 0000100a
Call Trace:
[<f8d5ac59>] ieee80211_sysfs_add_netdevice+0x20/0x55
[80211] [<f8d4e982>] ieee80211_register_hw+0xbe/0x20e
[80211]
[<f8ba4d80>] rt2500usb_alloc_dev+0x387/0x995
[rt2500usb] [<c023d34a>] __driver_attach+0x0/0x8f
[<f8ba6be0>] rt2500usb_probe+0x55/0x80 [rt2500usb]
[<c02769e2>] usb_probe_interface+0x58/0x86
[<c023d295>] driver_probe_device+0x42/0x8b [<c023d3af>]
__driver_attach+0x65/0x8f
[<c023cd8b>] bus_for_each_dev+0x33/0x55 [<c023d1f9>]
driver_attach+0x11/0x13
[<c023d34a>] __driver_attach+0x0/0x8f [<c023caac>]
bus_add_driver+0x64/0xfd
[<c02767e5>] usb_register_driver+0x73/0xd0 [<c013bfdb>]
sys_init_module+0x1701/0x18a8
[<c0160d8e>] __kmalloc+0x0/0x81 [<c01639fb>]
do_sync_read+0xb8/0xf3
[<c0134c83>] autoremove_wake_function+0x0/0x2d
[<c0163943>] do_sync_read+0x0/0xf3
[<c01642c5>] vfs_read+0x9f/0x13e [<c0164711>]
sys_read+0x3c/0x63
[<c0103db9>] syscall_call+0x7/0xb <0>Code: 81 20 31 c0
83 c4 10 5b 5e 5f 5d c3 8b 40 30 e9 f1 e4 ff ff 55 57
56 53 83 ec 0c 89 14 24 89 ce 8b 68 30 85 ed 74 04 85
c9 75 08 <0f> 0b 58 00 f7 c0 31 c0 8b 45 18 83 e8 80 e8
e4 bf 15 00 8b 45

The kernel BUG at fs/sysfs/symlink.c:88! means that the "dev" argument
in ieee80211_sysfs_add_netdevice has a problem since
dev->class_dev.kobj or dev->class_dev.kobj.dentry are NULL.

Could this problem be caused by my compatibility hack (which is indeed
ugly, but if I want testers that are willing to test rt2x00, than I
have to workaround that ieee80211_ptr field)
or is this some issue in the dscape stack?

Thanks.

Ivo
