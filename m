From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netprio_cgroup: Fix obo in get_prioidx
Date: Fri,  3 Feb 2012 10:18:43 -0500
Message-ID: <1328282323-15902-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40997 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab2BCPTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:19:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was recently pointed out to me that the get_prioidx function sets a bit in
the prioidx map prior to checking to see if the index being set is out of
bounds.  This patch corrects that, avoiding the possiblity of us writing beyond
the end of the array

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Stanislaw Gruszka <sgruszka@redhat.com>
CC: Stanislaw Gruszka <sgruszka@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/core/netprio_cgroup.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 3a9fd48..9ae183a 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -58,11 +58,12 @@ static int get_prioidx(u32 *prio)
 
 	spin_lock_irqsave(&prioidx_map_lock, flags);
 	prioidx = find_first_zero_bit(prioidx_map, sizeof(unsigned long) * PRIOIDX_SZ);
+	if (prioidx == sizeof(unsigned long) * PRIOIDX_SZ) {
+		spin_unlock_irqrestore(&prioidx_map_lock, flags);
+		return -ENOSPC;
+	}
 	set_bit(prioidx, prioidx_map);
 	spin_unlock_irqrestore(&prioidx_map_lock, flags);
-	if (prioidx == sizeof(unsigned long) * PRIOIDX_SZ)
-		return -ENOSPC;
-
 	atomic_set(&max_prioidx, prioidx);
 	*prio = prioidx;
 	return 0;
-- 
1.7.7.6
