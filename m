From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: pktgen
Date: Sun, 28 Nov 2004 19:31:43 +0100
Message-ID: <20041128183143.GD6045@xi.wantstofly.org>
References: <20041124170948.GC18059@xi.wantstofly.org> <16804.60621.990421.525393@robur.slu.se> <20041125030450.GA24417@xi.wantstofly.org> <16805.40983.937641.670275@robur.slu.se> <20041127002841.GA17184@xi.wantstofly.org> <20041127004325.GA17401@xi.wantstofly.org> <16808.28005.74903.881087@robur.slu.se> <20041127135354.GA24617@xi.wantstofly.org> <20041127143923.GA25155@xi.wantstofly.org> <1101567861.1044.87.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1101567861.1044.87.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 27, 2004 at 10:04:22AM -0500, jamal wrote:

> Note the constant part of the equation though is not exactly "constant"
> even if uyou picked constant hardware. It is per machine (chipset,
> topology layout of the bus), per machine setup (how much latency does
> your RAM have) and worse: load dependent (two IO endpoints contending
> for a PCI-X bridge or the CPU being very busy at the moment with a lot
> compute vs RAM-bound execution).

Yup.


> It would be interesting to see a study in this area though.

Indeed.  Right now it feels like I'm just poking around in the dark.  I'm
really interested by now in finding out exactly what part of packet TX is
taking how long and where all my cycles are going.

I don't have an Itanic but it's still possible to instrument the driver
and do some stuff Grant talks about in his OLS paper, something like the
attached.  (Exports # of MMIO reads/writes/flushes in the RX frame/
TX carrier/collision stats field.  Beware, flushes are double-counted
as reads.  Produces lots of output.)

During a 10Mpkt pktgen session (~16 seconds), I'm seeing:
- 131757 interrupts, ~8k ints/sec, ~76 pkts/int
- 131789 pure MMIO reads (i.e. not counting MMIO reads intended as write
	flushes), which is E1000_READ_REG(icr) in the irq handler
- 10263536 MMIO writes (which would be 1 per packet plus 2 per interrupt)
- 131757 MMIO write flushes (readl() of the e1000 status register after
	re-enabling IRQs in dev->poll())

Pretty consistent with what Grant was seeing.

MMIO reads from the e1000 are somewhere between 2000 and 3000 cycles a
pop on my hardware.  2400MHz CPU -> ~1us/each.  (Reading netdevice stats
does ~50 of those in a row.)


cheers,
Lennert



diff -urN e1000.orig/e1000_hw.h e1000/e1000_hw.h
--- e1000.orig/e1000_hw.h	2004-11-24 15:35:24.000000000 +0100
+++ e1000/e1000_hw.h	2004-11-28 14:27:25.953933398 +0100
@@ -1038,6 +1038,9 @@
     boolean_t adaptive_ifs;
     boolean_t ifs_params_forced;
     boolean_t in_ifs_mode;
+    uint32_t mmio_reads;
+    uint32_t mmio_writes;
+    uint32_t mmio_write_flushes;
 };
 
 
diff -urN e1000.orig/e1000_main.c e1000/e1000_main.c
--- e1000.orig/e1000_main.c	2004-11-24 15:35:23.000000000 +0100
+++ e1000/e1000_main.c	2004-11-28 15:52:13.127944083 +0100
@@ -491,7 +491,7 @@
 	}
 
 #ifdef NETIF_F_TSO
-	/* Disbaled for now until root-cause is found for
+	/* Disabled for now until root cause is found for
 	 * hangs reported against non-IA archs.  TSO can be
 	 * enabled using ethtool -K eth<x> tso on */
 	if((adapter->hw.mac_type >= e1000_82544) &&
@@ -585,6 +585,21 @@
 	if(eeprom_data & E1000_EEPROM_APME)
 		adapter->wol |= E1000_WUFC_MAG;
 
+	/* print bus type/speed/width info */
+	printk(KERN_INFO "%s: e1000 (PCI%s:%s:%s) ", netdev->name,
+		((adapter->hw.bus_type == e1000_bus_type_pcix) ? "X" : ""),
+		((adapter->hw.bus_speed == e1000_bus_speed_133) ? "133MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_120) ? "120MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_100) ? "100MHz" :
+		 (adapter->hw.bus_speed == e1000_bus_speed_66) ? "66MHz" :
+		  "33MHz"),
+		((adapter->hw.bus_width == e1000_bus_width_64) ? "64-bit" :
+		  "32-bit"));
+
+	for (i = 0; i < 6; i++)
+		printk("%2.2x%c", netdev->dev_addr[i],
+			i == 5 ? '\n' : ':');
+
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
@@ -1971,6 +1986,7 @@
 	 * be written while holding adapter->stats_lock
 	 */
 
+#if 0
 	adapter->stats.crcerrs += E1000_READ_REG(hw, CRCERRS);
 	adapter->stats.gprc += E1000_READ_REG(hw, GPRC);
 	adapter->stats.gorcl += E1000_READ_REG(hw, GORCL);
@@ -2035,6 +2051,7 @@
 		adapter->stats.tsctc += E1000_READ_REG(hw, TSCTC);
 		adapter->stats.tsctfc += E1000_READ_REG(hw, TSCTFC);
 	}
+#endif
 
 	/* Fill out the OS statistics structure */
 
@@ -2043,7 +2060,7 @@
 	adapter->net_stats.rx_bytes = adapter->stats.gorcl;
 	adapter->net_stats.tx_bytes = adapter->stats.gotcl;
 	adapter->net_stats.multicast = adapter->stats.mprc;
-	adapter->net_stats.collisions = adapter->stats.colc;
+	adapter->net_stats.collisions = hw->mmio_write_flushes;
 
 	/* Rx Errors */
 
@@ -2054,7 +2071,7 @@
 	adapter->net_stats.rx_dropped = adapter->stats.rnbc;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
-	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
+	adapter->net_stats.rx_frame_errors = hw->mmio_reads;
 	adapter->net_stats.rx_fifo_errors = adapter->stats.mpc;
 	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
 
@@ -2064,12 +2081,13 @@
 	                               adapter->stats.latecol;
 	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
 	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
-	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
+	adapter->net_stats.tx_carrier_errors = hw->mmio_writes;
 
 	/* Tx Dropped needs to be maintained elsewhere */
 
 	/* Phy Stats */
 
+#if 0
 	if(hw->media_type == e1000_media_type_copper) {
 		if((adapter->link_speed == SPEED_1000) &&
 		   (!e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
@@ -2082,6 +2100,7 @@
 		   !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
+#endif
 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
diff -urN e1000.orig/e1000_osdep.h e1000/e1000_osdep.h
--- e1000.orig/e1000_osdep.h	2004-11-24 15:35:23.000000000 +0100
+++ e1000/e1000_osdep.h	2004-11-28 16:05:50.063341317 +0100
@@ -78,23 +78,40 @@
 
 
 #define E1000_WRITE_REG(a, reg, value) ( \
+    printk(KERN_INFO "e1000: MMIO write\n"), \
+    (a)->mmio_writes++, \
     writel((value), ((a)->hw_addr + \
         (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg))))
 
-#define E1000_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
+#define E1000_READ_REG(a, reg) ({ \
+    unsigned long s, e, d, v; \
+\
+    (a)->mmio_reads++; \
+    rdtsc(s, d); \
+    v = readl((a)->hw_addr + \
+        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)); \
+    rdtsc(e, d); \
+    e -= s; \
+    printk(KERN_INFO "e1000: MMIO read took %ld clocks\n", e); \
+    printk(KERN_INFO "e1000: in process %d(%s)\n", current->pid, current->comm); \
+    dump_stack(); \
+    v; \
+})
 
 #define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
+    (a)->mmio_writes++, \
     writel((value), ((a)->hw_addr + \
         (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
         ((offset) << 2))))
 
 #define E1000_READ_REG_ARRAY(a, reg, offset) ( \
+    (a)->mmio_reads++, \
     readl((a)->hw_addr + \
         (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
         ((offset) << 2)))
 
-#define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, STATUS)
+#define E1000_WRITE_FLUSH(a) ( \
+    (a)->mmio_write_flushes++, \
+    E1000_READ_REG(a, STATUS))
 
 #endif /* _E1000_OSDEP_H_ */
