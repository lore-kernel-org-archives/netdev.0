From: Jonas Johansson <jonasj76@gmail.com>
Subject: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Fri, 20 Mar 2015 13:22:46 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: stephen@networkplumber.org, f.fainelli@gmail.com, jiri@resnulli.us,
	sfeldma@gmail.com, jonasj76@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:34856 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbbCTM1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 08:27:23 -0400
Received: by labjg1 with SMTP id jg1so85708176lab.2
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 05:27:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge code will sometimes hold a spinlock and the code following 
must therefore be atomic. If using a MDIO call which uses a wait/sleep in 
this contex, the kernel will not be very happy.

I'm using a switch device and wants to flush its FDB when the linux bridge 
FDB is flushed. I've implemented some hooks for this task.
In short:
      bridge    - br_fdb_flush() & br_fdb_delete_by_port
   -> switchdev - switch_flush()
   -> dsa       - slave_flush()
   -> mv88e6xxx - mv88_flush()

So, when a bridge port is flushed via e.g. sysfs, the mv88_flush() 
function will at the end be called. The mv88_flush() will use MDIO calls 
to set the proper registers and flush the device. But, due to that 
the MDIO on my platform uses wait_for_completion() and a spinlock is held 
(in this case in brport_store()) the process will not go very well.

The only possible solutions that came into my mind is:
  1) Let mv88_flush() schedule a work queue to take care of the flush
     later on.
  2) Change the MDIO implementation to use polling.
  3) Dont use spinlock in bridge code.

1) Using this approach the the atomic part is missed, i.e. the switch 
device isn't guaranteed to be flushed after the command has been issued. 
And, if a FDB entry is added (atomic) to the switch device immediately 
after the flush command, there will not be defined if the entry will be 
added before or after the flush occurs. To solve this, all (FDB) 
operations must be added to a work queue to assure that they are executed 
in the right order.

2) This will result in unsued CPU cycles.

3) Havent looked into this, but probably a lot of work.

Any ideas?
