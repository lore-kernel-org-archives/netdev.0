From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v4 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 02 Nov 2015 11:51:38 -0800
Message-ID: <1446493898.24485.59.camel@perches.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	scottwood@freescale.com, igal.liberman@freescale.com,
	roy.pledge@freescale.com, ppc@mindchasers.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, gregkh@linuxfoundation.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.
[]
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
[]
> +static void _dpa_rx_error(struct net_device *net_dev,
> +			  const struct dpa_priv_s *priv,
> +			  struct dpa_percpu_priv_s *percpu_priv,
> +			  const struct qm_fd *fd,
> +			  u32 fqid)
> +{
> +	/* limit common, possibly innocuous Rx FIFO Overflow errors'
> +	 * interference with zero-loss convergence benchmark results.
> +	 */
> +	if (likely(fd->status & FM_FD_ERR_PHYSICAL))
> +		pr_warn_once("non-zero error counters in fman statistics (sysfs)\n");
> +	else
> +		if (net_ratelimit())
> +			netif_err(priv, hw, net_dev, "Err FD status = 0x%08x\n",
> +				  fd->status & FM_FD_STAT_RX_ERRORS);

It's a bit of a pity the logging message code is
a mix of pr_<level>, dev_<level>, netdev_<level>
and netif_<level>

Perhaps netif_<foo>_ratelimited macros should be added.

Something like:

---
 include/linux/netdevice.h | 54 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 210d11a..555471d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4025,6 +4025,60 @@ do {								\
 })
 #endif
 
+#define netif_level_ratelimited(level, priv, type, dev, fmt, args...)	\
+do {									\
+	if (netif_msg_##type(priv) && net_ratelimit())			\
+		netdev_##level(dev, fmt, ##args);			\
+} while (0)
+
+#define netif_emerg_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(emerg, priv, type, dev, fmt, ##args)
+#define netif_alert_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(alert, priv, type, dev, fmt, ##args)
+#define netif_crit_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(crit, priv, type, dev, fmt, ##args)
+#define netif_err_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(err, priv, type, dev, fmt, ##args)
+#define netif_warn_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(warn, priv, type, dev, fmt, ##args)
+#define netif_notice_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(notice, priv, type, dev, fmt, ##args)
+#define netif_info_ratelimited(priv, type, dev, fmt, args...)		\
+	netif_level_ratelimited(info, priv, type, dev, fmt, ##args)
+
+#if defined(CONFIG_DYNAMIC_DEBUG)
+/* descriptor check is first to prevent flooding with "callbacks suppressed" */
+#define netif_dbg_ratelimited(priv, type, dev, fmt, args...)		\
+do {									\
+	DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);			\
+	if (unlikely(descriptor.flags & _DPRINTK_FLAGS_PRINT) &&	\
+	    netif_msg_##type(priv) && net_ratelimit())			\
+		__dynamic_netdev_dbg(&descriptor, dev, fmt, ##args);	\
+} while (0)
+#elif defined(DEBUG)
+#define netif_dbg_ratelimited(priv, type, dev, fmt, args...)		\
+do {									\
+	if (netif_msg_##type(priv) && net_ratelimit())			\
+		netif_printk(priv, type, KERN_DEBUG, dev, fmt, ##args);	\
+} while (0)
+#else
+#define netif_dbg_ratelimited(priv, type, dev, fmt, args...)		\
+do {									\
+	if (0)								\
+		netif_printk(priv, type, KERN_DEBUG, dev, fmt, ##args);	\
+} while (0)
+#endif
+
+#if defined(VERBOSE_DEBUG)
+#define netif_vdbg_ratelimited	netif_dbg_ratelimited
+#else
+#define netif_vdbg(priv, type, dev, fmt, args...)			\
+do {									\
+	if (0)								\
+		netif_printk(priv, type, KERN_DEBUG, dev, fmt, ##args);	\
+} while (0)
+#endif
+
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
