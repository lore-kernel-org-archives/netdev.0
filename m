From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Regression due to: net/usbnet: avoid recursive locking in usbnet_stop()
Date: Thu, 22 Mar 2012 16:56:52 -0600
Message-ID: <4F6BAE34.7010805@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Willy Tarreau <willy-859RlTSWH48dnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It looks like commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d
"net/usbnet: avoid recursive locking in usbnet_stop()" causes a problem
for me.

When I reboot or shutdown, I see the error spew below at least 50% of
the time. Reverting the above patch fixes this, at least for 10 reboot
attempts.

Other notes:
* I'm running on an NVIDIA Tegra ARM device, with smsc95xx USB ethernet.
* This first happens in next-20120309, not in next-20120308.
* The problematic commit appears to have been queued for backport to
various stable branches:-(

> Will now restart.
> [ 85.622493] Unable to handle kernel paging request at virtual address 6b6b6bfb
> [ 85.629748] pgd = eea68000
> [ 85.632477] [6b6b6bfb] *pgd=00000000
> [ 85.636096] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
> [ 85.641426] Modules linked in:
> [ 85.644527] CPU: 0 Not tainted (3.3.0-rc7-next-20120319-00027-gee679a3 #30)
> [ 85.651879] PC is at kobject_put+0xc/0x74
> [ 85.655936] LR is at usb_hcd_unlink_urb+0x68/0xc4
> [ 85.660675] pc : [<c019fb14>] lr : [<c0228db4>] psr: 20000013
> [ 85.660695] sp : ee8c7e08 ip : ffffac43 fp : 00000000
> [ 85.672198] r10: c057e190 r9 : ee87e0c0 r8 : ee83ac00
> [ 85.677448] r7 : a0000013 r6 : ffffff98 r5 : ee87e0c0 r4 : 6b6b6bdb
> [ 85.684000] r3 : ee82c800 r2 : ef1b6800 r1 : a0000013 r0 : 6b6b6bdb
> [ 85.690554] Flags: nzCv IRQs on FIQs on Mode SVC_32 ISA ARM Segment user
> [ 85.697716] Control: 10c5387d Table: 2ea6804a DAC: 00000015
> [ 85.703485] Process reboot (pid: 1528, stack limit = 0xee8c62f0)
> [ 85.709516] Stack: (0xee8c7e08 to 0xee8c8000)
> [ 85.713908] 7e00: 6b6b6bdb a0000013 00000000 c0228db4 ee87e0c0 ffffff98
> [ 85.722132] 7e20: ee82c800 ee83acd4 00000000 ee926bb8 ee83acc8 c02180f8 ee83ac00 ee83acc8
> [ 85.730353] 7e40: ee83acdc ee8c6000 00000000 ee83ba00 c057e190 c02181fc 00000000 00000000
> [ 85.738575] 7e60: eea53a40 c004a820 ee8c7e78 ee8c7e78 00000000 00000000 ee8c7e68 ee8c7e68
> [ 85.746796] 7e80: 00000000 ee83a800 ee83ac00 c03bb8f8 00000001 00000000 ee83ba0c c02191c8
> [ 85.755017] 7ea0: ee83a800 00000200 ee8c7ed0 ee83a800 00001003 00000001 00000000 c02ba42c
> [ 85.763239] 7ec0: ee83a858 ee83a800 00001042 c02ba480 ee83a858 ee83a858 c02bd224 c02bd4c4
> [ 85.771459] 7ee0: 00000000 ee83a800 00001003 ee83a800 beca7468 c02bd5b4 ee917840 00000000
> [ 85.779679] 7f00: ee83a800 c0302dfc ee83a828 beca7468 30687465 00000000 00000000 00000000
> [ 85.787899] 7f20: 00001042 71cc140a 00000000 00000000 30687465 00008914 beca7468 00008914
> [ 85.796120] 7f40: 00000003 c000e264 ee8c6000 00000000 beca7470 c02a974c ee9a0080 beca7468
> [ 85.804342] 7f60: 00008914 c00be058 ee9a0080 00000003 00008914 ee9a0080 beca7468 00008914
> [ 85.812562] 7f80: 00000003 c00be0c4 00000003 00000000 beca7468 00000000 beca746a beca7468
> [ 85.820782] 7fa0: 00000036 c000e0e0 00000000 beca746a 00000003 00008914 beca7468 00001042
> [ 85.829003] 7fc0: 00000000 beca746a beca7468 00000036 beca7468 00000001 beca7468 beca7470
> [ 85.837224] 7fe0: 00000000 beca7460 000095bc b6f1bcec 20000010 00000003 e0836006 e2044fff
> [ 85.845470] [<c019fb14>] (kobject_put+0xc/0x74) from [<c0228db4>] (usb_hcd_unlink_urb+0x68/0xc4)
> [ 85.854336] [<c0228db4>] (usb_hcd_unlink_urb+0x68/0xc4) from [<c02180f8>] (unlink_urbs+0x44/0xa8)
> [ 85.863270] [<c02180f8>] (unlink_urbs+0x44/0xa8) from [<c02181fc>] (usbnet_terminate_urbs+0xa0/0x15c)
> [ 85.872547] [<c02181fc>] (usbnet_terminate_urbs+0xa0/0x15c) from [<c02191c8>] (usbnet_stop+0xe0/0x13c)
> [ 85.881935] [<c02191c8>] (usbnet_stop+0xe0/0x13c) from [<c02ba42c>] (__dev_close_many+0x88/0xb8)
> [ 85.890782] [<c02ba42c>] (__dev_close_many+0x88/0xb8) from [<c02ba480>] (__dev_close+0x24/0x34)
> [ 85.899541] [<c02ba480>] (__dev_close+0x24/0x34) from [<c02bd4c4>] (__dev_change_flags+0x8c/0x110)
> [ 85.908548] [<c02bd4c4>] (__dev_change_flags+0x8c/0x110) from [<c02bd5b4>] (dev_change_flags+0x10/0x44)
> [ 85.918010] [<c02bd5b4>] (dev_change_flags+0x10/0x44) from [<c0302dfc>] (devinet_ioctl+0x2b0/0x598)
> [ 85.927125] [<c0302dfc>] (devinet_ioctl+0x2b0/0x598) from [<c02a974c>] (sock_ioctl+0x1dc/0x230)
> [ 85.935883] [<c02a974c>] (sock_ioctl+0x1dc/0x230) from [<c00be058>] (do_vfs_ioctl+0x294/0x2cc)
> [ 85.944544] [<c00be058>] (do_vfs_ioctl+0x294/0x2cc) from [<c00be0c4>] (sys_ioctl+0x34/0x54)
> [ 85.952957] [<c00be0c4>] (sys_ioctl+0x34/0x54) from [<c000e0e0>] (ret_fast_syscall+0x0/0x30)
> [ 85.961436] Code: c045ccd1 e92d4013 e2504000 0a000015 (e5d43020)
> [ 85.971554] ---[ end trace 2a43ec4ab88bc4a2 ]---
> Segmentation fault 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
