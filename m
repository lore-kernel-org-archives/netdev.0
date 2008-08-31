From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: IPv6 tunnel scalability problem
Date: Sun, 31 Aug 2008 19:58:51 +0300
Message-ID: <200808311958.51510.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bernhard Schmidt <berni+ipv6@birkenwald.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39121 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbYHaQ6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 12:58:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello all,

I have been maintaining a TUN-based Linux implementation of Teredo/RFC4=
380. On=20
a busy node, this can trigger quite many peers on the virtual point-to-=
point=20
tunnel interface. I have received complaints that the whole thing seems=
 to=20
hit some severe performance bottleneck when this happens. It is not cle=
ar to=20
me at this point whether it's a kernel or a user problem. So I have bee=
n=20
writing a stress test.

Now I seem to be hitting a kernel segmentation fault as soon as there a=
re 1024=20
peers on a given tunnel interface (filed as #11469):

BUG: unable to handle kernel NULL pointer dereference at 0000001d
IP: [<f8b375bf>] :ipv6:ip6_dst_lookup_tail+0x95/0x15a
*pde =3D 00000000
Oops: 0000 [#14] SMP
Modules linked in: ipx p8022 psnap llc p8023 i915 drm tun cpufreq_ondem=
and
binfmt_misc fuse nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4
nf_conntrack ipv6 snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss
snd_mixer_oss snd_pcm snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi=
_event
snd_seq snd_timer snd_seq_device snd intel_agp psmouse soundcore agpgar=
t=20
button
processor snd_page_alloc parport_pc parport iTCO_wdt evdev pcspkr dm_mi=
rror
dm_log dm_snapshot dm_mod sg sr_mod cdrom e100 mii ehci_hcd uhci_hcd us=
bcore
unix

Pid: 9950, comm: tunload Tainted: G      D   (2.6.26.3 #8)
EIP: 0060:[<f8b375bf>] EFLAGS: 00210246 CPU: 0
EIP is at ip6_dst_lookup_tail+0x95/0x15a [ipv6]
EAX: 00000000 EBX: 00000000 ECX: ef4abdac EDX: 00000000
ESI: ef4abd3c EDI: ef64ca00 EBP: ef4abcb8 ESP: ef4abc64
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process tunload (pid: 9950, ti=3Def4aa000 task=3Df7d45320 task.ti=3Def4=
aa000)
Stack: ef4abd58 ef4abdac f7cc0c00 ef4abc80 f8b36918 00000000 ef673e40 e=
f4abcc0
       f8b381b2 00000002 f7cc0c00 ef7c3e00 f7cc0e24 00000000 ef4abca8 e=
f4abca8
       c030bcfa ef4abcc0 00000000 ef4abed4 00000000 ef4abcc0 f8b377d5 e=
f4abdbc
Call Trace:
 [<f8b36918>] ? ip6_cork_release+0x2e/0x52 [ipv6]
 [<f8b381b2>] ? ip6_push_pending_frames+0x1c9/0x3d9 [ipv6]
 [<c030bcfa>] ? _spin_unlock_bh+0xd/0xf
 [<f8b377d5>] ? ip6_dst_lookup+0xe/0x10 [ipv6]
 [<f8b4c2b2>] ? rawv6_sendmsg+0x25d/0xc08 [ipv6]
 [<c0151022>] ? filemap_fault+0x203/0x3d5
 [<c02e8de0>] ? inet_sendmsg+0x2e/0x50
 [<c02a24b8>] ? sock_sendmsg+0xcc/0xf0
 [<c01365f5>] ? autoremove_wake_function+0x0/0x3a
 [<c0136799>] ? remove_wait_queue+0x30/0x34
 [<f8a08fbe>] ? tun_chr_aio_read+0x298/0x31f [tun]
 [<c0211d67>] ? copy_from_user+0x2a/0x114
 [<c02a2790>] ? sys_sendto+0xa5/0xc5
 [<c02b3713>] ? neigh_periodic_timer+0x0/0x17a
 [<c01365f5>] ? autoremove_wake_function+0x0/0x3a
 [<c02a348f>] ? sys_socketcall+0x141/0x262
 [<c0102f99>] ? sysenter_past_esp+0x6a/0x91
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 22 83 fb 9b 74 37 8b 4d b0 8b 01 e8 35 96 77 c7 8b 45 b0 c7 00 00=
 00 00
00 89 d8 83 c4 48 5b 5e 5f 5d c3 8b 4d b0 8b 39 8b 47 2c <f6> 40 1d de =
74 23=20
31
db 89 d8 83 c4 48 5b 5e 5f 5d c3 64 a1 04
EIP: [<f8b375bf>] ip6_dst_lookup_tail+0x95/0x15a [ipv6] SS:ESP 0068:ef4=
abc64
---[ end trace 1035c8e1d028e84b ]---

The test case is here: http://www.remlab.net/files/divers/tunload.c

I would assume some that this is an allocation failure somehow, also it=
 seems=20
weird that there would be need to allocate any per-destination data on =
a=20
point-to-point link, as there is no need for a neighbors cache.

I'll try with 2.6.27-rc later.

Regards,

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
