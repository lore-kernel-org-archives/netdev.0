From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: How to use ixp4xx_hss (or generic-hdlc?)
Date: Sat, 22 Nov 2008 00:28:16 +0100
Message-ID: <m37i6wslpr.fsf@maximus.localdomain>
References: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
	<20081120222431.GA16068@electric-eye.fr.zoreil.com>
	<b0438a630811210018j38518462ve975dfd3a7220b00@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53979 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755188AbYKUX2T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:28:19 -0500
In-Reply-To: <b0438a630811210018j38518462ve975dfd3a7220b00@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Fri\, 21 Nov
 2008 09\:18\:43 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> I have also taken a look to the code of sethdlc to see how the socket
> to the interface was set. He made "sock =3D socket(PF_INET, SOCK_DGRA=
M,
> IPPROTO_IP);" which I suppose does not care a lot because sethdlc onl=
y
> uses the socket to send ioctls, and not any data transfers.

This is a bit different matter, though you may need it to get ifr_index=
=2E

> However, in my case, I need to send data in a non-IP world using the
> interface. So... Is this the way I should open the socket? Would this
> encapsulate my data in hdlc before sending it to the interface?
>
> if I open the socket using sock =3D socket(PF_PACKET, SOCK_RAW,
> htons(ETH_P_ALL)); I can send data into the interface, but it is just
> sent as raw data (which is logic).

It should be bit-stuffed and encapsulated in HDLC frames (flags etc),
assuming a real HDLC device.

You may need to prepend some headers, though.

The basic idea is:

        int sock;
        struct ifreq ifr;
        struct sockaddr_ll addr;

        strcpy(ifr.ifr_name, "hdlc0");
        if ((sock =3D socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0)
                error();
        if (ioctl(sock, SIOCGIFINDEX, &ifr))
                error();
        close(sock);

        if ((sock =3D socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) < =
0)
                error();

        memset(&addr, 0, sizeof(addr));
        addr.sll_family =3D AF_PACKET;
        addr.sll_protocol =3D htons(ETH_P_ALL);
        addr.sll_ifindex =3D ifr.ifr_ifindex;
then:
        sendto(sock, packet_data, packet_size, 0, &addr, sizeof(addr)) =
< 0)

for RX:
        if (bind(sock, &addr, sizeof(addr)) < 0)
                error();
then:
        recvfrom(sock, buffer, max_packet_size, 0, &addr, &addr_len)
--=20
Krzysztof Halasa
