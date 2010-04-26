From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-2.6] netns: assign NULL after pernet memory is freed
Date: Mon, 26 Apr 2010 13:18:07 +0200
Message-ID: <20100426111806.GB2941@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275Ab0DZLSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 07:18:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed to let know appropriate code (driver) know that pernet memory
chunk  was freed already. For example when driver has also registered netdev
notifier, it can be called after memory is freed which could eventually lead
to panic. Also a null check should be present in these notifiers.

For example, previously, when drivers were responsible for pernet memory
allocation/freeing, in pppoe this assign was done in pppoe_exit_net() right
after pernet memory was freed. The check in notifier stayed (in pppoe_flush_dev
called from pppoe_device_event) but makes no sense now without this patch.

I already know about several notifiers where the check should be present,
patches will follow up.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index bd8c471..29f622c 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -51,6 +51,7 @@ static void ops_free(const struct pernet_operations *ops, struct net *net)
 	if (ops->id && ops->size) {
 		int id = *ops->id;
 		kfree(net_generic(net, id));
+		net_assign_generic(net, id, NULL);
 	}
 }
 
