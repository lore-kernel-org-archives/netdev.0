From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: mmap RX_RING socket issue 32b application running on 64b kernel.
Date: Thu, 8 Nov 2012 09:00:04 +0100
Message-ID: <CAD6jFUS7L+3uMqP3zi1S2bocNVQFFBNbzdRpymKv=Tq9R7AmZQ@mail.gmail.com>
References: <CAMJ=MEfeMDC3H2bjKz9XA4072Vo7U17108N4bK77q0GvUEF09w@mail.gmail.com>
	<CAD6jFURNbY4BkcUeykrkO2PU17+G_mOD7Dw3KrEx0BAaOpqiSA@mail.gmail.com>
	<CAMJ=MEdjyJ8+Y_ZaHkcizy_Y8gdWFoSbz+PdVbYkRDTKyMzT1Q@mail.gmail.com>
	<CAMJ=MEc1zHTr=X4dT6sD=sQKiLHe2p8F-0atHALBcRkMZidPdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ronny Meeus <ronny.meeus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52846 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab2KHIAO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 03:00:14 -0500
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TWN22-0004QX-Fy
	for netdev@vger.kernel.org; Thu, 08 Nov 2012 09:00:10 +0100
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TWN20-0003w5-Kw
	for netdev@vger.kernel.org; Thu, 08 Nov 2012 09:00:08 +0100
Received: by mail-ee0-f46.google.com with SMTP id b15so1374689eek.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 00:00:04 -0800 (PST)
In-Reply-To: <CAMJ=MEc1zHTr=X4dT6sD=sQKiLHe2p8F-0atHALBcRkMZidPdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 8, 2012 at 8:32 AM, Ronny Meeus <ronny.meeus@gmail.com> wro=
te:
> On Wed, Nov 7, 2012 at 7:54 PM, Ronny Meeus <ronny.meeus@gmail.com> w=
rote:
>> On Wed, Nov 7, 2012 at 7:26 PM, Daniel Borkmann
>> <danborkmann@iogearbox.net> wrote:
>>> On Wed, Nov 7, 2012 at 6:58 PM, Ronny Meeus <ronny.meeus@gmail.com>=
 wrote:
>>>> I have an application using raw Ethernet sockets in combination wi=
th
>>>> the mmaped RX_RING.
>>>> The application is running on a Cavium MIPS processor (64bit) and =
the
>>>> application code is compiled with the N32 ABI.
>>>>
>>>> Since the ring buffer is shared between the Linux kernel and the
>>>> application there is a conflict in the way the data is presented.
>>>> Each buffer in the ring has a header that has following structure:
>>>> (File http://lxr.free-electrons.com/source/include/linux/if_packet=
=2Eh )
>>>> 103 struct tpacket_hdr {
>>>> 104         unsigned long   tp_status;
>>>> 105         unsigned int    tp_len;
>>>> 106         unsigned int    tp_snaplen;
>>>> 107         unsigned short  tp_mac;
>>>> 108         unsigned short  tp_net;
>>>> 109         unsigned int    tp_sec;
>>>> 110         unsigned int    tp_usec;
>>>> 111 };
>>>>
>>>> The status field indicates that the buffer belongs to the kernel o=
r to
>>>> the user. Note that an unsigned long is used to represent the fiel=
d.
>>>> In the kernel the long is 64 bit while in application space the lo=
ng
>>>> is only 32bit, so the bits do not match.
>>>>
>>>> After adapting the code to take this into account my program works=
 well.
>>>> In my test program I have defined a new struct where I change the
>>>> =93unsigned long=94 into an =93unsigned long long=94:
>>>>
>>>> struct tpacket_hdr_64 {
>>>>   unsigned long long tp_status;
>>>>   unsigned int tp_len;
>>>>   unsigned int tp_snaplen;
>>>>   unsigned short tp_mac;
>>>>   unsigned short tp_net;
>>>>   unsigned int tp_sec;
>>>>   unsigned int tp_usec;
>>>> };
>>>>
>>>> In my opinion this is not a correct solution. It should be solved
>>>> somewhere in the include file I used so that it is transparent for=
 the
>>>> application.
>>>> Please comment.
>>>
>>> Have you tried to use packet_mmap with TPACKET version 2  [1]?
>>>
>>> In my understanding, it was introduced because of such issues that =
you
>>> described.
>>>
>>> [1] E.g. http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux=
=2Egit;a=3Dcommitdiff;h=3Dbbd6ef87c544d88c30e4b762b1b61ef267a7d279
>>
>> I did not try this. I will do it tomorrow.
>> Thanks for the quick response.
>
> With the code below it indeed works.
>
> req.tp_block_size =3D FRAME_SIZE * NR_FRAMES_PER_BLOCK;
> req.tp_frame_size =3D FRAME_SIZE;
> req.tp_block_nr   =3D NR_FRAMES / NR_FRAMES_PER_BLOCK;
> req.tp_frame_nr   =3D NR_FRAMES;
>
> val =3D TPACKET_V2;
> setsockopt(eth_sock, SOL_PACKET,PACKET_VERSION, &val, sizeof(val));
> setsockopt(eth_sock,SOL_PACKET,PACKET_RX_RING,(char *)&req,sizeof(req=
));
> packet_mem =3D mmap(NULL,req.tp_block_size * req.tp_block_nr,
>                   PROT_READ|PROT_WRITE|PROT_EXEC,MAP_SHARED,eth_sock,=
 0);
>
> I wonder why there are so many examples available on the Internet tha=
t
> either do not set the version or set the version to 1.

Maybe it should be documented somewhere. ;)

> I would assume that the only correct usage of this interface is to us=
e
> version 2 since this is working on all platforms.
> Is this correct?

=46or using RX_RING/TX_RING ... yep. I think version 1 is only for
backwards compatibility.
