From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: How to use ixp4xx_hss (or generic-hdlc?)
Date: Mon, 24 Nov 2008 10:56:23 +0100
Message-ID: <b0438a630811240156u161af1em917c7b4d35fe019a@mail.gmail.com>
References: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
	 <20081120222431.GA16068@electric-eye.fr.zoreil.com>
	 <b0438a630811210018j38518462ve975dfd3a7220b00@mail.gmail.com>
	 <m37i6wslpr.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:61603 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbYKXJ4Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 04:56:24 -0500
Received: by an-out-0708.google.com with SMTP id d40so775211and.1
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 01:56:23 -0800 (PST)
In-Reply-To: <m37i6wslpr.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/11/22 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> I have also taken a look to the code of sethdlc to see how the socke=
t
>> to the interface was set. He made "sock =3D socket(PF_INET, SOCK_DGR=
AM,
>> IPPROTO_IP);" which I suppose does not care a lot because sethdlc on=
ly
>> uses the socket to send ioctls, and not any data transfers.
>
> This is a bit different matter, though you may need it to get ifr_ind=
ex.
>
Sure. You are right.

>> However, in my case, I need to send data in a non-IP world using the
>> interface. So... Is this the way I should open the socket? Would thi=
s
>> encapsulate my data in hdlc before sending it to the interface?
>>
>> if I open the socket using sock =3D socket(PF_PACKET, SOCK_RAW,
>> htons(ETH_P_ALL)); I can send data into the interface, but it is jus=
t
>> sent as raw data (which is logic).
>
> It should be bit-stuffed and encapsulated in HDLC frames (flags etc),
> assuming a real HDLC device.
>
> You may need to prepend some headers, though.
>

I am not sure of having understood you. The buffer I send using sendto
should be just the payload and the generic-hdlc (or the hardware)
encapsulates it in an hdlc frame, or should I prepare the whole frame?

> The basic idea is:
>
>        int sock;
>        struct ifreq ifr;
>        struct sockaddr_ll addr;
>
>        strcpy(ifr.ifr_name, "hdlc0");
>        if ((sock =3D socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)) < 0)
>                error();
>        if (ioctl(sock, SIOCGIFINDEX, &ifr))
>                error();
>        close(sock);
>
>        if ((sock =3D socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) <=
 0)
>                error();
>
>        memset(&addr, 0, sizeof(addr));
>        addr.sll_family =3D AF_PACKET;
>        addr.sll_protocol =3D htons(ETH_P_ALL);
>        addr.sll_ifindex =3D ifr.ifr_ifindex;
> then:
>        sendto(sock, packet_data, packet_size, 0, &addr, sizeof(addr))=
 < 0)
>
> for RX:
>        if (bind(sock, &addr, sizeof(addr)) < 0)
>                error();
> then:
>        recvfrom(sock, buffer, max_packet_size, 0, &addr, &addr_len)

I took a little different approach, using the same PF_PACKET socket to
obtain the ifr_ifindex, but in any case using your method or "my"
method, and activating the debugging in ixp4xx_hss, when I do a two
byte (0x30 0x31) sendto, the traces in debug_pkt give me:

1970/01/01,00:00:47 (none) user.debug kernel: hdlc0: hss_hdlc_xmit(2)
<7> 30<7>31<7>

I cannot test the real hardware output in the lines at the moment, so
I do not know if this is what I was supposed to obtain, or not
(talking about the hdlc headers and trailers...).

Thanks

Miguel =C1ngel
