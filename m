From: sfeldma@gmail.com
Subject: [PATCH net-next 2/5] rocker: mark neigh update event processing as 'no wait'
Date: Fri, 12 Jun 2015 21:35:47 -0700
Message-ID: <1434170150-63838-3-git-send-email-sfeldma@gmail.com>
References: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33082 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbFMEeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:34:03 -0400
Received: by igbpi8 with SMTP id pi8so23455939igb.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:34:02 -0700 (PDT)
In-Reply-To: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Neigh update event handler runs in a context where we can't sleep, so mark
processing in driver with ROCKER_OP_FLAG_NOWAIT.  NOWAIT will use
GFP_ATOMIC for allocations and will queue cmds to the device's cmd ring but
will not wait (sleep) for cmd response back from device.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c1910c1..1995b59 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -5251,7 +5251,8 @@ static struct notifier_block rocker_netdevice_nb __read_mostly = {
 static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = (n->nud_state & NUD_VALID) ? 0 : ROCKER_OP_FLAG_REMOVE;
+	int flags = (n->nud_state & NUD_VALID ? 0 : ROCKER_OP_FLAG_REMOVE) |
+		    ROCKER_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
 
 	return rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
-- 
1.7.10.4
