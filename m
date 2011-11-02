From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fix NULL dereference in x25_recvmsg
Date: Wed, 02 Nov 2011 03:16:05 +0100
Message-ID: <1320200165.4728.25.camel@edumazet-laptop>
References: <20111102015315.GA6569@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Matthew Daley <mattjd@gmail.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44687 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172Ab1KBCQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 22:16:11 -0400
Received: by wwi36 with SMTP id 36so3987356wwi.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 19:16:10 -0700 (PDT)
In-Reply-To: <20111102015315.GA6569@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 novembre 2011 =C3=A0 21:53 -0400, Dave Jones a =C3=A9crit :
> commit cb101ed2 in 3.0 introduced a bug in x25_recvmsg()
> When passed bogus junk from userspace, x25->neighbour can be NULL,
> as shown in this oops..
>=20
> BUG: unable to handle kernel NULL pointer dereference at 000000000000=
001c
> IP: [<ffffffffa05482bd>] x25_recvmsg+0x4d/0x280 [x25]
> PGD 1015f3067 PUD 105072067 PMD 0=20
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> CPU 0=20
> Pid: 27928, comm: iknowthis Not tainted 3.1.0+ #2 Gigabyte Technology=
 Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
> RIP: 0010:[<ffffffffa05482bd>]  [<ffffffffa05482bd>] x25_recvmsg+0x4d=
/0x280 [x25]
> RSP: 0018:ffff88010c0b7cc8  EFLAGS: 00010282
> RAX: 0000000000000000 RBX: ffff88010c0b7d78 RCX: 0000000000000c02
> RDX: ffff88010c0b7d78 RSI: ffff88011c93dc00 RDI: ffff880103f667b0
> RBP: ffff88010c0b7d18 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880103f667b0
> R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> FS:  00007f479ce7f700(0000) GS:ffff88012a600000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 000000000000001c CR3: 000000010529e000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process iknowthis (pid: 27928, threadinfo ffff88010c0b6000, task ffff=
880103faa4f0)
> Stack:
>  0000000000000c02 0000000000000c02 ffff88010c0b7d18 ffffff958153cb37
>  ffffffff8153cb60 0000000000000c02 ffff88011c93dc00 0000000000000000
>  0000000000000c02 ffff88010c0b7e10 ffff88010c0b7de8 ffffffff815372c2
> Call Trace:
>  [<ffffffff8153cb60>] ? sock_update_classid+0xb0/0x180
>  [<ffffffff815372c2>] sock_aio_read.part.10+0x142/0x150
>  [<ffffffff812d6752>] ? inode_has_perm+0x62/0xa0
>  [<ffffffff815372fd>] sock_aio_read+0x2d/0x40
>  [<ffffffff811b05e2>] do_sync_read+0xd2/0x110
>  [<ffffffff812d3796>] ? security_file_permission+0x96/0xb0
>  [<ffffffff811b0a91>] ? rw_verify_area+0x61/0x100
>  [<ffffffff811b103d>] vfs_read+0x16d/0x180
>  [<ffffffff811b109d>] sys_read+0x4d/0x90
>  [<ffffffff81657282>] system_call_fastpath+0x16/0x1b
> Code: 8b 66 20 4c 8b 32 48 89 d3 48 89 4d b8 45 89 c7 c7 45 cc 95 ff =
ff ff 4d 85 e4 0f 84 ed 01 00 00 49 8b 84 24 18 05 00 00 4c 89 e7=20
>  78 1c 01 45 19 ed 31 f6 e8 d5 37 ff e0 41 0f b6 44 24 0e 41=20
>=20
> Signed-off-by: Dave Jones <davej@redhat.com>
>=20
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index 5f03e4e..291b2e0 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -1261,13 +1261,17 @@ static int x25_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>  	struct x25_sock *x25 =3D x25_sk(sk);
>  	struct sockaddr_x25 *sx25 =3D (struct sockaddr_x25 *)msg->msg_name;
>  	size_t copied;
> -	int qbit, header_len =3D x25->neighbour->extended ?
> -		X25_EXT_MIN_LEN : X25_STD_MIN_LEN;
> -
> +	int qbit, header_len;
>  	struct sk_buff *skb;
>  	unsigned char *asmptr;
>  	int rc =3D -ENOTCONN;
> =20
> +	if (x25->neighbour =3D=3D NULL)
> +		return rc;
> +
> +	header_len =3D x25->neighbour->extended ?
> +		X25_EXT_MIN_LEN : X25_STD_MIN_LEN;
> +
>  	lock_sock(sk);

BTW, you probably want to check x25->neighbour while sk is locked, not
before.

	lock_sock(sk);
	if (x25->neighbour =3D=3D NULL)
		goto out;
	header_len =3D x25->neighbour->extended ?
		     X25_EXT_MIN_LEN : X25_STD_MIN_LEN;
=20
