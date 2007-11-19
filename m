From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH][net-2.6.25][NETNS] make netns cleanup to run in a separate
 workqueue
Date: Mon, 19 Nov 2007 11:44:25 +0100
Message-ID: <47416909.4000602@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406080409010300070800"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Denis V. Lunev" <den@openvz.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:54014 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbXKSKuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 05:50:08 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lAJAo703137750
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 10:50:07 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAJAo7j83096612
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 10:50:07 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJAnoDC011317
	for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 10:49:51 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070406080409010300070800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070406080409010300070800
Content-Type: text/x-patch;
 name="create-workq-for-the-namespace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="create-workq-for-the-namespace.patch"

Subject: make netns cleanup to run in a separate queue
From: Benjamin Thery <benjamin.thery@bull.net>

This patch adds a separate workqueue for cleaning up a network 
namespace. If we use the keventd workqueue to execute cleanup_net(), 
there is a problem to unregister devices in IPv6. Indeed the code 
that cleans up also schedule work in keventd: as long as cleanup_net() 
hasn't return, dst_gc_task() cannot run and as long as dst_gc_task() has
not run, there are still some references pending on the net devices and
cleanup_net() can not unregister and exit the keventd workqueue.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Acked-by: Denis V. Lunev <den@openvz.org>
---
 net/core/net_namespace.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: net-2.6.25/net/core/net_namespace.c
===================================================================
--- net-2.6.25.orig/net/core/net_namespace.c
+++ net-2.6.25/net/core/net_namespace.c
@@ -58,6 +58,7 @@ out_undo:
 
 #ifdef CONFIG_NET_NS
 static struct kmem_cache *net_cachep;
+static struct workqueue_struct *netns_wq;
 
 static struct net *net_alloc(void)
 {
@@ -149,7 +150,7 @@ void __put_net(struct net *net)
 {
 	/* Cleanup the network namespace in process context */
 	INIT_WORK(&net->work, cleanup_net);
-	schedule_work(&net->work);
+	queue_work(netns_wq, &net->work);
 }
 EXPORT_SYMBOL_GPL(__put_net);
 
@@ -171,7 +172,13 @@ static int __init net_ns_init(void)
 	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
 					SMP_CACHE_BYTES,
 					SLAB_PANIC, NULL);
+
+	/* Create workqueue for cleanup */
+	netns_wq = create_singlethread_workqueue("netns");
+	if (!netns_wq)
+		panic("Could not create netns workq");
 #endif
+
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);
 

--------------070406080409010300070800--
