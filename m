From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 20:43:51 +0400
Message-ID: <20080903164346.GA6729@2ka.mipt.ru>
References: <20080902194603.GA2825@2ka.mipt.ru> <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com> <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com> <20080903.040626.198546183.davem@davemloft.net> <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com> <20080903132734.GA17541@2ka.mipt.ru> <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com> <20080903151340.GA7566@2ka.mipt.ru> <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:47859 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbYICQoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 12:44:22 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Wed, Sep 03, 2008 at 05:58:50PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> > What is the bus width and is there burst mode support?
> > Not to point to the error in the speed calculation, just out of curiosity :)
> > Always liked such tiny systems...
> 
> 32 bits with burst support. This is a PPC 405 embedded into Xilinx V4
> FPGA . (PLB bus)

So small PLB? Not OPB? Weird hardware :)
But nevertheless at most 400 MB/s with 100mhz, so looks like either
there is no burst mode or weird NIC hardware (or something else :)
I used to easily saturate 100mbit channel with 405gp(r) and emac driver,
which are better numbers than what you have with gige and sockets...
Actually even 405gp had much wider plb, so this could be an issue.

Likley your project will just dma data from some sensor to the
preallocated buffer, you will add headers and send the data, so very
small memory bus speed will not allow to use sockets and thus TCP.
Having splice-friendly setup is possible, but I think raw socket
approach is simpler for you.

> > But why sendfile/splice does not work the same?
> > It is (supposed to be) a zero-copy sending interface, which should be even
> > more optimal, than your ring buffer approach, since uses just single
> > syscall and no initialization of the data (well, there is page
> > population and so on, but if file is in the ramdisk, it is effectively
> > zero overhead). Can you run oprofile during sendfile() data transfer or
> > describe behaviour (i.e. CPU usage and tcpdump).
> 
> I've never used oprofile before. I will get more logs and let you know.
> Just a question: I don't want to use TCP for final application.
> Is it expected that the kernel execute packet_sendmsg() when using
> packet socket with splice()?  (because this function is doing a memcpy
> from a buffer to a socket buffer).

No, it will use sendpage() if hardware and driver support scatter/gather
and checksumm ofloading. Since you say they do, then there should be no
copies at all.

> Or is there a dedicated path for splicing? or maybe only in TCP read
> (I can see that splice_read operator is redefined with
> tcp_splice_read())?

It will endup with generic_splice_sendpage() and pipe_to_sendpage().

> And I've also faced some issues with the size of packet (it seems to
> be limited to page size). It is really important for me to send large
> packet. I've just decreased the packet size of pktgen script from 7200
> to 4096 and the bitrate has fallen from 85Mbytes/s to 50Mbytes/s.
> I understand that this is not a problem with TCP when sending a file,
> we don't really care about accuracy of the packet size.
> Do you know if there is way to adjust the size ?

What do you mean by packet size? MTU/MSS? In pktgen it means size of the
allocated skb, so it will be eventually split into smaller chunks and the
bigger size you have, the less allocations will be performed. Actually
the fact, that 7200 works at all, is a bit surprising: your small
machine has lots of ram and is effectively unused during tests (i.e. no
other allocations). Changing it do 4k should not decrease performance at
all... Do you have jumbo frames enabled?

-- 
	Evgeniy Polyakov
