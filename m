From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/3] dsa: fix freeing of sparse port allocation
Date: Mon, 25 Mar 2013 16:03:40 +0100
Message-ID: <1364223820-26051-4-git-send-email-florian@openwrt.org>
References: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43612 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab3CYPDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 11:03:52 -0400
In-Reply-To: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have defined a sparse port allocation which is non-contiguous and
contains gaps, the code freeing port_names will just stop when it
encouters a first NULL port_names, which is not right, we should iterate
over all possible number of ports (DSA_MAX_PORTS) until we are done.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 net/dsa/dsa.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index aa2ff58..0eb5d5e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -350,9 +350,11 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 
 	for (i = 0; i < pd->nr_chips; i++) {
 		port_index = 0;
-		while (pd->chip[i].port_names &&
-			pd->chip[i].port_names[++port_index])
-			kfree(pd->chip[i].port_names[port_index]);
+		while (port_index < DSA_MAX_PORTS) {
+			if (pd->chip[i].port_names[port_index])
+				kfree(pd->chip[i].port_names[port_index]);
+			port_index++;
+		}
 		kfree(pd->chip[i].rtable);
 	}
 	kfree(pd->chip);
-- 
1.7.10.4
