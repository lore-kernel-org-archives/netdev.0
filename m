From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: kernel 3.1.1 message:  <IRQ> warn_alloc_failed
Date: Tue, 13 Dec 2011 10:41:52 -0800
Message-ID: <20111213104152.14c01911@nehalam.linuxnetplumber.net>
References: <6.2.5.6.2.20111208210303.03a06228@flumedata.com>
	<20111209095014.14a647cd@nehalam.linuxnetplumber.net>
	<6.2.5.6.2.20111209130007.039b3078@binnacle.cx>
	<13A253B3F9BEFE43B93C09CF75F63CAA8162593365@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "starlight@binnacle.cx" <starlight@binnacle.cx>,
	Sony Chacko <sony.chacko@qlogic.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <13A253B3F9BEFE43B93C09CF75F63CAA8162593365@MNEXMB1.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Dec 2011 11:42:13 -0600
Rajesh Borundia <rajesh.borundia@qlogic.com> wrote:

> Hi All,
> 
> Sorry for late reply.
> 
> Stephan,
> Thanks for analyzing.
> 
> Yes, the netxen adapter does not support fragmented page memory.
> They are not harmful messages. At that instant of time it may fail allocating
> memory for some buffers in the ring but after enough memory is available
> it will try to allocate memory for unallocated buffers in ring.
> 
> Or the other option could be to turn LRO off.
> 
> Rajesh  
> 
> ________________________________________
> From: starlight@binnacle.cx [starlight@binnacle.cx]
> Sent: Friday, December 09, 2011 11:33 PM
> To: Stephen Hemminger; Sony Chacko; Rajesh Borundia
> Cc: linux-kernel; netdev
> Subject: Re: kernel 3.1.1 message:  <IRQ> warn_alloc_failed
> 
> At 09:50 AM 12/9/2011 -0800, Stephen Hemminger wrote:
> >On Thu, 08 Dec 2011 21:10:02 -0500 starlight@binnacle.cx wrote:
> >
> >You are seeing memory allocation failures because device
> >is allocating a 16K (order 2) size socket buffer. You are using
> >netxen device, and it looks like the problem.
> >
> >From reading the netxen driver source. The LRO buffers
> >in this device are very large (8060+skb overhead).
> >Until the driver is fixed to use fragmented page size memory,
> >I recommend turning off LRO.
> 
> Thank you for the analysis.  As an alternative
> would it make sense to double or quadruple
> 
>     /proc/sys/vm/min_free_kbytes
> 
> or perhaps do the same for
> 
>     /proc/slabinfo(size-16384)
> 

The driver should be changed to call allocation with __GFP_NOWARN.
Change dev_alloc_skb(size) to
  __dev_alloc_skb(size, GFP_ATOMIC|__GFP_NOWARN)

Or better yet, switch to using netdev_alloc variant like
  __netdev_alloc_skb_ip_align(dev, length, GFP_ATOMIC|__GFP_NOWARN)
