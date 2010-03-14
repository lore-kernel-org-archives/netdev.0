From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [RFC PATCH net-2.6] net/ethtool: add multiple queue support to
 {get,set}_ringparams
Date: Sun, 14 Mar 2010 07:13:45 +0530
Message-ID: <20100314014335.GA17208@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:45005 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759394Ab0CNBnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 20:43:51 -0500
Received: by iwn6 with SMTP id 6so901334iwn.4
        for <netdev@vger.kernel.org>; Sat, 13 Mar 2010 17:43:50 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With network devices and hence device drivers supporting
multiple Tx and Rx rings, currently there is no way for
ethtool to specify which Tx/Rx ring the user wants to get/set.
This patch enhances the {get,set}_ringparams by allowing
the user to specify the Tx/Rx ring id of interest.
Please review.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 include/linux/ethtool.h |    1 +
 net/core/ethtool.c      |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b33f316..de6a90a 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -206,6 +206,7 @@ struct ethtool_coalesce {
 /* for configuring RX/TX ring parameters */
 struct ethtool_ringparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}RINGPARAM */
+	__u32	ring_id;
 
 	/* Read only attributes.  These indicate the maximum number
 	 * of pending RX/TX ring entries the driver will allow the
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f4cb6b6..81e2e62 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -881,11 +881,14 @@ static noinline_for_stack int ethtool_set_coalesce(struct net_device *dev, void
 
 static int ethtool_get_ringparam(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_ringparam ringparam = { .cmd = ETHTOOL_GRINGPARAM };
+	struct ethtool_ringparam ringparam;
 
 	if (!dev->ethtool_ops->get_ringparam)
 		return -EOPNOTSUPP;
 
+	if (copy_from_user(&ringparam, useraddr, sizeof(ringparam)))
+		return -EFAULT;
+
 	dev->ethtool_ops->get_ringparam(dev, &ringparam);
 
 	if (copy_to_user(useraddr, &ringparam, sizeof(ringparam)))
-- 
1.6.3.3

