From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: BUG: sky2: hw csum failure with dual-port copper NIC on SMP
Date: Tue, 13 Nov 2007 14:14:14 -0800
Message-ID: <20071113141414.0959735a@freepuppy.rosehill>
References: <4739E425.20408@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tony Battersby <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46821 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759591AbXKMWQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 17:16:14 -0500
In-Reply-To: <4739E425.20408@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 12:51:33 -0500
Tony Battersby <tonyb@cybernetics.com> wrote:

> I am getting "hw csum failure" messages with sky2.  I have seen this
> problem reported elsewhere with a fibre NIC, but I am using a copper
> NIC.  It seems to be triggered by SMP.  It is easy to reproduce in
> 2.6.23.  2.6.24-rc2-git3 still has the problem, but it happens less
> frequently.
> 
> To reproduce the problem, I am using a simple network benchmark program
> that I wrote that basically does send()/recv() as fast as possible using
> a memory buffer (null data, no disk I/O, no data integrity checking).
> The computer with the SysKonnect NIC acts as the server.  I have two
> other computers with Intel PRO/1000 NICs that are directly cabled to the
> two ports on the SysKonnect NIC.  Each of them runs the client program,
> which connects to the server, send()s 10 GB, and then recv()s 10 GB.
> Essentially, both ports on the Syskonnect NIC are receiving at the
> maximum rate for a few minutes, and then transmitting at the maximum
> rate for a few minutes.  Sustained throughput is about 117 MB/s on both
> ports simultaneously.
> 
> The "hw csum failure" does not seem to affect the test.  send()/recv()
> continue to work normally.  Nothing locks up.
> 
> I get several "hw csum failure" messages per minute on 2.6.23-SMP.  The
> error does not happen with 2.6.23 if I boot with "max_cpus=1".  The
> message seems less frequent with 2.6.24-SMP, but it still happens once
> every minute or so.
> 
> The "hw csum failure" message does not happen when only one port is in
> use.  You have to stress both ports simultaneously to reproduce the
> problem.
> 
> Another cosmetic issue is that "ifconfig" shows eth2 at IRQ 16 and eth3
> at IRQ 218, when in fact both are at IRQ 218.  IRQ 16 is the regular
> interrupt line and IRQ 218 is the MSI interrupt.  I imagine that the
> driver is just reporting the IRQ incorrectly in this case.  It is just a
> minor cosmetic issue which doesn't break anything.

ifconfig reports value from dev->irq, which is a a legacy thing.
When using MSI it gets it wrong.

I can reproduce the problem under load with only a single port on 2.6.23.
I haven't been able to reproduce it on 2.6.24-rc2 (latest) but that maybe
because of either insufficient stress or another bug fix correcting the
problem.  There is an issue with Yukon XL updating the receive status index
before updating the receive status structure, that is now fixed in 2.6.24.
The fix is:

commit ab5adecb2d02f3688719dfb5936a82833fcc3955
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Mon Nov 5 15:52:09 2007 -0800

    sky2: status ring race fix
    
    The D-Link PCI-X board (and maybe others) can lie about status
    ring entries. It seems it will update the register for last status
    index before completing the DMA for the ring entry. To avoid reading
    stale data, zap the old entry and check.
    
    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
