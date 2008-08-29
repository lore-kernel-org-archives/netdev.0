From: Joe Malicki <jmalicki@metacarta.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Fri, 29 Aug 2008 11:21:26 -0400 (EDT)
Message-ID: <32566205.1357331220023286187.JavaMail.root@ouachita>
References: <20080828072218.GI26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from silene.metacarta.com ([208.80.142.18]:36937 "EHLO
	silene.metacarta.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbYH2PV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 11:21:28 -0400
In-Reply-To: <20080828072218.GI26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- "Andi Kleen" <andi@firstfloor.org> wrote:
> > I've worked with systems where SO_TIMESTAMP has been used for
> > H.323 videoconferencing systems to synchronize audio and video
> 
> But didn't you really want a "end2end" time stamp in this case,
> as in really at the end of all kernel/hardware queues on your side.

No.

That adds variance, and packets aren't comparable because they may
suffer different kernel/hardware delays.

The goal is to approximate original sendtime when the application-level
timestamps are unreliable.  The more queueing delays that can be
taken out of the timestamp, the better.

> A packet roughly travels this way on a normal NIC before it hits
> recvmsg()
> 
> wire -> NIC on die buffers -> NIC RX ring -> interrupt handler -> 
> NAPI or per CPU queue -> softirq socket lookup -> socket queue ->
> recvmsg
> 
> These all do their own queuing and all queues can add delays
> depending
> on the load.  Right now SO_TIMESTAMP is in the interrupt handler,
> but it's just an arbitary position in a multitude of queues.
> 

If it could be even earlier, it would be better.

> For video conferencing (or e.g. in general if you implement a
> retransmit 
> timeout in user space) scheduling delays on the local box
> surely need to be taken into account too because they all add
> to the final timing of the packets on the wire.

For retransmit timeouts, that might be interesting, and might be
one case where it is interesting.  But then what value does
SO_TIMESTAMP have, since you could call gettimeofday() immediately
after receipt, and also include application scheduling delays?

For videoconferencing, one wants to know when to display a packet
as compared to other packets.

> The queues inside the system are really part of the network
> too. In Linux for example the algorithms who size the TCP 
> buffer space know that and especially take account for it
> and reserve a local queue buffer. 
> 
> > where remote systems' timestamps on the protocol streams proved
> > to be inaccurate (based off of different, unsynchronized clocks).
> 
> Yes, but why ignore local scheduling delays? 

Because one would want to ignore even network scheduling delays
if possible... unfortunately in some instances it's not.

> > 
> > I can't see any other realistic use of this, but trying to get
> > timestamps for quasi-realtime protocols may be an important use
> > case - and in that case, you want the time when it hits the
> > interface, NOT when it hits the socket.
> 
> I think it's the other way round. Why would the real time 
> protocol care when it hits some arbitary queue in the network
> stack instead of the time when the application can really
> read the data?
>  
> > What utility does the time of hitting the socket get you?
> 
> SO_TIMESTAMP was originally invented for passive network
> monitoring as in tcpdump (for which PACKET sockets were designed
> originally, DHCP is really just abusing them imho). There it makes 
> some sense to do the time stamp as near on the wire as possible
> but really a hardware time stamp would be better because
> it is even nearer. But for anything that does end2end it's
> the wrong semantics anyways because ignoring local queueing 
> delays would be just a bug, and SO_TIMESTAMP ignores them currently.
> 
> -Andi
> 
> -- 
> ak@linux.intel.com

Why would you want to do end-to-end with SO_TIMESTAMP, vs. gettimeofday
after recv?
