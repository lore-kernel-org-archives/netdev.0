From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 09/12] ipv4: fib: Add sysctl to limit number of FIB dump retries
Date: Wed, 30 Nov 2016 11:09:03 +0100
Message-ID: <1480500546-2544-10-git-send-email-jiri@resnulli.us>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34829 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932506AbcK3KJU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:09:20 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so28642287wme.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:09:19 -0800 (PST)
In-Reply-To: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When dumping the FIB tables in the next commit, the dump will be
considered invalid if notifications were sent in the FIB notification
chain mid-dump. In systems where routing changes are frequent, the dump
might need to be restarted multiple times.

Add sysctl to limit the number of FIB dump retries, thereby preventing
callers from looping for long periods of time.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 Documentation/networking/ip-sysctl.txt | 8 ++++++++
 include/net/netns/ipv4.h               | 1 +
 net/ipv4/fib_frontend.c                | 1 +
 net/ipv4/sysctl_net_ipv4.c             | 7 +++++++
 4 files changed, 17 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5af48dd..5182b23 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -73,6 +73,14 @@ fib_multipath_use_neigh - BOOLEAN
 	0 - disabled
 	1 - enabled
 
+fib_dump_max_retries - INTEGER
+	Maximum number of retries until the FIB dump is aborted. For a
+	given net namespace, a FIB dump is considered invalid if
+	notifications were sent in the FIB notification chain mid-dump.
+	The dump will be retried until it is successful or maximum
+	number of retries has been reached.
+	Default: 5
+
 route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
 	this when using large numbers of interfaces and/or routes.
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index f0cf5a1..71c4ca8 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -136,6 +136,7 @@ struct netns_ipv4 {
 	int sysctl_fib_multipath_use_neigh;
 #endif
 
+	int sysctl_fib_dump_max_retries;
 	unsigned int	fib_seq;	/* protected by rtnl_mutex */
 
 	atomic_t	rt_genid;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index dbad5a1..43f7557 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1219,6 +1219,7 @@ static int __net_init ip_fib_net_init(struct net *net)
 	int err;
 	size_t size = sizeof(struct hlist_head) * FIB_TABLE_HASHSZ;
 
+	net->ipv4.sysctl_fib_dump_max_retries = 5;
 	net->ipv4.fib_seq = 0;
 
 	/* Avoid false sharing : Use at least a full cache line */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 80bc36b..046147c 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -971,6 +971,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "fib_dump_max_retries",
+		.data		= &init_net.ipv4.sysctl_fib_dump_max_retries,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
-- 
2.7.4
