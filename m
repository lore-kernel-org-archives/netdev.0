From: Dong Zhu <bluezhudong@gmail.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time
 stamping policy
Date: Sun, 12 May 2013 22:25:55 +0800
Message-ID: <20130512142555.GI8399@zhudong.nay.redhat.com>
References: <20130511140219.GG8399@zhudong.nay.redhat.com>
	<518E7723.5010003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Jacob Keller <Jacob.e.keller@intel.com>, Dave Jones <davej@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <518E7723.5010003@cogentembedded.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Thanks for your pointing out my mistakes of CodingStyle.

> > struct hwtstamp_config {
> >+	int rw;

My initial idea was that the type of rw should be enum like tx_type, but I am
not sure whther it is necessary to define a new enum, if this patch could
be accpeted I will ask someone about the rw. At that time I will change
the type of rw to bool or define a new enum, then convert the if to
switch if necessary.

Patch after modifying:

>From cf337e7863af66428554785c32a9840fafaa3492 Mon Sep 17 00:00:00 2001
From: Dong Zhu <bluezhudong@gmail.com>
Date: Sun, 12 May 2013 21:57:57 +0800

Currently kernel only support setting the hw time stamping policy
through ioctl,now add a method to check which packets(Outgoing and
Incoming) are time stamped by nic.

Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 28 ++++++++++++++++++++++++++++
 include/uapi/linux/net_tstamp.h          |  4 +++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 7e8c477..4ea091d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -577,6 +577,33 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	if (config.flags)
 		return -EINVAL;
 
+	if (config.rw == 0) {
+		goto set_policy;
+	} else if (config.rw == 1) {
+		if (config.tx_type || config.rx_filter)
+			return -EINVAL;
+
+		regval = rd32(E1000_TSYNCTXCTL);
+		if (regval & E1000_TSYNCTXCTL_ENABLED)
+			config.tx_type = HWTSTAMP_TX_ON;
+		else
+			config.tx_type = HWTSTAMP_TX_OFF;
+
+		regval = rd32(E1000_TSYNCRXCTL);
+		if (!(regval & E1000_TSYNCRXCTL_ENABLED))
+			config.rx_filter = HWTSTAMP_FILTER_NONE;
+		else if (E1000_TSYNCRXCTL_TYPE_ALL ==
+				(regval & E1000_TSYNCRXCTL_TYPE_MASK))
+			config.rx_filter = HWTSTAMP_FILTER_ALL;
+		else
+			return -ERANGE;
+
+		goto end;
+	} else {
+		return -EINVAL;
+	}
+
+set_policy:
 	switch (config.tx_type) {
 	case HWTSTAMP_TX_OFF:
 		tsync_tx_ctl = 0;
@@ -707,6 +734,7 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	regval = rd32(E1000_RXSTMPL);
 	regval = rd32(E1000_RXSTMPH);
 
+end:
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 		-EFAULT : 0;
 }
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index ae5df12..77147da 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -28,9 +28,10 @@ enum {
 /**
  * struct hwtstamp_config - %SIOCSHWTSTAMP parameter
  *
+ * @rw:        0/1 represents set/get the hw time stamp policy
  * @flags:	no flags defined right now, must be zero
  * @tx_type:	one of HWTSTAMP_TX_*
- * @rx_type:	one of one of HWTSTAMP_FILTER_*
+ * @rx_filter:	one of one of HWTSTAMP_FILTER_*
  *
  * %SIOCSHWTSTAMP expects a &struct ifreq with a ifr_data pointer to
  * this structure. dev_ifsioc() in the kernel takes care of the
@@ -39,6 +40,7 @@ enum {
  * 32 and 64 bit systems, don't break this!
  */
 struct hwtstamp_config {
+	int rw;
 	int flags;
 	int tx_type;
 	int rx_filter;
-- 
1.7.11.7

-- 
Best Regards,
Dong Zhu

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and 
their applications. This 200-page book is written by three acclaimed 
leaders in the field. The early access version is available now. 
Download your free book today! http://p.sf.net/sfu/neotech_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
