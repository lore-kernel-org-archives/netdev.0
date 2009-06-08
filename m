From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 17:59:36 +0200
Message-ID: <4A2D3568.6010901@gmail.com>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru> <4A2D2906.6090002@gmail.com> <4A2D301D.9040301@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55684 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbZFHP7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 11:59:39 -0400
In-Reply-To: <4A2D301D.9040301@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev a =E9crit :
> Eric Dumazet wrote:
>> Michael Tokarev a =E9crit :
> []
>>>>> The situation is very simple: with an RTL8169 (probably
>>>>> onboard) GigE card which, by default, is configured to
>>>>> have MTU (maximal transmission unit) to be 1500 bytes,
>>>>> it's *trivial* to instantly crash the machine by sending
>>>>> it a *single* packet of size >1500 bytes (provided the
>>>>> network switch can handle jumbo frames).
> []
>> OK, 2nd try then :)
>=20
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>> index e94316b..9080b08 100644
>> --- a/drivers/net/r8169.c
>> +++ b/drivers/net/r8169.c
>> @@ -3495,7 +3495,8 @@ static int rtl8169_rx_interrupt(struct
>> net_device *dev,
>>               * frames. They are seen as a symptom of over-mtu
>>               * sized frames.
>>               */
>> -            if (unlikely(rtl8169_fragmented_frame(status))) {
>> +            if (unlikely(rtl8169_fragmented_frame(status) ||
>> +                     (unsigned int)pkt_size > tp->rx_buf_sz)) {
>>                  dev->stats.rx_dropped++;
>>                  dev->stats.rx_length_errors++;
>>                  rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
>=20
> This one behaves much better.  There's no instant crash anymore, and =
the
> 'dropped' and 'frame' stats in ifconfig gets incremented with each pi=
ng.
>=20
> It fails down the line however.  I wasn't able to reply to this email=
 after
> doing the ping test with the above change (no more large packets were
> sent).
> With OOPSes like this one:
>=20
>  general protection fault: 0000 [#1] SMP
>  last sysfs file:
> /sys/devices/pci0000:00/0000:00:01.0/0000:01:05.0/drm/card0/dev
>  CPU 0
>  Modules linked in: radeon drm r8169 powernow_k8 autofs4 nfsd nfs loc=
kd
> nfs_acl auth_rpcgss sunrpc quota_v2
>  Pid: 10917, comm: icedove-bin Not tainted 2.6.29-x86-64 #2.6.29.4
> System Product Name
>  RIP: 0010:[<ffffffff8029889b>]  [<ffffffff8029889b>] put_page+0x1b/0=
x170
>  RSP: 0018:ffff8800cd8fdb88  EFLAGS: 00210296
>  RAX: 0000000000000020 RBX: 6d6c6b6a69686766 RCX: 0000000000000760
>  RDX: ffff88011d9f1680 RSI: ffff88011d9f139b RDI: 6d6c6b6a69686766
>  RBP: ffff88011c936ac0 R08: 0000000000000001 R09: 0000000000000000
>  R10: ffffffff80552840 R11: 0000000000200293 R12: ffff88011d03e080
>  R13: 0000000000000030 R14: ffff88011d03e4bc R15: 0000000000000000
>  FS:  0000000000000000(0000) GS:ffffffff80608000(0063)
> knlGS:00000000f220bb90
>  CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
>  CR2: 000000000820302c CR3: 0000000116c57000 CR4: 00000000000006e0
>  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>  Process icedove-bin (pid: 10917, threadinfo ffff8800cd8fc000, task
> ffff8801158d8820)
>  Stack:
>   0000000000000000 0000000000000001 ffff88011c936ac0 ffff88011d03e080
>   0000000000000030 ffffffff803dbc7f 0000000000000319 ffff88011c936ac0
>   0000000000000000 ffffffff803db911 ffff88011c936ac0 ffffffff80418a88
>  Call Trace:
>   [<ffffffff803dbc7f>] ? skb_release_data+0xaf/0xe0
>   [<ffffffff803db911>] ? __kfree_skb+0x11/0xa0
>   [<ffffffff80418a88>] ? tcp_recvmsg+0x6d8/0x950
>   [<ffffffff8046f91e>] ? _spin_lock_irqsave+0x2e/0x40
>   [<ffffffff803d61b0>] ? sock_common_recvmsg+0x30/0x50
>   [<ffffffff803d4365>] ? sock_recvmsg+0xd5/0x110
>   [<ffffffff80244640>] ? default_wake_function+0x0/0x10
>   [<ffffffff802d5019>] ? file_update_time+0x59/0x140
>   [<ffffffff80261e90>] ? autoremove_wake_function+0x0/0x30
>   [<ffffffff8046fa25>] ? _spin_lock+0x5/0x10
>   [<ffffffff8026f109>] ? futex_wake+0x129/0x140
>   [<ffffffff803d3ab2>] ? sockfd_lookup_light+0x22/0x90
>   [<ffffffff803d56e9>] ? sys_recvfrom+0xe9/0x180
>   [<ffffffff80261e90>] ? autoremove_wake_function+0x0/0x30
>   [<ffffffff8046d8c5>] ? thread_return+0x3d/0x6d8
>   [<ffffffff803f6c86>] ? compat_sys_socketcall+0x136/0x1f0
>   [<ffffffff80238c47>] ? cstar_dispatch+0x7/0x4a
>  Code: 2c fd ff ff eb db 66 2e 0f 1f 84 00 00 00 00 00 48 83 ec 28 48=
 89
> 5c 24 08 48 89 6c 24 10 48 89 fb 4c
>  RIP  [<ffffffff8029889b>] put_page+0x1b/0x170
>   RSP <ffff8800cd8fdb88>
>  ---[ end trace c2d84c667e0d946d ]---
>=20
> (it probably has nothing to do with radeon drm sysfs file
> (it is NOT the binary fglrx module by the way)).
>=20
> Looks like some memory corruption.  And most probably it is in
> that error path in r8169 driver - it is the only new codepath
> which were executed here.  The problem is quite repeatable -
> after sending a single large ping system starts behaving like
> the above at random.
>=20
> So we're on a right way it seems, but there's more than one
> issue here.
>=20
> By the way, is there anything else we can do here but drop the
> packet?  Or is there any REASON to do something else?
>=20

Hmm... this code path is not new, I believe your adapter is buggy, beca=
use it
is overwriting part of memory it should not touch at all.

When this driver queues a skb in rx queue, it tells NIC the max size of=
 the skb,
and apparently NIC happily delivers packets with larger sizes, so proba=
bly DMA
wrote data past end of skb data.

Try to change=20

static void rtl_set_rx_max_size(void __iomem *ioaddr)
    RTL_W16(RxMaxSize, 16383);=20

to ->

    RTL_W16(RxMaxSize, RX_BUF_SIZE);


(But it will probably break jumbo frames rx as well)


