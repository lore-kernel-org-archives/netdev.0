From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Mon, 8 Feb 2010 09:14:50 -0800
Message-ID: <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com>
References: <201001271104.20607.arnd@arndb.de>
	 <201001302322.15237.arnd@arndb.de>
	 <20100203.202104.151098461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:35318 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab0BHROz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 12:14:55 -0500
Received: by ewy28 with SMTP id 28so2753018ewy.28
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 09:14:53 -0800 (PST)
In-Reply-To: <20100203.202104.151098461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Arnd Bergmann <arnd@arndb.de>
> Date: Sat, 30 Jan 2010 23:22:15 +0100
>
>> This is the fourth version of the macvtap driver,
>> based on the comments I got for the last version
>> I got a few days ago. Very few changes:
>>
>> * release netdev in chardev open function so
>> =A0 we can destroy it properly.
>> * Implement TUNSETSNDBUF
>> * fix sleeping call in rcu_read_lock
>> * Fix comment in namespace isolation patch
>> * Fix small context difference to make it apply
>> =A0 to net-next
>>
>> I can't really test here while travelling, so please
>> give it a go if you're interested in this driver.

I'm seeing complaints from might_sleep():

=46eb  8 16:21:06 ti102 kernel: BUG: sleeping function called from
invalid context at include/linux/kernel.h:155
=46eb  8 16:21:06 ti102 kernel: in_atomic(): 1, irqs_disabled(): 0, pid=
:
2881, name: qemu-kvm
=46eb  8 16:21:06 ti102 kernel: Pid: 2881, comm: qemu-kvm Not tainted
2.6.29.6.Ar-224527.2009eswierk8 #1
=46eb  8 16:21:06 ti102 kernel: Call Trace:
=46eb  8 16:21:06 ti102 kernel: [<c0119250>] __might_sleep+0xdc/0xe3
=46eb  8 16:21:06 ti102 kernel: [<c0210f7c>] copy_to_user+0x36/0x106
=46eb  8 16:21:06 ti102 kernel: [<c02af568>] memcpy_toiovec+0x2c/0x50
=46eb  8 16:21:06 ti102 kernel: [<c02afbb3>] skb_copy_datagram_iovec+0x=
47/0x184
=46eb  8 16:21:06 ti102 kernel: [<c034bd07>] ? _spin_unlock_irqrestore+=
0x17/0x2c
=46eb  8 16:21:06 ti102 kernel: [<f829a776>]
macvtap_aio_read+0x102/0x158 [macvtap]
=46eb  8 16:21:06 ti102 kernel: [<c011eaf7>] ? default_wake_function+0x=
0/0xd
=46eb  8 16:21:06 ti102 kernel: [<c016c75f>] do_sync_read+0xab/0xe9
=46eb  8 16:21:06 ti102 kernel: [<c0133933>] ? autoremove_wake_function=
+0x0/0x33
=46eb  8 16:21:06 ti102 kernel: [<c019211f>] ? eventfd_read+0x121/0x156
=46eb  8 16:21:06 ti102 kernel: [<c011eaf7>] ? default_wake_function+0x=
0/0xd
=46eb  8 16:21:06 ti102 kernel: [<c016d101>] vfs_read+0xb5/0x129
=46eb  8 16:21:06 ti102 kernel: [<c016d20e>] sys_read+0x3b/0x60
=46eb  8 16:21:06 ti102 kernel: [<c0102e71>] sysenter_do_call+0x12/0x25

=46eb  8 16:21:08 ti102 kernel: BUG: sleeping function called from
invalid context at include/linux/kernel.h:155
=46eb  8 16:21:08 ti102 kernel: in_atomic(): 1, irqs_disabled(): 0, pid=
:
2882, name: qemu-kvm
=46eb  8 16:21:08 ti102 kernel: Pid: 2882, comm: qemu-kvm Not tainted
2.6.29.6.Ar-224527.2009eswierk8 #1
=46eb  8 16:21:08 ti102 kernel: Call Trace:
=46eb  8 16:21:08 ti102 kernel: [<c0119250>] __might_sleep+0xdc/0xe3
=46eb  8 16:21:08 ti102 kernel: [<c0210e5f>] copy_from_user+0x34/0x11b
=46eb  8 16:21:08 ti102 kernel: [<c02af388>] memcpy_fromiovec+0x2c/0x50
=46eb  8 16:21:08 ti102 kernel: [<c02afa30>]
skb_copy_datagram_from_iovec+0x47/0x183
=46eb  8 16:21:08 ti102 kernel: [<f829a618>]
macvtap_aio_write+0xaa/0x106 [macvtap]
=46eb  8 16:21:08 ti102 kernel: [<c034a553>] ? mutex_unlock+0x8/0xa
=46eb  8 16:21:08 ti102 kernel: [<c016c58d>] do_sync_readv_writev+0xa1/=
0xdf
=46eb  8 16:21:08 ti102 kernel: [<c0133933>] ? autoremove_wake_function=
+0x0/0x33
=46eb  8 16:21:08 ti102 kernel: [<c016c44f>] ? rw_copy_check_uvector+0x=
5b/0xc3
=46eb  8 16:21:08 ti102 kernel: [<c016cbec>] do_readv_writev+0x82/0x165
=46eb  8 16:21:08 ti102 kernel: [<f829a56e>] ?
macvtap_aio_write+0x0/0x106 [macvtap]
=46eb  8 16:21:08 ti102 kernel: [<c0177461>] ? do_vfs_ioctl+0x4a3/0x4dc
=46eb  8 16:21:08 ti102 kernel: [<c0112d83>] ? read_hpet+0xf/0x13
=46eb  8 16:21:08 ti102 kernel: [<c016cd1e>] vfs_writev+0x4f/0x6b
=46eb  8 16:21:08 ti102 kernel: [<c016cd75>] sys_writev+0x3b/0x60
=46eb  8 16:21:08 ti102 kernel: [<c0102e71>] sysenter_do_call+0x12/0x25

I backported your patch to kernel 2.6.29.6, an i386 kernel with
CONFIG_PREEMPT=3Dy and CONFIG_CLASSIC_RCU=3Dy. It's entirely possible t=
hat
I screwed something up in the backport; I can post my modified patch
if it would help.

--Ed
