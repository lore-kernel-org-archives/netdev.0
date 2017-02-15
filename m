From: Marcus Huewe <suse-tux@gmx.de>
Subject: [PATCH net] net: neigh: Fix netevent
 NETEVENT_DELAY_PROBE_TIME_UPDATE notification
Date: Wed, 15 Feb 2017 01:00:36 +0100
Message-ID: <20170215000036.qzzglyaasqfy7vsn@linux.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:59100 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750791AbdBOAAp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 19:00:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting a neigh related sysctl parameter, we always send a
NETEVENT_DELAY_PROBE_TIME_UPDATE netevent. For instance, when
executing

	sysctl net.ipv6.neigh.wlp3s0.retrans_time_ms=2000

a NETEVENT_DELAY_PROBE_TIME_UPDATE netevent is generated.

This is caused by commit 2a4501ae18b5 ("neigh: Send a
notification when DELAY_PROBE_TIME changes"). According to the
commit's description, it was intended to generate such an event
when setting the "delay_first_probe_time" sysctl parameter.

In order to fix this, only generate this event when actually
setting the "delay_first_probe_time" sysctl parameter. This fix
should not have any unintended side-effects, because all but one
registered netevent callbacks check for other netevent event
types (the registered callbacks were obtained by grepping for
"register_netevent_notifier"). The only callback that uses the
NETEVENT_DELAY_PROBE_TIME_UPDATE event is
mlxsw_sp_router_netevent_event() (in
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c): in case
of this event, it only accesses the DELAY_PROBE_TIME of the
passed neigh_parms.

Signed-off-by: Marcus Huewe <suse-tux@gmx.de>
---
 net/core/neighbour.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 7bb12e07ffef..e7c12caa20c8 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2923,7 +2923,8 @@ static void neigh_proc_update(struct ctl_table *ctl, int write)
 		return;
 
 	set_bit(index, p->data_state);
-	call_netevent_notifiers(NETEVENT_DELAY_PROBE_TIME_UPDATE, p);
+	if (index == NEIGH_VAR_DELAY_PROBE_TIME)
+		call_netevent_notifiers(NETEVENT_DELAY_PROBE_TIME_UPDATE, p);
 	if (!dev) /* NULL dev means this is default value */
 		neigh_copy_dflt_parms(net, p, index);
 }
-- 
2.11.0
