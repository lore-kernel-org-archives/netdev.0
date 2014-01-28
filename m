From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 1/2] sit: Unregister sit devices with rtnl_link_ops
Date: Tue, 28 Jan 2014 15:57:57 -0500
Message-ID: <20140128210543.190799134@goodmis.org>
References: <20140128205756.074448668@goodmis.org>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:61791 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755775AbaA1VFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 16:05:46 -0500
Content-Disposition: inline; filename=0001-sit-Unregister-sit-devices-with-rtnl_link_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>

The backport of upstream commit 205983c43700ac3 ("sit: allow to use rtnl
ops on fb tunnel") had a dependency on commit 5e6700b3bf98 ("sit: add
support of x-netns"). The dependency was on the way that commit
unregistered the sit devices.

Since the entire commit 5e6700b3bf98 is not necessary for a backport
we only need to backport the part required for the backport of
205983c43700ac3. This is the loop to unregister the sit devices where
dev->rtnl_link_ops == &sit_link_ops.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 net/ipv6/sit.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0491264..3652033 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1529,6 +1529,10 @@ static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_hea
 {
 	int prio;
 
+	for_each_netdev_safe(net, dev, aux)
+		if (dev->rtnl_link_ops == &sit_link_ops)
+			unregister_netdevice_queue(dev, head);
+
 	for (prio = 1; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
@@ -1536,7 +1540,12 @@ static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_hea
 
 			t = rtnl_dereference(sitn->tunnels[prio][h]);
 			while (t != NULL) {
-				unregister_netdevice_queue(t->dev, head);
+				/* If dev is in the same netns, it has already
+				 * been added to the list by the previous loop.
+				 */
+				if (dev_net(t->dev) != net)
+					unregister_netdevice_queue(t->dev,
+								   head);
 				t = rtnl_dereference(t->next);
 			}
 		}
-- 
1.8.4.3
