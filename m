From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: 8390.c workaround for interrupt storm
Date: Fri, 13 Aug 2004 12:30:47 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813153047.GC28640@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi netdev, 

We've been seeing an interrupt storm on our 
embedded PowerPC systems with Linksys PCMLM56 (network+modem) 
PCMCIA cards (network part of it driven by pcnet_cs.c) as soon as the network 
cable is  pluged/unpluged and after some activity on the serial
line. 

The card goes nuts, and doesnt stop sending interrupts. 

So I hacked up this patch which resets the 8390 chip
as soon as 256 empty interrupts are triggered. Works fine,
the card comes back to sanity after resetting.

Not sure if its specific to our boards, but I believe
it might happen on other archs also, so I'm posting it 
here in the hope it might be useful for someone with the
same problem.

Not likely to be included in mainline driver, but hey, why not,
its protection against hardware insanity.

--- 8390.c.orig 2004-08-13 11:54:28.000000000 -0300
+++ 8390.c      2004-08-13 11:54:07.000000000 -0300
@@ -411,6 +411,8 @@
  * needed.
  */
  
+int interrupt_cnt = 0;
+
 void ei_interrupt(int irq, void *dev_id, struct pt_regs * regs)
 {
        struct net_device *dev = dev_id;
@@ -493,6 +495,22 @@
  
                outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base + E8390_CMD);
        }
+
+       /*
+        * Workaround infinite interrupt storm caused by Linksys combocard
+        * on embedded PowerPC. Other cards/platform can suffer
+        * from the same. Reset the device if we get more than 256
+        * empty interrupts.
+        */
+       if (!nr_serviced)
+               interrupt_cnt++;
+       else
+               interrupt_cnt = 0;
+
+       if (interrupt_cnt > 256) {
+               ei_status.reset_8390(dev);
+               interrupt_cnt = 0;
+       }
      
        if (interrupts && ei_debug)
        {
