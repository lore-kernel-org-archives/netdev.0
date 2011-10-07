From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Fri, 07 Oct 2011 14:23:21 +0200
Message-ID: <1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	 <20111006132353.GF2479@zod.bos.redhat.com>
	 <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
	 <1317972573.3457.55.camel@edumazet-laptop>
	 <20111007114017.GA1165@zod.bos.redhat.com>
	 <1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joel Sing <jsing@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62262 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759951Ab1JGMXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 08:23:10 -0400
Received: by wyg34 with SMTP id 34so3828120wyg.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 05:23:09 -0700 (PDT)
In-Reply-To: <1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 octobre 2011 =C3=A0 14:04 +0200, Eric Dumazet a =C3=A9cr=
it :

> Its a completely different problem IMHO : You describe a tftp server
> bug.
>=20
> Say your tftp server is multihomed with 3 different IPS :=20
>=20
> 192.168.20.21, 192.168.20.22, 192.168.20.23
>=20
> And tftp server listens to any address (UDP port 69) : 0.0.0.0:69
>=20
> When receiving a request on 192.168.20.22, it should use same source
> address, not let the system chose a "random or whatever policy" one.
>=20
>=20
>=20
> So I would suggest to check/fix if TFTP server uses the correct socke=
t
> API to get both the client IP and its own IP in each UDP datagram
>=20
> -> setsockopt(fd, IPPROTO_IP, &on, sizeof(on))

> This permits tftp server to use the same "struct in_pktinfo" for repl=
ies, forcing a correct source address.
>=20

By the way, there is no need for tftp change :

Just launch several tftpd instances, and bind each them to one
particular IP.

If started from xinetd.d :

$ cat /etc/xinetd.d/tftp1
service tftp
{
	socket_type		=3D dgram
	protocol		=3D udp
	wait			=3D yes
	user			=3D root
	server			=3D /usr/sbin/in.tftpd
	server_args		=3D -s /tftpboot
	disable			=3D no
	bind		=3D 192.168.20.21
	per_source		=3D 11
	cps			=3D 100 2
	flags			=3D IPv4
}

$ cat /etc/xinetd.d/tftp2
service tftp
{
	socket_type		=3D dgram
	protocol		=3D udp
	wait			=3D yes
	user			=3D root
	server			=3D /usr/sbin/in.tftpd
	server_args		=3D -s /tftpboot
	disable			=3D no
	bind		=3D 192.168.20.22
	per_source		=3D 11
	cps			=3D 100 2
	flags			=3D IPv4
}

$ cat /etc/xinetd.d/tftp3
service tftp
{
	socket_type		=3D dgram
	protocol		=3D udp
	wait			=3D yes
	user			=3D root
	server			=3D /usr/sbin/in.tftpd
	server_args		=3D -s /tftpboot
	disable			=3D no
	bind		=3D 192.168.20.23
	per_source		=3D 11
	cps			=3D 100 2
	flags			=3D IPv4
}
