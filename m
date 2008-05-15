From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] net: handle errors from device_rename
Date: Wed, 14 May 2008 18:15:43 -0700
Message-ID: <20080514181543.744b8286@extreme>
References: <20080514170316.672f809d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50096 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755898AbYEOBQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 21:16:18 -0400
In-Reply-To: <20080514170316.672f809d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

device_rename can fail with -EEXIST or -ENOMEM, so handle any problems.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2008-05-14 17:49:37.000000000 -0700
+++ b/net/core/dev.c	2008-05-14 17:51:21.000000000 -0700
@@ -903,7 +903,11 @@ int dev_change_name(struct net_device *d
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
 rollback:
-	device_rename(&dev->dev, dev->name);
+	err = device_rename(&dev->dev, dev->name);
+	if (err) {
+		memcpy(dev->name, oldname, IFNAMSIZ);
+		return err;
+	}
 
 	write_lock_bh(&dev_base_lock);
 	hlist_del(&dev->name_hlist);
