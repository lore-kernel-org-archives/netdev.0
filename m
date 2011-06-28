From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Tue, 28 Jun 2011 14:37:48 -0700
Message-ID: <1309297068.29598.26.camel@Joe-Laptop>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
	 <1309292501.2771.48.camel@bwh-desktop>
	 <1309293068.29598.14.camel@Joe-Laptop>
	 <1309293416.2771.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3274 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab1F1Vht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 17:37:49 -0400
In-Reply-To: <1309293416.2771.50.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-28 at 21:36 +0100, Ben Hutchings wrote:
> On Tue, 2011-06-28 at 13:31 -0700, Joe Perches wrote:
> > On Tue, 2011-06-28 at 21:21 +0100, Ben Hutchings wrote:
> > > On Tue, 2011-06-28 at 12:40 -0700, Joe Perches wrote:
> > > > Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.
> > > > Coalesce long formats.
> > > [...]
> > > > --- a/net/core/dev.c
> > > > +++ b/net/core/dev.c
> > > > @@ -72,6 +72,8 @@
> > > > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > > [...]
> > > KBUILD_MODNAME is presumably going to be "dev".
> > 'tis.
> > > That's not very meaningful.
> > I think it's not useless though.
> > Anything else you think it should be?
> > Maybe "net_core_device:" or some such like that?
> "netdev"
> > Here are the format strings now prefaced by "dev:"
> > $ strings net/core/built-in.o |grep "^<.>dev:"
> > <6>dev: netif_stop_queue() cannot be called before register_netdev()
> > <4>dev: dev_remove_pack: %p not found
> > <3>dev: Loading kernel module for a network device with CAP_SYS_MODULE (deprecated)
> > <0>dev: %s: failed to move %s to init_net: %d
> > <3>dev: alloc_netdev: Unable to allocate device with zero queues
> > <3>dev: alloc_netdev: Unable to allocate device with zero RX queues
> > <3>dev: alloc_netdev: Unable to allocate device
> Many of these refer to a specific device and should be formatted with
> one of the netdev_* logging functions.

Perhaps another way to do this is like this:

As soon as alloc_netdev is called, netdev_<level> can
be used, but the netdev_name() function can contain
printf formatting control codes like %d.

Use pr_fmt(fmt) "netdev: " fmt in net/core/dev.c
Add netdev_is_registered() to netdevice.h
Extend uses of netdev_name() with netdev_is_registered()
to show "(unregistered)" as may be necessary.
Move setting of dev->name in alloc_netdev_mqs to just
after allocation instead of at end of function.

(on top of the original patch, will respin if wanted)

Thoughts?

---

 include/linux/netdevice.h |   29 ++++++++++++++++++++++-------
 net/core/dev.c            |   18 ++++++++++--------
 2 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 011eb89..4b6c4e2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2625,11 +2625,16 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 
 static inline const char *netdev_name(const struct net_device *dev)
 {
-	if (dev->reg_state != NETREG_REGISTERED)
-		return "(unregistered net_device)";
+	if (!dev)
+		return "NULL net_device";
 	return dev->name;
 }
 
+static inline bool netdev_is_registered(const struct net_device *dev)
+{
+	return dev && dev->reg_state == NETREG_REGISTERED;
+}
+
 extern int netdev_printk(const char *level, const struct net_device *dev,
 			 const char *format, ...)
 	__attribute__ ((format (printf, 3, 4)));
@@ -2657,8 +2662,11 @@ extern int netdev_info(const struct net_device *dev, const char *format, ...)
 #elif defined(CONFIG_DYNAMIC_DEBUG)
 #define netdev_dbg(__dev, format, args...)			\
 do {								\
-	dynamic_dev_dbg((__dev)->dev.parent, "%s: " format,	\
-			netdev_name(__dev), ##args);		\
+	dynamic_dev_dbg((__dev)->dev.parent, "%s%s: " format,	\
+			netdev_name(__dev),			\
+			netdev_is_registered(__dev)		\
+			  ? "" : " (unregistered)",		\
+			##args);				\
 } while (0)
 #else
 #define netdev_dbg(__dev, format, args...)			\
@@ -2687,7 +2695,11 @@ do {								\
  * file/line information and a backtrace.
  */
 #define netdev_WARN(dev, format, args...)			\
-	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args);
+	WARN(1, "netdevice: %s%s\n" format,			\
+	     netdev_name(dev),					\
+	     netdev_is_registered(dev)				\
+	       ? "" : " (unregistered)",			\
+	     ##args);
 
 /* netif printk helpers, similar to netdev_printk */
 
@@ -2726,8 +2738,11 @@ do {								\
 do {								\
 	if (netif_msg_##type(priv))				\
 		dynamic_dev_dbg((netdev)->dev.parent,		\
-				"%s: " format,			\
-				netdev_name(netdev), ##args);	\
+				"%s%s: " format,		\
+				netdev_name(netdev),		\
+				netdev_is_registered(netdev)	\
+				  ? "" : " (unregistered)",	\
+				##args);			\
 } while (0)
 #else
 #define netif_dbg(priv, type, dev, format, args...)			\
diff --git a/net/core/dev.c b/net/core/dev.c
index 3401227..44e2646 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -72,7 +72,7 @@
  *				        - netif_rx() feedback
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define pr_fmt(fmt) "netdev: " fmt
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -5803,13 +5803,13 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	if (txqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device with zero queues\n");
+		pr_err("Unable to allocate device with zero queues\n");
 		return NULL;
 	}
 
 #ifdef CONFIG_RPS
 	if (rxqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device with zero RX queues\n");
+		pr_err("Unable to allocate device with zero RX queues\n");
 		return NULL;
 	}
 #endif
@@ -5825,13 +5825,15 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
-		pr_err("alloc_netdev: Unable to allocate device\n");
+		pr_err("Unable to allocate device\n");
 		return NULL;
 	}
 
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
+	strcpy(dev->name, name);
+
 	dev->pcpu_refcnt = alloc_percpu(int);
 	if (!dev->pcpu_refcnt)
 		goto free_p;
@@ -5864,7 +5866,6 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		goto free_all;
 #endif
 
-	strcpy(dev->name, name);
 	dev->group = INIT_NETDEV_GROUP;
 	return dev;
 
@@ -6270,10 +6271,11 @@ static int __netdev_printk(const char *level, const struct net_device *dev,
 	if (dev && dev->dev.parent)
 		r = dev_printk(level, dev->dev.parent, "%s: %pV",
 			       netdev_name(dev), vaf);
-	else if (dev)
-		r = printk("%s%s: %pV", level, netdev_name(dev), vaf);
 	else
-		r = printk("%s(NULL net_device): %pV", level, vaf);
+		r = printk("%s%s%s: %pV",
+			   level, netdev_name(dev),
+			   netdev_is_registered(dev) ? "" : " (unregistered)",
+			   vaf);
 
 	return r;
 }


