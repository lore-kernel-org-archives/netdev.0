From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 11:06:33 -0700
Message-ID: <20151026180633.4289.4117.stgit@localhost.localdomain>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com
To: netdev@vger.kernel.org, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34149 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbbJZSGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 14:06:35 -0400
Received: by padhk11 with SMTP id hk11so195194201pad.1
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 11:06:35 -0700 (PDT)
In-Reply-To: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we reinitialize the interface if the MTU is
increased back above IPV6_MIN_MTU and the interface is up.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv6/addrconf.c |   46 +++++++++++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d0c685cdc345..d72fa90d6feb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3147,6 +3147,32 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		}
 		break;
 
+	case NETDEV_CHANGEMTU:
+		/* if MTU under IPV6_MIN_MTU stop IPv6 on this interface. */
+		if (dev->mtu < IPV6_MIN_MTU) {
+			addrconf_ifdown(dev, 1);
+			break;
+		}
+
+		if (idev) {
+			rt6_mtu_change(dev, dev->mtu);
+			idev->cnf.mtu6 = dev->mtu;
+			break;
+		}
+
+		/* allocate new idev */
+		idev = ipv6_add_dev(dev);
+		if (IS_ERR(idev))
+			break;
+
+		/* device is still not ready */
+		if (!(idev->if_flags & IF_READY))
+			break;
+
+		run_pending = 1;
+
+		/* fall through */
+
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
 		if (dev->flags & IFF_SLAVE)
@@ -3170,7 +3196,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				idev->if_flags |= IF_READY;
 				run_pending = 1;
 			}
-		} else {
+		} else if (event == NETDEV_CHANGE) {
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is still not ready. */
 				break;
@@ -3235,24 +3261,6 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		}
 		break;
 
-	case NETDEV_CHANGEMTU:
-		if (idev && dev->mtu >= IPV6_MIN_MTU) {
-			rt6_mtu_change(dev, dev->mtu);
-			idev->cnf.mtu6 = dev->mtu;
-			break;
-		}
-
-		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
-			idev = ipv6_add_dev(dev);
-			if (!IS_ERR(idev))
-				break;
-		}
-
-		/*
-		 * if MTU under IPV6_MIN_MTU.
-		 * Stop IPv6 on this interface.
-		 */
-
 	case NETDEV_DOWN:
 	case NETDEV_UNREGISTER:
 		/*
