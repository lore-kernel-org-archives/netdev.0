From: John Lumby <johnlumby@hotmail.com>
Subject: r8169 :  always copying the rx buffer to new skb
Date: Mon, 18 Apr 2011 13:08:17 -0400
Message-ID: <4DAC7001.9060800@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from toq8.bellnexxia.net ([209.226.175.204]:47283 "EHLO
	toq8-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667Ab1DRROV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 13:14:21 -0400
Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20110418170805.JJOS1798.tomts13-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 13:08:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Summary  -  current r8169 always memcpy's every received buffer to new skb,
             and I'd like to propose that it should not,
             which can improve throughput / reduce CPU utilization by 
around 10%

In the patch
   2010-10-09 Stanislaw Gruszka r8169: allocate with GFP_KERNEL flag 
when able to sleep
the code for making a decision
     "shall I copy the buffer to new skb or unhook it from ring to pass 
up and allocate new"
based on a module param called rx_copybreak,  was removed,  and instead 
we now always allocate naked data buffers (i.e. not wrapped in skb) and 
always memcpy each one to a new skb to pass up to netif.

I think (not sure) this was related to a bug
   Bug 629158 Network adapter "disappears" after resuming from acpi suspend
although the change from using GFP_ATOMIC to using GFP_KERNEL for 
initial allocation
was made (I believe) in
   2010-04-30 Eric Dumazet r8169: Fix rtl8169_rx_interrupt()

So I am not entirely certain of the motivation for the removal of 
rx_copybreak and the "always memcpy".  But I believe it is not 
necessary,  at least not on all (most?) systems, and have measured 11% 
increase in throughput (aggregate Mbits/sec) on a heavy network 
benchmark on my own machine,  on 2.6.39-rc2 with rps/rfs enabled, by 
patching the code back to the 2.6.39 equivalent of rx_copybreak.

oprofile shows the improvement is all or mostly obtained from avoiding 
the memcpy'ing.  And of course since the memcpy'ing is done in the 
driver before the netif/rps gets it,  all that memcpy'ing is done on 
CPU0    (I think true on any SMP machine with an rtl8169?)

The measurements are :
                              aggregate (rx+tx) Mbits/sec through the NIC
     2.6.39-rc2 unpatched                                  918
     2.6.39-rc2   patched,  rx_copybreak=64               1026

packet rates fluctuate around 60K - 70K pkts/sec rx plus 60K - 70K 
pkts/sec tx

I would like to propose that :
   .  switch back to wrapping databuffers in skb's (so we have the 
option of copying or unhooking)
   .  re-introduce rx_copybreak module param so each sysadmin can 
control if wished.

That is my main proposal,    and I would be interested to hear thoughts 
on that.

As a second proposal (which I made before),  I'd like to suggest that 
the number of rx buffers allocated at open should be configurable by 
module param.     This is not needed for my other proposal but may help 
reduce the possibility of temporary shortage of buffers.     There is 
really no justification for assuming that 256 buffers is the correct 
number for all systems from a netbook to a 32-way server.     I ran my 
"patched" measurement with num_rx_buffs=128 and there were no alloc 
failures logged.     I would say that if there is any enthusiasm for the 
main avoid_memcpy proposal,   then it is worth the extra small effort to 
do the num_rx_buffs as well.

My current patch (including configurable num_rx_buffs) -
lines deleted   120
lines added     668

BTW if this proposal is acceptable,  I'm willing to do the patch work 
but I have only one machine with a r8169 (actually a RTL8168c) to test on.

John Lumby
