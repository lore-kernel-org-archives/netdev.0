From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 06 Dec 2004 21:39:39 -0500
Message-ID: <1102387179.1091.39.camel@jzny.localdomain>
References: <OFAF17275D.316533A1-ONC1256F5C.0026AFAD-C1256F5C.002877C1@de.ibm.com>
	 <Pine.LNX.4.61.0412050605550.21671@hibernia.jakma.org>
	 <1102332479.1048.2243.camel@jzny.localdomain>
	 <200412061642.00552.hasso@estpak.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Jakma <paul@clubi.ie>, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200412061642.00552.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-06 at 09:42, Hasso Tepper wrote:

> I'm trying to summarize. The approach - one raw socket to send/receive 
> messages no matter how many interfaces are used - worked for Quagga/Zebra 
> routing software daemons till now. If some of these interfaces was 
> operationally down, socket wasn't blocked even if the queue was full.
>
>  In 
> fact "man sendmsg" has still text:
> 
> ENOBUFS
> 	The output queue for a network interface was full.  This  gener-
> 	ally  indicates  that the interface has stopped sending, but may
> 	be caused by transient congestion.   (Normally,  this  does  not
> 	occur  in Linux. Packets are just silently dropped when a device
> 	queue overflows.)
> 
> Seems that it's no longer true. Seems that kernel is now trying as hard as 
> possible not to loose any data - data is queued and if the queue will be 
> full, all related sockets will be blocked to notify application.

We need to investigate why this happens. It doesnt sound like good
behavior neither legit.
Does this happen to only raw sockets? Herbert asked for a sample small
program that reproduces it.

>  So, one 
> socket approach don't work any more for Quagga/Zebra. No problem, we can 
> take the "one socket per interface" approach. And we already have link 
> detection implemented to notify daemons.
> 

I dont think it would be necessary with latest changes to notifications
in 2.6.x

> But there will be still potential problem - sending the "interface down" 
> message from kernel to the zebra daemon and then to the routing protocol 
> daemon takes time. And during this time daemon can send packets which will 
> sit in queue and may cause many problems if sent to the network later (if 
> link comes up again). Think about statelss routing protocols like rip(ng), 
> ipv6 router advertisements etc. They may carry the info that's no longer 
> true causing routing loops etc.
> 
> And to clarify a little bit: no - the Quagga/Zebra didn't work with previous 
> approach perfectly. I fact with link detection and socket per interface it 
> will be better than ever no matter what's the kernel behaviour. We just 
> want to make sure that solution will be bulletproof.
> 
> So, problem - how can we make sure that no potentially dangerous aged 
> (routing) info will be in the network?

I think the idea of having driver junk packets when link is down does
sound plausible as a solution.

cheers,
jamal 
