From: Arthur Kepner <akepner@sgi.com>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 20 May 2005 14:52:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505201442380.11419@linux.site>
References: <Pine.LNX.4.61.0505131648140.14917@linux.site>
 <20050513.175013.00786860.davem@davemloft.net> <1116031159.6214.8.camel@rh4>
 <20050513.222007.78719997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-567735041-1116625955=:11419"
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050513.222007.78719997.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-567735041-1116625955=:11419
Content-Type: TEXT/PLAIN; charset=US-ASCII


Here are a couple more data points with the recent 
interrupt coalescing patches for the tg3 driver. 
Please see the attached graphs, which show how CPU 
utilization, and number of received packets per 
interrupt vary with link utilization. The workload 
here is receive-as-fast-as-you-can-over-TCP, with 
a single sending and a single receiving process.

The data in the graphs is labelled as follows:
----------------------------------------------
2.6.12-rc3: unmodified 2.6.12-rc3 

dflt coal : 2.6.12-rc3 + [1] + [2] + [3] + [4]
            using the default intr coalescence 
            values (rx-frames = rx-usecs-irq = 5)

4x coal   : 2.6.12-rc3 + [1] + [2] + [3] + [4] + [5]
            using 4 times the default values 
            for rx-frames and rx-frames-irq

[1] http://marc.theaimsgroup.com/?l=linux-netdev&m=111446723510962&w=2
    (This is one of a series of 3 patches - the others can't be
     found in the archive. But they're all in 2.6.12-rc4.)
[2] http://marc.theaimsgroup.com/?l=linux-netdev&m=111567944730302&w=2
    ("tagged status" patch)
[3] http://marc.theaimsgroup.com/?l=linux-netdev&m=111586526522981&w=2
    ("hw coalescing infrastructure" patch)
[4] http://marc.theaimsgroup.com/?l=linux-netdev&m=111604846510646&w=2
    ("tagged status update")
[5] the patches below which allow "ethtool -[cC]" to work


Patch [4] almost entirely eliminates updates to the tag in 
the status block between when it's been saved in tg3_poll() 
and when it's written back to the NIC in tg3_restart_ints(). 
It still happens, but the frequency is a few times in a 
thousand, so it doesn't significantly affect the interrupt 
rate. 

I had to make a couple of changes to allow setting/
retrieving the coalescence parameters with ethtool. Those 
patches are at the end. 

When the default coalescence parameters are used (rx-frames, 
rx-frames-irq both set to 5) the maximum number of received 
packets per interrupt is ~4.2. Setting rx-frames and 
rx-frames-irq to 20 caused the maximum number of received
packets per interrupt to rise to ~19.6. Maximum CPU 
utilization went down from ~52% to ~35%. Very nice.


Fix typo in ethtool_set_coalesce()

Signed-off-by: Arthur Kepner <akepner@sgi.com>

--- linux.save/net/core/ethtool.c	2005-05-20 12:40:04.426385446 -0700
+++ linux/net/core/ethtool.c	2005-05-20 12:49:34.087515306 -0700
@@ -347,7 +347,7 @@ static int ethtool_set_coalesce(struct n
 {
 	struct ethtool_coalesce coalesce;
 
-	if (!dev->ethtool_ops->get_coalesce)
+	if (!dev->ethtool_ops->set_coalesce)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&coalesce, useraddr, sizeof(coalesce)))


Changes to allow setting/getting coalescence parameters 
with tg3.

Signed-off-by: Arthur Kepner <akepner@sgi.com>

--- linux.save/drivers/net/tg3.c	2005-05-20 13:02:41.610865448 -0700
+++ linux/drivers/net/tg3.c	2005-05-20 13:11:36.467011288 -0700
@@ -5094,8 +5094,11 @@ static void tg3_set_bdinfo(struct tg3 *t
 }
 
 static void __tg3_set_rx_mode(struct net_device *);
-static void tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
+static int tg3_set_coalesce(struct net_device *dev, 
+				struct ethtool_coalesce *ec)
 {
+	struct tg3 *tp = netdev_priv(dev);
+
 	tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
 	tw32(HOSTCC_TXCOL_TICKS, ec->tx_coalesce_usecs);
 	tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
@@ -5114,6 +5117,9 @@ static void tg3_set_coalesce(struct tg3 
 
 		tw32(HOSTCC_STAT_COAL_TICKS, val);
 	}
+
+	memcpy(&tp->coal, ec, sizeof(tp->coal));
+	return 0;
 }
 
 /* tp->lock is held. */
@@ -5437,7 +5443,7 @@ static int tg3_reset_hw(struct tg3 *tp)
 		udelay(10);
 	}
 
-	tg3_set_coalesce(tp, &tp->coal);
+	tg3_set_coalesce(tp->dev, &tp->coal);
 
 	/* set status block DMA address */
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
@@ -7302,6 +7308,8 @@ static int tg3_get_coalesce(struct net_d
 	return 0;
 }
 
+static int tg3_set_coalesce(struct net_device *, struct ethtool_coalesce *);
+
 static struct ethtool_ops tg3_ethtool_ops = {
 	.get_settings		= tg3_get_settings,
 	.set_settings		= tg3_set_settings,
@@ -7335,6 +7343,7 @@ static struct ethtool_ops tg3_ethtool_op
 	.get_stats_count	= tg3_get_stats_count,
 	.get_ethtool_stats	= tg3_get_ethtool_stats,
 	.get_coalesce		= tg3_get_coalesce,
+	.set_coalesce		= tg3_set_coalesce,
 };
 
 static void __devinit tg3_get_eeprom_size(struct tg3 *tp)

--
Arthur
--8323584-567735041-1116625955=:11419
Content-Type: IMAGE/png; name="cpu_vs_link.4.png"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0505201452350.11419@linux.site>
Content-Description: CPU utilization
Content-Disposition: attachment; filename="cpu_vs_link.4.png"

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
tsNPcZrVAAAAAElFTkSuQmCC

--8323584-567735041-1116625955=:11419
Content-Type: IMAGE/png; name="packets_vs_link.4.png"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0505201452351.11419@linux.site>
Content-Description: Received Pkts/Intr
Content-Disposition: attachment; filename="packets_vs_link.4.png"

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

--8323584-567735041-1116625955=:11419--
