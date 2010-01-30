From: Joe Perches <joe@perches.com>
Subject: Re: RFC: Convert printks with net_device to dev_<level>
Date: Fri, 29 Jan 2010 18:26:24 -0800
Message-ID: <1264818384.25140.98.camel@Joe-Laptop.home>
References: <1264795286.25140.72.camel@Joe-Laptop.home>
	 <1264796707.2785.18.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1617 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755683Ab0A3C00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 21:26:26 -0500
In-Reply-To: <1264796707.2785.18.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-29 at 20:25 +0000, Ben Hutchings wrote:
> On Fri, 2010-01-29 at 12:01 -0800, Joe Perches wrote:
> > I've been playing with a cocci script and some additional
> > scripts to automate a conversion of printk and pr_<level>
> > logging messages with a reference to a struct net_device
> > to dev_<level>(&net_device->dev, ...)
> > 
> > A sample conversion:
> > 
> > -   printk(KERN_INFO "%s: Using MII transceiver %d, status %4.4x.\n",
> > -          dev->name, tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));
> > +   dev_info(&dev->dev, "Using MII transceiver %d, status %04x\n",
> > +            tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));
> [...]
> 
> My understanding is that dev_* should be given a bus device (pci_device,
> usb_device, ...), not a class device (net_device).  Of course, the net
> device name is rather useful as well.  In sfc we print both once the net
> device is registered.
> 
> It might be useful to add netdev_* print macros along the lines of:
> 
> #define netdev_name(dev)                                      \
>       (((dev)->reg_state == NETREG_REGISTERED) ? (dev)->name : "")
> 
> #define netdev_info(dev, fmt, ...)                            \
>       dev_info((dev)->dev.parent, "%s " fmt,                  \
>                netdev_name(dev), __VA_ARGS__)

Something like this?

 include/linux/netdevice.h |   59 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 93a32a5..1997b2d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2077,6 +2077,65 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 		return 0;
 	return dev->ethtool_ops->get_flags(dev);
 }
+
+/* debugging and troubleshooting/diagnostic helpers. */
+
+static inline const char *netdev_name(const struct net_device *dev)
+{
+	if (dev->reg_state != NETREG_REGISTERED)
+		return "";
+	return dev->name;
+}
+
+#define netdev_printk(level, dev, format, arg...)	\
+	dev_printk(level, (dev)->dev.parent,		\
+		   "%s:" format, netdev_name(dev), ##arg)
+
+#define netdev_emerg(dev, format, arg...)		\
+	netdev_printk(KERN_EMERG, dev, format, ##arg)
+#define netdev_alert(dev, format, arg...)		\
+	netdev_printk(KERN_ALERT, dev, format, ##arg)
+#define netdev_crit(dev, format, arg...)		\
+	netdev_printk(KERN_CRIT, dev, format, ##arg)
+#define netdev_err(dev, format, arg...)		\
+	netdev_printk(KERN_ERR, dev, format, ##arg)
+#define netdev_warn(dev, format, arg...)		\
+	netdev_printk(KERN_WARNING, dev, format, ##arg)
+#define netdev_notice(dev, format, arg...)		\
+	netdev_printk(KERN_NOTICE, dev, format, ##arg)
+#define netdev_info(dev, format, arg...)		\
+	netdev_printk(KERN_INFO, dev, format, ##arg)
+
+#if defined(DEBUG)
+#define netdev_dbg(dev, format, arg...)			\
+	netdev_printk(KERN_DEBUG, dev, format, ##arg)
+#elif defined(CONFIG_DYNAMIC_DEBUG)
+#define netdev_dbg(dev, format, arg...) do {			\
+	dynamic_dev_dbg((dev)->dev.parent,			\
+			"%s:" format, netdev_name(dev), ##arg); \
+	} while (0)
+#else
+#define netdev_dbg(dev, format, arg...)		\
+	({ if (0) netdev_printk(KERN_DEBUG, dev, format, ##arg); 0; })
+#endif
+
+#ifdef VERBOSE_DEBUG
+#define netdev_vdbg	netdev_dbg
+#else
+
+#define netdev_vdbg(dev, format, arg...)		\
+	({ if (0) netdev_printk(KERN_DEBUG, dev, format, ##arg); 0; })
+#endif
+
+/*
+ * netdev_WARN() acts like dev_printk(), but with the key difference
+ * of using a WARN/WARN_ON to get the message out, including the
+ * file/line information and a backtrace.
+ */
+#define netdev_WARN(dev, format, arg...) \
+	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##arg);
+
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_NETDEVICE_H */


