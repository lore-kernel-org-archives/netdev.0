From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH 2.6] ethtool_ops eeprom stuff
Date: Sun, 12 Oct 2003 04:30:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310120421590.9314-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Feldman, Scott" <scott.feldman@intel.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, <matthew@wil.cx>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Finally got around to adding ethtool_ops to e100-3.0.x.  I found a bug 
with get_eeprom() and it seems to work best if we add get_eeprom_len() to 
the ops list.  Also moved check for offest + len < size into ethtool.c.

I was able to test [GS]EEPROM, PHYS_ID, GSTATS, GSTRINGS, and TEST, and 
everything looks good.

Should I send same for 2.4?

-------------

--- linux-2.6.0-test7/net/core/ethtool.c.orig	2003-10-08 12:24:02.000000000 -0700
+++ linux-2.6.0-test7/net/core/ethtool.c	2003-10-12 04:18:38.000000000 -0700
@@ -122,7 +122,8 @@
 		info.n_stats = ops->get_stats_count(dev);
 	if (ops->get_regs_len)
 		info.regdump_len = ops->get_regs_len(dev);
-	/* XXX: eeprom? */
+	if (ops->get_eeprom_len)
+		info.eedump_len = ops->get_eeprom_len(dev);
 
 	if (copy_to_user(useraddr, &info, sizeof(info)))
 		return -EFAULT;
@@ -245,29 +246,34 @@
 static int ethtool_get_eeprom(struct net_device *dev, void *useraddr)
 {
 	struct ethtool_eeprom eeprom;
+	struct ethtool_ops *ops = dev->ethtool_ops;
 	u8 *data;
-	int len, ret;
+	int ret;
 
-	if (!dev->ethtool_ops->get_eeprom)
+	if (!ops->get_eeprom || !ops->get_eeprom_len)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
 		return -EFAULT;
 
-	len = eeprom.len;
 	/* Check for wrap and zero */
-	if (eeprom.offset + len <= eeprom.offset)
+	if (eeprom.offset + eeprom.len <= eeprom.offset)
+		return -EINVAL;
+
+	/* Check for exceeding total eeprom len */
+	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
 		return -EINVAL;
 
-	data = kmalloc(len, GFP_USER);
+	data = kmalloc(eeprom.len, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
-	if (copy_from_user(data, useraddr + sizeof(eeprom), len))
-		return -EFAULT;
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
+		goto out;
 
-	ret = dev->ethtool_ops->get_eeprom(dev, &eeprom, data);
-	if (!ret)
+	ret = ops->get_eeprom(dev, &eeprom, data);
+	if (ret)
 		goto out;
 
 	ret = -EFAULT;
@@ -285,32 +291,37 @@
 static int ethtool_set_eeprom(struct net_device *dev, void *useraddr)
 {
 	struct ethtool_eeprom eeprom;
+	struct ethtool_ops *ops = dev->ethtool_ops;
 	u8 *data;
-	int len, ret;
+	int ret;
 
-	if (!dev->ethtool_ops->set_eeprom)
+	if (!ops->set_eeprom || !ops->get_eeprom_len)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
 		return -EFAULT;
 
-	len = eeprom.len;
 	/* Check for wrap and zero */
-	if (eeprom.offset + len <= eeprom.offset)
+	if (eeprom.offset + eeprom.len <= eeprom.offset)
+		return -EINVAL;
+
+	/* Check for exceeding total eeprom len */
+	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
 		return -EINVAL;
 
-	data = kmalloc(len, GFP_USER);
+	data = kmalloc(eeprom.len, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
-	if (copy_from_user(data, useraddr + sizeof(eeprom), len))
-		return -EFAULT;
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
+		goto out;
 
-	ret = dev->ethtool_ops->set_eeprom(dev, &eeprom, data);
+	ret = ops->set_eeprom(dev, &eeprom, data);
 	if (ret)
 		goto out;
 
-	if (copy_to_user(useraddr + sizeof(eeprom), data, len))
+	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
 		ret = -EFAULT;
 
  out:
--- linux-2.6.0-test7/include/linux/ethtool.h.orig	2003-10-08 12:24:03.000000000 -0700
+++ linux-2.6.0-test7/include/linux/ethtool.h	2003-10-12 04:18:20.000000000 -0700
@@ -307,14 +307,14 @@
  *
  * get_eeprom:
  *	Should fill in the magic field.  Don't need to check len for zero
- *	or wraparound but must check offset + len < size.  Fill in the data
- *	argument with the eeprom values from offset to offset + len.  Update
- *	len to the amount read.  Returns an error or zero.
+ *	or wraparound.  Fill in the data argument with the eeprom values
+ *	from offset to offset + len.  Update len to the amount read.
+ *	Returns an error or zero.
  *
  * set_eeprom:
  *	Should validate the magic field.  Don't need to check len for zero
- *	or wraparound but must check offset + len < size.  Update len to
- *	the amount written.  Returns an error or zero.
+ *	or wraparound.  Update len to the amount written.  Returns an error
+ *	or zero.
  */
 struct ethtool_ops {
 	int	(*get_settings)(struct net_device *, struct ethtool_cmd *);
@@ -328,6 +328,7 @@
 	void	(*set_msglevel)(struct net_device *, u32);
 	int	(*nway_reset)(struct net_device *);
 	u32	(*get_link)(struct net_device *);
+	int	(*get_eeprom_len)(struct net_device *);
 	int	(*get_eeprom)(struct net_device *, struct ethtool_eeprom *, u8 *);
 	int	(*set_eeprom)(struct net_device *, struct ethtool_eeprom *, u8 *);
 	int	(*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
