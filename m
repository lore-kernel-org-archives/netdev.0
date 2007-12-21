From: "Michael Chan" <mchan@broadcom.com>
Subject: [ETH]: Combine format_addr() with print_mac().
Date: Fri, 21 Dec 2007 14:05:38 -0800
Message-ID: <1198274738.5578.2.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anilgv@broadcom.com, joe@perches.com,
	michaelc@cs.wisc.edu, david.somayajulu@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3938 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753275AbXLUVU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 16:20:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ETH]: Combine format_addr() with print_mac().

print_mac() used by most net drivers and format_addr() used by
net-sysfs.c are very similar and they can be integrated.

format_addr() is also identically redefined in the qla4xxx iscsi
driver.

Export a new function format_mac_addr() to be used by net-sysfs,
qla4xxx and others in the future.  Both print_mac() and
format_mac_addr() call _format_mac_addr() to do the formatting.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Joe Perches <joe@perches.com>
Cc: Mike Christie <michaelc@cs.wisc.edu>
Cc: David Somayajulu <david.somayajulu@qlogic.com>

diff --git a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
index 89460d2..0f4562b 100644
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
+		len = format_mac_addr(buf, ha->my_mac, MAC_ADDR_LEN);
 		break;
 	case ISCSI_HOST_PARAM_IPADDRESS:
 		len = sprintf(buf, "%d.%d.%d.%d\n", ha->ip_address[0],
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index cc002cb..d20512c 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -124,10 +124,11 @@ int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 extern struct ctl_table ether_table[];
 #endif
 
+extern ssize_t format_mac_addr(char *buf, const unsigned char *addr, int len);
+
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 extern char *print_mac(char *buf, const u8 *addr);
 #define DECLARE_MAC_BUF(var) char var[18] __maybe_unused
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index e41f4b9..e72993b 100644
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
+		ret = format_mac_addr(buf, net->dev_addr, net->addr_len);
 	read_unlock(&dev_base_lock);
 	return ret;
 }
@@ -124,7 +113,7 @@ static ssize_t show_broadcast(struct device *dev,
 {
 	struct net_device *net = to_net_dev(dev);
 	if (dev_isalive(net))
-		return format_addr(buf, net->broadcast, net->addr_len);
+		return format_mac_addr(buf, net->broadcast, net->addr_len);
 	return -EINVAL;
 }
 
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 6b2e454..f760d41 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -359,10 +359,33 @@ struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count)
 }
 EXPORT_SYMBOL(alloc_etherdev_mq);
 
+static ssize_t _format_mac_addr(char *buf, const unsigned char *addr, int len)
+{
+	int i;
+	char *cp = buf;
+
+	for (i = 0; i < len; i++) {
+		cp += sprintf(cp, "%02x", addr[i]);
+		if (i == len - 1)
+			break;
+		*cp++ = ':';
+	}
+	return cp - buf;
+}
+
+ssize_t format_mac_addr(char *buf, const unsigned char *addr, int len)
+{
+	ssize_t l;
+
+	l = _format_mac_addr(buf, addr, len);
+	strcpy(buf + l, "\n");
+	return l + 1;
+}
+EXPORT_SYMBOL(format_mac_addr);
+
 char *print_mac(char *buf, const u8 *addr)
 {
-	sprintf(buf, MAC_FMT,
-		addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+	_format_mac_addr(buf, addr, ETH_ALEN);
 	return buf;
 }
 EXPORT_SYMBOL(print_mac);


