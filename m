From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: =?utf-8?Q?=E7=AD=94=E5=A4=8D:_=5BPATCH=5D_set_fake=5Frtable's_ds?=
	=?utf-8?Q?t_to_NULL_to_avoid_kernel_Oops.?=
Date: Thu, 29 Mar 2012 14:40:01 +0800
Message-ID: <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
 <1333002975.2325.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([119.145.14.67]:38717 "EHLO
	szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab2C2GkW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 02:40:22 -0400
In-reply-to: <1333002975.2325.82.camel@edumazet-glaptop>
Content-language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already check current kernel-3.3, it has the same problem.

I am not very sure that if this modify could cause other problems or no=
t,
Because I don't know where fake_rtable was used.

-----=E9=82=AE=E4=BB=B6=E5=8E=9F=E4=BB=B6-----
=E5=8F=91=E4=BB=B6=E4=BA=BA: Eric Dumazet [mailto:eric.dumazet@gmail.co=
m]=20
=E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4: 2012=E5=B9=B43=E6=9C=8829=E6=97=A5=
 14:36
=E6=94=B6=E4=BB=B6=E4=BA=BA: Peter Huang (Peng)
=E6=8A=84=E9=80=81: linux-kernel@vger.kernel.org; harry.majun@huawei.co=
m; zhoukang7@huawei.com; netdev
=E4=B8=BB=E9=A2=98: Re: [PATCH] set fake_rtable's dst to NULL to avoid =
kernel Oops.

On Thu, 2012-03-29 at 14:21 +0800, Peter Huang (Peng) wrote:
> In our environment, we encountered a kernel Oops problem, and caused =
a
> restart.
>=20

CC netdev, since its more appropriate

> Below are what happened:
> kernel: 2.6.32.36-0.5-xen OS:xen + dom-0 + guest(rhel5.5)
> 1.destroy one VM.
> 2.ipsan path have some problem and make destroy process delayed about=
 10s.
> 3.customer defined script find that VM no longer exsit through libvir=
t API.
> 4.br0(related to the VM we are destoryed before) was deleted by the s=
cript.
> 5.delayed VM destroy process come to tap device releasing, this will
> decrement=20
> skb->_skb_dst's reference count(skb->_skb_dst points to fake_rtable),=
 but
> br0=20
> deleting already released this struct, and unfortunately OS reused th=
is
> memory=20
> and marked it read-only.
> 6.Oops happened, and caused restart.
>=20
> After analyzing the stack dump info, we find out that during our VM d=
estroy,
> lots of ipv6 multicast pkts=20
> exsited, and skb->_skb_dst pointed to (stuct)fake_rtable.
> through kernel source greping, will only find one reference to fake_r=
table's
> MTU setting.
>=20
> So I'm wondering that what fake_rtable stands for, and where we are u=
sing
> it.
> If fake_rtable's dst is not used, we can make dst as NULL to avoid ou=
r
> problem,.
> I also added the patch which modified the skb->_skb_dst to NULL when
> "skb->_skb_dst =3D=3D (unsigned long)&to->br->fake_rtable".
>=20
> BTW, we also verified a similar senario on kernel-3.3, that br0 has a=
ttached
> eth0 and eth1, eth1 was=20
> connected to our guest which will multicast ipv6 packets, and you can=
 get an
> "WARNING: at net/core/dst.c:274 dst_release+0x6d/0x70()"
> by using the fake_rtable_verify.c attached,=20
> #gcc fake_rtable_verify.c
> #./a.out &
> #sleep 30         //make sure ipv6 pkts was in tap00's receiving queu=
e.
> #ifconfig br0 down
> #brctl delbr br0 //delete br0, will also delete net_device's fake_rta=
ble.
> #sleep 50
> #kill -9 `pidof a.out` //tap00's delete will do dst_release, and this=
 will
> write to the memory already freed.
>=20
> Below is the Oops stack dump info:
> /////////////////////////////////////////////////////////////////////=
///////
> ///
> RIP: e030:[<ffffffff802ddbd1>]
> <ffffffff802ddbd1>{dst_release+0x11}
> RSP: e02b:ffff88008b185b70  EFLAGS: 00010286
> RAX: 00000000ffffffff RBX: ffff880033d184c0 RCX: 0000000000000000
> RDX: ffff88008b54f080 RSI: 0000000012df12df RDI: ffff88008b54efc0
> RBP: ffff8800f4a3f500 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000002 R11: ffffffff8018c1e0 R12: ffff8800f4a3f400
> R13: 0000000000000001 R14: ffff8800f4a3f4e0 R15: ffff8800351030c0
> FS:  00007f4cbd080700(0000) GS:ffff880002008000(0000) knlGS:000000000=
0000000
> CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffff88008b54f080 CR3: 000000008a27c000 CR4: 0000000000002620
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>        <ffffffff80009b05>{dump_trace+0x65}
>        <ffffffff8037d897>{notifier_call_chain+0x37}
>        <ffffffff8005a1ed>{notify_die+0x2d}
>        <ffffffff8037bd0b>{__die+0x8b}
>        <ffffffff8001bed1>{no_context+0xd1}
>        <ffffffff8001c1f5>{__bad_area_nosemaphore+0x175}
>        <ffffffff8037b298>{page_fault+0x28}
>        <ffffffff802ddbd1>{dst_release+0x11}
>        <ffffffff802cd69d>{skb_release_head_state+0xbd}
>        <ffffffff802cd369>{__kfree_skb+0x9}
>        <ffffffff802edaab>{pfifo_fast_reset+0x5b}
>        <ffffffff802edbd3>{qdisc_reset+0x13}
>        <ffffffff802edcc7>{dev_deactivate_queue+0x57}
>        <ffffffff802ee4bf>{dev_deactivate+0x3f}
>        <ffffffff802d9575>{dev_close+0x65}
>        <ffffffff802d960e>{rollback_registered+0x3e}
>        <ffffffff802d9715>{unregister_netdevice+0x15}
>        <ffffffffa0807655>{tun:tun_chr_close+0xe5}
>        <ffffffff800d9edd>{__fput+0xcd}
>        <ffffffff800d6076>{filp_close+0x56}
>        <ffffffff8003fd9a>{put_files_struct+0x7a}
>        <ffffffff80040fb2>{do_exit+0x752}
>        <ffffffff800410ef>{do_group_exit+0x3f}
>        <ffffffff8004d9d9>{get_signal_to_deliver+0x229}
>        <ffffffff80006acd>{do_notify_resume+0x11d}
>        <ffffffff8000763c>{int_signal+0x12}
>        [<00007f4cbc7fd57d>]
> /////////////////////////////////////////////////////////////////////=
///////
> ///
>=20
> Signed-off-by: Peter Huang(Peng) <peter.huangpeng@huawei.com>
> ---
> diff -Nur a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> @@ -91,6 +91,9 @@
>         skb->dev =3D to->dev;
>         skb_forward_csum(skb);
>=20
> +       if (skb->_skb_dst =3D=3D (unsigned long)&to->br->fake_rtable)
> +               skb_dst_set(skb, NULL);
> +
>         NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
>                 br_forward_finish);
> }

Did you check current kernel has this bug ?

I remember we already fix this, maybe you need a backport.
