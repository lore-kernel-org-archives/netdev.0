From: Ralf Baechle <ralf@linux-mips.org>
Subject: NETROM: Fix use of static buffer
Date: Mon, 17 Aug 2009 17:16:36 +0100
Message-ID: <20090817161636.GA26151@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The static variable used by nr_call_to_digi might result in corruption if
multiple threads are trying to usee a node or neighbour via ioctl.  Fixed
by having the caller pass a structure in.  This is safe because nr_add_node
rsp. nr_add_neigh will allocate a permanent structure, if needed.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/netrom/nr_route.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index e943c16..4eb1ac9 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -630,23 +630,23 @@ out:
 	return dev;
 }
 
-static ax25_digi *nr_call_to_digi(int ndigis, ax25_address *digipeaters)
+static ax25_digi *nr_call_to_digi(ax25_digi *digi, int ndigis,
+	ax25_address *digipeaters)
 {
-	static ax25_digi ax25_digi;
 	int i;
 
 	if (ndigis == 0)
 		return NULL;
 
 	for (i = 0; i < ndigis; i++) {
-		ax25_digi.calls[i]    = digipeaters[i];
-		ax25_digi.repeated[i] = 0;
+		digi->calls[i]    = digipeaters[i];
+		digi->repeated[i] = 0;
 	}
 
-	ax25_digi.ndigi      = ndigis;
-	ax25_digi.lastrepeat = -1;
+	digi->ndigi      = ndigis;
+	digi->lastrepeat = -1;
 
-	return &ax25_digi;
+	return digi;
 }
 
 /*
@@ -656,6 +656,7 @@ int nr_rt_ioctl(unsigned int cmd, void __user *arg)
 {
 	struct nr_route_struct nr_route;
 	struct net_device *dev;
+	ax25_digi digi;
 	int ret;
 
 	switch (cmd) {
@@ -673,13 +674,15 @@ int nr_rt_ioctl(unsigned int cmd, void __user *arg)
 			ret = nr_add_node(&nr_route.callsign,
 				nr_route.mnemonic,
 				&nr_route.neighbour,
-				nr_call_to_digi(nr_route.ndigis, nr_route.digipeaters),
+				nr_call_to_digi(&digi, nr_route.ndigis,
+						nr_route.digipeaters),
 				dev, nr_route.quality,
 				nr_route.obs_count);
 			break;
 		case NETROM_NEIGH:
 			ret = nr_add_neigh(&nr_route.callsign,
-				nr_call_to_digi(nr_route.ndigis, nr_route.digipeaters),
+				nr_call_to_digi(&digi, nr_route.ndigis,
+						nr_route.digipeaters),
 				dev, nr_route.quality);
 			break;
 		default:
