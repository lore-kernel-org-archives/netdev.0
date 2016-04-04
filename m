From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Best way to reduce system call overhead for tun device I/O?
Date: Mon, 4 Apr 2016 10:28:45 -0700
Message-ID: <20160404102845.54ffd20c@xeon-e3>
References: <57026D91.4090207@valdikss.org.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Guus Sliepen <guus@tinc-vpn.org>,
	Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
To: ValdikSS <iam@valdikss.org.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35458 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcDDR2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 13:28:34 -0400
Received: by mail-pf0-f180.google.com with SMTP id n1so43659536pfn.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 10:28:34 -0700 (PDT)
In-Reply-To: <57026D91.4090207@valdikss.org.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Apr 2016 16:35:13 +0300
ValdikSS <iam@valdikss.org.ru> wrote:

> I'm trying to increase OpenVPN throughput by optimizing tun manipulations, too.
> Right now I have more questions than answers.
> 
> I get about 800 Mbit/s speeds via OpenVPN with authentication and encryption disabled on a local machine with OpenVPN server and client running in a different
> network namespaces, which use veth for networking, with 1500 MTU on a TUN interface. This is rather limiting. Low-end devices like SOHO routers could only
> achieve 15-20 Mbit/s via OpenVPN with encryption with a 560 MHz CPU.
> Increasing MTU reduces overhead. You can get > 5GBit/s if you set 16000 MTU on a TUN interface.
> That's not only OpenVPN related. All the tunneling software I tried can't achieve gigabit speeds without encryption on my machine with MTU 1500. Didn't test
> tinc though.
> 
> TUN supports various offloading techniques: GSO, TSO, UFO, just as hardware NICs. From what I understand, if we use GSO/GRO for TUN, we would be able to receive
> send small packets combined in a huge one with one send/recv call with MTU 1500 on a TUN interface, and the performance should increase and be just as it now
> with increased MTU. But there is a very little information of how to use offloading with TUN.
> I've found an old example code which creates TUN interface with GSO support (TUN_VNET_HDR), does NAT and echoes TUN data to stdout, and a script to run two
> instances of this software connected with a pipe. But it doesn't work for me, I never see any combined frames (gso_type is always 0 in a virtio_net_hdr header).
> Probably I did something wrong, but I'm not sure what exactly is wrong.
> 
> Here's said application: http://ovrload.ru/f/68996_tun.tar.gz
> 
> The questions are as follows:
> 
>  1. Do I understand correctly that GSO/GRO would have the same effect as increasing MTU on TUN interface?
>  2. How GRO/GSO is different from TSO, UFO?
>  3. Can we get and send combined frames directly from/to NIC with offloading support?
>  4. How to implement GRO/GSO, TSO, UFO? What should be the logic behind it?
> 
> 
> Any reply is greatly appreciated.
> 
> P.S. this could be helpful: https://ldpreload.com/p/tuntap-notes.txt
> 
> > I'm trying to reduce system call overhead when reading/writing to/from a
> > tun device in userspace. For sockets, one can use sendmmsg()/recvmmsg(),
> > but a tun fd is not a socket fd, so this doesn't work. I'm see several
> > options to allow userspace to read/write multiple packets with one
> > syscall:
> >
> > - Implement a TX/RX ring buffer that is mmap()ed, like with AF_PACKET
> >   sockets.
> >
> > - Implement a ioctl() to emulate sendmmsg()/recvmmsg().
> >
> > - Add a flag that can be set using TUNSETIFF that makes regular
> >   read()/write() calls handle multiple packets in one go.
> >
> > - Expose a socket fd to userspace, so regular sendmmsg()/recvmmsg() can
> >   be used. There is tun_get_socket() which is used internally in the
> >   kernel, but this is not exposed to userspace, and doesn't look trivial
> >   to do either.
> >
> > What would be the right way to do this?
> >
> > -- 
> > Met vriendelijke groet / with kind regards,
> >      Guus Sliepen <guus@tinc-vpn.org>

The first step to getting better performance through GRO would be modifying
TUN device to use NAPI when receiving. I tried this once, and it got more complex
than I had patience for because TUN device write is obviously in userspace context.
