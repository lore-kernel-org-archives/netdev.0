From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [ETH]: Combine format_addr() with print_mac().
Date: Sun, 23 Dec 2007 16:20:35 -0800
Message-ID: <1198455635.5491.4.camel@dell>
References: <1198274738.5578.2.camel@dell>
 <1198276619.18877.42.camel@localhost> <1198295882.6752.9.camel@dell>
 <1198306965.4895.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>, anilgv@broadcom.com,
	michaelc@cs.wisc.edu, david.somayajulu@qlogic.com
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4836 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811AbXLWXfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2007 18:35:38 -0500
In-Reply-To: <1198306965.4895.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-12-21 at 23:02 -0800, Joe Perches wrote:
> On Fri, 2007-12-21 at 19:58 -0800, Michael Chan wrote:
> > > ssize_t? shouldn't it be size_t?
> > I'm just keeping the prototype unchanged as originally defined in net-
> > sysfs.c
> 
> It's painless to change the prototype.
> size_t seems more sensible.
> 

I'll change the internal function to use size_t, but the exported
function for sysfs use will be ssize_t since sysfs uses ssize_t.

Here's the revised patch:

[ETH]: Combine format_addr() with print_mac().

print_mac() used many most net drivers and format_addr() used by
net-sysfs.c are very similar and they can be intergrated.

format_addr() is also identically redefined in the qla4xxx iscsi
driver.

Export a new function sysfs_format_mac() to be used by net-sysfs,
qla4xxx and others in the future.  Both print_mac() and
sysfs_format_mac() call _format_mac_addr() to do the formatting.

Changed print_mac() to use unsigned char * to be consistent with
net_device struct's dev_addr.  Added buffer length overrun checking
as suggested by Joe Perches.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Joe Perches <joe@perches.com>
Cc: Mike Christie <michaelc@cs.wisc.edu>
Cc: David Somayajulu <david.somayajulu@qlogic.com>

diff --git a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
index 89460d2..4e9cf18 100644
--- a/drivers/scsi/qla4xxx/ql4_os.c
+++ b/drivers/scsi/qla4xxx/ql4_os.c
@@ -173,18 +173,6 @@ static void qla4xxx_conn_stop(struct iscsi_cls_conn *conn, int flag)
 		printk(KERN_ERR "iscsi: invalid stop flag %d\n", flag);
 }
 
-static ssize_t format_addr(char *buf, const unsigned char *addr, int len)
-{
-	int i;
-	char *cp = buf;
-
-	for (i = 0; i < len; i++)
-		cp += sprintf(cp, "%02x%c", addr[i],
-			      i == (len - 1) ? '\n' : ':');
-	return cp - buf;
-}
-
-
 static int qla4xxx_host_get_param(struct Scsi_Host *shost,
 				  enum iscsi_host_param param, char *buf)
 {
@@ -193,7 +181,7 @@ static int qla4xxx_host_get_param(struct Scsi_Host *shost,
 
 	switch (param) {
 	case ISCSI_HOST_PARAM_HWADDRESS:
-		len = format_addr(buf, ha->my_mac, MAC_ADDR_LEN);
+		len = sysfs_format_mac(buf, ha->my_mac, MAC_ADDR_LEN);
 		break;
 	case ISCSI_HOST_PARAM_IPADDRESS:
 		len = sprintf(buf, "%d.%d.%d.%d\n", ha->ip_address[0],
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index cc002cb..7a1e011 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -124,12 +124,14 @@ int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 extern struct ctl_table ether_table[];
 #endif
 
+extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
+
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-extern char *print_mac(char *buf, const u8 *addr);
-#define DECLARE_MAC_BUF(var) char var[18] __maybe_unused
+extern char *print_mac(char *buf, const unsigned char *addr);
+#define MAC_BUF_SIZE	18
+#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused
 
 #endif
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index e41f4b9..7635d3f 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -95,17 +95,6 @@ NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
 
 /* use same locking rules as GIFHWADDR ioctl's */
-static ssize_t format_addr(char *buf, const unsigned char *addr, int len)
-{
-	int i;
-	char *cp = buf;
-
-	for (i = 0; i < len; i++)
-		cp += sprintf(cp, "%02x%c", addr[i],
-			      i == (len - 1) ? '\n' : ':');
-	return cp - buf;
-}
-
 static ssize_t show_address(struct device *dev, struct device_attribute *attr,
 			    char *buf)
 {
@@ -114,7 +103,7 @@ static ssize_t show_address(struct device *dev, struct device_attribute *attr,
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(net))
-	    ret = format_addr(buf, net->dev_addr, net->addr_len);
+		ret = sysfs_format_mac(buf, net->dev_addr, net->addr_len);
 	read_unlock(&dev_base_lock);
 	return ret;
 }
@@ -124,7 +113,7 @@ static ssize_t show_broadcast(struct device *dev,
 {
 	struct net_device *net = to_net_dev(dev);
 	if (dev_isalive(net))
-		return format_addr(buf, net->broadcast, net->addr_len);
+		return sysfs_format_mac(buf, net->broadcast, net->addr_len);
 	return -EINVAL;
 }
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 6b2e454..a7b4175 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -359,10 +359,34 @@ struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count)
 }
 EXPORT_SYMBOL(alloc_etherdev_mq);
 
-char *print_mac(char *buf, const u8 *addr)
+static size_t _format_mac_addr(char *buf, int buflen,
+				const unsigned char *addr, int len)
 {
-	sprintf(buf, MAC_FMT,
-		addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+	int i;
+	char *cp = buf;
+
+	for (i = 0; i < len; i++) {
+		cp += scnprintf(cp, buflen - (cp - buf), "%02x", addr[i]);
+		if (i == len - 1)
+			break;
+		cp += strlcpy(cp, ":", buflen - (cp - buf));
+	}
+	return cp - buf;
+}
+
+ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
+{
+	size_t l;
+
+	l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
+	l += strlcpy(buf + l, "\n", PAGE_SIZE - l);
+	return ((ssize_t) l);
+}
+EXPORT_SYMBOL(sysfs_format_mac);
+
+char *print_mac(char *buf, const unsigned char *addr)
+{
+	_format_mac_addr(buf, MAC_BUF_SIZE, addr, ETH_ALEN);
 	return buf;
 }
 EXPORT_SYMBOL(print_mac);




