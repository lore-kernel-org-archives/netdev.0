From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 02/10] af_ieee802154: fix ioctl processing
Date: Fri,  7 Aug 2009 16:58:37 +0400
Message-ID: <1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
 <1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:64689 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757820AbZHGM7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 08:59:22 -0400
Received: by ey-out-2122.google.com with SMTP id 9so514095eyd.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 05:59:22 -0700 (PDT)
In-Reply-To: <1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix two errors in ioctl processing:
1) if the ioctl isn't supported one should return -ENOIOCTLCMD
2) don't call ndo_do_ioctl if the device doesn't provide it

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/af_ieee802154.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 69c8d92..d504c34 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -136,7 +136,7 @@ static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
 		unsigned int cmd)
 {
 	struct ifreq ifr;
-	int ret = -EINVAL;
+	int ret = -ENOIOCTLCMD;
 	struct net_device *dev;
 
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
@@ -146,8 +146,10 @@ static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
 
 	dev_load(sock_net(sk), ifr.ifr_name);
 	dev = dev_get_by_name(sock_net(sk), ifr.ifr_name);
-	if (dev->type == ARPHRD_IEEE802154 ||
-	    dev->type == ARPHRD_IEEE802154_PHY)
+
+	if ((dev->type == ARPHRD_IEEE802154 ||
+	     dev->type == ARPHRD_IEEE802154_PHY) &&
+	    dev->netdev_ops->ndo_do_ioctl)
 		ret = dev->netdev_ops->ndo_do_ioctl(dev, &ifr, cmd);
 
 	if (!ret && copy_to_user(arg, &ifr, sizeof(struct ifreq)))
-- 
1.6.3.3

