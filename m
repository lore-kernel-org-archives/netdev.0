From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Polling on sockets in kernel space and struct file
Date: Wed, 08 Dec 2010 16:02:53 +0100
Message-ID: <1291820573.2883.56.camel@edumazet-laptop>
References: <4CFF9757.3070100@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Martin Lucina <mato@kotelna.sk>
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:49569 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604Ab0LHPDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 10:03:02 -0500
Received: by eyg5 with SMTP id 5so930187eyg.2
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 07:03:00 -0800 (PST)
In-Reply-To: <4CFF9757.3070100@250bpm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 15:33 +0100, Martin Sustrik a =
=C3=A9crit :
> Hi all,
>=20
> As part of implementing a new experimental protocol family, we are=20
> trying to create a socket in kernel. This seems to be easy, just use=20
> sock_create_kern(). However, the socket returned by this function doe=
s=20
> not have associated file structure; thus it cannot be polled on using=
=20
> poll_initwait() and friends.
>=20
> We have tried to create the appropriate struct file using sock_map_fd=
(),=20
> but this has two problems:
>=20
> 1) We do not want our internal socket to be visible in the process=20
> context, i.e. it should not have a file descriptor.



>=20
> 2) During process exit, we get a kernel BUG from iput() in fs/inode.c=
:1260.
>=20

you could call sock_map_fd() then :


	int fd =3D sock_map_fd(sock, flags);
	struct file *file =3D NULL;

	if (fd !=3D -1) {
		file =3D fget(fd);
		sys_close(fd);  /* still racy */
	}

	if (file) ...

Take a look at net/9p/trans_fd.c

> We then tried another approach using anon_inode_getfile() to get a=20
> struct file, but this still produces the problem 2) above.
>=20
> Any help/advice on how to proceed would be appreciated; for reference=
=20
> our work in progress can be seen at
>=20
> http://github.com/sustrik/linux-2.6/blob/sp-v2.6.36/net/sp/af_sp.c


