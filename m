From: Justin Cormack <justin@myriabit.com>
Subject: [PATCH v5] macvtap add missing ioctls
Date: Wed, 13 May 2015 12:35:16 +0100
Message-ID: <1431516916.3278.8.camel@myriabit.com>
References: <1431262215.3278.2.camel@myriabit.com>
	 <20150511.134901.959375179450827063.davem@davemloft.net>
	 <1431370810.3278.4.camel@myriabit.com>
	 <20150512.230121.330638562727327262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:45844 "EHLO aibo.runbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067AbbEMLfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 07:35:34 -0400
In-Reply-To: <20150512.230121.330638562727327262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvtap driver tries to emulate all the ioctls supported by a normal
tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
SIOCSIFHWADDR ioctls to get and set the mac address that are supported
by tun/tap. This patch adds these.

Signed-off-by: Justin Cormack <justin@netbsd.org>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8c350c5..d2a7783 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1006,6 +1006,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	unsigned int __user *up = argp;
 	unsigned short u;
 	int __user *sp = argp;
+	struct sockaddr sa;
 	int s;
 	int ret;
 
@@ -1101,6 +1102,37 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		rtnl_unlock();
 		return ret;
 
+	case SIOCGIFHWADDR:
+		rtnl_lock();
+		vlan = macvtap_get_vlan(q);
+		if (!vlan) {
+			rtnl_unlock();
+			return -ENOLINK;
+		}
+		ret = 0;
+		u = vlan->dev->type;
+		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
+		    copy_to_user(&ifr->ifr_hwaddr.sa_data, vlan->dev->dev_addr, ETH_ALEN) ||
+		    put_user(u, &ifr->ifr_hwaddr.sa_family))
+			ret = -EFAULT;
+		macvtap_put_vlan(vlan);
+		rtnl_unlock();
+		return ret;
+
+	case SIOCSIFHWADDR:
+		if (copy_from_user(&sa, &ifr->ifr_hwaddr, sizeof(sa)))
+			return -EFAULT;
+		rtnl_lock();
+		vlan = macvtap_get_vlan(q);
+		if (!vlan) {
+			rtnl_unlock();
+			return -ENOLINK;
+		}
+		ret = dev_set_mac_address(vlan->dev, &sa);
+		macvtap_put_vlan(vlan);
+		rtnl_unlock();
+		return ret;
+
 	default:
 		return -EINVAL;
 	}
