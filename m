From: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.4 10/16] e1000:Implement a workaround for 82546
 errata 10
Date: Tue, 19 Apr 2005 23:07:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504190454570.10932@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Implement a workaround for 82546 errata 10 --  first Tx descriptor cannot have more than 2015 byte of data in it or it could hang the transmitter.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c      2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c  2005-04-12 23:00:55.000000000 -0700
@@ -1750,6 +1750,15 @@ e1000_tx_map(struct e1000_adapter *adapt
                if(unlikely(mss && !nr_frags && size == len && size > 8))
                        size -= 4;
 #endif
+               /* work-around for errata 10 and it applies
+                * to all controllers in PCI-X mode
+                * The fix is to make sure that the first descriptor of a
+                * packet is smaller than 2048 - 16 - 16 (or 2016) bytes
+                */
+               if(unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
+                               (size > 2015) && count == 0))
+                       size = 2015;
+                                                                               
                /* Workaround for potential 82544 hang in PCI-X.  Avoid
                 * terminating buffers within evenly-aligned dwords. */
                if(unlikely(adapter->pcix_82544 &&
@@ -1951,6 +1960,13 @@ e1000_xmit_frame(struct sk_buff *skb, st
        if(adapter->pcix_82544)
                count++;

+       /* work-around for errata 10 and it applies to all controllers
+        * in PCI-X mode, so add one more descriptor to the count
+        */
+       if(unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
+                       (len > 2015)))
+               count++;
+
        nr_frags = skb_shinfo(skb)->nr_frags;
        for(f = 0; f < nr_frags; f++)
                count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
