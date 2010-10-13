From: nhorman@tuxdriver.com
Subject: [PATCH 3/5] Fix napi poll for bonding driver
Date: Wed, 13 Oct 2010 08:35:32 -0400
Message-ID: <1286973334-4339-4-git-send-email-nhorman@tuxdriver.com>
References: <1286973334-4339-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38074 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab0JMMgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 08:36:01 -0400
In-Reply-To: <1286973334-4339-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

Usually the netpoll path, when preforming a napi poll can get away with just
polling all the napi instances of the configured device.  Thats not the case for
the bonding driver however, as the napi instances which may wind up getting
flagged as needing polling after the poll_controller call don't belong to the
bonded device, but rather to the slave devices.  Fix this by checking the device
in question for the IFF_MASTER flag, if set, we know we need to check the full
poll list for this cpu, rather than just the devices napi instance list.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/netpoll.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4e98ffa..d79d221 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -156,8 +156,15 @@ static void poll_napi(struct net_device *dev)
 {
 	struct napi_struct *napi;
 	int budget = 16;
+	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct list_head *nlist;
 
-	list_for_each_entry(napi, &dev->napi_list, dev_list) {
+	if (dev->flags & IFF_MASTER)
+		nlist = &sd->poll_list;
+	else
+		nlist = &dev->napi_list;
+
+	list_for_each_entry(napi, nlist, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
 			budget = poll_one_napi(dev->npinfo, napi, budget);
-- 
1.7.2.3

