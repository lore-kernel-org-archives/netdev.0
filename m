From: Eric Lemoine <Eric.Lemoine@Sun.COM>
Subject: Re: simple change to qdisc_restart()
Date: Tue, 20 May 2003 13:21:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520112109.GE978@udine>
References: <20030520082217.GC978@udine>
 <20030520.012824.85398613.davem@redhat.com> <20030520085724.GD978@udine>
 <16074.1339.3673.938923@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Eric Lemoine <Eric.Lemoine@Sun.COM>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <16074.1339.3673.938923@robur.slu.se>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  > >    Any comments regarding the following patch?
> 
>  I think it will make any use of "raw" dev->hard_start_xmit" impossible. 
>  Which is what pktgen uses.
> 
>  > > I understand why it is valid, etc., but why do we even want to do
>  > > this?  It is not like this dead-loop detection stuff is a hot-path or
>  > > anything like that.
>  > 
>  > I've implemented a prototype that uses per-CPU kernel threads for
>  > processing packets coming in from a single interface. The idea is to
>  > apply multiple CPUs to a single network interface to be able to have
>  > multiple CPUs simultaneously pumping data into the network. So in my
>  > case, I have lots of cpu_collisions and running the tx softirq to do
>  > nothing may lower the performances. Anyway, even though my patch may
>  > help me, it may indeed be irrelevant to the stock kernel.
> 
>  Sounds like a project at least having packet reordering and cache bouncing 
>  in mind.

Let me explain a bit more.

I developped a kernel module that basically implements per-cpu kernel
threads, each being bound to a particular cpu. I also modified the
Myrinet NIC driver and firmware so that they implement per-cpu rx rings.

The NIC makes sure that packets of the same connection are always
deposited in the same ring. Here's how it does it. For each incoming
pkt, the NIC computes the index of the ring into which the packet must
be placed [*], passes this index to the driver, and dmas the packet into
the appropriate ring. The driver uses the ring index to wake up the
appropriate kernel thread. Each kernel-thread behaves in a NAPI manner.

-- 
Eric
