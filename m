From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Mon, 19 Feb 2007 15:11:36 -0500
Message-ID: <20070219201136.GH7585@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca> <20070216202300.GD7585@csclub.uwaterloo.ca> <20070216210157.GE7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:47747 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932567AbXBSULh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 15:11:37 -0500
Content-Disposition: inline
In-Reply-To: <20070216210157.GE7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 04:01:57PM -0500, Lennart Sorensen wrote:
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: pcnet32_poll: pcnet32_rx() got 16 packets
> eth1: base: 0x05215812 status: 0310 next->status: 0310
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: netif_receive_skb(skb)
> eth1: pcnet32_poll: pcnet32_rx() got 16 packets
> eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> eth1: interrupt  csr0=0x6f3 new csr=0x33, csr3=0x0000.
> eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> eth1: exiting interrupt, csr0=0x0433, csr3=0x5f00.
> eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> 
> So somehow it ends up that when it reads the status of the descriptor at
> address 0x04c51812, it sees the status as 0x8000 (which means owned by
> the MAC I believe), even though the next descriptor in the ring has a
> sensible status, indicating that the descriptor is ready to be handled
> by the driver.  Since the descriptor isn't ready, we exit without
> handling anything and NAPI reschedules is the next time we get an
> interrupt, and after some random number of tries, we finally see the
> right status and handle the packet, along with a bunch of other packets
> waiting in the descriptor ring.  Then we seem to hit the exact same
> descriptor address again, with the same problem in the status we read,
> and again we are stuck for a while, until finally we see the right
> status, and another pile of packets get handled, and we again hit the
> same descriptor address and get stuck.

I have been poking at things with firescope to see if the MAC is
actually writing to system memory or not.

The entry that it gets stuch on is _always_ entry 0 in the rx_ring.
There does not appear to be any exceptions to this.  

Here is my firescope (slightly modified for this purpose) dump of the
rx_ring of eth1:

Descriptor:Address: /--base---\ /buf\ /sta\ /-message-\ /reserved-\
          :       : |         | |len| |tus| | length  | |         |
RXdesc[00]:6694000: 12 18 5f 05 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[01]:6694010: 12 78 15 05 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[02]:6694020: 12 a0 52 06 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[03]:6694030: 12 f8 c2 04 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[04]:6694040: 12 70 15 05 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[05]:6694050: 12 e8 37 05 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[06]:6694060: 12 e0 37 05 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[07]:6694070: 12 e8 d5 04 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[08]:6694080: 12 e0 d5 04 fa f9 40 03 ee 05 00 00 00 00 00 00
RXdesc[09]:6694090: 12 d8 d1 05 fa f9 40 03 46 00 00 00 00 00 00 00
RXdesc[10]:66940a0: 12 d0 d1 05 fa f9 40 03 4e 00 00 00 00 00 00 00
RXdesc[11]:66940b0: 12 d8 02 05 fa f9 10 03 40 00 00 00 00 00 00 00
RXdesc[12]:66940c0: 12 d0 02 05 fa f9 40 03 46 00 00 00 00 00 00 00
RXdesc[13]:66940d0: 12 38 58 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[14]:66940e0: 12 30 58 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[15]:66940f0: 12 78 2c 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[16]:6694100: 12 a0 58 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[17]:6694110: 12 b0 04 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[18]:6694120: 12 b8 04 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[19]:6694130: 12 70 2c 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[20]:6694140: 12 f8 56 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[21]:6694150: 12 c8 29 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[22]:6694160: 12 20 03 05 fa f9 00 80 ee 05 00 00 00 00 00 00
RXdesc[23]:6694170: 12 60 4c 05 fa f9 00 80 87 05 00 00 00 00 00 00
RXdesc[24]:6694180: 12 98 53 05 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[25]:6694190: 12 b0 cc 04 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[26]:66941a0: 12 a8 3f 05 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[27]:66941b0: 12 58 e8 04 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[28]:66941c0: 12 b0 4d 06 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[29]:66941d0: 12 38 ef 04 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[30]:66941e0: 12 98 1f 05 fa f9 00 80 40 00 00 00 00 00 00 00
RXdesc[31]:66941f0: 12 28 f1 04 fa f9 00 80 40 00 00 00 00 00 00 00

I only ever see entry 0 as status 0080 (0x8000 which is owned by mac),
and this is while the driver is checking entry 0 every time it tries to
check for any waiting packets.

Running tcpdump while pinging gives the interesting result that some
packets are ariving out of order making it seem like the driver is
processing the packets out of order.  Perhaps the driver is wrong to be
looking at entry 0, and should be looking at entry 1 and is hence stuck
until the whole receive ring has been filled again?

15:06:04.112812 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 1
15:06:05.119799 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 2
15:06:05.120159 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 2
15:06:05.127045 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 1
15:06:06.119862 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 3
15:06:07.119921 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 4
15:06:08.119994 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 5
15:06:08.426400 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 3
15:06:08.427915 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 4
15:06:08.429033 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 5
15:06:09.120053 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 6
15:06:10.120109 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 7
15:06:10.705332 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 6
15:06:10.707258 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 7
15:06:11.120175 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 8
15:06:12.120233 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 9
15:06:13.120297 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 10
15:06:14.120359 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 11
15:06:14.120737 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 11
15:06:14.127064 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 8
15:06:14.127700 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 9
15:06:14.128268 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 10
15:06:15.120426 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 12
15:06:16.120484 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 13
15:06:16.120840 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 13
15:06:16.129476 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 12
15:06:17.120551 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 14
15:06:17.615429 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 14
15:06:18.120612 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 15
15:06:19.120672 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 16
15:06:19.748981 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 15
15:06:19.749976 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 16
15:06:20.120738 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 17
15:06:21.120799 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 18
15:06:22.120859 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 19
15:06:23.120926 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 20
15:06:24.120985 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 21
15:06:24.881809 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 17
15:06:24.882287 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 18
15:06:24.882578 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 19
15:06:24.883347 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 20
15:06:24.884158 IP 10.128.10.1 > 10.128.10.254: icmp 64: echo reply seq 21
15:06:25.129659 IP 10.128.10.254 > 10.128.10.1: icmp 64: echo request seq 22

Does anyone see any reason why the driver would get into such a state
after a pile of traffic in a row?  So far I have only seen it when NAPI
is enabled, so I have to assume so far that it makes a difference to it.

--
Len Sorensen
