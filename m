From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Using ethernet device as efficient small packet generator
Date: Tue, 21 Dec 2010 10:22:46 -0800
Message-ID: <20101221102246.5ec107b9@nehalam>
References: <3dbea0c095731ef843058388c29df8c1.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51950 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280Ab0LUSWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 13:22:54 -0500
In-Reply-To: <3dbea0c095731ef843058388c29df8c1.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Dec 2010 11:56:42 +0200
"juice" <juice@swagman.org> wrote:

> 
> Hi net-devvers.
> 
> I am involved in telecom equipment R&D, and I need to do some network
> performance benchmarking. We need to generate streams of Ethernet/IP/UDP
> traffic that consists of different sized payloads ranging from smallest
> AMR payload to ethernet MTU.
> 
> We have various tools including for example Spirent traffic generators
> as well as in-house made software generating 3GPP specified protocol
> streams. Now, the problem with the off-the-shelf generators is the
> inflexibility in our needs and the unavailability to R&D personnel to
> have the generator available at any given time.
> 
> For larger packet sizes our linux-based generator is quite sufficent,
> as I can use it to fully saturate GE link with packet sizes around 1kB.
> However, as packet sizes get smalles ethernet performance suffers.
> 
> I did some benchmarking using pktgen with 64B packets against AX4000 and
> confirmed that the maximun throughput is only around 25% of GE capacity.
> I managed to get to about same speeds using own custom module that writes
> skbuffs directly to kernel *xmit of the netdev.
> 
> Now, it is evident that something is not optimized to the maximum here
> as PCI bus allows for way higher transfer speeds. If large packets can
> fully saturate the ethernet link same should apply for minimum sized
> packets too, unless there is some overhead I am unaware of.
> 
> I have couple of questions here:
> 
> 1.) Is it possible to enhance the "normal" behaving network driver so
>     that the device would still work as an ethernet device (ethxx)?
> 
>     Currently the test stream is generated in userland process that
>     writes to RAW_SOCK, but it is OK for me if I need to write the
>     packet generating part as a kernel module that is configured
>     from the userland part to send the prepared stream out.
> 
> 2.) If it is not possible to get the needed performance from normal
>     network architecture, is it possible to make a "generate only"
>     ethernet device that I can use to replace the network card driver?
> 
>     For example, RX is not really needed at all by my application, so
>     just optimizing the driver to send out packets from memory as fast
>     as possible is enough.
> 
>     Are there notable differences between ethernet chipsets/cards
>     regarding to the raw output speed they are capable?
>     I have benchmarked e1000, r8169 ang tg3 based cards and with all
>     of those I get about same throughput of 64byte ethernet frames.
> 
>     For my purpose, it would be OK, for example, to remove the normal
>     r8169 driver and replace it with a custom TX-only driver, and use
>     some other normal driver tied to another card to access the box.
> 
> I appreciate your comments and any pointers to existing projects that
> have similar implementation that I require.
> 
> Yours, Jussi Ohenoja

I regularly get full 1G line rate of 64 byte packets using old Opteron
box and pktgen.  It does require some tuning of IRQ's and interrupt mitigation but
no patches. Did you remember to do the basic stuff like setting IRQ affinity
and not enabling debugging or tracing in the kernel? This is on sky2, but
also using e1000 and tg3. Others have reported 7M packets per second over 10G cards.
The r8169 hardware is low end consumer hardware and doesn't work as well.

It is possible to get close to 1G line rate forwarding with a single core with current
generation processors. Actual rate depends on hardware and configuration (size of route
table, firewalling, etc).  Much better performance with multi-queue hardware to spread load
over multiple cores.


-- 
