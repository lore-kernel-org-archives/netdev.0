From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1 net-2.6] Re-enable IP when MTU > 68
Date: Sat, 30 Aug 2008 14:57:18 -0300
Message-ID: <48B989FE.9070604@linux.vnet.ibm.com>
References: <48B80D6B.5030007@linux.vnet.ibm.com> <20080829150506.GO7908@solarflare.com> <48B81457.9010105@linux.vnet.ibm.com> <20080829.133345.248034879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rafaello@br.ibm.com
To: David Miller <davem@davemloft.net>, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:55646 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbYH3R57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Aug 2008 13:57:59 -0400
Received: from mailhub1.br.ibm.com (mailhub1 [9.18.232.109])
	by igw2.br.ibm.com (Postfix) with ESMTP id EF4DB17F43C
	for <netdev@vger.kernel.org>; Sat, 30 Aug 2008 14:43:04 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7UHvlvO2412798
	for <netdev@vger.kernel.org>; Sat, 30 Aug 2008 14:57:52 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7UHveaV016408
	for <netdev@vger.kernel.org>; Sat, 30 Aug 2008 14:57:41 -0300
In-Reply-To: <20080829.133345.248034879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-enable IP when the MTU gets back to a valid size. 

This patch just checks if the in_dev is NULL on a NETDEV_CHANGEMTU event
and if MTU is valid (bigger than 68), then re-enable in_dev. 

Also a function that checks valid MTU size was created.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 91d3d96..27193dd 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1029,6 +1029,11 @@ skip:
 	}
 }
 
+static inline bool inetdev_valid_mtu(unsigned mtu)
+{
+	return mtu >= 68;
+}
+
 /* Called only under RTNL semaphore */
 
 static int inetdev_event(struct notifier_block *this, unsigned long event,
@@ -1048,6 +1053,10 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
 				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
 			}
+		} else if (event == NETDEV_CHANGEMTU) {
+			/* Re-enabling IP */
+			if (inetdev_valid_mtu(dev->mtu))
+				in_dev = inetdev_init(dev);
 		}
 		goto out;
 	}
@@ -1058,7 +1067,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		dev->ip_ptr = NULL;
 		break;
 	case NETDEV_UP:
-		if (dev->mtu < 68)
+		if (!inetdev_valid_mtu(dev->mtu))
 			break;
 		if (dev->flags & IFF_LOOPBACK) {
 			struct in_ifaddr *ifa;
@@ -1080,9 +1089,9 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		ip_mc_down(in_dev);
 		break;
 	case NETDEV_CHANGEMTU:
-		if (dev->mtu >= 68)
+		if (inetdev_valid_mtu(dev->mtu))
 			break;
-		/* MTU falled under 68, disable IP */
+		/* disable IP when MTU is not enough */
 	case NETDEV_UNREGISTER:
 		inetdev_destroy(in_dev);
 		break;
