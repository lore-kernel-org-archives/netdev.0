From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Remove notifier block from chain when register_netdevice_notifier
 fails
Date: Wed, 14 Nov 2007 15:08:03 +0300
Message-ID: <473AE523.70501@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35203 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292AbXKNMJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 07:09:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit fcc5a03ac42564e9e255c1134dda47442289e466 makes the
register_netdevice_notifier() handle the error from the
NETDEV_REGISTER event, sent to the registering block. 

The bad news is that in this case the notifier block is 
not removed from the list, but the error is returned to the 
caller. In case the caller is in module init function and 
handles this error this can abort the module loading. The
notifier block will be then removed from the kernel, but 
will be left in the list. Oops :(

I think that the notifier block should be removed from the
chain in case of error, regardless whether this error is 
handled by the caller or not. In the worst case (the error 
is _not_ handled) module will not receive the events any 
longer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index dd40b35..86d6261 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1171,6 +1171,8 @@ rollback:
 			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
 		}
 	}
+
+	raw_notifier_chain_unregister(&netdev_chain, nb);
 	goto unlock;
 }
 
