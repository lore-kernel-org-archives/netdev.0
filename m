From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 19:21:44 +0200
Message-ID: <4AA54128.2050607@gmail.com>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net> <4AA503E4.2060504@gmail.com> <4AA50ACF.9010400@trash.net> <4AA5175F.6030600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34869 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbZIGRVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 13:21:45 -0400
In-Reply-To: <4AA5175F.6030600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Patrick McHardy wrote:
>> Eric Dumazet wrote:
>>> Had very litle time to test this, but got problems very fast, if ra=
te estimator configured.
>> I didn't test that, but I'll look into it.
>>
>>> qdisc mq 1: root
>>>  Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
>>>  rate 177925Kbit 49pps backlog 0b 0p requeues 0
>>> qdisc pfifo 8001: parent 1:1 limit 1000p
>>>  Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
>>>  rate 25400bit 21pps backlog 0b 0p requeues 0
>>>
>>> <<<crash>>>
>> Did you capture the crash?

No, in fact it was a freeze.

>>
>>> (On another term I had a "ping -i 0.1 192.168.20.120" that gave :
>>>
>>> 2009/08/07 14:53:42.498 64 bytes from 192.168.20.120: icmp_seq=3D19=
82 ttl=3D64 time=3D0.126 ms
>>> 2009/08/07 14:53:42.598 64 bytes from 192.168.20.120: icmp_seq=3D19=
83 ttl=3D64 time=3D0.118 ms
>>> 2009/08/07 14:53:42.698 64 bytes from 192.168.20.120: icmp_seq=3D19=
84 ttl=3D64 time=3D0.114 ms
>>> 2009/08/07 14:53:42.798 64 bytes from 192.168.20.120: icmp_seq=3D19=
85 ttl=3D64 time=3D0.123 ms
>>> 2009/08/07 14:53:42.898 64 bytes from 192.168.20.120: icmp_seq=3D19=
86 ttl=3D64 time=3D0.126 ms
>>> 2009/08/07 14:53:42.998 64 bytes from 192.168.20.120: icmp_seq=3D19=
87 ttl=3D64 time=3D0.119 ms
>>> 2009/08/07 14:53:43.098 64 bytes from 192.168.20.120: icmp_seq=3D19=
88 ttl=3D64 time=3D0.122 ms
>>> 2009/08/07 14:53:43.198 64 bytes from 192.168.20.120: icmp_seq=3D19=
89 ttl=3D64 time=3D0.119 ms
>>> 2009/08/07 14:53:43.298 64 bytes from 192.168.20.120: icmp_seq=3D19=
90 ttl=3D64 time=3D0.117 ms
>>> 2009/08/07 14:53:43.398 64 bytes from 192.168.20.120: icmp_seq=3D19=
91 ttl=3D64 time=3D0.117 ms
>>> ping: sendmsg: No buffer space available
>> Was this also with rate estimators? No buffer space available
>> indicates that some class/qdisc isn't dequeued or the packets
>> are leaking, so the output of tc -s -d qdisc show ... might be
>> helpful.
>=20
> I figured out the bug, which is likely responsible for both
> problems. When grafting a mq class and creating a rate estimator,
> the new qdisc is not attached to the device queue yet and also
> doesn't have TC_H_ROOT as parent, so qdisc_create() selects
> qdisc_root_sleeping_lock() for the estimator, which belongs to
> the qdisc that is getting replaced.
>=20
> This is a patch I used for testing, but I'll come up with
> something more elegant (I hope) as a final fix :)

Yes, this was the problem, and your patch fixed it.

Now adding CONFIG_SLUB_DEBUG_ON=3Dy for next tries :)

Sep  7 16:37:55 erd kernel: [  217.056813] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Sep  7 16:37:55 erd kernel: [  217.056865] BUG kmalloc-256: Poison over=
written
Sep  7 16:37:55 erd kernel: [  217.056910] ----------------------------=
-------------------------------------------------
Sep  7 16:37:55 erd kernel: [  217.056911]
Sep  7 16:37:55 erd kernel: [  217.056990] INFO: 0xf6e622bc-0xf6e622bd.=
 First byte 0x76 instead of 0x6b
Sep  7 16:37:55 erd kernel: [  217.057049] INFO: Allocated in qdisc_all=
oc+0x1b/0x80 age=3D154593 cpu=3D2 pid=3D5165
Sep  7 16:37:55 erd kernel: [  217.057094] INFO: Freed in qdisc_destroy=
+0x88/0xa0 age=3D139186 cpu=3D4 pid=3D5173
Sep  7 16:37:55 erd kernel: [  217.057139] INFO: Slab 0xc16ddc40 object=
s=3D26 used=3D6 fp=3D0xf6e62260 flags=3D0x28040c3
Sep  7 16:37:55 erd kernel: [  217.057184] INFO: Object 0xf6e62260 @off=
set=3D608 fp=3D0xf6e62850
Sep  7 16:37:55 erd kernel: [  217.057184]
Sep  7 16:37:55 erd kernel: [  217.057259] Bytes b4 0xf6e62250:  d9 04 =
00 00 fc 6f fb ff 5a 5a 5a 5a 5a 5a 5a 5a =D9...=FCo=FB=FFZZZZZZZZ
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62260:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62270:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62280:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62290:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e622a0:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e622b0:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 76 76 6b 6b kkkkkkkkkkkkvvkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e622c0:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e622d0:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e622e0:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e622f0:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62300:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62310:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62320:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62330:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62340:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Sep  7 16:37:55 erd kernel: [  217.057771]   Object 0xf6e62350:  6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=A5
Sep  7 16:37:55 erd kernel: [  217.057771]  Redzone 0xf6e62360:  bb bb =
bb bb                                     =BB=BB=BB=BB
Sep  7 16:37:55 erd kernel: [  217.057771]  Padding 0xf6e62388:  5a 5a =
5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
Sep  7 16:37:55 erd kernel: [  217.057771] Pid: 5334, comm: bash Not ta=
inted 2.6.31-rc5-04006-gedfbc1d-dirty #188
Sep  7 16:37:55 erd kernel: [  217.057771] Call Trace:
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02a6d5f>] print_trailer+=
0xcf/0x120
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02a6e69>] check_bytes_an=
d_report+0xb9/0xe0
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02a7097>] check_object+0=
x1b7/0x200
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02a89b6>] __slab_alloc+0=
x3d6/0x5a0
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02a9602>] __kmalloc+0x17=
2/0x180
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02e4c02>] ? load_elf_bin=
ary+0x122/0x1550
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02e4c02>] load_elf_binar=
y+0x122/0x1550
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c035655e>] ? strrchr+0xe/=
0x30
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02e2644>] ? load_misc_bi=
nary+0x64/0x420
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c029190f>] ? page_address=
+0xcf/0xf0
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c0291aac>] ? kmap_high+0x=
1c/0x1e0
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c029190f>] ? page_address=
+0xcf/0xf0
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c029194a>] ? kunmap_high+=
0x1a/0x90
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02b20d7>] search_binary_=
handler+0xa7/0x240
Sep  7 16:37:55 erd kernel: [  217.057771]  [<c02b3686>] do_execve+0x2e=
6/0x3c0
Sep  7 16:37:56 erd kernel: [  217.057771]  [<c0201638>] sys_execve+0x2=
8/0x60
Sep  7 16:37:56 erd kernel: [  217.057771]  [<c0202d08>] sysenter_do_ca=
ll+0x12/0x26
Sep  7 16:37:56 erd kernel: [  217.057771] FIX kmalloc-256: Restoring 0=
xf6e622bc-0xf6e622bd=3D0x6b
Sep  7 16:37:56 erd kernel: [  217.057771]
Sep  7 16:37:56 erd kernel: [  217.057771] FIX kmalloc-256: Marking all=
 objects used
