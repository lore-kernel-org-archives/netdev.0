From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2]  bridge: fix error handling in br_add_if()
Date: Mon, 28 Apr 2008 17:29:25 -0700
Message-ID: <20080428172925.64b88010@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Volodymyr G Lukiianyk <volodymyrgl@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44325 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935877AbYD2A3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 20:29:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When device is added to bridge its refcnt is incremented (in new_nbp()), but if
error occurs during further br_add_if() operations this counter is not
decremented back. Fix it by adding dev_put() call in the error path.

Signed-off-by: Volodymyr G Lukiianyk <volodymyrgl@gmail.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_if.c	2008-04-28 15:27:06.000000000 -0700
+++ b/net/bridge/br_if.c	2008-04-28 15:31:18.000000000 -0700
@@ -411,9 +411,12 @@ err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
 	kobject_del(&p->kobj);
-	return err;
+	goto put_back;
 err0:
 	kobject_put(&p->kobj);
+
+put_back:
+	dev_put(dev);
 	return err;
 }
 
