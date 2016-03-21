From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ipv4: fix broadcast packets reception
Date: Mon, 21 Mar 2016 16:42:11 +0100
Message-ID: <b2a74da9e3b01065d0244088c2038c8b6ec1d334.1458574841.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51353 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756004AbcCUPme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 11:42:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ingress ipv4 broadcast datagrams are dropped if the
ingress interface lacks an ipv4 address. This is caused by
multiple issues:

- in udp_v4_early_demux() ip_check_mc_rcu is invoked even on
  bcast packets

- ip_route_input_slow() always try to validate the source

This patch tries to address both issues, invoking ip_check_mc_rcu()
only for mcast packets and calling fib_validate_source() only
if the in_device has an address, at least.

Fixes: 6e5403093261 ("ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/route.c |  6 +++++-
 net/ipv4/udp.c   | 12 ++++++++----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c6229..e86d33d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1867,7 +1867,11 @@ brd_input:
 	if (skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
-	if (!ipv4_is_zeronet(saddr)) {
+	/* Do not validate the source if this device not not have an
+	 * IPv4 address yet and the destination is the broadcast address.
+	 */
+	if (!ipv4_is_zeronet(saddr) && (in_dev->ifa_list ||
+					!ipv4_is_lbcast(daddr))) {
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
 					  in_dev, &itag);
 		if (err < 0)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 836abe5..08eed5e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2070,10 +2070,14 @@ void udp_v4_early_demux(struct sk_buff *skb)
 		if (!in_dev)
 			return;
 
-		ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
-				       iph->protocol);
-		if (!ours)
-			return;
+		/* we are supposed to accept bcast packets */
+		if (skb->pkt_type == PACKET_MULTICAST) {
+			ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
+					       iph->protocol);
+			if (!ours)
+				return;
+		}
+
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
 						   uh->source, iph->saddr, dif);
 	} else if (skb->pkt_type == PACKET_HOST) {
-- 
1.8.3.1
