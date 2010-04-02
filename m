From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 2 Apr 2010 13:04:58 +0800
Message-ID: <j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62189 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab0DBFF5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 01:05:57 -0400
Received: by gyg13 with SMTP id 13so817000gyg.19
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 22:05:57 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 2, 2010 at 11:59 AM, Tom Herbert <therbert@google.com> wrot=
e:
> @@ -714,6 +716,8 @@ int inet_sendmsg(struct kiocb *iocb, struct socke=
t *sock, struct msghdr *msg,
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sock *sk =3D sock->sk;
>
> + =C2=A0 =C2=A0 =C2=A0 inet_rps_record_flow(sk);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We may need to bind the socket. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!inet_sk(sk)->inet_num && inet_autobin=
d(sk))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EAGAIN=
;
> @@ -722,12 +726,13 @@ int inet_sendmsg(struct kiocb *iocb, struct soc=
ket *sock, struct msghdr *msg,
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(inet_sendmsg);
>
> -
> =C2=A0static ssize_t inet_sendpage(struct socket *sock, struct page *=
page, int offset,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t size, int flags)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sock *sk =3D sock->sk;
>
> + =C2=A0 =C2=A0 =C2=A0 inet_rps_record_flow(sk);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We may need to bind the socket. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!inet_sk(sk)->inet_num && inet_autobin=
d(sk))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EAGAIN=
;
> @@ -737,6 +742,22 @@ static ssize_t inet_sendpage(struct socket *sock=
, struct page *page, int offset,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return sock_no_sendpage(sock, page, offset=
, size, flags);
> =C2=A0}
>

for sending packets, how about letting sender compute the rxhash of
the packets from the other side if the rxhash of socket hasn't been
set yet. I is better for client applications.

=46or router and bridge, the current RPS can work well, but not for
server or client applications. So I propose a new socket option to get
the rps cpu of the packets received on a socket. It may be like this:

int cpu;
getsockopt(sock, SOL_SOCKET, SO_RPSCPU, &cpu, sizeof(cpu));

As Tom's patch did, rxhash is recorded in socket. When the call above
is made, rps_map is looked up to find the RPSCPU for that hash. Once
we get the cpu of the current connection, for a TCP server, it can
dispatch the new connection to the processes which run on that CPU.
the server code will be like this:

fd =3D accpet(fd, NULL, NULL);
getsockopt(fd, SOL_SOCKET, SO_RPSCPU, &cpu, sizeof(cpu));
asyncq_enqueue(work_queue[cpu], fd);

=46or a client program, the rxhash can be got after the first packet of
the connection is sent. So the client code will be:

fd =3D connect(fd, &addr, addr_len);
getsockopt(fd, SOL_SOCKET, SO_RPSCPU, &cpu, sizeof(cpu));
asyncq_enqueue(work_queue[cpu], fd);

I do think this idea is easier to understood. I'll cook a patch later
if it is welcomed.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
