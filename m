From: Johannes Berg <johannes@sipsolutions.net>
Subject: d80211 oops with bcm43xx-d80211
Date: Fri, 15 Dec 2006 15:56:27 +0100
Message-ID: <1166194587.3462.18.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-EB57R8w44NCABqWgMVPD"
Cc: Jiri Benc <jbenc@suse.cz>, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55402 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbWLOO4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 09:56:10 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EB57R8w44NCABqWgMVPD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Turns out I was right, current bcm43xx-d80211 oopses when rmmod'ed in
use... However, it looks like d80211 is to blame.

the instruction c003030c is in the middle of tasklet_action and it's a
free-after-use type of thing as you can see from accessing 0x6b6b6b73,
in fact, the code in question is:

c003030c:       80 0b 00 08     lwz     r0,8(r11)

and you can see that r11 is 6b6b6b6b so obviously some tasklet is freed
while being scheduled, then the tasklet handler comes along and oopses
trying to execute it.

The "skb_queue not empty" message would indicate that it's probably
tx_pending_tasklet, but I haven't really been able to come up with a fix
or even an explanation of why this happens... The queue should be empty
at that point, otherwise we leak SKBs too!=20

Here's the full backtrace, it's a bit confusing because mutex debugging
comes in as well, we'll have to see if that is a separate problem.=20

[  148.056722] bcm43xx_d80211: DMA-32 0x02A0 (TX) max used slots: 0/128
[  148.057799] bcm43xx_d80211: DMA-32 0x0280 (TX) max used slots: 0/128
[  148.058845] bcm43xx_d80211: DMA-32 0x0260 (TX) max used slots: 0/128
[  148.059912] bcm43xx_d80211: DMA-32 0x0240 (TX) max used slots: 0/128
[  148.060978] bcm43xx_d80211: DMA-32 0x0220 (TX) max used slots: 2/128
[  148.062045] bcm43xx_d80211: DMA-32 0x0200 (TX) max used slots: 0/128
[  148.063159] bcm43xx_d80211: Virtual interface removed (type: 0x00000002,=
 ID: 7, MAC: 00:11:24:91:07:4d)
[  148.513009] wmaster0: skb_queue not empty<1>Unable to handle kernel pagi=
ng request for data at address 0x6b6b6b73
[  148.519927] Faulting instruction address: 0xc003030c
[  148.520615] Badness in __mutex_lock_common at kernel/mutex.c:132
[  148.521329] Call Trace:
[  148.521914] [C11BBB80] [C0009048] show_stack+0x3c/0x194 (unreliable)
[  148.522762] [C11BBBB0] [C000FE64] program_check_exception+0x47c/0x598
[  148.523561] [C11BBC00] [C001153C] ret_from_except_full+0x0/0x4c
[  148.524336] --- Exception: 700 at __mutex_lock_slowpath+0x168/0x170
[  148.525104]     LR =3D __mutex_lock_slowpath+0x160/0x170
[  148.525785] [C11BBCC0] [C0221398] kfree_skbmem+0x70/0xf4 (unreliable)
[  148.526613] [C11BBD10] [C000F3DC] die+0x54/0x1b4
[  148.527329] [C11BBD30] [C0014ECC] bad_page_fault+0xbc/0xd4
[  148.528063] [C11BBD40] [C001137C] handle_page_fault+0x7c/0x80
[  148.528813] --- Exception: 300 at tasklet_action+0x84/0xe8
[  148.529559]     LR =3D __do_softirq+0x80/0xf4
[  148.530211] [C11BBE00] [C007E058] cache_alloc_debugcheck_after+0x1a8/0x1=
e8 (unreliable)
[  148.531068] [C11BBE20] [C00304D8] __do_softirq+0x80/0xf4
[  148.531812] [C11BBE50] [C00069DC] do_softirq+0x58/0x5c
[  148.532537] [C11BBE60] [C00301A8] local_bh_enable+0x6c/0x94
[  148.533279] [C11BBE70] [C021D2F0] lock_sock+0xa0/0xb4
[  148.534024] [C11BBEB0] [C021A610] sock_fasync+0x40/0x130
[  148.534768] [C11BBEE0] [C021C378] sock_close+0x2c/0x68
[  148.535489] [C11BBEF0] [C00843AC] __fput+0xc8/0x1e0
[  148.536235] [C11BBF10] [C0080DF8] filp_close+0x64/0xa0
[  148.536977] [C11BBF30] [C0080ECC] sys_close+0x98/0xc4
[  148.537718] [C11BBF40] [C0010EE0] ret_from_syscall+0x0/0x38
[  148.538469] --- Exception: c01 at 0xff22a24
[  148.539184]     LR =3D 0x1000bd78
[  148.539798] Oops: Kernel access of bad area, sig: 11 [#1]
[  148.540479]=20
[  148.541035] Modules linked in: af_packet arc4 rc80211_simple snd_powerma=
c configfs nls_utf8 hfsplus nls_base dm_snapshot dm_mirror sha256 eth1394 j=
oydev appletouch usbhid ssb 80211 snd_aoa_codec_tas snd_aoa_fabric_layout s=
nd_aoa pcmcia firmware_class ieee80211softmac ieee80211 ieee80211_crypt ohc=
i1394 ieee1394 snd_aoa_i2sbus snd_pcm snd_timer snd_page_alloc snd soundcor=
e snd_aoa_soundbus ehci_hcd ohci_hcd yenta_socket usbcore uninorth_agp rsrc=
_nonstatic pcmcia_core agpgart evdev unix
[  148.546406] NIP: C003030C LR: C00304D8 CTR: C0030288
[  148.547084] REGS: c11bbd50 TRAP: 0300   Not tainted  (2.6.19-rc6)
[  148.547786] MSR: 00009032 <EE,ME,IR,DR>  CR: 44002484  XER: 20000000
[  148.548756] DAR: 6B6B6B73, DSISR: 40000000
[  148.549406] TASK =3D c1dd7300[1816] 'udevd' THREAD: c11ba000
[  148.549606] GPR00: 00009032 C11BBE00 C1DD7300 C077FA48 000005FC 000005FC=
 00000000 00000000=20
[  148.550703] GPR08: CFD997AC 00000000 00000000 6B6B6B6B 84000488 1002714C=
 28204422 00000000=20
[  148.551805] GPR16: 100FB7A8 100D0000 100B0000 100D0000 00000007 0000000E=
 100210CC 10021147=20
[  148.552926] GPR24: C0780000 00000000 C0781458 00000001 C0780000 C0580000=
 00000001 6B6B6B6B=20
[  148.554530] NIP [C003030C] tasklet_action+0x84/0xe8
[  148.555245] LR [C00304D8] __do_softirq+0x80/0xf4
[  148.555942] Call Trace:
[  148.556518] [C11BBE00] [C007E058] cache_alloc_debugcheck_after+0x1a8/0x1=
e8 (unreliable)
[  148.557404] [C11BBE20] [C00304D8] __do_softirq+0x80/0xf4
[  148.558127] [C11BBE50] [C00069DC] do_softirq+0x58/0x5c
[  148.558851] [C11BBE60] [C00301A8] local_bh_enable+0x6c/0x94
[  148.559611] [C11BBE70] [C021D2F0] lock_sock+0xa0/0xb4
[  148.560346] [C11BBEB0] [C021A610] sock_fasync+0x40/0x130
[  148.561076] [C11BBEE0] [C021C378] sock_close+0x2c/0x68
[  148.561816] [C11BBEF0] [C00843AC] __fput+0xc8/0x1e0
[  148.562557] [C11BBF10] [C0080DF8] filp_close+0x64/0xa0
[  148.563289] [C11BBF30] [C0080ECC] sys_close+0x98/0xc4
[  148.564042] [C11BBF40] [C0010EE0] ret_from_syscall+0x0/0x38
[  148.564802] --- Exception: c01 at 0xff22a24
[  148.565493]     LR =3D 0x1000bd78
[  148.566102] Instruction dump:
[  148.566731] 7c00492d 40a2fff4 71400001 40820008 0fe00000 806b0010 816b00=
0c 7d6903a6=20
[  148.568058] 4e800421 2f9f0000 7febfb78 419e0054 <800b0008> 392b0004 83eb=
0000 2f800000=20
[  148.569070]  <0>Kernel panic - not syncing: Fatal exception in interrupt
[  148.569856]  <0>Rebooting in 180 seconds..

--=-EB57R8w44NCABqWgMVPD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFgreb/ETPhpq3jKURAq6fAJ9zcSpyVYdtwJOWhBLLbX9YFts0iwCfQkHi
ciabulF5MYhxPjElVRaAPjw=
=zUA3
-----END PGP SIGNATURE-----

--=-EB57R8w44NCABqWgMVPD--

