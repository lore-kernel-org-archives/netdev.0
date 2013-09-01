From: Paul Wouters <pwouters@redhat.com>
Subject: [PATCH] Fix for loading non-namespace aware ipv4 protocols without
 CONFIG_NAMESPACES
Date: Sun, 01 Sep 2013 15:30:26 -0400
Message-ID: <522395D2.7080209@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070908040609020805090302"
Cc: netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755958Ab3IATaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 15:30:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070908040609020805090302
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Attached is a trivial patch to allow inet_add_protocol on kernels without CONFIG_NAMESPACES to load non-namespace aware (out of kernel) modules.
For IPv6, there is no such check. Some discussion of that can be found in the archive: http://www.spinics.net/lists/netdev/msg225184.html

I'm ambivalent on whether the check should be there (like in ipv4) or not (like in ipv6). But if it is there, it should use the proper #ifdef.

Paul

--------------070908040609020805090302
Content-Type: text/x-patch;
 name="ipv4-protocol-nonamespace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ipv4-protocol-nonamespace.patch"

commit 9e3ddb21568284fb9061a91bbd3158909b1dec45
Author: Paul Wouters <pwouters@redhat.com>
Date:   Sun Sep 1 15:18:37 2013 -0400

    * Fix for loading non-namespace aware ipv4 protocols without
      CONFIG_NAMESPACES set. IPv6 does not have this check.

diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index ce84846..b5f785c 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -37,11 +37,13 @@ const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
+#ifdef CONFIG_NAMESPACES
 	if (!prot->netns_ok) {
 		pr_err("Protocol %u is not namespace aware, cannot register.\n",
 			protocol);
 		return -EINVAL;
 	}
+#endif
 
 	return !cmpxchg((const struct net_protocol **)&inet_protos[protocol],
 			NULL, prot) ? 0 : -1;

--------------070908040609020805090302--
