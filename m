From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/3] net: Don't leak packets when a netns is going down
Date: Wed, 05 Nov 2008 15:27:34 -0800
Message-ID: <m1skq53g9l.fsf_-_@frodo.ebiederm.org>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org> <48EB36FC.4000008@fr.ibm.com>
	<48EB3F72.5090201@openvz.org> <m1d4ic4pbr.fsf@frodo.ebiederm.org>
	<48ECA8D2.4090406@openvz.org> <m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
	<m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	"Denis V. Lunev" <den@openvz.org>,
	Pavel Emelyanov <xemul@openvz.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57055 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbYKEXfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 18:35:08 -0500
In-Reply-To: <m1y6zx3gcs.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 05 Nov 2008 15:25:39 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have been tracking for a while a case where when the
network namespace exits the cleanup gets stck in an
endless precessess of:

unregister_netdevice: waiting for lo to become free. Usage count = 3
unregister_netdevice: waiting for lo to become free. Usage count = 3
unregister_netdevice: waiting for lo to become free. Usage count = 3
unregister_netdevice: waiting for lo to become free. Usage count = 3
unregister_netdevice: waiting for lo to become free. Usage count = 3
unregister_netdevice: waiting for lo to become free. Usage count = 3
unregister_netdevice: waiting for lo to become free. Usage count = 3

It turns out that if you listen on a multicast address an unsubscribe
packet is sent when the network device goes down.   If you shutdown
the network namespace without carefully cleaning up this can trigger
the unsubscribe packet to be sent over the loopback interface while
the network namespace is going down.

All of which is fine except when we drop the packet and forget to
free it leaking the skb and the dst entry attached to.  As it
turns out the dst entry hold a reference to the idev which holds
the dev and keeps everything from being cleaned up.  Yuck!

By fixing my earlier thinko and add the needed kfree_skb and everything
cleans up beautifully. 

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 811507c..a0c6060 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2253,8 +2253,10 @@ int netif_receive_skb(struct sk_buff *skb)
 	rcu_read_lock();
 
 	/* Don't receive packets in an exiting network namespace */
-	if (!net_alive(dev_net(skb->dev)))
+	if (!net_alive(dev_net(skb->dev))) {
+		kfree_skb(skb);
 		goto out;
+	}
 
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
-- 
1.5.6.5

