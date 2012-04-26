From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: Heavy spin_lock contention in __udp4_lib_mcast_deliver increase
Date: Thu, 26 Apr 2012 11:28:19 -0500
Message-ID: <20120426162819.GD2479@BohrerMBP.rgmadvisors.com>
References: <20120426151527.GA2479@BohrerMBP.rgmadvisors.com>
 <1335455595.2775.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:51357 "EHLO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758028Ab2DZQ2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 12:28:24 -0400
Received: by mail-ob0-f179.google.com with SMTP id up19so1828171obb.38
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 09:28:23 -0700 (PDT)
In-Reply-To: <1335455595.2775.47.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 26, 2012 at 05:53:15PM +0200, Eric Dumazet wrote:
> On Thu, 2012-04-26 at 10:15 -0500, Shawn Bohrer wrote:
> > I've been doing some UDP multicast benchmarking and noticed that as we
> > increase the number of sockets/multicast addresses the performance
> > degrades.  The test I'm running has multiple machines sending packets
> > on multiple multicast addresses.  A single receiving machine opens one
> > socket per multicast address to receive all the packets.  The
> > receiving process is bound to a core that is not processing
> > interrupts.
> > 
> > Running this test with 300 multicast addresses and sockets and
> > profiling the receiving machine with 'perf -a -g' I can see the
> > following:
> > 
> > 
> > # Events: 45K cycles
> > #
> > # Overhead
> > # ........  .....................................
> > #
> >     52.56%  [k] _raw_spin_lock
> >             |
> >             |--99.09%-- __udp4_lib_mcast_deliver
> >     20.10%  [k] __udp4_lib_mcast_deliver
> >             |
> >             --- __udp4_lib_rcv
> > 
> > So if I understand this correctly 52.56% of the time is spent
> > contending for the spin_lock in __udp4_lib_mcast_deliver.  If I
> > understand the code correctly it appears that for every packet
> > received we walk the list of all UDP sockets while holding the
> > spin_lock.  Therefore I believe the thing that hurts so much in this
> > case is that we have a lot of UDP sockets.
> > 
> > Are there any ideas on how we can improve the performance in this
> > case?  Honestly I have two ideas though my understanding of the
> > network stack is limited and it is unclear to me how to implement
> > either of them.
> > 
> > The first idea is to use RCU instead of acquiring the spin_lock.  This
> > is what the Unicast path does however looking back to 271b72c7 "udp:
> > RCU handling for Unicast packets." Eric points out that the multicast
> > path is difficult.  It appears from that commit description that the
> > problem is that since we have to find all sockets interested in
> > receiving the packet instead of just one that restarting the scan of
> > the hlist could lead us to deliver the packet twice to the same
> > socket.  That commit is rather old though I believe things may have
> > changed.  Looking at commit 1240d137 "ipv4: udp: Optimise multicast
> > reception" I can see that Eric also has already done some work to
> > reduce how long the spin_lock is held in __udp4_lib_mcast_deliver().
> > That commit also says "It's also a base for a future RCU conversion of
> > multicast recption".  Is the idea that you could remove duplicate
> > sockets within flush_stack()?  Actually I don't think that would work
> > since flush_stack() can be called multiple times if the stack gets
> > full.
> > 
> > The second idea would be to hash the sockets to reduce the number of
> > sockets to walk for each packet.  Once again it looks like the Unicast
> > path already does this in commits 512615b6b "udp: secondary hash on
> > (local port, local address)" and 5051ebd27 "ipv4: udp: optimize
> > unicast RX path".  Perhaps these hash lists could be used, however I
> > don't think they can since they currently use RCU and thus it might
> > depend on converting to RCU first.
> 
> Let me understand
> 
> You have 300 sockets bound to the same port, so a single message must be
> copied 300 times and delivered to those sockets ?

No in this case it is 300 unique multicast addresses, and there is one
socket listening to each multicast address.  So a single message is
only copied once to a single socket.  The bottle neck appears to be
that even though a single message is only going to get copied to a
single socket we still have to walk the list of all 300 sockets while
holding the spin lock to figure that out.  The incoming packet rate is
also roughly evenly distributed across all 300 multicast addresses so
even though we have multiple receive queues they are all contending
for the same spin lock.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
