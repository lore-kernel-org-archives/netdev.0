From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Fri, 07 Oct 2011 14:04:33 +0200
Message-ID: <1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111005202723.GE2479@zod.bos.redhat.com>
	 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
	 <20111006132353.GF2479@zod.bos.redhat.com>
	 <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
	 <1317972573.3457.55.camel@edumazet-laptop>
	 <20111007114017.GA1165@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joel Sing <jsing@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:63300 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759892Ab1JGMET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 08:04:19 -0400
Received: by ggnv2 with SMTP id v2so2656846ggn.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 05:04:18 -0700 (PDT)
In-Reply-To: <20111007114017.GA1165@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 octobre 2011 =C3=A0 07:40 -0400, Josh Boyer a =C3=A9crit=
 :

> The original bug reporter explained the loopback testcase is simply a
> trivial example to illustrate the problem.  The real setup seems to b=
e:
>=20
> "I have a hardware (Dell PC) booting over the network with PXE, this
> hardware try to load it system from a tftp server. If I used the real
> ip of the tftp server I have no problem, if I used an alias I have th=
e
> problem (I have to use an alias, because I have a Cluster).
>=20
> What I think, the bios tftp client talk to the server with the IP ali=
as
> but the server reply with the real IP and the client reject the reply=
=2E"
>=20
> So in this case, because the alias is being used in a cluster, should=
 he
> also setup the local routing table as you suggested?
>=20
> I apologize for my lack of depth here.  I'm at the moment somewhat of=
 a
> go-between.  I do greatly appreciate the help!

Its a completely different problem IMHO : You describe a tftp server
bug.

Say your tftp server is multihomed with 3 different IPS :=20

192.168.20.21, 192.168.20.22, 192.168.20.23

And tftp server listens to any address (UDP port 69) : 0.0.0.0:69

When receiving a request on 192.168.20.22, it should use same source
address, not let the system chose a "random or whatever policy" one.



So I would suggest to check/fix if TFTP server uses the correct socket
API to get both the client IP and its own IP in each UDP datagram

-> setsockopt(fd, IPPROTO_IP, &on, sizeof(on))

       IP_PKTINFO
              Pass  an  IP_PKTINFO  ancillary message that contains a p=
ktinfo structure that supplies some
              information about the incoming packet.  This only works f=
or datagram oriented sockets.   The
              argument  is a flag that tells the socket whether the IP_=
PKTINFO message should be passed or
              not.  The message itself can only be sent/retrieved as co=
ntrol message with a  packet  using
              recvmsg(2) or sendmsg(2).

                  struct in_pktinfo {
                      unsigned int   ipi_ifindex;  /* Interface index *=
/
                      struct in_addr ipi_spec_dst; /* Local address */
                      struct in_addr ipi_addr;     /* Header Destinatio=
n
                                                      address */
                  };

              ipi_ifindex  is  the unique index of the interface the pa=
cket was received on.  ipi_spec_dst
              is the local address of the packet and ipi_addr is the de=
stination  address  in  the  packet
              header.  If IP_PKTINFO is passed to sendmsg(2) and ipi_sp=
ec_dst is not zero, then it is used
              as the local source address for the routing table lookup =
and for setting up IP source  route
              options.  When ipi_ifindex is not zero, the primary local=
 address of the interface specified
              by the index overwrites ipi_spec_dst for the routing tabl=
e lookup.



This permits tftp server to use the same "struct in_pktinfo" for replie=
s, forcing a correct source address.
