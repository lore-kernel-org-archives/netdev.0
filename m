From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Mon, 23 Aug 2004 22:51:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823205114.GB19921@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

Introduces a new rtnetlink link message attribute to provide txqlen value
via RTM_GETLINK and adds support for setting MTU and txqlen via RTM_SETLINK.

First step to supersede ioctl network link configuration with
rtnetlink equivalent.

    Thomas


--- 1.19/net/core/rtnetlink.c	Thu Apr 29 01:04:48 2004
+++ 1.20/net/core/rtnetlink.c	Sun Aug 22 18:11:03 2004
@@ -175,6 +175,7 @@
 		r->ifi_flags |= IFF_RUNNING;
 
 	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+	RTA_PUT(skb, IFLA_TXQLEN, sizeof(unsigned long), &dev->tx_queue_len);
 	if (dev->addr_len) {
 		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
 		RTA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
@@ -268,6 +269,23 @@
 			goto out;
 		memcpy(dev->broadcast, RTA_DATA(ida[IFLA_BROADCAST - 1]),
 		       dev->addr_len);
+	}
+
+	if (ida[IFLA_MTU - 1]) {
+		if (ida[IFLA_MTU - 1]->rta_len != RTA_LENGTH(sizeof(unsigned)))
+			goto out;
+		err = dev_set_mtu(dev, *((unsigned *) RTA_DATA(ida[IFLA_MTU - 1])));
+
+		if (err)
+			goto out;
+
+	}
+
+	if (ida[IFLA_TXQLEN - 1]) {
+		if (ida[IFLA_TXQLEN - 1]->rta_len != RTA_LENGTH(sizeof(unsigned long)))
+			goto out;
+
+		dev->tx_queue_len = *((unsigned long *) RTA_DATA(ida[IFLA_TXQLEN - 1]));
 	}
 
 	err = 0;

--- 1.33/include/linux/rtnetlink.h	Mon Apr  5 23:41:40 2004
+++ 1.34/include/linux/rtnetlink.h	Sun Aug 22 18:11:03 2004
@@ -540,6 +540,7 @@
 	IFLA_QDISC,
 	IFLA_STATS,
 	IFLA_COST,
+	IFLA_TXQLEN,
 #define IFLA_COST IFLA_COST
 	IFLA_PRIORITY,
 #define IFLA_PRIORITY IFLA_PRIORITY
