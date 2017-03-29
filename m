From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bonding: refine bond_fold_stats() wrap detection
Date: Wed, 29 Mar 2017 10:45:44 -0700
Message-ID: <1490809544.24891.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36568 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932141AbdC2Rps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:45:48 -0400
Received: by mail-pf0-f194.google.com with SMTP id r137so2687019pfr.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 10:45:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some device drivers reset their stats at down/up events, possibly
fooling bonding stats, since they operate with relative deltas.

It is nearly not possible to fix drivers, since some of them compute the
tx/rx counters based on per rx/tx queue stats, and the queues can be
reconfigured (ethtool -L) between the down/up sequence.

Lets avoid accumulating 'negative' values that render bonding stats
useless.

It is better to lose small deltas, assuming the bonding stats are
fetched at a reasonable frequency.

Fixes: 5f0c5f73e5ef ("bonding: make global bonding stats more reliable")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/bonding/bond_main.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6cea964ab70ad101a13cfd1a9fbabb51e95b2bbf..27359dab78a1d750c520c3a02e5914ea138b093b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3332,12 +3332,17 @@ static void bond_fold_stats(struct rtnl_link_stats64 *_res,
 	for (i = 0; i < sizeof(*_res) / sizeof(u64); i++) {
 		u64 nv = new[i];
 		u64 ov = old[i];
+		s64 delta = nv - ov;
 
 		/* detects if this particular field is 32bit only */
 		if (((nv | ov) >> 32) == 0)
-			res[i] += (u32)nv - (u32)ov;
-		else
-			res[i] += nv - ov;
+			delta = (s64)(s32)((u32)nv - (u32)ov);
+
+		/* filter anomalies, some drivers reset their stats
+		 * at down/up events.
+		 */
+		if (delta > 0)
+			res[i] += delta;
 	}
 }
 
