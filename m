From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Thu, 07 Jul 2016 01:57:49 -0600
Message-ID: <577E279D02000078000FBEBF@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:43101 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756296AbcGGH5u convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Thu, 7 Jul 2016 03:57:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... for single items being collected: It is more typesafe (as the
compiler can check format string and to-be-written-to variable match)
and requires one less parameter to be passed.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
---
 drivers/net/xen-netback/xenbus.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- 4.7-rc6-prefer-xenbus_scanf.orig/drivers/net/xen-netback/xenbus.c
+++ 4.7-rc6-prefer-xenbus_scanf/drivers/net/xen-netback/xenbus.c
@@ -842,16 +842,16 @@ static int connect_ctrl_ring(struct back
 	unsigned int evtchn;
 	int err;
 
-	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "ctrl-ring-ref", "%u", &val, NULL);
-	if (err)
+	err = xenbus_scanf(XBT_NIL, dev->otherend,
+			   "ctrl-ring-ref", "%u", &val);
+	if (err <= 0)
 		goto done; /* The frontend does not have a control ring */
 
 	ring_ref = val;
 
-	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "event-channel-ctrl", "%u", &val, NULL);
-	if (err) {
+	err = xenbus_scanf(XBT_NIL, dev->otherend,
+			   "event-channel-ctrl", "%u", &val);
+	if (err <= 0) {
 		xenbus_dev_fatal(dev, err,
 				 "reading %s/event-channel-ctrl",
 				 dev->otherend);
@@ -872,7 +872,7 @@ done:
 	return 0;
 
 fail:
-	return err;
+	return err ?: -ENODATA;
 }
 
 static void connect(struct backend_info *be)
