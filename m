From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] netdev_ops
Date: Wed, 9 Jul 2003 17:15:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: willy@debian.org, greearb@candelatech.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20030708.150835.78728697.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Changes since yesterday's patch:

 - Make all methods take the struct net_device as suggested by Ben Greear.
 - Rename self_test_len() and get_stats_len() to *_count() to reflect
   that they return a count of elements, not a byte length.
 - Related bugfixes.
 - Remove the get_strings_len() method; we now infer the length from
   either self_test_count() or get_stats_count().
 - memset() the drvinfo struct so it doesn't leak information from the
   kernel stack (existing bug in tg3).
 - Clamp regs.len in ethtool.c rather than in the driver.
 - Pass the stringset value to get_strings() rather than a pointer to
   the whole ethtool_gstrings struct.

I have a question about the error return values in ethtool_get_strings().
Are -EOPNOTSUPP and -EINVAL the right ones to use in the case statement?
Or should I perhaps be using -ENOSYS instead of EINVAL?  I've noticed
drepper tends to prefer this for unimplemented subops.  Since this is
an ioctl(), perhaps I should be using -ENOTTY instead ;-)

Anyway, further comments welcomed.

Index: include/linux/ethtool.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/linux/ethtool.h,v
retrieving revision 1.5
diff -u -p -r1.5 ethtool.h
--- include/linux/ethtool.h	14 Jun 2003 22:16:01 -0000	1.5
+++ include/linux/ethtool.h	8 Jul 2003 15:25:49 -0000
@@ -12,6 +12,7 @@
 #ifndef _LINUX_ETHTOOL_H
 #define _LINUX_ETHTOOL_H
 
+#include <linux/types.h>
 
 /* This should work for both 32 and 64 bit userland. */
 struct ethtool_cmd {
@@ -97,7 +98,7 @@ struct ethtool_coalesce {
 	u32	rx_max_coalesced_frames;
 
 	/* Same as above two parameters, except that these values
-	 * apply while an IRQ is being services by the host.  Not
+	 * apply while an IRQ is being serviced by the host.  Not
 	 * all cards support this feature and the values are ignored
 	 * in that case.
 	 */
@@ -119,7 +120,7 @@ struct ethtool_coalesce {
 	u32	tx_max_coalesced_frames;
 
 	/* Same as above two parameters, except that these values
-	 * apply while an IRQ is being services by the host.  Not
+	 * apply while an IRQ is being serviced by the host.  Not
 	 * all cards support this feature and the values are ignored
 	 * in that case.
 	 */
Index: include/linux/netdevice.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/linux/netdevice.h,v
retrieving revision 1.14
diff -u -p -r1.14 netdevice.h
--- include/linux/netdevice.h	2 Jul 2003 22:08:52 -0000	1.14
+++ include/linux/netdevice.h	9 Jul 2003 15:24:33 -0000
@@ -42,6 +42,7 @@
 
 struct divert_blk;
 struct vlan_group;
+struct netdev_ops;
 
 #define HAVE_ALLOC_NETDEV		/* feature macro: alloc_xxxdev
 					   functions are available. */
@@ -299,6 +300,8 @@ struct net_device
 	 * See <net/iw_handler.h> for details. Jean II */
 	struct iw_handler_def *	wireless_handlers;
 
+	struct netdev_ops *netdev_ops;
+
 	/*
 	 * This marks the end of the "visible" part of the structure. All
 	 * fields hereafter are internal to the system, and may change at
@@ -484,6 +487,100 @@ struct packet_type 
 	struct list_head	list;
 };
 
+/* Some generic methods drivers may use in their netops */
+u32 netdev_op_get_link(struct net_device *dev);
+u32 netdev_op_get_tx_csum(struct net_device *dev);
+u32 netdev_op_get_sg(struct net_device *dev);
+int netdev_op_set_sg(struct net_device *dev, u32 data);
+
+struct ethtool_cmd;
+struct ethtool_drvinfo;
+struct ethtool_regs;
+struct ethtool_wolinfo;
+struct ethtool_eeprom;
+struct ethtool_coalesce;
+struct ethtool_ringparam;
+struct ethtool_pauseparam;
+struct ethtool_test;
+struct ethtool_stats;
+
+/**
+ * &netdev_ops - Alter and report network device settings
+ * get_settings: Get device-specific settings
+ * set_settings: Set device-specific settings
+ * get_drvinfo: Report driver information
+ * get_regs: Get device registers
+ * get_wol: Report whether Wake-on-Lan is enabled
+ * set_wol: Turn Wake-on-Lan on or off
+ * get_msglevel: Report driver message level
+ * set_msglevel: Set driver message level
+ * nway_reset: Restart autonegotiation
+ * get_link: Get link status
+ * get_eeprom: Read data from the device EEPROM
+ * set_eeprom: Writedata to the device EEPROM
+ * get_coalesce: Get interrupt coalescing parameters
+ * set_coalesce: Set interrupt coalescing parameters
+ * get_ringparam: Report ring sizes
+ * set_ringparam: Set ring sizes
+ * get_pauseparam: Report pause parameters
+ * set_pauseparam: Set pause paramters
+ * get_rx_csum: Report whether receive checksums are turned on or off
+ * set_rx_csum: Turn receive checksum on or off
+ * get_tx_csum: Report whether transmit checksums are turned on or off
+ * set_tx_csum: Turn transmit checksums on or off
+ * get_sg: Report whether scatter-gather is enabled
+ * set_sg: Turn scatter-gather on or off
+ * self_test: Run specified self-tests
+ * get_strings: Return a set of strings that describe the requested objects 
+ * phys_id: Identify the device
+ * get_stats: Return statistics about the device
+ *
+ * Description:
+ *
+ * Each operation is passed a &struct net_device as its first parameter.
+ *
+ * get_settings:
+ *	@get_settings is passed an &ethtool_cmd to fill in.  It returns
+ *	an negative errno or zero.
+ *
+ * set_settings:
+ *	@set_settings is passed an &ethtool_cmd and should attempt to set
+ *	all the settings this device supports.  It may return an error value
+ *	if something goes wrong (otherwise 0).
+ */
+struct netdev_ops {
+	int	(*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int	(*set_settings)(struct net_device *, struct ethtool_cmd *);
+	void	(*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
+	int	(*get_regs_len)(struct net_device *);
+	void	(*get_regs)(struct net_device *, struct ethtool_regs *, void *);
+	void	(*get_wol)(struct net_device *, struct ethtool_wolinfo *);
+	int	(*set_wol)(struct net_device *, struct ethtool_wolinfo *);
+	u32	(*get_msglevel)(struct net_device *);
+	void	(*set_msglevel)(struct net_device *, u32);
+	int	(*nway_reset)(struct net_device *);
+	u32	(*get_link)(struct net_device *);
+	int	(*get_eeprom)(struct net_device *, struct ethtool_eeprom *);
+	int	(*set_eeprom)(struct net_device *, struct ethtool_eeprom *);
+	int	(*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
+	int	(*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
+	void	(*get_ringparam)(struct net_device *, struct ethtool_ringparam *);
+	int	(*set_ringparam)(struct net_device *, struct ethtool_ringparam *);
+	void	(*get_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
+	int	(*set_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
+	u32	(*get_rx_csum)(struct net_device *);
+	int	(*set_rx_csum)(struct net_device *, u32);
+	u32	(*get_tx_csum)(struct net_device *);
+	int	(*set_tx_csum)(struct net_device *, u32);
+	u32	(*get_sg)(struct net_device *);
+	int	(*set_sg)(struct net_device *, u32);
+	int	(*self_test_count)(struct net_device *);
+	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
+	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
+	void	(*phys_id)(struct net_device *, u32);
+	int	(*get_stats_count)(struct net_device *);
+	void	(*get_stats)(struct net_device *, struct ethtool_stats *, u64 *);
+};
 
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
@@ -633,6 +730,7 @@ extern int		netif_rx(struct sk_buff *skb
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_ioctl(unsigned int cmd, void *);
+extern int		dev_ethtool(struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_set_mtu(struct net_device *, int);
Index: net/socket.c
===================================================================
RCS file: /var/cvs/linux-2.5/net/socket.c,v
retrieving revision 1.21
diff -u -p -r1.21 socket.c
--- net/socket.c	17 Jun 2003 11:54:29 -0000	1.21
+++ net/socket.c	17 Jun 2003 11:57:20 -0000
@@ -74,7 +74,6 @@
 #include <linux/poll.h>
 #include <linux/cache.h>
 #include <linux/module.h>
-#include <linux/highmem.h>
 #include <linux/divert.h>
 #include <linux/mount.h>
 #include <linux/security.h>
@@ -1916,10 +1915,7 @@ int sock_unregister(int family)
 
 
 extern void sk_init(void);
-
-#ifdef CONFIG_WAN_ROUTER
 extern void wanrouter_init(void);
-#endif
 
 void __init sock_init(void)
 {
Index: net/core/Makefile
===================================================================
RCS file: /var/cvs/linux-2.5/net/core/Makefile,v
retrieving revision 1.9
diff -u -p -r1.9 Makefile
--- net/core/Makefile	27 May 2003 17:29:33 -0000	1.9
+++ net/core/Makefile	4 Jun 2003 18:39:01 -0000
@@ -10,8 +10,8 @@ obj-y += sysctl_net_core.o
 endif
 endif
 
-obj-$(CONFIG_NET) += flow.o dev.o net-sysfs.o dev_mcast.o dst.o neighbour.o \
-		     rtnetlink.o utils.o link_watch.o filter.o
+obj-$(CONFIG_NET) += flow.o dev.o ethtool.o net-sysfs.o dev_mcast.o dst.o \
+			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_NETFILTER) += netfilter.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
Index: net/core/dev.c
===================================================================
RCS file: /var/cvs/linux-2.5/net/core/dev.c,v
retrieving revision 1.22
diff -u -p -r1.22 dev.c
--- net/core/dev.c	2 Jul 2003 22:08:58 -0000	1.22
+++ net/core/dev.c	8 Jul 2003 15:36:35 -0000
@@ -2224,6 +2224,36 @@ int dev_set_mtu(struct net_device *dev, 
 	return err;
 }
 
+/* These are all netdev_op methods in case a driver needs to do something
+ * different.  If we find that all drivers want to do the same thing here,
+ * we can turn them into dev_() function calls.
+ */
+
+u32 netdev_op_get_link(struct net_device *dev)
+{
+	return netif_carrier_ok(dev) ? 1 : 0;
+}
+
+u32 netdev_op_get_tx_csum(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_IP_CSUM) != 0;
+}
+
+u32 netdev_op_get_sg(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_SG) != 0;
+}
+
+int netdev_op_set_sg(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_SG;
+	else
+		dev->features &= ~NETIF_F_SG;
+
+	return 0;
+}
+
 
 /*
  *	Perform the SIOCxIFxxx calls.
@@ -2364,7 +2394,6 @@ static int dev_ifsioc(struct ifreq *ifr,
 			    cmd == SIOCBONDSLAVEINFOQUERY ||
 			    cmd == SIOCBONDINFOQUERY ||
 			    cmd == SIOCBONDCHANGEACTIVE ||
-			    cmd == SIOCETHTOOL ||
 			    cmd == SIOCGMIIPHY ||
 			    cmd == SIOCGMIIREG ||
 			    cmd == SIOCSMIIREG ||
@@ -2461,13 +2490,26 @@ int dev_ioctl(unsigned int cmd, void *ar
 			}
 			return ret;
 
+		case SIOCETHTOOL:
+			dev_load(ifr.ifr_name);
+			rtnl_lock();
+			ret = dev_ethtool(&ifr);
+			rtnl_unlock();
+			if (!ret) {
+				if (colon)
+					*colon = ':';
+				if (copy_to_user(arg, &ifr,
+						 sizeof(struct ifreq)))
+					ret = -EFAULT;
+			}
+			return ret;
+
 		/*
 		 *	These ioctl calls:
 		 *	- require superuser power.
 		 *	- require strict serialization.
 		 *	- return a value
 		 */
-		case SIOCETHTOOL:
 		case SIOCGMIIPHY:
 		case SIOCGMIIREG:
 			if (!capable(CAP_NET_ADMIN))
Index: net/core/ethtool.c
===================================================================
RCS file: net/core/ethtool.c
diff -N net/core/ethtool.c
--- /dev/null	1 Jan 1970 00:00:00 -0000
+++ net/core/ethtool.c	9 Jul 2003 16:04:26 -0000
@@ -0,0 +1,585 @@
+/*
+ * net/core/ethtool.c - Ethtool ioctl handler
+ * Split from net/core/dev.c by Matthew Wilcox <matthew@wil.cx>
+ * The only entry point in this file is dev_ethtool() and its only caller
+ * is from net/core/dev.c
+ *
+ * It's GPL, stupid.
+ */
+
+#include <linux/errno.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+
+static int ethtool_get_settings(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	int err;
+
+	if (!dev->netdev_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	err = dev->netdev_ops->get_settings(dev, &cmd);
+	if (err < 0)
+		return err;
+
+	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_settings(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_cmd cmd;
+
+	if (!dev->netdev_ops->set_settings)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_settings(dev, &cmd);
+}
+
+static int ethtool_get_drvinfo(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_drvinfo info;
+	struct netdev_ops *ops = dev->netdev_ops;
+
+	if (!ops->get_drvinfo)
+		return -EOPNOTSUPP;
+
+	memset(&info, 0, sizeof(info));
+	info.cmd = ETHTOOL_GDRVINFO;
+	ops->get_drvinfo(dev, &info);
+
+	if (ops->self_test_count)
+		info.testinfo_len = ops->self_test_count(dev);
+	if (ops->get_stats_count)
+		info.n_stats = ops->get_stats_count(dev);
+	if (ops->get_regs_len)
+		info.regdump_len = ops->get_regs_len(dev);
+
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_get_regs(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_regs regs;
+	struct netdev_ops *ops = dev->netdev_ops;
+	void *regbuf;
+	int reglen, ret;
+
+	if (!ops->get_regs || !ops->get_regs_len)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&regs, useraddr, sizeof(regs)))
+		return -EFAULT;
+
+	reglen = ops->get_regs_len(dev);
+	if (regs.len > reglen)
+		regs.len = reglen;
+
+	regbuf = kmalloc(reglen, GFP_KERNEL);
+	if (!regbuf)
+		return -ENOMEM;
+
+	ops->get_regs(dev, &regs, regbuf);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &regs, sizeof(regs)))
+		goto out;
+	useraddr += offsetof(struct ethtool_regs, data);
+	if (copy_to_user(useraddr, regbuf, reglen))
+		goto out;
+	ret = 0;
+
+ out:
+	kfree(regbuf);
+	return ret;
+}
+
+static int ethtool_get_wol(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
+
+	if (!dev->netdev_ops->get_wol)
+		return -EOPNOTSUPP;
+
+	dev->netdev_ops->get_wol(dev, &wol);
+
+	if (copy_to_user(useraddr, &wol, sizeof(wol)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_wol(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_wolinfo wol;
+
+	if (!dev->netdev_ops->set_wol)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&wol, useraddr, sizeof(wol)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_wol(dev, &wol);
+}
+
+static int ethtool_get_msglevel(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GMSGLVL };
+
+	if (!dev->netdev_ops->get_msglevel)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->netdev_ops->get_msglevel(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_msglevel(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->netdev_ops->set_msglevel)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	dev->netdev_ops->set_msglevel(dev, edata.data);
+	return 0;
+}
+
+static int ethtool_nway_reset(struct net_device *dev)
+{
+	if (!dev->netdev_ops->nway_reset)
+		return -EOPNOTSUPP;
+
+	return dev->netdev_ops->nway_reset(dev);
+}
+
+static int ethtool_get_link(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GLINK };
+
+	if (!dev->netdev_ops->get_link)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->netdev_ops->get_link(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_get_eeprom(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_eeprom eeprom = { ETHTOOL_GEEPROM };
+
+	if (!dev->netdev_ops->get_eeprom)
+		return -EOPNOTSUPP;
+
+	dev->netdev_ops->get_eeprom(dev, &eeprom);
+
+	if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_eeprom(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_eeprom eeprom;
+
+	if (!dev->netdev_ops->get_eeprom)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(useraddr, &eeprom, sizeof(eeprom)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_eeprom(dev, &eeprom);
+}
+
+static int ethtool_get_coalesce(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_coalesce coalesce = { ETHTOOL_GCOALESCE };
+
+	if (!dev->netdev_ops->get_coalesce)
+		return -EOPNOTSUPP;
+
+	dev->netdev_ops->get_coalesce(dev, &coalesce);
+
+	if (copy_to_user(useraddr, &coalesce, sizeof(coalesce)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_coalesce(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_coalesce coalesce;
+
+	if (!dev->netdev_ops->get_coalesce)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(useraddr, &coalesce, sizeof(coalesce)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_coalesce(dev, &coalesce);
+}
+
+static int ethtool_get_ringparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_ringparam ringparam = { ETHTOOL_GRINGPARAM };
+
+	if (!dev->netdev_ops->get_ringparam)
+		return -EOPNOTSUPP;
+
+	dev->netdev_ops->get_ringparam(dev, &ringparam);
+
+	if (copy_to_user(useraddr, &ringparam, sizeof(ringparam)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_ringparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_ringparam ringparam;
+
+	if (!dev->netdev_ops->get_ringparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(useraddr, &ringparam, sizeof(ringparam)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_ringparam(dev, &ringparam);
+}
+
+static int ethtool_get_pauseparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
+
+	if (!dev->netdev_ops->get_pauseparam)
+		return -EOPNOTSUPP;
+
+	dev->netdev_ops->get_pauseparam(dev, &pauseparam);
+
+	if (copy_to_user(useraddr, &pauseparam, sizeof(pauseparam)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_pauseparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_pauseparam pauseparam;
+
+	if (!dev->netdev_ops->get_pauseparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(useraddr, &pauseparam, sizeof(pauseparam)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_pauseparam(dev, &pauseparam);
+}
+
+static int ethtool_get_rx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GRXCSUM };
+
+	if (!dev->netdev_ops->get_rx_csum)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->netdev_ops->get_rx_csum(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_rx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->netdev_ops->set_rx_csum)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	dev->netdev_ops->set_rx_csum(dev, edata.data);
+	return 0;
+}
+
+static int ethtool_get_tx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GTXCSUM };
+
+	if (!dev->netdev_ops->get_tx_csum)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->netdev_ops->get_tx_csum(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_tx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->netdev_ops->set_tx_csum)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_tx_csum(dev, edata.data);
+}
+
+static int ethtool_get_sg(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GSG };
+
+	if (!dev->netdev_ops->get_sg)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->netdev_ops->get_sg(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_sg(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->netdev_ops->set_sg)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->netdev_ops->set_sg(dev, edata.data);
+}
+
+static int ethtool_self_test(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_test test;
+	struct netdev_ops *ops = dev->netdev_ops;
+	u64 *data;
+	int ret;
+
+	if (!ops->self_test || !ops->self_test_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&test, useraddr, sizeof(test)))
+		return -EFAULT;
+
+	test.len = ops->self_test_count(dev);
+	data = kmalloc(test.len * sizeof(u64), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	ops->self_test(dev, &test, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &test, sizeof(test)))
+		goto out;
+	useraddr += sizeof(test);
+	if (copy_to_user(useraddr, data, test.len * sizeof(u64)))
+		goto out;
+	ret = 0;
+
+ out:
+	kfree(data);
+	return ret;
+}
+
+static int ethtool_get_strings(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_gstrings gstrings;
+	struct netdev_ops *ops = dev->netdev_ops;
+	u8 *data;
+	int ret;
+
+	if (!ops->get_strings)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
+		return -EFAULT;
+
+	switch (gstrings.string_set) {
+	case ETH_SS_TEST:
+		if (ops->self_test_count)
+			gstrings.len = ops->self_test_count(dev);
+		else
+			return -EOPNOTSUPP;
+	case ETH_SS_STATS:
+		if (ops->get_stats_count)
+			gstrings.len = ops->get_stats_count(dev);
+		else
+			return -EOPNOTSUPP;
+	default:
+		return -EINVAL;
+	}
+
+	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	ops->get_strings(dev, gstrings.string_set, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
+		goto out;
+	useraddr += sizeof(gstrings);
+	if (copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
+		goto out;
+	ret = 0;
+
+ out:
+	kfree(data);
+	return ret;
+}
+
+static int ethtool_phys_id(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_value id;
+
+	if (!dev->netdev_ops->phys_id)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&id, useraddr, sizeof(id)))
+		return -EFAULT;
+
+	dev->netdev_ops->phys_id(dev, id.data);
+	return 0;
+}
+
+static int ethtool_get_stats(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_stats stats;
+	struct netdev_ops *ops = dev->netdev_ops;
+	u64 *data;
+	int ret;
+
+	if (!ops->get_stats || !ops->get_stats_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&stats, useraddr, sizeof(stats)))
+		return -EFAULT;
+
+	stats.n_stats = ops->get_stats_count(dev);
+	data = kmalloc(stats.n_stats * sizeof(u64), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	ops->get_stats(dev, &stats, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &stats, sizeof(stats)))
+		goto out;
+	useraddr += sizeof(stats);
+	if (copy_to_user(useraddr, data, stats.n_stats * sizeof(u64)))
+		goto out;
+	ret = 0;
+
+ out:
+	kfree(data);
+	return ret;
+}
+
+int dev_ethtool(struct ifreq *ifr)
+{
+	struct net_device *dev = __dev_get_by_name(ifr->ifr_name);
+	void *useraddr = (void *) ifr->ifr_data;
+	u32 ethcmd;
+
+	/* XXX: We can make this more finegrained now.  Keep existing
+	 * behaviour for the moment.
+	 */
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!dev || !netif_device_present(dev))
+		return -ENODEV;
+
+	if (!dev->netdev_ops)
+		goto ioctl;
+
+	if (copy_from_user (&ethcmd, useraddr, sizeof (ethcmd)))
+		return -EFAULT;
+
+	switch (ethcmd) {
+	case ETHTOOL_GSET:
+		return ethtool_get_settings(dev, useraddr);
+	case ETHTOOL_SSET:
+		return ethtool_set_settings(dev, useraddr);
+	case ETHTOOL_GDRVINFO:
+		return ethtool_get_drvinfo(dev, useraddr);
+	case ETHTOOL_GREGS:
+		return ethtool_get_regs(dev, useraddr);
+	case ETHTOOL_GWOL:
+		return ethtool_get_wol(dev, useraddr);
+	case ETHTOOL_SWOL:
+		return ethtool_set_wol(dev, useraddr);
+	case ETHTOOL_GMSGLVL:
+		return ethtool_get_msglevel(dev, useraddr);
+	case ETHTOOL_SMSGLVL:
+		return ethtool_set_msglevel(dev, useraddr);
+	case ETHTOOL_NWAY_RST:
+		return ethtool_nway_reset(dev);
+	case ETHTOOL_GLINK:
+		return ethtool_get_link(dev, useraddr);
+	case ETHTOOL_GEEPROM:
+		return ethtool_get_eeprom(dev, useraddr);
+	case ETHTOOL_SEEPROM:
+		return ethtool_set_eeprom(dev, useraddr);
+	case ETHTOOL_GCOALESCE:
+		return ethtool_get_coalesce(dev, useraddr);
+	case ETHTOOL_SCOALESCE:
+		return ethtool_set_coalesce(dev, useraddr);
+	case ETHTOOL_GRINGPARAM:
+		return ethtool_get_ringparam(dev, useraddr);
+	case ETHTOOL_SRINGPARAM:
+		return ethtool_set_ringparam(dev, useraddr);
+	case ETHTOOL_GPAUSEPARAM:
+		return ethtool_get_pauseparam(dev, useraddr);
+	case ETHTOOL_SPAUSEPARAM:
+		return ethtool_set_pauseparam(dev, useraddr);
+	case ETHTOOL_GRXCSUM:
+		return ethtool_get_rx_csum(dev, useraddr);
+	case ETHTOOL_SRXCSUM:
+		return ethtool_set_rx_csum(dev, useraddr);
+	case ETHTOOL_GTXCSUM:
+		return ethtool_get_tx_csum(dev, useraddr);
+	case ETHTOOL_STXCSUM:
+		return ethtool_set_tx_csum(dev, useraddr);
+	case ETHTOOL_GSG:
+		return ethtool_get_sg(dev, useraddr);
+	case ETHTOOL_SSG:
+		return ethtool_set_sg(dev, useraddr);
+	case ETHTOOL_TEST:
+		return ethtool_self_test(dev, useraddr);
+	case ETHTOOL_GSTRINGS:
+		return ethtool_get_strings(dev, useraddr);
+	case ETHTOOL_PHYS_ID:
+		return ethtool_phys_id(dev, useraddr);
+	case ETHTOOL_GSTATS:
+		return ethtool_get_stats(dev, useraddr);
+	default:
+		return -EOPNOTSUPP;
+	}
+
+ ioctl:
+	if (dev->do_ioctl)
+		return dev->do_ioctl(dev, ifr, SIOCETHTOOL);
+	return -EOPNOTSUPP;
+}
+
Index: drivers/net/tg3.c
===================================================================
RCS file: /var/cvs/linux-2.5/drivers/net/tg3.c,v
retrieving revision 1.16
diff -u -p -r1.16 tg3.c
--- drivers/net/tg3.c	14 Jun 2003 22:15:21 -0000	1.16
+++ drivers/net/tg3.c	9 Jul 2003 14:33:19 -0000
@@ -5036,16 +5036,20 @@ static void tg3_set_rx_mode(struct net_d
 
 #define TG3_REGDUMP_LEN		(32 * 1024)
 
-static u8 *tg3_get_regs(struct tg3 *tp)
+static int tg3_get_regs_len(struct net_device *dev)
 {
-	u8 *orig_p = kmalloc(TG3_REGDUMP_LEN, GFP_KERNEL);
-	u8 *p;
+	return TG3_REGDUMP_LEN;
+}
+
+static void tg3_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
+{
+	struct tg3 *tp = dev->priv;
+	u8 *orig_p = p;
 	int i;
 
-	if (orig_p == NULL)
-		return NULL;
+	regs->version = 0;
 
-	memset(orig_p, 0, TG3_REGDUMP_LEN);
+	memset(p, 0, TG3_REGDUMP_LEN);
 
 	spin_lock_irq(&tp->lock);
 	spin_lock(&tp->tx_lock);
@@ -5099,390 +5103,287 @@ do {	p = orig_p + (reg);	\
 
 	spin_unlock(&tp->tx_lock);
 	spin_unlock_irq(&tp->lock);
-
-	return orig_p;
 }
 
-static int tg3_ethtool_ioctl (struct net_device *dev, void *useraddr)
+static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tg3 *tp = dev->priv;
-	struct pci_dev *pci_dev = tp->pdev;
-	u32 ethcmd;
 
-	if (copy_from_user (&ethcmd, useraddr, sizeof (ethcmd)))
-		return -EFAULT;
-
-	switch (ethcmd) {
-	case ETHTOOL_GDRVINFO:{
-		struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
-		strcpy (info.driver, DRV_MODULE_NAME);
-		strcpy (info.version, DRV_MODULE_VERSION);
-		memset(&info.fw_version, 0, sizeof(info.fw_version));
-		strcpy (info.bus_info, pci_dev->slot_name);
-		info.eedump_len = 0;
-		info.regdump_len = TG3_REGDUMP_LEN;
-		if (copy_to_user (useraddr, &info, sizeof (info)))
-			return -EFAULT;
-		return 0;
-	}
+	if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
+					tp->link_config.phy_is_low_power)
+		return -EAGAIN;
+
+	cmd->supported = (SUPPORTED_Autoneg);
+
+	if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY))
+		cmd->supported |= (SUPPORTED_1000baseT_Half |
+				   SUPPORTED_1000baseT_Full);
+
+	if (tp->phy_id != PHY_ID_SERDES)
+		cmd->supported |= (SUPPORTED_100baseT_Half |
+				  SUPPORTED_100baseT_Full |
+				  SUPPORTED_10baseT_Half |
+				  SUPPORTED_10baseT_Full |
+				  SUPPORTED_MII);
+	else
+		cmd->supported |= SUPPORTED_FIBRE;
 
-	case ETHTOOL_GSET: {
-		struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	cmd->advertising = tp->link_config.advertising;
+	cmd->speed = tp->link_config.active_speed;
+	cmd->duplex = tp->link_config.active_duplex;
+	cmd->port = 0;
+	cmd->phy_address = PHY_ADDR;
+	cmd->transceiver = 0;
+	cmd->autoneg = tp->link_config.autoneg;
+	cmd->maxtxpkt = 0;
+	cmd->maxrxpkt = 0;
+	return 0;
+}
 
-		if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
-		    tp->link_config.phy_is_low_power)
-			return -EAGAIN;
-		cmd.supported = (SUPPORTED_Autoneg);
-
-		if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY))
-			cmd.supported |= (SUPPORTED_1000baseT_Half |
-					  SUPPORTED_1000baseT_Full);
-
-		if (tp->phy_id != PHY_ID_SERDES)
-			cmd.supported |= (SUPPORTED_100baseT_Half |
-					  SUPPORTED_100baseT_Full |
-					  SUPPORTED_10baseT_Half |
-					  SUPPORTED_10baseT_Full |
-					  SUPPORTED_MII);
-		else
-			cmd.supported |= SUPPORTED_FIBRE;
+static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tg3 *tp = dev->priv;
 
-		cmd.advertising = tp->link_config.advertising;
-		cmd.speed = tp->link_config.active_speed;
-		cmd.duplex = tp->link_config.active_duplex;
-		cmd.port = 0;
-		cmd.phy_address = PHY_ADDR;
-		cmd.transceiver = 0;
-		cmd.autoneg = tp->link_config.autoneg;
-		cmd.maxtxpkt = 0;
-		cmd.maxrxpkt = 0;
-		if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
-			return -EFAULT;
-		return 0;
+	if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
+					tp->link_config.phy_is_low_power)
+		return -EAGAIN;
+
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		tp->link_config.advertising = cmd->advertising;
+		tp->link_config.speed = SPEED_INVALID;
+		tp->link_config.duplex = DUPLEX_INVALID;
+	} else {
+		tp->link_config.speed = cmd->speed;
+		tp->link_config.duplex = cmd->duplex;
 	}
-	case ETHTOOL_SSET: {
-		struct ethtool_cmd cmd;
 
-		if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
-		    tp->link_config.phy_is_low_power)
-			return -EAGAIN;
-
-		if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
-			return -EFAULT;
-
-		/* Fiber PHY only supports 1000 full/half */
-		if (cmd.autoneg == AUTONEG_ENABLE) {
-			if (tp->phy_id == PHY_ID_SERDES &&
-			    (cmd.advertising &
-			     (ADVERTISED_10baseT_Half |
-			      ADVERTISED_10baseT_Full |
-			      ADVERTISED_100baseT_Half |
-			      ADVERTISED_100baseT_Full)))
-				return -EINVAL;
-			if ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) &&
-			    (cmd.advertising &
-			     (ADVERTISED_1000baseT_Half |
-			      ADVERTISED_1000baseT_Full)))
-				return -EINVAL;
-		} else {
-			if (tp->phy_id == PHY_ID_SERDES &&
-			    (cmd.speed == SPEED_10 ||
-			     cmd.speed == SPEED_100))
-				return -EINVAL;
-			if ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) &&
-			    (cmd.speed == SPEED_10 ||
-			     cmd.speed == SPEED_100))
-				return -EINVAL;
-		}
-
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
-
-		tp->link_config.autoneg = cmd.autoneg;
-		if (cmd.autoneg == AUTONEG_ENABLE) {
-			tp->link_config.advertising = cmd.advertising;
-			tp->link_config.speed = SPEED_INVALID;
-			tp->link_config.duplex = DUPLEX_INVALID;
-		} else {
-			tp->link_config.speed = cmd.speed;
-			tp->link_config.duplex = cmd.duplex;
-		}
+	tg3_setup_phy(tp);
+	spin_unlock(&tp->tx_lock);
+	spin_unlock_irq(&tp->lock);
 
-		tg3_setup_phy(tp);
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
+	return 0;
+}
 
-		return 0;
-	}
+static void tg3_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	struct tg3 *tp = dev->priv;
 
-	case ETHTOOL_GREGS: {
-		struct ethtool_regs regs;
-		u8 *regbuf;
-		int ret;
-
-		if (copy_from_user(&regs, useraddr, sizeof(regs)))
-			return -EFAULT;
-		if (regs.len > TG3_REGDUMP_LEN)
-			regs.len = TG3_REGDUMP_LEN;
-		regs.version = 0;
-		if (copy_to_user(useraddr, &regs, sizeof(regs)))
-			return -EFAULT;
-
-		regbuf = tg3_get_regs(tp);
-		if (!regbuf)
-			return -ENOMEM;
-
-		useraddr += offsetof(struct ethtool_regs, data);
-		ret = 0;
-		if (copy_to_user(useraddr, regbuf, regs.len))
-			ret = -EFAULT;
-		kfree(regbuf);
-		return ret;
-	}
-	case ETHTOOL_GWOL: {
-		struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
-
-		wol.supported = WAKE_MAGIC;
-		wol.wolopts = 0;
-		if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)
-			wol.wolopts = WAKE_MAGIC;
-		memset(&wol.sopass, 0, sizeof(wol.sopass));
-		if (copy_to_user(useraddr, &wol, sizeof(wol)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SWOL: {
-		struct ethtool_wolinfo wol;
+	strcpy(info->driver, DRV_MODULE_NAME);
+	strcpy(info->version, DRV_MODULE_VERSION);
+	strcpy(info->bus_info, pci_name(tp->pdev));
+}
 
-		if (copy_from_user(&wol, useraddr, sizeof(wol)))
-			return -EFAULT;
-		if (wol.wolopts & ~WAKE_MAGIC)
-			return -EINVAL;
-		if ((wol.wolopts & WAKE_MAGIC) &&
-		    tp->phy_id == PHY_ID_SERDES &&
-		    !(tp->tg3_flags & TG3_FLAG_SERDES_WOL_CAP))
-			return -EINVAL;
+static void tg3_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct tg3 *tp = dev->priv;
 
-		spin_lock_irq(&tp->lock);
-		if (wol.wolopts & WAKE_MAGIC)
-			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
-		else
-			tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
-		spin_unlock_irq(&tp->lock);
+	wol->supported = WAKE_MAGIC;
+	wol->wolopts = 0;
+	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)
+		wol->wolopts = WAKE_MAGIC;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
 
-		return 0;
-	}
-	case ETHTOOL_GMSGLVL: {
-		struct ethtool_value edata = { ETHTOOL_GMSGLVL };
-		edata.data = tp->msg_enable;
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SMSGLVL: {
-		struct ethtool_value edata;
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
-		tp->msg_enable = edata.data;
-		return 0;
-	}
-	case ETHTOOL_NWAY_RST: {
-		u32 bmcr;
-		int r;
+static int tg3_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct tg3 *tp = dev->priv;
 
-		spin_lock_irq(&tp->lock);
-		tg3_readphy(tp, MII_BMCR, &bmcr);
-		tg3_readphy(tp, MII_BMCR, &bmcr);
-		r = -EINVAL;
-		if (bmcr & BMCR_ANENABLE) {
-			tg3_writephy(tp, MII_BMCR,
-				     bmcr | BMCR_ANRESTART);
-			r = 0;
-		}
-		spin_unlock_irq(&tp->lock);
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EINVAL;
+	if ((wol->wolopts & WAKE_MAGIC) &&
+	    tp->phy_id == PHY_ID_SERDES &&
+	    !(tp->tg3_flags & TG3_FLAG_SERDES_WOL_CAP))
+		return -EINVAL;
 
-		return r;
-	}
-	case ETHTOOL_GLINK: {
-		struct ethtool_value edata = { ETHTOOL_GLINK };
-		edata.data = netif_carrier_ok(tp->dev) ? 1 : 0;
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_GRINGPARAM: {
-		struct ethtool_ringparam ering = { ETHTOOL_GRINGPARAM };
+	spin_lock_irq(&tp->lock);
+	if (wol->wolopts & WAKE_MAGIC)
+		tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+	else
+		tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
+	spin_unlock_irq(&tp->lock);
 
-		ering.rx_max_pending = TG3_RX_RING_SIZE - 1;
-		ering.rx_mini_max_pending = 0;
-		ering.rx_jumbo_max_pending = TG3_RX_JUMBO_RING_SIZE - 1;
-
-		ering.rx_pending = tp->rx_pending;
-		ering.rx_mini_pending = 0;
-		ering.rx_jumbo_pending = tp->rx_jumbo_pending;
-		ering.tx_pending = tp->tx_pending;
+	return 0;
+}
 
-		if (copy_to_user(useraddr, &ering, sizeof(ering)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SRINGPARAM: {
-		struct ethtool_ringparam ering;
+static u32 tg3_get_msglevel(struct net_device *dev)
+{
+	struct tg3 *tp = dev->priv;
+	return tp->msg_enable;
+}
 
-		if (copy_from_user(&ering, useraddr, sizeof(ering)))
-			return -EFAULT;
+static void tg3_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct tg3 *tp = dev->priv;
+	tp->msg_enable = value;
+}
 
-		if ((ering.rx_pending > TG3_RX_RING_SIZE - 1) ||
-		    (ering.rx_jumbo_pending > TG3_RX_JUMBO_RING_SIZE - 1) ||
-		    (ering.tx_pending > TG3_TX_RING_SIZE - 1))
-			return -EINVAL;
+static int tg3_nway_reset(struct net_device *dev)
+{
+	struct tg3 *tp = dev->priv;
+	u32 bmcr;
+	int r;
 
-		tg3_netif_stop(tp);
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
+	spin_lock_irq(&tp->lock);
+	tg3_readphy(tp, MII_BMCR, &bmcr);
+	tg3_readphy(tp, MII_BMCR, &bmcr);
+	r = -EINVAL;
+	if (bmcr & BMCR_ANENABLE) {
+		tg3_writephy(tp, MII_BMCR, bmcr | BMCR_ANRESTART);
+		r = 0;
+	}
+	spin_unlock_irq(&tp->lock);
 
-		tp->rx_pending = ering.rx_pending;
-		tp->rx_jumbo_pending = ering.rx_jumbo_pending;
-		tp->tx_pending = ering.tx_pending;
-
-		tg3_halt(tp);
-		tg3_init_rings(tp);
-		tg3_init_hw(tp);
-		netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
-		tg3_netif_start(tp);
+	return r;
+}
 
-		return 0;
-	}
-	case ETHTOOL_GPAUSEPARAM: {
-		struct ethtool_pauseparam epause = { ETHTOOL_GPAUSEPARAM };
+static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
+{
+	struct tg3 *tp = dev->priv;
 
-		epause.autoneg =
-			(tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) != 0;
-		epause.rx_pause =
-			(tp->tg3_flags & TG3_FLAG_PAUSE_RX) != 0;
-		epause.tx_pause =
-			(tp->tg3_flags & TG3_FLAG_PAUSE_TX) != 0;
-		if (copy_to_user(useraddr, &epause, sizeof(epause)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SPAUSEPARAM: {
-		struct ethtool_pauseparam epause;
+	ering->rx_max_pending = TG3_RX_RING_SIZE - 1;
+	ering->rx_mini_max_pending = 0;
+	ering->rx_jumbo_max_pending = TG3_RX_JUMBO_RING_SIZE - 1;
+
+	ering->rx_pending = tp->rx_pending;
+	ering->rx_mini_pending = 0;
+	ering->rx_jumbo_pending = tp->rx_jumbo_pending;
+	ering->tx_pending = tp->tx_pending;
+}
 
-		if (copy_from_user(&epause, useraddr, sizeof(epause)))
-			return -EFAULT;
+static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
+{
+	struct tg3 *tp = dev->priv;
 
-		tg3_netif_stop(tp);
-		spin_lock_irq(&tp->lock);
-		spin_lock(&tp->tx_lock);
-		if (epause.autoneg)
-			tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
-		else
-			tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
-		if (epause.rx_pause)
-			tp->tg3_flags |= TG3_FLAG_PAUSE_RX;
-		else
-			tp->tg3_flags &= ~TG3_FLAG_PAUSE_RX;
-		if (epause.tx_pause)
-			tp->tg3_flags |= TG3_FLAG_PAUSE_TX;
-		else
-			tp->tg3_flags &= ~TG3_FLAG_PAUSE_TX;
-		tg3_halt(tp);
-		tg3_init_rings(tp);
-		tg3_init_hw(tp);
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irq(&tp->lock);
-		tg3_netif_start(tp);
+	if ((ering->rx_pending > TG3_RX_RING_SIZE - 1) ||
+	    (ering->rx_jumbo_pending > TG3_RX_JUMBO_RING_SIZE - 1) ||
+	    (ering->tx_pending > TG3_TX_RING_SIZE - 1))
+		return -EINVAL;
 
-		return 0;
-	}
-	case ETHTOOL_GRXCSUM: {
-		struct ethtool_value edata = { ETHTOOL_GRXCSUM };
+	tg3_netif_stop(tp);
+	spin_lock_irq(&tp->lock);
+	spin_lock(&tp->tx_lock);
 
-		edata.data =
-			(tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) != 0;
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SRXCSUM: {
-		struct ethtool_value edata;
+	tp->rx_pending = ering->rx_pending;
+	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
+	tp->tx_pending = ering->tx_pending;
+
+	tg3_halt(tp);
+	tg3_init_rings(tp);
+	tg3_init_hw(tp);
+	netif_wake_queue(tp->dev);
+	spin_unlock(&tp->tx_lock);
+	spin_unlock_irq(&tp->lock);
+	tg3_netif_start(tp);
 
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
+	return 0;
+}
 
-		if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
-			if (edata.data != 0)
-				return -EINVAL;
-			return 0;
-		}
+static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
+{
+	struct tg3 *tp = dev->priv;
 
-		spin_lock_irq(&tp->lock);
-		if (edata.data)
-			tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
-		else
-			tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
-		spin_unlock_irq(&tp->lock);
+	epause->autoneg = (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) != 0;
+	epause->rx_pause = (tp->tg3_flags & TG3_FLAG_PAUSE_RX) != 0;
+	epause->tx_pause = (tp->tg3_flags & TG3_FLAG_PAUSE_TX) != 0;
+}
 
-		return 0;
-	}
-	case ETHTOOL_GTXCSUM: {
-		struct ethtool_value edata = { ETHTOOL_GTXCSUM };
+static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
+{
+	struct tg3 *tp = dev->priv;
 
-		edata.data =
-			(tp->dev->features & NETIF_F_IP_CSUM) != 0;
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_STXCSUM: {
-		struct ethtool_value edata;
+	tg3_netif_stop(tp);
+	spin_lock_irq(&tp->lock);
+	spin_lock(&tp->tx_lock);
+	if (epause->autoneg)
+		tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+	else
+		tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
+	if (epause->rx_pause)
+		tp->tg3_flags |= TG3_FLAG_PAUSE_RX;
+	else
+		tp->tg3_flags &= ~TG3_FLAG_PAUSE_RX;
+	if (epause->tx_pause)
+		tp->tg3_flags |= TG3_FLAG_PAUSE_TX;
+	else
+		tp->tg3_flags &= ~TG3_FLAG_PAUSE_TX;
+	tg3_halt(tp);
+	tg3_init_rings(tp);
+	tg3_init_hw(tp);
+	spin_unlock(&tp->tx_lock);
+	spin_unlock_irq(&tp->lock);
+	tg3_netif_start(tp);
 
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
+	return 0;
+}
 
-		if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
-			if (edata.data != 0)
-				return -EINVAL;
-			return 0;
-		}
+static u32 tg3_get_rx_csum(struct net_device *dev)
+{
+	struct tg3 *tp = dev->priv;
+	return (tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) != 0;
+}
 
-		if (edata.data)
-			tp->dev->features |= NETIF_F_IP_CSUM;
-		else
-			tp->dev->features &= ~NETIF_F_IP_CSUM;
+static int tg3_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct tg3 *tp = dev->priv;
 
+	if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
+		if (data != 0)
+			return -EINVAL;
 		return 0;
 	}
-	case ETHTOOL_GSG: {
-		struct ethtool_value edata = { ETHTOOL_GSG };
 
-		edata.data =
-			(tp->dev->features & NETIF_F_SG) != 0;
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	case ETHTOOL_SSG: {
-		struct ethtool_value edata;
+	spin_lock_irq(&tp->lock);
+	if (data)
+		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
+	else
+		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
+	spin_unlock_irq(&tp->lock);
 
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
+	return 0;
+}
 
-		if (edata.data)
-			tp->dev->features |= NETIF_F_SG;
-		else
-			tp->dev->features &= ~NETIF_F_SG;
+static int tg3_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct tg3 *tp = dev->priv;
 
+	if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
+		if (data != 0)
+			return -EINVAL;
 		return 0;
 	}
-	};
 
-	return -EOPNOTSUPP;
+	if (data)
+		dev->features |= NETIF_F_IP_CSUM;
+	else
+		dev->features &= ~NETIF_F_IP_CSUM;
+
+	return 0;
 }
 
+static struct netdev_ops tg3_netdev_ops = {
+	.get_settings	= tg3_get_settings,
+	.set_settings	= tg3_set_settings,
+	.get_drvinfo	= tg3_get_drvinfo,
+	.get_regs_len	= tg3_get_regs_len,
+	.get_regs	= tg3_get_regs,
+	.get_wol	= tg3_get_wol,
+	.set_wol	= tg3_set_wol,
+	.get_msglevel	= tg3_get_msglevel,
+	.set_msglevel	= tg3_set_msglevel,
+	.nway_reset	= tg3_nway_reset,
+	.get_link	= netdev_op_get_link,
+	.get_ringparam	= tg3_get_ringparam,
+	.set_ringparam	= tg3_set_ringparam,
+	.get_pauseparam	= tg3_get_pauseparam,
+	.set_pauseparam	= tg3_set_pauseparam,
+	.get_rx_csum	= tg3_get_rx_csum,
+	.set_rx_csum	= tg3_set_rx_csum,
+	.get_tx_csum	= netdev_op_get_tx_csum,
+	.set_tx_csum	= tg3_set_tx_csum,
+	.get_sg		= netdev_op_get_sg,
+	.set_sg		= netdev_op_set_sg,
+};
+
 static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&ifr->ifr_data;
@@ -5490,8 +5391,6 @@ static int tg3_ioctl(struct net_device *
 	int err;
 
 	switch(cmd) {
-	case SIOCETHTOOL:
-		return tg3_ethtool_ioctl(dev, (void *) ifr->ifr_data);
 	case SIOCGMIIPHY:
 		data->phy_id = PHY_ADDR;
 
@@ -6773,6 +6672,7 @@ static int __devinit tg3_init_one(struct
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
 
+	dev->netdev_ops = &tg3_netdev_ops;
 	dev->open = tg3_open;
 	dev->stop = tg3_close;
 	dev->get_stats = tg3_get_stats;

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
