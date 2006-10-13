From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Fri, 13 Oct 2006 08:17:25 +0200
Message-ID: <20061013061725.GB12571@mellanox.co.il>
References: <20061012.212240.26278742.davem@davemloft.net>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, steve@chygwyn.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:35203 "EHLO
	dev.mellanox.co.il") by vger.kernel.org with ESMTP id S1751009AbWJMGRz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 02:17:55 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061012.212240.26278742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. David Miller <davem@davemloft.net>:
> Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> 
> From: "Michael S. Tsirkin" <mst@mellanox.co.il>
> Date: Thu, 12 Oct 2006 21:12:06 +0200
> 
> > Quoting r. David Miller <davem@davemloft.net>:
> > > Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> > > 
> > > Numbers?
> > 
> > I created two subnets on top of the same pair infiniband HCAs:
> 
> I was asking for SG vs. non-SG numbers so I could see proof
> that it really does help like you say it will.
> 

Dave, thanks for the clarification.
Please note that ib0 is a non-SG device with MTU 2K,
sorry that I forgot to mention that.


so, to summarize my previous mail:


interface   flags      mtu    bandwidth
ib0         linear(0)  2044   286.45
ibc0        _F_SG      65484  782.55



If I will set both ib0 and ibc0 to 64K MTU, then
benchmark-mode with the same MTU SG is somewhat slower than non-SG 
(I tested this at some point, by some 10%, don't have the numbers at the moment -
do you want to see them?).  I did not claim it is faster to do SG with same MTU
and it is I think clear why linear should be faster for copy *with the same MTU*.
But do you really think that we will be able to allocate
even a single 64K linear skb after the machine has been active for a while?

My assumption is that if I want to reliably get MTU > PAGE_SIZE I must support SG.
Is it the wrong one?

If this assumption is correct, then below is my line of thinking:
- with infiniband we provably get a 2.5x speedup with MTU of 64K vs to 2K.
- to get packets of that size reliably we must declare S/G support
- infiniband verbs do not support IP checksumming
- per network algorithmics, it is better to piggyback checksum calculation
  on copying if copying takes place

For this reason, I would like to define the meaning of S/G set when checksum
bits are all clear as "we support S/G but not checksum, please checksum
for us if you copy data anyway". Alternatively, add a new
NETIF_F_??_CSUM bit to mean this capability.
Does this make sense?

Thanks,

-- 
MST
