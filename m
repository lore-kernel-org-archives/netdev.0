From: Ingo Molnar <mingo@elte.hu>
Subject: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Thu, 17 Jul 2008 23:42:22 +0200
Message-ID: <20080717214222.GA29449@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43681 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbYGQVmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 17:42:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A regression to v2.6.26:

I started getting this skb-head corruption message today, on a T60=20
laptop with e1000:

PM: Removing info for No Bus:vcs11
device: 'vcs11': device_create_release
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG skbuff_head_cache: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
INFO: Allocated in __alloc_skb+0x2c/0x110 age=3D0 cpu=3D0 pid=3D5098
INFO: Freed in __kfree_skb+0x31/0x80 age=3D0 cpu=3D1 pid=3D4440
INFO: Slab 0xc16cc140 objects=3D16 used=3D1 fp=3D0xf658ae00 flags=3D0x4=
00000c3
INFO: Object 0xf658ae00 @offset=3D3584 fp=3D0xf658af00

Bytes b4 0xf658adf0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
  Object 0xf658ae00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf658ae70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
 Redzone 0xf658aea0:  bb bb bb bb                                     =EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD           =20
 Padding 0xf658aec8:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
 Padding 0xf658aed8:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
 Padding 0xf658aee8:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
 Padding 0xf658aef8:  5a 5a 5a 5a 5a 5a 5a 5a                         Z=
ZZZZZZZ       =20
Pid: 5098, comm: gdm-binary Not tainted 2.6.26-tip #3094
 [<c0186f99>] print_trailer+0xa9/0xf0
 [<c018707b>] check_bytes_and_report+0x9b/0xc0
 [<c01874ae>] check_object+0x19e/0x1e0
 [<c0187ef1>] __slab_alloc+0x371/0x4e0
 [<c0188552>] kmem_cache_alloc+0xb2/0xc0
 [<c06732dc>] ? __alloc_skb+0x2c/0x110
 [<c06732dc>] ? __alloc_skb+0x2c/0x110
 [<c06732dc>] __alloc_skb+0x2c/0x110
 [<c0685b6c>] find_skb+0x3c/0x80
 [<c068624b>] netpoll_send_udp+0x2b/0x1f0
 [<c0322e62>] ? notify_update+0x22/0x30
 [<c046d405>] write_msg+0x95/0xe0
 [<c046d370>] ? write_msg+0x0/0xe0
 [<c012df70>] __call_console_drivers+0x60/0x70
 [<c012dff9>] _call_console_drivers+0x79/0x90
 [<c012e3f4>] release_console_sem+0xc4/0x1f0
 [<c012e89e>] vprintk+0x15e/0x3b0
 [<c01ce683>] ? release_sysfs_dirent+0x43/0xa0
 [<c01ce683>] ? release_sysfs_dirent+0x43/0xa0
 [<c01ce683>] ? release_sysfs_dirent+0x43/0xa0
 [<c012eb0b>] printk+0x1b/0x20
 [<c0367597>] device_create_release+0x27/0x40
 [<c0367955>] device_release+0x15/0x70
 [<c02b1d29>] kobject_release+0x39/0x80
 [<c02b1cf0>] ? kobject_release+0x0/0x80
 [<c02b2a0d>] kref_put+0x2d/0x70
 [<c02b1c30>] kobject_put+0x20/0x50
 [<c02b1ce2>] ? kobject_del+0x22/0x30
 [<c03680f3>] ? device_del+0x123/0x140
 [<c0367b7f>] put_device+0xf/0x20
 [<c0368145>] device_unregister+0x35/0x40
 [<c0368179>] device_destroy+0x29/0x30
 [<c031e66c>] vcs_remove_sysfs+0x1c/0x40
 [<c032480e>] con_close+0x5e/0x70
 [<c0317289>] release_dev+0x139/0x600
 [<c0188222>] ? __slab_free+0x1c2/0x240
 [<c019fd59>] ? destroy_inode+0x39/0x40
 [<c019d4d3>] ? __d_free+0x23/0x30
 [<c019d4d3>] ? __d_free+0x23/0x30
 [<c019d4d3>] ? __d_free+0x23/0x30
 [<c0317762>] tty_release+0x12/0x20
 [<c018dba2>] __fput+0xb2/0x1d0
 [<c018dfe9>] fput+0x19/0x20
 [<c018ad59>] filp_close+0x49/0x70
 [<c018c3a6>] sys_close+0x66/0xb0
 [<c0103d01>] sysenter_past_esp+0x6a/0x99
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46IX skbuff_head_cache: Restoring 0xf658ae9c-0xf658ae9c=3D0x6b

=46IX skbuff_head_cache: Marking all objects used
device: 'vcsa11': device_unregister
PM: Removing info for No Bus:vcsa11
device: 'vcsa11': device_create_release

With this config:

   http://redhat.com/~mingo/misc/config-Thu_Jul_17_20_24_45_CEST_2008.b=
ad
=09
The box uses netconsole.

Suspected range of breakage is v2.6.26..a3cf859, or around 3000 commits=
=2E=20
But a fair portion of those commit were tested on this box before.

Perhaps SLUB debugging got smarter?

	Ingo
