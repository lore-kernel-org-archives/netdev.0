From: Andy Fleming <afleming@freescale.com>
Subject: DHCP and keventd
Date: Tue, 24 Aug 2004 16:28:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7A755E44-F614-11D8-942E-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm having issues with using DHCP and nfs at boot time on my 85xx 
system, using the gianfar ethernet driver.  Currently, the gianfar 
driver handles changes in link status through either an interrupt or a 
timer, depending on the board configuration.  My board is using 
interrupts, but I have tried using the timer, and had the same problem.

Anyway, whenever a phy interrupt or timer fires, it calls 
schedule_work() to do the actual PHY reads and writes in a 
non-interrupt thread.  However, when DHCP is coming up during boot to 
get the IP for loading NFS, the driver has yet to find out the link 
state from the PHY, and the work thread it schedules doesn't get 
activated until after the DHCP request times out.

My current theory is that keventd is not active, or that it is locked 
out during DHCP's send loop.  I have confirmed that the interrupt is 
called, but my worker function is not called until the 30 seconds have 
expired.  Fortunately, after the timeout, the link is seen to be up, 
and when it tries again, it succeeds, so this isn't a HUGE thing, but 
it seems wrong to me to have to wait so long for the board to boot.

1) Has anyone else had this problem with another driver?  I saw in the 
source that the eepro100 had a problem which sounded similar.  If any 
one else has seen this, how did you solve it?

2) Is this a kernel bug, or a bug in my driver?  The driver is in 
drivers/net/gianfar.c (at least, the parts that matter are).

3) Any suggestions?

Andy Fleming
PowerPC Software Enablement
Freescale Semiconductor, Inc.
