From: Bill Moss <bmoss@CLEMSON.EDU>
Subject: airo.c patches
Date: Mon, 31 Oct 2005 15:14:46 -0500
Message-ID: <43667B36.3000200@clemson.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: breed@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Below are three patches to 
/usr/src/kernels/2.6.13-1.1532_FC4-i686/drivers/net/wireless/airo.c for 
your consideration.

Patch one. Remove 3 second delay in returning scan results. This delay 
appears to be unnecessary. Users of NetworkManager have found that this 
delay makes NetworkManager slow to connect in certain scenarios. Testing 
has shown no ill effect of removing this delay. This delay does not 
appear in other drivers such as ipw2200/ieee80211

--- airo.c_orig 2005-10-28 20:06:40.000000000 -0400
+++ airo.c      2005-10-28 20:08:16.000000000 -0400
@@ -6918,7 +6918,7 @@
       /* When we are associated again, the scan has surely finished.
        * Just in case, let's make sure enough time has elapsed since
        * we started the scan. - Javier */
-       if(ai->scan_timestamp && 
time_before(jiffies,ai->scan_timestamp+3*HZ)) {
+       if(ai->scan_timestamp && time_before(jiffies,ai->scan_timestamp)) {
               /* Important note : we don't want to block the caller
                * until results are ready for various reasons.
                * First, managing wait queues is complex and racy

Patch two. Report the channel correctly in the output from iwlist.

--- airo.c_orig 2005-10-28 20:06:40.000000000 -0400
+++ airo.c      2005-10-28 20:16:59.000000000 -0400
@@ -6846,7 +6846,7 @@
       /* Add frequency */
       iwe.cmd = SIOCGIWFREQ;
       iwe.u.freq.m = le16_to_cpu(bss->dsChannel);
-       iwe.u.freq.m = frequency_list[iwe.u.freq.m] * 100000;
+       iwe.u.freq.m = frequency_list[iwe.u.freq.m-1] * 100000;
       iwe.u.freq.e = 1;
       current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe, 
IW_EV_FREQ_LEN);

Patch three. Introduce minimal ethtool support. Report driver name and 
version. Report link (association). This code was cloned from 
ipw2200/ieee80211. Ethtool support is used by NetworkManager.

--- airo.c_orig 2005-10-28 20:06:40.000000000 -0400
+++ airo.c      2005-10-28 20:21:55.000000000 -0400
@@ -39,6 +39,7 @@
#include <asm/system.h>

#include <linux/netdevice.h>
+#include <linux/ethtool.h>
#include <linux/etherdevice.h>
#include <linux/skbuff.h>
#include <linux/if_arp.h>
@@ -46,6 +47,10 @@
#include <linux/pci.h>
#include <asm/uaccess.h>

+#define DRV_NAME        "airo"
+#define AIRO_VERSION "0.6 (Ben Reed & Javier Achirica)"
+#define DRV_VERSION     AIRO_VERSION
+
#ifdef CONFIG_PCI
static struct pci_device_id card_ids[] = {
       { 0x14b9, 1, PCI_ANY_ID, PCI_ANY_ID, },
@@ -65,7 +70,7 @@
static int airo_pci_resume(struct pci_dev *pdev);

static struct pci_driver airo_driver = {
-       .name     = "airo",
+       .name     = DRV_NAME,
       .id_table = card_ids,
       .probe    = airo_pci_probe,
       .remove   = __devexit_p(airo_pci_remove),
@@ -1069,7 +1074,7 @@
static const struct iw_handler_def     airo_handler_def;
#endif /* WIRELESS_EXT */

-static const char version[] = "airo.c 0.6 (Ben Reed & Javier Achirica)";
+static const char version[] = DRV_VERSION;

struct airo_info;

@@ -2318,6 +2323,28 @@
       return 0;
}

+static void airo_ethtool_get_drvinfo(struct net_device *dev,
+                                                struct ethtool_drvinfo 
*info)
+{
+       strcpy(info->driver, DRV_NAME);
+       strcpy(info->version, DRV_VERSION);
+}
+
+static u32 airo_ethtool_get_link(struct net_device *dev)
+{
+       struct airo_info *local = dev->priv;
+       StatusRid status_rid;
+
+       readStatusRid(local, &status_rid, 1);
+
+       return (status_rid.assocStatus == STAT_ASSOCIATED);
+}
+
+static struct ethtool_ops airo_ethtool_ops = {
+       .get_link = airo_ethtool_get_link,
+       .get_drvinfo = airo_ethtool_get_drvinfo,
+};
+
static int airo_change_mtu(struct net_device *dev, int new_mtu)
{
       if ((new_mtu < 68) || (new_mtu > 2400))
@@ -2757,6 +2784,7 @@
       dev->change_mtu = &airo_change_mtu;
       dev->open = &airo_open;
       dev->stop = &airo_close;
+       dev->ethtool_ops = &airo_ethtool_ops;
       dev->irq = irq;
       dev->base_addr = port;

-- 
Bill Moss
Professor, Mathematical Sciences
Clemson University


-- 
Bill Moss
Professor, Mathematical Sciences
Clemson University
