From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.12+
Date: Mon, 01 Dec 2014 12:20:09 +0100
Message-ID: <1647323.BnLExmnE1g@storm>
References: <20141201102522.GA16579@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:51827 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbaLALUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 06:20:13 -0500
In-Reply-To: <20141201102522.GA16579@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 1. December 2014 18:25:22 Herbert Xu wrote:
> Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> > When I revert it, even kernel v3.18-rc6 starts working.
> > But I doubt this is the root problem, may be just hiding another issue.
> 
> Can you do a tcpdump with this patch reverted? I would like to
> see the size of the packets that are sent out vs. the ICMP message
> that came back.
> 
> My guess is that the IPsec GSO path is buggy since as you rightly
> pointed out it couldn't have been heavily tested prior to this
> patch.
> 
> Though I am surprised that it only breaks when you have a PMTU event
> so it might be something else after all.

I've sent you two pcap files off list. One with the reverted patch
and one I created on Saturday showing the stalling TCP connection.
(though the mail currently seems greylisted by the receiving mail server)

One thing I can say from looking at the tcpdump with the reverted patch
is that the ESP packet size drops from 1510 to 1478. The announced MTU
of the next hop in the ICMP message is 1464. It also contains seven
duplicated ACK packets later on.


Without the reverted patch, it sends four ESP packets:
1. 1498 bytes
2. 1498 bytes
3. 1498 bytes
4. 234 bytes

That triggers the  ICMP "fragmentation needed" message. I can only spot one 
ESP packet of size 1466 afterwards that's sent from time to time. Only one
duplicated ACK packet can be seen. The other packets are just not resent. 
May be it's stuck in some in-kernel queue because it's too big to send
and stays there until it expires?

Today I also tried changing the NIC driver on the virtual machine
from virtio_net to e1000. Luckily still the same behavior,
so it's probably not related to the virtio_net driver.

Cheers,
Thomas
