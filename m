From: Justin Cormack <justin@myriabit.com>
Subject: [PATCH net-next] fix missing copy_from_user in macvtap
Date: Wed, 13 May 2015 19:19:02 +0100
Message-ID: <1431541142.3278.10.camel@myriabit.com>
References: <1431370810.3278.4.camel@myriabit.com>
	 <20150512.230121.330638562727327262.davem@davemloft.net>
	 <1431516916.3278.8.camel@myriabit.com>
	 <20150513.120956.970928701180963590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:37943 "EHLO aibo.runbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbbEMSTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 14:19:35 -0400
In-Reply-To: <20150513.120956.970928701180963590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing copy_from_user in macvtap SIOCSIFHWADDR ioctl.

Signed-off-by: Justin Cormack <justin@netbsd.org>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index c8a2389..483afb1 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1006,6 +1006,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	unsigned int __user *up = argp;
 	unsigned short u;
 	int __user *sp = argp;
+	struct sockaddr sa;
 	int s;
 	int ret;
 
@@ -1119,13 +1120,15 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return ret;
 
 	case SIOCSIFHWADDR:
+		if (copy_from_user(&sa, &ifr->ifr_hwaddr, sizeof(sa)))
+			return -EFAULT;
 		rtnl_lock();
 		vlan = macvtap_get_vlan(q);
 		if (!vlan) {
 			rtnl_unlock();
 			return -ENOLINK;
 		}
-		ret = dev_set_mac_address(vlan->dev, &ifr->ifr_hwaddr);
+		ret = dev_set_mac_address(vlan->dev, &sa);
 		macvtap_put_vlan(vlan);
 		rtnl_unlock();
 		return ret;
