From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Sun, 05 Jun 2005 14:36:53 -0700 (PDT)
Message-ID: <20050605.143653.75191476.davem@davemloft.net>
References: <1117830922.4430.44.camel@rh4>
	<1117837798.6266.25.camel@localhost.localdomain>
	<1117844736.4430.51.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, buytenh@wantstofly.org, mitch.a.williams@intel.com,
        john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1117844736.4430.51.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


To illustrate my most recent point (that packet processing cost
on RX is variable, and at times highly so) I made some hacks
to the tg3 driver to record how many system clock ticks each
netif_receive_skb() call consumed.

This clock on my sparc64 box updates at a rate of 12MHZ and
is used for system time keeping.

Anyways, here is a log from a stream transfer to this system.  So the
packet trace is heavily TCP receive bound.  Here is a sample from
this.  I take a tick sample before the netif_receive_skb() call, take
one afterwards, and record the difference between the two:

[ 52 73 41 65 38 61 58 63 37 62 36 62 50 74 38 64 ]
[ 37 63 39 62 36 64 36 61 50 75 38 64 39 65 37 62 ]
[ 36 60 36 62 50 76 39 67 38 63 35 62 35 64 35 62 ]
[ 62 74 41 65 37 62 37 63 36 61 39 62 52 75 38 66 ]
[ 37 63 35 61 38 62 36 60 49 75 38 64 37 62 36 66 ]
[ 42 62 36 62 48 76 38 64 35 62 40 63 36 60 36 63 ]
[ 49 76 36 64 35 64 38 64 37 61 36 62 60 74 37 80 ]
[ 43 69 36 65 36 62 37 62 54 77 42 66 37 64 35 60 ]
[ 36 61 38 62 51 75 40 64 35 62 36 61 37 61 39 61 ]
[ 51 76 38 64 35 63 36 63 38 62 37 63 49 76 39 64 ]
[ 35 64 35 64 38 62 36 62 61 85 42 65 38 79 38 62 ]
[ 36 61 35 64 49 77 37 63 38 64 36 60 37 62 36 60 ]
[ 51 76 38 66 38 62 37 63 36 62 37 60 50 77 41 64 ]
[ 36 60 36 60 36 61 37 61 50 78 39 66 37 63 36 62 ]
[ 36 61 39 63 60 74 38 66 37 61 35 63 37 65 36 65 ]
[ 48 76 38 65 36 64 41 64 36 60 35 61 49 76 39 66 ]
[ 36 64 39 60 37 60 36 59 51 73 37 64 40 64 36 62 ]
[ 37 61 35 62 50 78 39 67 38 63 35 61 36 63 36 61 ]
[ 66 75 41 66 37 65 36 61 36 62 38 63 50 75 38 65 ]
[ 37 63 36 62 38 63 36 63 49 76 38 64 38 63 40 64 ]
[ 35 63 36 60 50 74 39 65 37 65 38 62 36 62 36 60 ]
[ 51 75 37 66 39 65 37 62 37 62 38 61 67 72 39 65 ]
[ 37 62 35 61 37 61 54 63 53 75 42 67 35 63 36 61 ]
[ 36 65 39 62 53 75 38 64 36 63 35 62 38 63 36 61 ]
[ 49 77 39 66 38 62 36 62 38 61 35 59 83 91 77 25 ]
[ 22 22 22 24 21 21 21 20 21 35 67 24 50 47 67 39 ]
[ 65 34 65 36 63 65 74 38 64 35 64 37 63 37 62 36 ]
[ 61 51 75 38 67 39 63 35 64 37 62 36 61 50 74 37 ]
[ 66 37 62 35 63 35 61 36 65 52 76 40 65 38 61 37 ]
[ 62 36 61 40 64 63 71 40 62 36 64 36 63 36 61 39 ]
[ 62 49 76 37 65 36 62 36 61 38 65 41 64 50 75 39 ]
[ 67 37 62 37 63 36 62 38 61 69 153 70 140 200 737 67 ]

Notice how the packet trail seems to bounce back and
forth between taking ~30 ticks to taking ~60 ticks?

The ~60 tick packets are the TCP data packets that
make us output an ACK packet.  So this makes it cost
double of what it takes to process a TCP data packet
for which we do not immediately generate an ACK.

It pretty much shows that we need to have something
other than a blank "COUNT" to represent the NAPI weight,
and we should instead try to measure the real "work"
actually consumed, via some time measurement and limit,
to implement this stuff properly.

BTW, here is the patch implementing this stuff.

--- ./drivers/net/tg3.c.~1~	2005-06-03 11:13:14.000000000 -0700
+++ ./drivers/net/tg3.c	2005-06-05 14:16:32.000000000 -0700
@@ -2836,7 +2836,17 @@ static int tg3_rx(struct tg3 *tp, int bu
 				    desc->err_vlan & RXD_VLAN_MASK);
 		} else
 #endif
+		{
+			unsigned long t = get_cycles();
+			unsigned int ent;
+
 			netif_receive_skb(skb);
+			t = get_cycles() - t;
+
+			ent = tp->rx_log_ent;
+			tp->rx_log[ent] = (u32) t;
+			tp->rx_log_ent = ((ent + 1) & RX_LOG_MASK);
+		}
 
 		tp->dev->last_rx = jiffies;
 		received++;
@@ -6609,6 +6619,28 @@ static struct net_device_stats *tg3_get_
 	stats->rx_crc_errors = old_stats->rx_crc_errors +
 		calc_crc_errors(tp);
 
+	/* XXX Yes, I know, do this right. :-)  */
+	{
+		unsigned int ent, pos;
+
+		printk("TG3: RX LOG, current ent[%d]\n", tp->rx_log_ent);
+		ent = tp->rx_log_ent - 512;
+		pos = 0;
+		while (ent != tp->rx_log_ent) {
+			if (!pos) printk("[ ");
+
+			printk("%u ", tp->rx_log[ent]);
+
+			if (++pos >= 16) {
+				printk("]\n");
+				pos = 0;
+			}
+			ent = (ent + 1) & RX_LOG_MASK;
+		}
+		if (pos != 0)
+			printk("]\n");
+	}
+
 	return stats;
 }
 
--- ./drivers/net/tg3.h.~1~	2005-06-03 11:13:14.000000000 -0700
+++ ./drivers/net/tg3.h	2005-06-05 14:16:00.000000000 -0700
@@ -2232,6 +2232,11 @@ struct tg3 {
 #define SST_25VF0X0_PAGE_SIZE		4098
 
 	struct ethtool_coalesce		coal;
+
+#define RX_LOG_SIZE	(1 << 14)
+#define RX_LOG_MASK	(RX_LOG_SIZE - 1)
+	unsigned int			rx_log_ent;
+	u32				rx_log[RX_LOG_SIZE];
 };
 
 #endif /* !(_T3_H) */
