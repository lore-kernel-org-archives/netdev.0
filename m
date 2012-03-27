From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [RFC PATCH 1/2] net: ethtool: Add capability to retrieve plug-in
 module EEPROM
Date: Tue, 27 Mar 2012 18:51:06 +0100
Message-ID: <4F71FE0A.3060203@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	<bruce.w.allan@intel.com>, <mirq-linux@rere.qmqm.pl>,
	<decot@google.com>, <amit.salecha@qlogic.com>,
	<alexander.h.duyck@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12693 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754587Ab2C0RvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 13:51:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added extensions to the ethtool API to obtain plugin module eeprom data
This is useful for end users to be able to determine what the capabilities
of the in use module are.

The first provides a new struct ethtool_modinfo that will return the
type and size of plug-in module eeprom (such as SFP+) for parsing
by userland program.

The second provides the API to get the raw eeprom information
using the existing ethtool_eeprom structture to return the data

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
---
  include/linux/ethtool.h |   20 ++++++++++++
  net/core/ethtool.c      |   79 
+++++++++++++++++++++++++++++++++++++++++++++++
  2 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index da5b2de..50eaf35 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -117,6 +117,14 @@ struct ethtool_eeprom {
      __u8    data[0];
  };

+/* for passing plug-in module information */
+struct ethtool_modinfo {
+    __u32   cmd;
+    __u32   type;
+    __u32   eeprom_len;
+    __u32   reserved[8];
+};
+
  /**
   * struct ethtool_coalesce - coalescing parameters for IRQs and stats 
updates
   * @cmd: ETHTOOL_{G,S}COALESCE
@@ -936,6 +944,10 @@ struct ethtool_ops {
      int    (*get_dump_data)(struct net_device *,
                   struct ethtool_dump *, void *);
      int    (*set_dump)(struct net_device *, struct ethtool_dump *);
+    int    (*get_module_info)(struct net_device *,
+                   struct ethtool_modinfo *);
+    int    (*get_module_eeprom)(struct net_device *,
+                     struct ethtool_eeprom *, u8 *);

  };
  #endif /* __KERNEL__ */
@@ -1010,6 +1022,8 @@ struct ethtool_ops {
  #define ETHTOOL_SET_DUMP    0x0000003e /* Set dump settings */
  #define ETHTOOL_GET_DUMP_FLAG    0x0000003f /* Get dump settings */
  #define ETHTOOL_GET_DUMP_DATA    0x00000040 /* Get dump data */
+#define ETHTOOL_GMODULEINFO    0x00000041 /* Get plug-in module 
information */
+#define ETHTOOL_GMODULEEEPROM    0x00000042 /* Get plug-in module eeprom */

  /* compatibility with older code */
  #define SPARC_ETH_GSET        ETHTOOL_GSET
@@ -1159,6 +1173,12 @@ struct ethtool_ops {
  #define RX_CLS_LOC_FIRST    0xfffffffe
  #define RX_CLS_LOC_LAST        0xfffffffd

+/* EEPROM Standards for plug in modules */
+#define SFF_8079        0x1
+#define SFF_8079_LEN        256
+#define SFF_8472        0x2
+#define SFF_8472_LEN        512
+
  /* Reset flags */
  /* The reset() operation must clear the flags for the components which
   * were actually reset.  On successful return, the flags indicate the
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 3f79db1..1e86bd9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1276,6 +1276,79 @@ out:
      return ret;
  }

+static int ethtool_get_module_info(struct net_device *dev,
+        void __user *useraddr)
+{
+    int ret;
+    struct ethtool_modinfo modinfo;
+    const struct ethtool_ops *ops = dev->ethtool_ops;
+
+    if (!ops->get_module_info)
+        return -EOPNOTSUPP;
+
+    if (copy_from_user(&modinfo, useraddr, sizeof(modinfo)))
+        return -EFAULT;
+
+    ret = ops->get_module_info(dev, &modinfo);
+    if (ret)
+        return ret;
+
+    if (copy_to_user(useraddr, &modinfo, sizeof(modinfo)))
+        return -EFAULT;
+
+    return 0;
+}
+
+static int ethtool_get_module_eeprom(struct net_device *dev,
+        void __user *useraddr)
+{
+    int ret;
+    struct ethtool_eeprom eeprom;
+    struct ethtool_modinfo modinfo;
+    const struct ethtool_ops *ops = dev->ethtool_ops;
+    void __user *userbuf = useraddr + sizeof(eeprom);
+    u8 *data;
+
+    if (!ops->get_module_info || !ops->get_module_eeprom)
+        return -EOPNOTSUPP;
+
+    if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
+        return -EFAULT;
+
+    /* Check for wrap and zero */
+    if (eeprom.offset + eeprom.len <= eeprom.offset)
+        return -EINVAL;
+
+    /* Get the modinfo to get the length */
+    ret = ops->get_module_info(dev, &modinfo);
+    if (ret)
+        return ret;
+
+    if (eeprom.offset + eeprom.len > modinfo.eeprom_len)
+        return -EINVAL;
+
+    data = kmalloc(PAGE_SIZE, GFP_USER);
+    if (!data)
+        return -ENOMEM;
+
+    ret = ops->get_module_eeprom(dev, &eeprom, data);
+    if (ret)
+        goto out;
+
+
+    if (copy_to_user(userbuf, data, eeprom.len)) {
+        ret = -EFAULT;
+        goto out;
+    }
+
+    if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
+        ret = -EFAULT;
+
+out:
+    kfree(data);
+    return ret;
+}
+
  /* The main entry point in this file.  Called from net/core/dev.c */

  int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1494,6 +1567,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
      case ETHTOOL_GET_DUMP_DATA:
          rc = ethtool_get_dump_data(dev, useraddr);
          break;
+    case ETHTOOL_GMODULEINFO:
+        rc = ethtool_get_module_info(dev, useraddr);
+        break;
+    case ETHTOOL_GMODULEEEPROM:
+        rc = ethtool_get_module_eeprom(dev, useraddr);
+        break;
      default:
          rc = -EOPNOTSUPP;
      }
-- 
1.7.7.6
