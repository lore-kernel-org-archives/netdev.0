From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 5 Dec 2004 06:25:31 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0412050605550.21671@hibernia.jakma.org>
References: <OFAF17275D.316533A1-ONC1256F5C.0026AFAD-C1256F5C.002877C1@de.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261262AbULEG0S@vger.kernel.org>
To: Thomas Spatzier <thomas.spatzier@de.ibm.com>
In-Reply-To: <OFAF17275D.316533A1-ONC1256F5C.0026AFAD-C1256F5C.002877C1@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004, Thomas Spatzier wrote:

> Ok, then some logic could be implemented in userland to take 
> appropriate actions. It must be ensured that zebra handles the 
> netlink notification fast enough.

AIUI, netlink is not synchronous, it most definitely makes no 
reliability guarantees (and at the moment, zebra isnt terribly 
efficient at reading netlink, large numbers of interfaces will cause 
overruns in zebra - fixing this is on the TODO list). So we can never 
get rid of the window where a daemon could send a packet out a 
link-down interface - we can make that window smaller but not 
eliminate it.

Hence we need either a way to flush packets associated with an 
(interface,socket) (or just the socket) or we need the kernel to not 
accept such packets (and drop packets it has accepted).

> In the manpages for send/sendto/sendmsg it says that there is a -ENOBUFS
> return value, if a sockets write queue is full.

Yes, ENOBUFS, sorry.

> It also says:

> "Normally, this does not occur in Linux. Packets are just silently dropped
> when a device queue overflows."

This has always been (AFAIK) the behaviour yes. We started getting 
reports of the new queuing behaviour with, iirc, a version of Intel's 
e100 driver for 2.4.2x, which was later changed back to the old 
behaviour. However now that the queue behaviour is apparently the 
mandated behaviour we really need to work out what to do about the 
sending-long-stale packets problem.

> So, if packets are 'silently dropped' anyway, the fact that we drop 
> them in our driver (and increment the error count in the 
> net_device_stats accordingly) should not be a problem.

It shouldnt no.

The likes of OSPF already specify their own reliability mechanisms.

> I think that both behaviours are similar for TCP. TCP waits for 
> ACKs for each packet. If they do not arrive, a retransmit is done. 
> Sooner or later the connection will be reset, if no responses from 
> the other side arrive. So the result for both driver behaviours 
> should be the same.

But if TCP worked even when drivers dropped packets, then that 
implies TCP has its own queue? That we're talking about a seperate 
driver packet queue rather than the socket buffer (which is, 
presumably, where TCP retains packets until ACKed - i have no idea).

Anyway, we do, I think, need some way to deal with the 
sending-stale-packet-on-link-back problem. Either a way to flush this 
driver queue or else a guarantee that writes to sockets whose 
protocol makes no reliability guarantee will either return ENOBUFS or 
drop the packet.

Otherwise we will start getting reports of "Quagga on Linux sent an 
ancient {RIP,IRDP,RA} packet when we fixed a switch problem, and it 
caused an outage for a section of our network due to bad routes", I 
think.

Some comment or advice would be useful. (Am I kill-filed by all of 
netdev? feels like it).

> Regards,
> Thomas

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
No directory.
