From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: bad error handling when adding invalid ether
 address
Date: Wed, 25 Mar 2009 20:57:00 -0700
Message-ID: <20090325205700.1a4a7fd6@nehalam>
References: <062c01c9adb4$c12a8e80$b100000a@Stig>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Stig Thormodsrud'" <stig@vyatta.com>, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49296 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbZCZD5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 23:57:17 -0400
In-Reply-To: <062c01c9adb4$c12a8e80$b100000a@Stig>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes an crash when empty bond device is added to a bridge.
If an interface with invalid ethernet address (all zero) is added
to a bridge, then bridge code detects it when setting up the forward
databas entry. But the error unwind is broken, the bridge port object 
can get freed twice: once when ref count went to zeo, and once by kfree.
Since object is never really accessible, just free it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against 2.6.29, but same code has been around for a while
in older releases, so should apply to 2.6.27.y as well.


--- a/net/bridge/br_if.c	2009-03-25 20:29:08.310404430 -0700
+++ b/net/bridge/br_if.c	2009-03-25 20:48:21.353468017 -0700
@@ -426,7 +426,6 @@ err2:
 err1:
 	kobject_del(&p->kobj);
 err0:
-	kobject_put(&p->kobj);
 	dev_set_promiscuity(dev, -1);
 put_back:
 	dev_put(dev);
