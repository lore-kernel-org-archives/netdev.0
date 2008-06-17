From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: data received but not detected
Date: Tue, 17 Jun 2008 15:27:33 -0700
Message-ID: <20080617152733.7f469f2e@extreme>
References: <1213740538.5771.192.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60647 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757787AbYFQW1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 18:27:55 -0400
In-Reply-To: <1213740538.5771.192.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008 17:08:58 -0500
Travis Stratman <tstratman@emacinc.com> wrote:

> Hello,
> 
> (I sent this earlier today but it doesn't look like it made it, I
> apologize if it gets through multiple times)
> 
> I am working on an application that uses a fairly simple UDP protocol to
> send data between two embedded devices. I'm noticing an issue with an
> initial test that was written where datagrams are received but not seen
> by the recvfrom() call until more data arrives after it. As of right now
> the test case does not implement any type of lost packet protection or
> other flow control, which is what makes the issue so noticeable.
> 
> The target for this code is a board using the Atmel AT91SAM9260 ARM
> processor. I have tested with 2.6.20 and 2.6.25 on this board.
> 
> The test consists of a two applications with the following pseudo code
> (msg_size = 127, 9003/9005 are the UDP ports used):
> 
> "client app"
> while(1) {
>     sendto(9003, &msg_size, 4bytes);
>     sendto(9003, buffer, msg_size);
>     recvfrom(9005, &msg_size, 4bytes);
>     recvfrom(9005, buffer, msg_size);
> }
> 
> "server app"
> while(1) {
>     recvfrom(9003, &msg_size, 4bytes);
>     recvfrom(9003, buffer, msg_size);
>     sendto(9005, &msg_size, 4bytes);
>     sendto(9005, buffer, msg_size);
> }
> 
> As long as the server is started first and no packets are lost or out of
> order, the client and server should continue indefinitely. When run
> between two boards on a local gigabit switch, the application will run
> smoothly most of the time, but I periodically see delays of 30 seconds
> or more where one of the applications is waiting for the second datagram
> to arrive before sending the next packet. Wireshark shows that the data
> was sent very shortly after the first datagram, and no packets are ever
> lost, ifconfig reports no collisions, overruns, or errors.
> 
> When I run the application between two identical devices on a cross-over
> cable, data is transferred for a few seconds after which everything
> freezes until I send a ping between the two boards in the background.
> This forces the communication to start up again for a few seconds before
> they hang up again. If I insert a delay between the sendto() calls with
> usleep(1) (CONFIG_HZ is 100 so this could be up to 10ms) everything
> seems to work. Using a busy loop I was able to determine that
> approximately 500 us delay is required to "fix" the issue but even then
> I saw one hang up in several hours of testing.
> 
> At first I thought that this was the "rotting packet" case that the NAPI
> references where an IRQ is missed on Rx, so I rewrote the poll function
> in the macb driver to try to fix this but I didn't see any noticeable
> differences. If I enable debugging in the MACB driver it slows things
> down enough to make everything work.
> 
> Next, I tested on a Cirrus ep93xx based board (with 2.6.20) and a 133
> MHz x86 board (with 2.6.14.7) and noticed the same issue when run
> between the target and my PC. When run between my 2.6.23 2GHz PC and
> another similar PC, the issue does not show up (these both use Intel
> NICs). I also tested on the local loopback and things worked as
> expected.
> 
> I would very much appreciate any suggestions that anyone could give to
> point me in the right direction.
> 
> Thanks in advance,
> 
> Travis

I am unfamiliar with interrupts on the ARM. Are IRQ's level or edge triggered?
NAPI won't work if interrupts are edge-triggered.
