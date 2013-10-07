From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: transition to CLOSED when removing a VIF
Date: Mon, 7 Oct 2013 13:55:19 +0100
Message-ID: <1381150519-14557-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51173 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734Ab3JGMzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 08:55:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

If a guest is destroyed without transitioning its frontend to CLOSED,
the domain becomes a zombie as netback was not grant unmapping the
shared rings.

When removing a VIF, transition the backend to CLOSED so the VIF is
disconnected if necessary (which will unmap the shared rings etc).

This fixes a regression introduced by
279f438e36c0a70b23b86d2090aeec50155034a9 (xen-netback: Don't destroy
the netdev until the vif is shut down).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Paul Durrant <Paul.Durrant@citrix.com>
---
 drivers/net/xen-netback/xenbus.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index b45bce2..1b08d87 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -39,11 +39,15 @@ static int connect_rings(struct backend_info *);
 static void connect(struct backend_info *);
 static void backend_create_xenvif(struct backend_info *be);
 static void unregister_hotplug_status_watch(struct backend_info *be);
+static void set_backend_state(struct backend_info *be,
+			      enum xenbus_state state);
 
 static int netback_remove(struct xenbus_device *dev)
 {
 	struct backend_info *be = dev_get_drvdata(&dev->dev);
 
+	set_backend_state(be, XenbusStateClosed);
+
 	unregister_hotplug_status_watch(be);
 	if (be->vif) {
 		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
-- 
1.7.2.5
