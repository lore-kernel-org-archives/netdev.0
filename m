From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Mon, 31 Mar 2003 19:14:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16008.30588.705825.524303@robur.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D2D8@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jeff Garzik
	 <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D2D8@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hello!

A better approximation I think but probably not the last...

Cheers.
						--ro



--- linux/drivers/net/e1000/e1000_main.c.orig   2003-03-27 14:38:02.000000000 +0100
+++ linux/drivers/net/e1000/e1000_main.c        2003-03-31 17:56:05.000000000 +0200
@@ -1999,11 +1999,17 @@
                mod_timer(&adapter->watchdog_timer, jiffies);
        }
 
-#ifdef CONFIG_E1000_NAPI
-       /* Don't disable interrupts - rely on h/w interrupt
-        * moderation to keep interrupts low.  netif_rx_schedule
-        * is NOP if already polling. */
-       netif_rx_schedule(netdev);
+#ifdef  CONFIG_E1000_NAPI
+       if (netif_rx_schedule_prep(netdev)) {
+
+               /* Disable interrupts and register for poll. The flush 
+                  of the posted write is intentionally left out.
+               */
+
+               atomic_inc(&adapter->irq_sem);
+               E1000_WRITE_REG(&adapter->hw, IMC, ~0);
+               __netif_rx_schedule(netdev);
+       }
 #else
        for(i = 0; i < E1000_MAX_INTR; i++)
                if(!e1000_clean_rx_irq(adapter) &&
@@ -2025,17 +2031,16 @@
        int work_to_do = min(*budget, netdev->quota);
        int work_done = 0;
        
-       while(work_done < work_to_do)
-               if(!e1000_clean_rx_irq(adapter, &work_done, work_to_do) &&
-                  !e1000_clean_tx_irq(adapter))
-                       break;
+       e1000_clean_tx_irq(adapter);
+       e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
        *budget -= work_done;
        netdev->quota -= work_done;
        
-       if(work_done < work_to_do)
+       if(work_done < work_to_do) {
                netif_rx_complete(netdev);
-
+               e1000_irq_enable(adapter);
+       }
        return (work_done >= work_to_do);
 }
#endif
