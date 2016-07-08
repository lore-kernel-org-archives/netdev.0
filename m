From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH v2 4/4] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Fri, 08 Jul 2016 06:28:58 -0600
Message-ID: <577FB8AA02000078000FCA21@prv-mh.provo.novell.com>
References: <577FB70002000078000FC9FA@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <xen-devel@lists.xenproject.org>,
	<boris.ostrovsky@oracle.com>, "Juergen Gross" <JGross@suse.com>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:50013 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574AbcGHM26 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 8 Jul 2016 08:28:58 -0400
In-Reply-To: <577FB70002000078000FC9FA@prv-mh.provo.novell.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For single items being collected this should be preferred as being more
typesafe (as the compiler can check format string and to-be-written-to
variable match) and more efficient (requiring one less parameter to be
passed).

Signed-off-by: Jan Beulich <jbeulich@suse.com>
---
v2: Avoid commit message to continue from subject.
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
