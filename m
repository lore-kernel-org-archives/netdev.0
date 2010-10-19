From: nhorman@tuxdriver.com
Subject: [PATCH 2/2] Revert napi_poll fix for bonding driver
Date: Tue, 19 Oct 2010 13:04:26 -0400
Message-ID: <1287507866-25156-3-git-send-email-nhorman@tuxdriver.com>
References: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59539 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077Ab0JSRE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 13:04:59 -0400
In-Reply-To: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

In an erlier patch I modified napi_poll so that devices with IFF_MASTER polled
the per_cpu list instead of the device list for napi.  I did this because the
bonding driver has no napi instances to poll, it instead expects to check the
slave devices napi instances, which napi_poll was unaware of.  Looking at this
more closely however, I now see this isn't strictly needed.  As the bond driver
poll_controller calls the slaves poll_controller via netpoll_poll_dev, which
recursively calls poll_napi on each slave, allowing those napi instances to get
serviced.  The earlier patch isn't at all harmfull, its just not needed, so lets
revert it to make the code cleaner.  Sorry for the noise,

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/netpoll.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index d79d221..4e98ffa 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -156,15 +156,8 @@ static void poll_napi(struct net_device *dev)
 {
 	struct napi_struct *napi;
 	int budget = 16;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
-	struct list_head *nlist;
 
-	if (dev->flags & IFF_MASTER)
-		nlist = &sd->poll_list;
-	else
-		nlist = &dev->napi_list;
-
-	list_for_each_entry(napi, nlist, dev_list) {
+	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
 			budget = poll_one_napi(dev->npinfo, napi, budget);
-- 
1.7.2.3

