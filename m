From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: add mac_pton() for parsing MAC address
Date: Wed, 4 May 2011 09:15:51 +0300
Message-ID: <20110504061551.GA12297@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48404 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab1EDGP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 02:15:56 -0400
Received: by fxm17 with SMTP id 17so587303fxm.19
        for <netdev@vger.kernel.org>; Tue, 03 May 2011 23:15:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mac_pton() parses MAC address in form XX:XX:XX:XX:XX:XX and
only in that form.

mac_pton() doesn't dirty result until it's sure string representation is valid.

mac_pton() doesn't care about characters _after_ last octet,
it's up to caller to deal with it.

mac_pton() diverges from 0/-E return value convention.
Target usage:

	if (!mac_pton(str, whatever->mac))
		return -EINVAL;
	/* ->mac being u8 [ETH_ALEN] is filled at this point. */
	/* optionally check str[3 * ETH_ALEN - 1] for termination */


Use mac_pton() in pktgen and netconsole for start.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/netconsole.c |   18 +++------------
 include/linux/if_ether.h |    1 
 net/core/netpoll.c       |   26 -----------------------
 net/core/pktgen.c        |   53 +++++++----------------------------------------
 net/core/utils.c         |   24 +++++++++++++++++++++
 5 files changed, 38 insertions(+), 84 deletions(-)

--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -473,23 +473,13 @@ static ssize_t store_remote_mac(struct netconsole_target *nt,
 		return -EINVAL;
 	}
 
-	for (i = 0; i < ETH_ALEN - 1; i++) {
-		remote_mac[i] = simple_strtoul(p, &p, 16);
-		if (*p != ':')
-			goto invalid;
-		p++;
-	}
-	remote_mac[ETH_ALEN - 1] = simple_strtoul(p, &p, 16);
-	if (*p && (*p != '\n'))
-		goto invalid;
-
+	if (!mac_pton(buf, remote_mac))
+		return -EINVAL;
+	if (buf[3 * ETH_ALEN - 1] && buf[3 * ETH_ALEN - 1] != '\n')
+		return -EINVAL;
 	memcpy(nt->np.remote_mac, remote_mac, ETH_ALEN);
 
 	return strnlen(buf, count);
-
-invalid:
-	printk(KERN_ERR "netconsole: invalid input\n");
-	return -EINVAL;
 }
 
 /*
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -136,6 +136,7 @@ int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 extern struct ctl_table ether_table[];
 #endif
 
+int mac_pton(const char *s, u8 *mac);
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 
 #endif
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -698,32 +698,8 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 
 	if (*cur != 0) {
 		/* MAC address */
-		if ((delim = strchr(cur, ':')) == NULL)
+		if (!mac_pton(cur, np->remote_mac))
 			goto parse_failed;
-		*delim = 0;
-		np->remote_mac[0] = simple_strtol(cur, NULL, 16);
-		cur = delim + 1;
-		if ((delim = strchr(cur, ':')) == NULL)
-			goto parse_failed;
-		*delim = 0;
-		np->remote_mac[1] = simple_strtol(cur, NULL, 16);
-		cur = delim + 1;
-		if ((delim = strchr(cur, ':')) == NULL)
-			goto parse_failed;
-		*delim = 0;
-		np->remote_mac[2] = simple_strtol(cur, NULL, 16);
-		cur = delim + 1;
-		if ((delim = strchr(cur, ':')) == NULL)
-			goto parse_failed;
-		*delim = 0;
-		np->remote_mac[3] = simple_strtol(cur, NULL, 16);
-		cur = delim + 1;
-		if ((delim = strchr(cur, ':')) == NULL)
-			goto parse_failed;
-		*delim = 0;
-		np->remote_mac[4] = simple_strtol(cur, NULL, 16);
-		cur = delim + 1;
-		np->remote_mac[5] = simple_strtol(cur, NULL, 16);
 	}
 
 	netpoll_print_options(np);
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1420,11 +1420,6 @@ static ssize_t pktgen_if_write(struct file *file,
 		return count;
 	}
 	if (!strcmp(name, "dst_mac")) {
-		char *v = valstr;
-		unsigned char old_dmac[ETH_ALEN];
-		unsigned char *m = pkt_dev->dst_mac;
-		memcpy(old_dmac, pkt_dev->dst_mac, ETH_ALEN);
-
 		len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
 		if (len < 0)
 			return len;
@@ -1432,35 +1427,16 @@ static ssize_t pktgen_if_write(struct file *file,
 		memset(valstr, 0, sizeof(valstr));
 		if (copy_from_user(valstr, &user_buffer[i], len))
 			return -EFAULT;
-		i += len;
-
-		for (*m = 0; *v && m < pkt_dev->dst_mac + 6; v++) {
-			int value;
-
-			value = hex_to_bin(*v);
-			if (value >= 0)
-				*m = *m * 16 + value;
-
-			if (*v == ':') {
-				m++;
-				*m = 0;
-			}
-		}
 
+		if (!mac_pton(valstr, pkt_dev->dst_mac))
+			return -EINVAL;
 		/* Set up Dest MAC */
-		if (compare_ether_addr(old_dmac, pkt_dev->dst_mac))
-			memcpy(&(pkt_dev->hh[0]), pkt_dev->dst_mac, ETH_ALEN);
+		memcpy(&pkt_dev->hh[0], pkt_dev->dst_mac, ETH_ALEN);
 
-		sprintf(pg_result, "OK: dstmac");
+		sprintf(pg_result, "OK: dstmac %pM", pkt_dev->dst_mac);
 		return count;
 	}
 	if (!strcmp(name, "src_mac")) {
-		char *v = valstr;
-		unsigned char old_smac[ETH_ALEN];
-		unsigned char *m = pkt_dev->src_mac;
-
-		memcpy(old_smac, pkt_dev->src_mac, ETH_ALEN);
-
 		len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
 		if (len < 0)
 			return len;
@@ -1468,26 +1444,13 @@ static ssize_t pktgen_if_write(struct file *file,
 		memset(valstr, 0, sizeof(valstr));
 		if (copy_from_user(valstr, &user_buffer[i], len))
 			return -EFAULT;
-		i += len;
-
-		for (*m = 0; *v && m < pkt_dev->src_mac + 6; v++) {
-			int value;
-
-			value = hex_to_bin(*v);
-			if (value >= 0)
-				*m = *m * 16 + value;
-
-			if (*v == ':') {
-				m++;
-				*m = 0;
-			}
-		}
 
+		if (!mac_pton(valstr, pkt_dev->src_mac))
+			return -EINVAL;
 		/* Set up Src MAC */
-		if (compare_ether_addr(old_smac, pkt_dev->src_mac))
-			memcpy(&(pkt_dev->hh[6]), pkt_dev->src_mac, ETH_ALEN);
+		memcpy(&pkt_dev->hh[6], pkt_dev->src_mac, ETH_ALEN);
 
-		sprintf(pg_result, "OK: srcmac");
+		sprintf(pg_result, "OK: srcmac %pM", pkt_dev->src_mac);
 		return count;
 	}
 
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -296,3 +296,27 @@ void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 				csum_unfold(*sum)));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace4);
+
+int mac_pton(const char *s, u8 *mac)
+{
+	int i;
+
+	/* XX:XX:XX:XX:XX:XX */
+	if (strlen(s) < 3 * ETH_ALEN - 1)
+		return 0;
+
+	/* Don't half dirty result. */
+	for (i = 0; i < ETH_ALEN; i++) {
+		if (!strchr("0123456789abcdefABCDEF", s[i * 3]))
+			return 0;
+		if (!strchr("0123456789abcdefABCDEF", s[i * 3 + 1]))
+			return 0;
+		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
+			return 0;
+	}
+	for (i = 0; i < ETH_ALEN; i++) {
+		mac[i] = (hex_to_bin(s[i * 3]) << 4) | hex_to_bin(s[i * 3 + 1]);
+	}
+	return 1;
+}
+EXPORT_SYMBOL(mac_pton);
