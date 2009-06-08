From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: net: uninitialized loopback addr leaks to userspace
Date: Mon, 8 Jun 2009 11:16:56 +0200
Message-ID: <19f34abd0906080216u7cc6fb4dj5247900daf9eab86@mail.gmail.com>
References: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com>
	 <20090607161105.385d6e92@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:64479 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbZFHJQz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 05:16:55 -0400
In-Reply-To: <20090607161105.385d6e92@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/8 Stephen Hemminger <shemminger@vyatta.com>:
> On Sat, 30 May 2009 22:23:24 +0200
> Vegard Nossum <vegard.nossum@gmail.com> wrote:
>
>> Hi,
>>
>> It seems that loopback's hardware address is never initialized by th=
e
>> kernel. So if userspace attempts to read this address before it has
>> been set, the kernel will return some uninitialized data (only 6
>> bytes, though). This can be demonstrated by creating a new network
>> namespace (CLONE_NEWNET), which creates a new loopback device, then
>> call ioctl() with SIOCGIFHWADDR on "lo". If this is done in a loop,
>> with some background load, or by running multiple instances, random
>> data will start to show up in the returned address.
>>
>> [ =C2=A0406.750329] WARNING: kmemcheck: Caught 16-bit read from
>> uninitialized memory (ffff880007220974)
>> [ =C2=A0406.753555] 18a2d7060088ffff18a2d7060088ffff0000000001000000=
0100000003000000
>> [ =C2=A0406.758862] =C2=A0i i i i i i i i i i i i i i i i i u u u u =
u u u u u u u u u u u
>> [ =C2=A0406.766224] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0^
>> [ =C2=A0406.768792] Modules linked in:
>> [ =C2=A0406.770416] Pid: 757, comm: ifconfig Not tainted
>> 2.6.30-rc7-next-20090529 #404
>> [ =C2=A0406.772876] RIP: 0010:[<ffffffff80664789>] =C2=A0[<ffffffff8=
0664789>]
>> dev_ioctl+0x5d9/0x600
>> [ =C2=A0406.804677] =C2=A0[<ffffffff8064ff75>] sock_ioctl+0x95/0x2a0
>> [ =C2=A0406.807242] =C2=A0[<ffffffff802c35eb>] vfs_ioctl+0x1b/0x70
>> [ =C2=A0406.809348] =C2=A0[<ffffffff802c36fa>] do_vfs_ioctl+0x8a/0x5=
70
>> [ =C2=A0406.811419] =C2=A0[<ffffffff802c3c79>] sys_ioctl+0x99/0xa0
>> [ =C2=A0406.813400] =C2=A0[<ffffffff802f3941>] dev_ifsioc+0x81/0x2f0
>> [ =C2=A0406.815424] =C2=A0[<ffffffff802f454d>] compat_sys_ioctl+0xed=
/0x3c0
>> [ =C2=A0406.817596] =C2=A0[<ffffffff8022d476>] cstar_dispatch+0x7/0x=
26
>> [ =C2=A0406.819978] =C2=A0[<ffffffffffffffff>] 0xffffffffffffffff
>>
>> This is the code that triggers the warning, in net/core/dev.c, aroun=
d line 4150:
>>
>> =C2=A0 =C2=A0 memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 min(sizeof ifr->ifr_hwaddr.sa_data, (siz=
e_t) dev->addr_len));
>>
>> So it's dev->dev_addr that is the pointer to the uninitialized data.
>>
>> I didn't know how to fix it.
>>
>
>
> The whole dev structure is zeroed in alloc_netdev(), kmemcheck
> is giving bogus warning.

Hi -- and sorry for being unclear. If I hadn't been sure that this was
a real error, I would have said so (or not reported it at all).

I investigated it now, and as can be seen in the report above, I am
using a -next kernel. It seems that the error was introduced in:

commit f001fde5eadd915f4858d22ed70d7040f48767cf
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Tue May 5 02:48:28 2009 +0000

    net: introduce a list of device addresses dev_addr_list (v6)

So the error does not, as you say, exist in mainline Linux, but it's
not a bogus warning either :-)

Adding to Cc.


Vegard

--=20
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
