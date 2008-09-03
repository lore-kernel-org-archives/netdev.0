From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 22:30:14 +0200
Message-ID: <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
References: <20080902194603.GA2825@2ka.mipt.ru>
	 <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
	 <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
	 <20080903.040626.198546183.davem@davemloft.net>
	 <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
	 <20080903132734.GA17541@2ka.mipt.ru>
	 <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
	 <20080903151340.GA7566@2ka.mipt.ru>
	 <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
	 <20080903164346.GA6729@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:32346 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbYICUaP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 16:30:15 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2920500rvb.1
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 13:30:14 -0700 (PDT)
In-Reply-To: <20080903164346.GA6729@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> So small PLB? Not OPB? Weird hardware :)
> But nevertheless at most 400 MB/s with 100mhz, so looks like either
> there is no burst mode or weird NIC hardware (or something else :)
> I used to easily saturate 100mbit channel with 405gp(r) and emac driv=
er,
> which are better numbers than what you have with gige and sockets...
> Actually even 405gp had much wider plb, so this could be an issue.
>
> Likley your project will just dma data from some sensor to the
> preallocated buffer, you will add headers and send the data, so very
> small memory bus speed will not allow to use sockets and thus TCP.
> Having splice-friendly setup is possible, but I think raw socket
> approach is simpler for you.

Yes, this is a custom hardware (FPGA :)). There is no combo IPLB / DPLB=
,
only one and small PLB bus at 100Mhz.

> No, it will use sendpage() if hardware and driver support scatter/gat=
her
> and checksumm ofloading. Since you say they do, then there should be =
no
> copies at all.
>

> It will endup with generic_splice_sendpage() and pipe_to_sendpage().
>
Indeed, I've double checked, but pipe_to_sendpage() will end up with
packet_sendmsg()

=2Esplice_write =3D generic_splice_sendpage,
generic_splice_sendpage()
splice_from_pipe();
pipe_to_sendpage() from err =3D actor(pipe, buf, sd);
sock_sendpage() from ile->f_op->sendpage()
sock_no_sendpage() from sock->ops->sendpage()
kernel_sendmsg()
sock_sendmsg();
packet_sendmsg() from sock->ops->sendmsg();
memcpy() :'(

I think a non-generic splice_write function should do the job.
What do you think?

>
> What do you mean by packet size? MTU/MSS? In pktgen it means size of =
the
> allocated skb, so it will be eventually split into smaller chunks and=
 the
> bigger size you have, the less allocations will be performed. Actuall=
y
> the fact, that 7200 works at all, is a bit surprising: your small
> machine has lots of ram and is effectively unused during tests (i.e. =
no
> other allocations). Changing it do 4k should not decrease performance=
 at
> all... Do you have jumbo frames enabled?
>

I mean the transfer unit size (ethernet frame length) that must be <=3D=
 MTU.
Jumbo frames are enabled in the driver and mtu size is set to 7200.
I'm currently using wireshark on a remote pc to check bitrate and forma=
t.
I think performance can decrease because CPU will spend the same time
to send 7200 or 4096 bytes but not the DMA.(~50=B5s for 7200, ~30=B5s f=
or
4096)


Thanks,
Johann

--=20
Johann Baudy
johaahn@gmail.com
