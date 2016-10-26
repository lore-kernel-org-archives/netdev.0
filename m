From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: dev: Fix non-RCU based lower dev walker
Date: Wed, 26 Oct 2016 13:21:33 -0700
Message-ID: <1477513293-10117-1-git-send-email-dsa@cumulusnetworks.com>
Cc: idosch@mellanox.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35181 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932320AbcJZU2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 16:28:49 -0400
Received: by mail-pf0-f174.google.com with SMTP id s8so2637250pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 13:28:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_walk_all_lower_dev is not properly walking the lower device
list.  Commit 1a3f060c1a47 made netdev_walk_all_lower_dev similar
to netdev_walk_all_upper_dev_rcu and netdev_walk_all_lower_dev_rcu
but failed to update its netdev_next_lower_dev iterator. This patch
fixes that.

Fixes: 1a3f060c1a47 ("net: Introduce new api for walking upper and
                     lower devices")
Reported-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f55fb4536016..6aa43cd8cbb5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5400,12 +5400,12 @@ static struct net_device *netdev_next_lower_dev(struct net_device *dev,
 {
 	struct netdev_adjacent *lower;
 
-	lower = list_entry(*iter, struct netdev_adjacent, list);
+	lower = list_entry((*iter)->next, struct netdev_adjacent, list);
 
 	if (&lower->list == &dev->adj_list.lower)
 		return NULL;
 
-	*iter = lower->list.next;
+	*iter = &lower->list;
 
 	return lower->dev;
 }
-- 
2.1.4
