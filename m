From: Steve Modica <modica@sgi.com>
Subject: do_gettimeofday
Date: Thu, 02 Oct 2003 13:32:27 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7C6F3B.6070502@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We've been doing some experiments here with large numbers of adapters on a 64p Linux system. 

When running 8 threads and 8 cpus, the do_gettimeofday code starts to use a lot of time.

It turns out that if a driver does not timestamp an incoming packet, the upper layer will stamp it for you in
PSCHED_GET_TIME(stamp).  What happens then is multiple cpus start fighting over the cacheline for the system clock and things get bad. 

One possible solution to this is to have the driver do the stamp using xtime. A number of ATM drivers do this now. In testing, it helps a lot.

Here's a sample diff for the tg3.c driver:

===========================================================================
Index: linux/linux/drivers/net/tg3.c
===========================================================================
 
--- /usr/tmp/TmpDir.8948-0/linux/linux/drivers/net/tg3.c_1.23   Thu Oct  2 13:30:21 2003
+++ linux/linux/drivers/net/tg3.c       Wed Oct  1 14:27:54 2003
@@ -2019,6 +2019,7 @@
                        skb->ip_summed = CHECKSUM_NONE;
  
                skb->protocol = eth_type_trans(skb, tp->dev);
+               skb->stamp = xtime;
 #if TG3_VLAN_TAG_USED
                if (tp->vlgrp != NULL &&
                    desc->type_flags & RXD_FLAG_VLAN) {


It's been suggested that we make this tuneable so it's easy to enable and disable. There was concern as to whether xtime would be accurate enough for all possible uses of ->stamp.  

Does anyone have any comments on this?

Regards!
Steve





-- 
Steve Modica
work: 651-683-3224
mobile: 651-261-3201
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
