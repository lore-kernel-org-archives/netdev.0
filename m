From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 6 Dec 2004 16:42:00 +0200
Message-ID: <200412061642.00552.hasso@estpak.ee>
References: <OFAF17275D.316533A1-ONC1256F5C.0026AFAD-C1256F5C.002877C1@de.ibm.com> <Pine.LNX.4.61.0412050605550.21671@hibernia.jakma.org> <1102332479.1048.2243.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Paul Jakma <paul@clubi.ie>, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1102332479.1048.2243.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Dont post networking related patches on other lists. I havent seen said
> patch, but it seems someone is complaining about some behavior changing?

For some strange reason I didn't find the beginning of thread either from 
archive, the first post seems to be  
http://oss.sgi.com/projects/netdev/archive/2004-11/msg01015.html.

I'm trying to summarize. The approach - one raw socket to send/receive 
messages no matter how many interfaces are used - worked for Quagga/Zebra 
routing software daemons till now. If some of these interfaces was 
operationally down, socket wasn't blocked even if the queue was full. In 
fact "man sendmsg" has still text:

ENOBUFS
	The output queue for a network interface was full.  This  gener-
	ally  indicates  that the interface has stopped sending, but may
	be caused by transient congestion.   (Normally,  this  does  not
	occur  in Linux. Packets are just silently dropped when a device
	queue overflows.)

Seems that it's no longer true. Seems that kernel is now trying as hard as 
possible not to loose any data - data is queued and if the queue will be 
full, all related sockets will be blocked to notify application. So, one 
socket approach don't work any more for Quagga/Zebra. No problem, we can 
take the "one socket per interface" approach. And we already have link 
detection implemented to notify daemons.

But there will be still potential problem - sending the "interface down" 
message from kernel to the zebra daemon and then to the routing protocol 
daemon takes time. And during this time daemon can send packets which will 
sit in queue and may cause many problems if sent to the network later (if 
link comes up again). Think about statelss routing protocols like rip(ng), 
ipv6 router advertisements etc. They may carry the info that's no longer 
true causing routing loops etc.

And to clarify a little bit: no - the Quagga/Zebra didn't work with previous 
approach perfectly. I fact with link detection and socket per interface it 
will be better than ever no matter what's the kernel behaviour. We just 
want to make sure that solution will be bulletproof.

So, problem - how can we make sure that no potentially dangerous aged 
(routing) info will be in the network?


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
