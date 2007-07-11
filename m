From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Wed, 11 Jul 2007 13:50:07 +0200
Message-ID: <20070711115007.GA27431@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, cfriesen@nortel.com,
	shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:37151 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbXGKMCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 08:02:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Sorry for breaking the thread, please CC me on future replies...)

If I understand the discussion correctly, the problem in itself isn't greater
then that different methods of gathering the statistics have different
rollovers and thus confuse people who aren't aware of which method each tool
uses. The the main issue with fixing this is that it needs to be handled
gently to not break the userspace API/ABI.

I see three different paths...

a) just ignore the issue and let everybody who run into this stay confused
and cry about linux being crap unless they dig deeper and gets informed of
the different interfaces and their rollovers.

b) be lazy and fix only the confusion by making sure that the statistics in
/proc/net/dev also rolls over at 32bits so that all exported statistics show
the same number (while ignoring possible problems with 32bit rollovers, like
fast networks might roll over too quickly and make the stats useless).

c) take the more painful route of switching over to 64bit statistics in
netlink. Add 64bit interface, port userspace tools, deprecate the old 32bit
interface. (I guess exporting as u64 even on 32bit architectures wouldn't
hurt them, even if they still will rollover at (unsigned long) 32 bits.)


I'd prefer not to do (a). Would (b) be acceptable? If not, could someone who
is more familiar with how to do netlink please help me out with a patch for
adding the required kernel part of (c)?
(I'm going away for 2 weeks on friday, so I'll pick up whatever needs doing
when I'm back...)


Here's a completely untested patch for (b):


--- linux-2.6.22/net/core/dev.c	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22/net/core/dev.c.new	2007-07-11 13:56:21.000000000 +0200
@@ -2184,23 +2184,24 @@
 {
 	struct net_device_stats *stats = dev->get_stats(dev);
 
-	seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
-		   "%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
-		   dev->name, stats->rx_bytes, stats->rx_packets,
-		   stats->rx_errors,
-		   stats->rx_dropped + stats->rx_missed_errors,
-		   stats->rx_fifo_errors,
-		   stats->rx_length_errors + stats->rx_over_errors +
-		    stats->rx_crc_errors + stats->rx_frame_errors,
-		   stats->rx_compressed, stats->multicast,
-		   stats->tx_bytes, stats->tx_packets,
-		   stats->tx_errors, stats->tx_dropped,
-		   stats->tx_fifo_errors, stats->collisions,
-		   stats->tx_carrier_errors +
-		    stats->tx_aborted_errors +
+	/* Always rollover stats at 32bits to match netlink interface */
+	seq_printf(seq, "%6s:%8u %7u %4u %4u %4u %5u %10u %9u "
+		   "%8u %7u %4u %4u %4u %5u %7u %10u\n",
+		   dev->name, (u32)stats->rx_bytes, (u32)stats->rx_packets,
+		   (u32)stats->rx_errors,
+		   (u32)(stats->rx_dropped + stats->rx_missed_errors),
+		   (u32)stats->rx_fifo_errors,
+		   (u32)(stats->rx_length_errors + stats->rx_over_errors +
+		    stats->rx_crc_errors + stats->rx_frame_errors),
+		   (u32)stats->rx_compressed, (u32)stats->multicast,
+		   (u32)stats->tx_bytes, (u32)stats->tx_packets,
+		   (u32)stats->tx_errors, (u32)stats->tx_dropped,
+		   (u32)stats->tx_fifo_errors, (u32)stats->collisions,
+		   (u32)(stats->tx_carrier_errors +
+		    ustats->tx_aborted_errors +
 		    stats->tx_window_errors +
-		    stats->tx_heartbeat_errors,
-		   stats->tx_compressed);
+		    stats->tx_heartbeat_errors),
+		   (u32)stats->tx_compressed);
 }
 
 /*


-- 
Regards,
Andreas Henriksson
