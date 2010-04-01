From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 1 Apr 2010 13:50:44 +0800
Message-ID: <v2q412e6f7f1003312250g35ad9ffex8b707bd817ef946f@mail.gmail.com>
References: <20100331223637.31f5f6ed@notabene.brown> <20100331114936.3549ca90@s6510>
	<20100401072412.032aa8e6@notabene.brown> <20100331.141732.225997212.davem@davemloft.net>
	<20100401090756.69bfb57d@notabene.brown> <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
	<20100401143805.1f83a161@notabene.brown> <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:37216 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab0DAFvF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 01:51:05 -0400
Received: by yxe37 with SMTP id 37so323349yxe.21
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 22:51:04 -0700 (PDT)
In-Reply-To: <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 1, 2010 at 12:16 PM, Changli Gao <xiaosuo@gmail.com> wrote:
>
> I found this from man page for connect(2)
>
> =C2=A0 =C2=A0 =C2=A0 Generally, connection-based protocol sockets may=
 successfully connect()
> =C2=A0 =C2=A0 =C2=A0 only once; connectionless protocol sockets may u=
se =C2=A0connect() =C2=A0multiple
> =C2=A0 =C2=A0 =C2=A0 times to change their association. =C2=A0Connect=
ionless sockets may dissolve
> =C2=A0 =C2=A0 =C2=A0 the association by connecting to an address with=
 the =C2=A0sa_family =C2=A0member
> =C2=A0 =C2=A0 =C2=A0 of sockaddr set to AF_UNSPEC (supported on Linux=
 since kernel 2.2).
>

dissolving the association by connecting to an address with the
sa_family member of sockaddr set to AF_UNSEPC is broken too.

int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a=
ddr_len)
{
        struct inet_sock *inet =3D inet_sk(sk);
        struct sockaddr_in *usin =3D (struct sockaddr_in *) uaddr;
        struct rtable *rt;
        __be32 saddr;
        int oif;
        int err;


        if (addr_len < sizeof(*usin))
                return -EINVAL;

        if (usin->sin_family !=3D AF_INET)
                return -EAFNOSUPPORT;

according to the man page, sin_family =3D=3D AF_UNSPEC should be allowe=
d.
And netlink's connect doesn't check the addr_len, so it behavior is
also undeterminedl

static int netlink_connect(struct socket *sock, struct sockaddr *addr,
                           int alen, int flags)
{
        int err =3D 0;
        struct sock *sk =3D sock->sk;
        struct netlink_sock *nlk =3D nlk_sk(sk);
        struct sockaddr_nl *nladdr =3D (struct sockaddr_nl *)addr;

        if (addr->sa_family =3D=3D AF_UNSPEC) {
                sk->sk_state    =3D NETLINK_UNCONNECTED;
                nlk->dst_pid    =3D 0;
                nlk->dst_group  =3D 0;
                return 0;
        }

If this issues need to be fixed, I'll check all the protocols if their
connect() checkes the sizeof of socket address or not, and post a
patch.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
