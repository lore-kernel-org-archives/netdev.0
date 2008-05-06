From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: [PATCH] au1k_ir: use netstats in net_device structure
Date: Wed, 07 May 2008 00:32:19 +0300
Message-ID: <4820CE63.7050505@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030305010008050208030004"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030305010008050208030004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill au1k_irda_stats function, because by default it is used
identical internal_stats function from net/core/dev.c

Haven't tried to compile it. Need ack from MIPS people!

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>

--------------030305010008050208030004
Content-Type: text/x-patch;
 name="au1k_ir_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="au1k_ir_netstats.patch"

diff --git a/drivers/net/irda/au1000_ircc.h b/drivers/net/irda/au1000_ircc.h
index 7a31d46..1ed665a 100644
--- a/drivers/net/irda/au1000_ircc.h
+++ b/drivers/net/irda/au1000_ircc.h
@@ -107,7 +107,6 @@ struct au1k_private {
 	iobuff_t rx_buff;
 
 	struct net_device *netdev;
-	struct net_device_stats stats;
 	
 	struct timeval stamp;
 	struct timeval now;
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index a1e4508..f4e639b 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -53,7 +53,6 @@ static int au1k_irda_hard_xmit(struct sk_buff *, struct net_device *);
 static int au1k_irda_rx(struct net_device *);
 static void au1k_irda_interrupt(int, void *);
 static void au1k_tx_timeout(struct net_device *);
-static struct net_device_stats *au1k_irda_stats(struct net_device *);
 static int au1k_irda_ioctl(struct net_device *, struct ifreq *, int);
 static int au1k_irda_set_speed(struct net_device *dev, int speed);
 
@@ -213,7 +212,6 @@ static int au1k_irda_net_init(struct net_device *dev)
 	dev->open = au1k_irda_start;
 	dev->hard_start_xmit = au1k_irda_hard_xmit;
 	dev->stop = au1k_irda_stop;
-	dev->get_stats = au1k_irda_stats;
 	dev->do_ioctl = au1k_irda_ioctl;
 	dev->tx_timeout = au1k_tx_timeout;
 
@@ -421,7 +419,7 @@ static inline void
 update_tx_stats(struct net_device *dev, u32 status, u32 pkt_len)
 {
 	struct au1k_private *aup = netdev_priv(dev);
-	struct net_device_stats *ps = &aup->stats;
+	struct net_device_stats *ps = &dev->stats;
 
 	ps->tx_packets++;
 	ps->tx_bytes += pkt_len;
@@ -557,7 +555,7 @@ static inline void
 update_rx_stats(struct net_device *dev, u32 status, u32 count)
 {
 	struct au1k_private *aup = netdev_priv(dev);
-	struct net_device_stats *ps = &aup->stats;
+	struct net_device_stats *ps = &dev->stats;
 
 	ps->rx_packets++;
 
@@ -596,7 +594,7 @@ static int au1k_irda_rx(struct net_device *dev)
 			update_rx_stats(dev, flags, count);
 			skb=alloc_skb(count+1,GFP_ATOMIC);
 			if (skb == NULL) {
-				aup->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				continue;
 			}
 			skb_reserve(skb, 1);
@@ -833,13 +831,6 @@ au1k_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 	return ret;
 }
 
-
-static struct net_device_stats *au1k_irda_stats(struct net_device *dev)
-{
-	struct au1k_private *aup = netdev_priv(dev);
-	return &aup->stats;
-}
-
 MODULE_AUTHOR("Pete Popov <ppopov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>");
 MODULE_DESCRIPTION("Au1000 IrDA Device Driver");
 

--------------030305010008050208030004
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
--------------030305010008050208030004
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
irda-users mailing list
irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
http://lists.sourceforge.net/lists/listinfo/irda-users

--------------030305010008050208030004--
