From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next 4/4] net: fib: avoid calling fib_flush for each device when doing batch close and unregister
Date: Mon,  1 Feb 2016 14:32:32 -0800
Message-ID: <1454365952-10324-5-git-send-email-noureddine@arista.com>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:24787 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932285AbcBAWdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 17:33:32 -0500
In-Reply-To: <1454365952-10324-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call fib_flush at the end when closing or unregistering multiple
devices. This can save walking the fib many times and greatly
reduce rtnl_lock hold time when unregistering many devices with
a fib having hundreds of thousands of routes.

Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 include/net/netns/ipv4.h |  1 +
 net/ipv4/fib_frontend.c  | 16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d75be32..d59a078 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -111,5 +111,6 @@ struct netns_ipv4 {
 #endif
 #endif
 	atomic_t	rt_genid;
+	bool		needs_fib_flush;
 };
 #endif
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4734475..808426e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1161,11 +1161,22 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	unsigned int flags;
 
 	if (event == NETDEV_UNREGISTER) {
-		fib_disable_ip(dev, event, true);
+		if (fib_sync_down_dev(dev, event, true))
+			net->ipv4.needs_fib_flush = true;
 		rt_flush_dev(dev);
 		return NOTIFY_DONE;
 	}
 
+	if (event == NETDEV_UNREGISTER_BATCH || event == NETDEV_DOWN_BATCH) {
+		if (net->ipv4.needs_fib_flush) {
+			fib_flush(net);
+			net->ipv4.needs_fib_flush = false;
+		}
+		rt_cache_flush(net);
+		arp_ifdown_all();
+		return NOTIFY_DONE;
+	}
+
 	in_dev = __in_dev_get_rtnl(dev);
 	if (!in_dev)
 		return NOTIFY_DONE;
@@ -1182,7 +1193,8 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		rt_cache_flush(net);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, event, false);
+		if (fib_sync_down_dev(dev, event, false))
+			net->ipv4.needs_fib_flush = true;
 		break;
 	case NETDEV_CHANGE:
 		flags = dev_get_flags(dev);
-- 
1.8.1.4
