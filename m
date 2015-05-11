From: Justin Cormack <justin@myriabit.com>
Subject: [PATCH v4] macvtap add missing ioctls - fix wrapping
Date: Mon, 11 May 2015 20:00:10 +0100
Message-ID: <1431370810.3278.4.camel@myriabit.com>
References: <20150509.174017.6956415471104971.davem@davemloft.net>
	 <1431249359.669.5.camel@myriabit.com>
	 <1431262215.3278.2.camel@myriabit.com>
	 <20150511.134901.959375179450827063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:58262 "EHLO aibo.runbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628AbbEKTAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 15:00:45 -0400
In-Reply-To: <20150511.134901.959375179450827063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvtap driver tries to emulate all the ioctls supported by a normal
tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
SIOCSIFHWADDR ioctls to get and set the mac address that are supported
by tun/tap. This patch adds these.

Signed-off-by: Justin Cormack <justin@netbsd.org>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8c350c5..5f98b34 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1101,6 +1101,35 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
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
+		rtnl_lock();
+		vlan = macvtap_get_vlan(q);
+		if (!vlan) {
+			rtnl_unlock();
+			return -ENOLINK;
+		}
+		ret = dev_set_mac_address(vlan->dev, &ifr->ifr_hwaddr);
+		macvtap_put_vlan(vlan);
+		rtnl_unlock();
+		return ret;
+
 	default:
 		return -EINVAL;
 	}
