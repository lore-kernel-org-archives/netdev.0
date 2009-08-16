From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: System freeze on reboot - general protection fault
Date: Sun, 16 Aug 2009 11:16:16 +0200
Message-ID: <4A87CE60.4020506@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>	 <alpine.DEB.1.10.0908111032110.30494@gentwo.org>	 <c4e36d110908110752x253e30epb00cc71f4683052b@mail.gmail.com>	 <alpine.DEB.1.10.0908111056550.30494@gentwo.org>	 <c4e36d110908110832y21fba830ub8804613df571228@mail.gmail.com>	 <20090811154853.GF2763@sgi.com>	 <c4e36d110908111410y29b922ceod6871fda2514f6e6@mail.gmail.com>	 <c4e36d110908121516u504809e9y537e9babfa95df1d@mail.gmail.com>	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com> <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47413 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbZHPJQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2009 05:16:44 -0400
In-Reply-To: <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zdenek Kabelac a =E9crit :
> 2009/8/13 Zdenek Kabelac <zdenek.kabelac@gmail.com>:
>> 2009/8/13 Christoph Lameter <cl@linux-foundation.org>:
>>> On Thu, 13 Aug 2009, Zdenek Kabelac wrote:
>>>
>>>>> I've added authors of some recent conntrack commits to Cc: - mayb=
e
>>>>> they might know?
>>>> I've tested v2.6.30 - and it's crashing in the same way - so any o=
ther
>>>> starting point where slub has the same detection mechanism and
>>>> conntrack module should be working reliable ?
>>> Next point is 2.6.29.
>>>
>> Ok  - played lengthy game between 2.6.29 which appeared to be ok and=
 2.6.30
>>
>> And the winner is: ea781f197d6a835cbb93a0bf88ee1696296ed8aa
>> netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call=
_rcu()
>>
>> The error is actually being hit by  libvirtd networking rules added
>> during boot for my kvm usage.
>> (Which I noticed after some time...  leading my game into wrong
>> direction ;))....
>>
>> Here are the some last bisect entries:
>>
>> git bisect bad 54dc79fe0d895758bdaa1dcf8512d3d21263d105
>> # bad: [5c0de29d06318ec8f6e3ba0d17d62529dbbdc1e8] netfilter:
>> nf_conntrack: add generic function to get len of generic policy
>> git bisect bad 5c0de29d06318ec8f6e3ba0d17d62529dbbdc1e8
>> # good: [e487eb99cf9381a4f8254fa01747a85818da612b] netlink: add nla_=
policy_len()
>> git bisect good e487eb99cf9381a4f8254fa01747a85818da612b
>> # good: [1f9352ae2253a97b07b34dcf16ffa3b4ca12c558] netfilter:
>> {ip,ip6,arp}_tables: fix incorrect loop detection
>> git bisect good 1f9352ae2253a97b07b34dcf16ffa3b4ca12c558
>> # bad: [2732c4e45bb67006fdc9ae6669be866762711ab5] netfilter:
>> ctnetlink: allocate right-sized ctnetlink skb
>> git bisect bad 2732c4e45bb67006fdc9ae6669be866762711ab5
>>
>>
>> Unfortunately the commit cannot be reverted with current tree - thus=
 I
>> cannot easily check if it's the only problem.
>> (warning: too many files (created: 3096 deleted: 1096), skipping
>> inexact rename detection
>> Automatic revert failed.  After resolving the conflicts,)
>=20
> Hmm after checking today with serial cable attached - it looks like
> I've tracked the problem but to the wrong commit - my original 'slub'
> error was now actually something else - so there are most probably tw=
o
> kinds of problem - as with this kernel the nf_conntrack_ipv4 fails to
> register tcp so it's not loaded at all.
> This might get fixed later, but different error was there.
>=20
> I'll need to play the game again and check when I'll start to get the
> same slub oops/
>=20
> Here is the second oops I've got with 2.6.29-rc5 kernel:
>=20
> IP: [<ffffffffa02b2c2c>] nf_conntrack_helper_unregister+0x16c/0x320
> [nf_conntrack]
> PGD 13bfb1067 PUD 1384c8067 PMD 0
> Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> last sysfs file: /sys/module/nf_conntrack_ftp/refcnt
> CPU 0
> Modules linked in: sit tunnel4 nf_defrag_ipv4 bridge stp llc autofs4
> ipv6 nf_conntrack_ftp(-) nf_conntrack binfmt_misc loop dm_mirror
> dm_region_hash dm_log dm_mod kvm_intel kvm i915 drm i2c_algo_bit
> uinput i2c_i801 arc4 ecb cryptomgr aead crypto_blkcipher crypto_hash
> crypto_algapi iwl3945 iwlcore mac80211 video thinkpad_acpi i2c_core
> sr_mod rfkill led_class evdev iTCO_wdt backlight usbhid hid cfg80211
> iTCO_vendor_support e1000e psmouse serio_raw cdrom output rtc_cmos
> rtc_core battery intel_agp nvram rtc_lib button ac uhci_hcd ohci_hcd
> ehci_hcd usbcore [last unloaded: x_tables]
> Pid: 2824, comm: modprobe Not tainted 2.6.29-rc5-00889-gea781f1 #25 6=
464CTO
> RIP: 0010:[<ffffffffa02b2c2c>]  [<ffffffffa02b2c2c>]
> nf_conntrack_helper_unregister+0x16c/0x320 [nf_conntrack]
> RSP: 0018:ffff88013982fe68  EFLAGS: 00010202
> RAX: 0000000000000200 RBX: 0000000000000001 RCX: ffffffffa02b2b31
> RDX: 00000000000001ff RSI: 8f5c28f5c28f5c29 RDI: 0000000000000001
> RBP: ffff88013982feb8 R08: 0000000000000000 R09: 0000000000000000
> R10: 000000000000006d R11: 0000000000000000 R12: ffffffffa02c6a00
> R13: ffffffffa02c71a0 R14: ffffffff81188e20 R15: ffff88013982fe78
> FS:  00007ffbd4984700(0000) GS:ffffffff8092e040(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000038 CR3: 000000013779b000 CR4: 00000000000026e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process modprobe (pid: 2824, threadinfo ffff88013982e000, task ffff88=
0138710000)
> Stack:
>  ffff88013982fe88 0000020080271bf2 ffffffff806a47c0 0000000000000246
>  ffff88013982fe98 ffffffffa02c6a00 0000000000000000 ffffffffa02c71a0
>  0000000000000000 000000000040f510 ffff88013982fed8 ffffffffa02c502f
> Call Trace:
>  [<ffffffffa02c502f>] nf_conntrack_ftp_fini+0x2f/0x70 [nf_conntrack_f=
tp]
>  [<ffffffff8027bcc5>] sys_delete_module+0x1a5/0x270
>  [<ffffffff8020d329>] ? retint_swapgs+0xe/0x13
>  [<ffffffff80271bf2>] ? trace_hardirqs_on_caller+0x162/0x1b0
>  [<ffffffff80292121>] ? audit_syscall_entry+0x191/0x1c0
>  [<ffffffff80526dae>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff8020c84b>] system_call_fastpath+0x16/0x1b
> Code: c6 00 00 0f 82 66 ff ff ff 49 8b 9e d8 05 00 00 48 85 db 75 16
> e9 8e 00 00 00 0f 1f 44 00 00 48 85 c0 0f 84 80 00 00 00 48 89 c3 <0f=
>
> b6 4b 37 48 8b 03 48 8d 14 cd 00 00 00 00 0f 18 08 48 29 ca
> RIP  [<ffffffffa02b2c2c>] nf_conntrack_helper_unregister+0x16c/0x320
> [nf_conntrack]
>  RSP <ffff88013982fe68>
> CR2: 0000000000000038
> ---[ end trace bc3a0ede3d0084db ]---
>=20
> Zdenek

Hello Zdenek

I am currently traveling and wont be able to help you before next week.

I added netdev, Patrick, and netfilter-devel in CC so that more eyes ca=
n take a look.

Thank you
