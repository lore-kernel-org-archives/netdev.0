From: Andi Kleen <andi@firstfloor.org>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 09:22:18 +0200
Message-ID: <20080828072218.GI26610@one.firstfloor.org>
References: <20080827.201020.17601834.davem@davemloft.net> <21915755.1327801219904892242.JavaMail.root@ouachita>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Joe Malicki <jmalicki@metacarta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753933AbYH1HT7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <21915755.1327801219904892242.JavaMail.root@ouachita>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I've worked with systems where SO_TIMESTAMP has been used for
> H.323 videoconferencing systems to synchronize audio and video

But didn't you really want a "end2end" time stamp in this case,
as in really at the end of all kernel/hardware queues on your side.

A packet roughly travels this way on a normal NIC before it hits recvmsg()

wire -> NIC on die buffers -> NIC RX ring -> interrupt handler -> 
NAPI or per CPU queue -> softirq socket lookup -> socket queue -> recvmsg

These all do their own queuing and all queues can add delays depending
on the load.  Right now SO_TIMESTAMP is in the interrupt handler,
but it's just an arbitary position in a multitude of queues.

For video conferencing (or e.g. in general if you implement a retransmit 
timeout in user space) scheduling delays on the local box
surely need to be taken into account too because they all add
to the final timing of the packets on the wire.

The queues inside the system are really part of the network
too. In Linux for example the algorithms who size the TCP 
buffer space know that and especially take account for it
and reserve a local queue buffer. 

> where remote systems' timestamps on the protocol streams proved
> to be inaccurate (based off of different, unsynchronized clocks).

Yes, but why ignore local scheduling delays? 

> 
> I can't see any other realistic use of this, but trying to get
> timestamps for quasi-realtime protocols may be an important use
> case - and in that case, you want the time when it hits the
> interface, NOT when it hits the socket.

I think it's the other way round. Why would the real time 
protocol care when it hits some arbitary queue in the network
stack instead of the time when the application can really
read the data?
 
> What utility does the time of hitting the socket get you?

SO_TIMESTAMP was originally invented for passive network
monitoring as in tcpdump (for which PACKET sockets were designed
originally, DHCP is really just abusing them imho). There it makes 
some sense to do the time stamp as near on the wire as possible
but really a hardware time stamp would be better because
it is even nearer. But for anything that does end2end it's
the wrong semantics anyways because ignoring local queueing 
delays would be just a bug, and SO_TIMESTAMP ignores them currently.

-Andi

-- 
ak@linux.intel.com
