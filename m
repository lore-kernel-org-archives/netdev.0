From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 2/2] xen-netback: handle frontends that fail to transition through Closing
Date: Fri, 20 Sep 2013 14:57:40 +0100
Message-ID: <1379685460-25032-3-git-send-email-paul.durrant@citrix.com>
References: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:57327 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab3ITN5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 09:57:46 -0400
In-Reply-To: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some old Windows frontends fail to transition through the xenbus Closing
state and move directly from Connected to Closed. Handle this case properly.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/xenbus.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index a53782e..684b0f6 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -265,6 +265,13 @@ static void frontend_changed(struct xenbus_device *dev,
 		break;
 
 	case XenbusStateClosed:
+		/*
+		 * Handle frontends which erroneously transition
+		 * directly from Connected to Closed.
+		 */
+		if (dev->state == XenbusStateConnected)
+			disconnect_backend(dev);
+
 		xenbus_switch_state(dev, XenbusStateClosed);
 		if (xenbus_dev_is_online(dev))
 			break;
-- 
1.7.10.4
