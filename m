From: Saurabh Mohan <saurabh.mohan@vyatta.com>
Subject: [PATCH] ipv6: Netlink notify forwarding change
Date: Tue, 8 Jan 2013 16:11:14 -0800
Message-ID: <20130109001114.GA3393@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41099 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754869Ab3AIAMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 19:12:44 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 0C5B01410365
	for <netdev@vger.kernel.org>; Tue,  8 Jan 2013 16:12:44 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0rpVC7HLm0JE for <netdev@vger.kernel.org>;
	Tue,  8 Jan 2013 16:12:43 -0800 (PST)
Received: from localhost (eng-dhcp-109.vyatta.com [10.3.0.109])
	by mail.vyatta.com (Postfix) with ESMTP id 39EAF1410363
	for <netdev@vger.kernel.org>; Tue,  8 Jan 2013 16:12:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



If the interface is up and the forwarding attribute
(net.ipv6.conf.eth1.forwarding) is changed then a netlink message is not
generated.

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0f9f15e..a959606 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -130,6 +130,8 @@ static void ipv6_regen_rndid(unsigned long data);
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
+static int addrconf_notify(struct notifier_block *this, unsigned long event,
+			   void *data);
 
 /*
  *	Configured unicast address hash table
@@ -467,6 +469,9 @@ static void dev_forward_change(struct inet6_dev *idev)
 
 	if (!idev)
 		return;
+
+	addrconf_notify(NULL, NETDEV_CHANGE, idev->dev);
+
 	dev = idev->dev;
 	if (idev->cnf.forwarding)
 		dev_disable_lro(dev);
@@ -2615,9 +2620,11 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			}
 
 			if (idev) {
-				if (idev->if_flags & IF_READY)
+				if (idev->if_flags & IF_READY) {
 					/* device is already configured. */
+					inet6_ifinfo_notify(RTM_NEWLINK, idev);
 					break;
+				}
 				idev->if_flags |= IF_READY;
 			}
 
