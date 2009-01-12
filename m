From: Paul Bolle <pebolle@tiscali.nl>
Subject: [i4l] stop address leakage when shutting down an i4l ppp interface
Date: Mon, 12 Jan 2009 13:54:49 +0100
Message-ID: <1231764889.7132.23.camel@test.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:59301 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbZALMyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 07:54:51 -0500
Received: from [212.123.169.34] (helo=[192.168.1.42])
	by smtp-out1.tiscali.nl with esmtp
	id 1LMMJe-0002Ba-Ft
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 13:54:50 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an i4l ppp interface is shut down (e.g. with /sbin/ifdown ippp0)
__dev_addr-discard() warns us for "address leakage":
    
    __dev_addr_discard: address leakage! da_users=1
    
The easiest way to stop that leakage is to partly change that interface's
net_device at the end of isdn_net_close() so that it will be acceptable to
arp_mc_map().
    
Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Please note that I hardly understand what multicast lists are, and why
an i4l ppp interface uses those, etc. I just pinpointed the problem with
a few printk()s. This patch tries to fix only this specific problem
while touching as little as possible (i.e. it only covers the "address
leakage" that I was able to trigger).

Anyhow, a critical review of this patch would be appreciated. 

Sent only to netdev@vger.kernel.org (and not also to
isdn4linux@listserv.isdn4linux.de) because an earlier ISDN patch I wrote
only got a response from this list (and this patch is NETWORKING related
anyway).
---
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index cb8943d..d58e952 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1336,6 +1336,13 @@ isdn_net_close(struct net_device *dev)
 	}
 	isdn_net_hangup(dev);
 	isdn_unlock_drivers();
+#ifdef CONFIG_ISDN_PPP
+	/* make sure arp_mc_map() handles this device properly */
+	if (dev->type == ARPHRD_PPP) {
+		dev->type = ARPHRD_ETHER;
+		dev->addr_len = ETH_ALEN;
+	}
+#endif
 	return 0;
 }
 


