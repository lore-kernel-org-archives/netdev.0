From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH][net-2.6.25][NETNS] make netns cleanup to run in a separate
 workqueue
Date: Mon, 19 Nov 2007 14:08:49 +0300
Message-ID: <47416EC1.7080702@sw.ru>
References: <47416909.4000602@fr.ibm.com> <47416DF3.700@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	"Denis V. Lunev" <den@openvz.org>,
	David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Kirill Korotaev <dev@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9551 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbXKSLFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 06:05:01 -0500
In-Reply-To: <47416DF3.700@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ah, sorry. Didn't notice it's called only on boot.

Acked-By: Kirill Korotaev <dev@sw.ru>

Kirill Korotaev wrote:
> imho panic() is too much.
> create_singlethread_workqueue() can fail e.g. due to out of memory...
> 
> Thanks,
> Kirill
> 
> 
> Daniel Lezcano wrote:
> 
>>Subject: make netns cleanup to run in a separate queue
>>From: Benjamin Thery <benjamin.thery@bull.net>
>>
>>This patch adds a separate workqueue for cleaning up a network 
>>namespace. If we use the keventd workqueue to execute cleanup_net(), 
>>there is a problem to unregister devices in IPv6. Indeed the code 
>>that cleans up also schedule work in keventd: as long as cleanup_net() 
>>hasn't return, dst_gc_task() cannot run and as long as dst_gc_task() has
>>not run, there are still some references pending on the net devices and
>>cleanup_net() can not unregister and exit the keventd workqueue.
>>
>>Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
>>Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
>>Acked-by: Denis V. Lunev <den@openvz.org>
>>---
>> net/core/net_namespace.c |    9 ++++++++-
>> 1 file changed, 8 insertions(+), 1 deletion(-)
>>
>>Index: net-2.6.25/net/core/net_namespace.c
>>===================================================================
>>--- net-2.6.25.orig/net/core/net_namespace.c
>>+++ net-2.6.25/net/core/net_namespace.c
>>@@ -58,6 +58,7 @@ out_undo:
>> 
>> #ifdef CONFIG_NET_NS
>> static struct kmem_cache *net_cachep;
>>+static struct workqueue_struct *netns_wq;
>> 
>> static struct net *net_alloc(void)
>> {
>>@@ -149,7 +150,7 @@ void __put_net(struct net *net)
>> {
>> 	/* Cleanup the network namespace in process context */
>> 	INIT_WORK(&net->work, cleanup_net);
>>-	schedule_work(&net->work);
>>+	queue_work(netns_wq, &net->work);
>> }
>> EXPORT_SYMBOL_GPL(__put_net);
>> 
>>@@ -171,7 +172,13 @@ static int __init net_ns_init(void)
>> 	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
>> 					SMP_CACHE_BYTES,
>> 					SLAB_PANIC, NULL);
>>+
>>+	/* Create workqueue for cleanup */
>>+	netns_wq = create_singlethread_workqueue("netns");
>>+	if (!netns_wq)
>>+		panic("Could not create netns workq");
> 
> 
>> #endif
>>+
>> 	mutex_lock(&net_mutex);
>> 	err = setup_net(&init_net);
>> 
>>
>>
>>------------------------------------------------------------------------
>>
>>_______________________________________________
>>Containers mailing list
>>Containers@lists.linux-foundation.org
>>https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

