From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH v2 RESEND] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Mon, 24 Oct 2016 09:08:16 -0600
Message-ID: <580E40000200007800119234@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <xen-devel@lists.xenproject.org>,
        <boris.ostrovsky@oracle.com>, "Juergen Gross" <JGross@suse.com>,
        <netdev@vger.kernel.org>
To: "Paul Durrant" <paul.durrant@citrix.com>,
        "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:54864 "EHLO
        prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939720AbcJXPIU (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:5:1>);
        Mon, 24 Oct 2016 11:08:20 -0400
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

--- 4.9-rc2/drivers/net/xen-netback/xenbus.c
+++ 4.9-rc2-xen-netback-prefer-xenbus_scanf/drivers/net/xen-netback/xenbus.c
@@ -889,16 +889,16 @@ static int connect_ctrl_ring(struct back
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
@@ -919,7 +919,7 @@ done:
 	return 0;
 
 fail:
-	return err;
+	return err ?: -ENODATA;
 }
 
 static void connect(struct backend_info *be)
