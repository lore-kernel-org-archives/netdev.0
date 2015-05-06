From: Justin Cormack <justin@myriabit.com>
Subject: [PATCH] macvtap add missing ioctls
Date: Wed, 06 May 2015 16:56:15 +0100
Message-ID: <1430927775.669.2.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:59478 "EHLO aibo.runbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613AbbEFQQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 12:16:52 -0400
Received: from [10.9.9.206] (helo=mailfront02.runbox.com)
	by bars.runbox.com with esmtp (Exim 4.71)
	(envelope-from <justin@myriabit.com>)
	id 1Yq1gI-0007vM-Dw
	for netdev@vger.kernel.org; Wed, 06 May 2015 17:56:18 +0200
Received: from 197.40.187.81.in-addr.arpa ([81.187.40.197] helo=brill)
	by mailfront02.runbox.com with esmtpsa  (uid:818294 )  (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	id 1Yq1gF-0004T5-TS
	for netdev@vger.kernel.org; Wed, 06 May 2015 17:56:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvtap driver tries to emulate all the ioctls supported by a normal tun/tap driver,
however it was missing the generic SIOCGIFHWADDR and SIOCSIFHWADDR ioctls to get and set
the mac address that are supported by tun/tap. This patch adds these.

Signed off by Justin Cormack <justin@netbsd.org>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8c350c5..f37e8f9 100644
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
+			copy_to_user(&ifr->ifr_hwaddr.sa_data, vlan->dev->dev_addr, ETH_ALEN) ||
+			put_user(u, &ifr->ifr_hwaddr.sa_family))
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
