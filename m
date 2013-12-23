From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/1] ipv4: arp: update neighbour address when a gratuitous arp is received and arp_accept is set
Date: Mon, 23 Dec 2013 11:21:32 -0800
Message-ID: <1387826492-25413-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:37819 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab3LWTVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 14:21:50 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so5464121pdj.30
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 11:21:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gratuitous arp packets are useful in switchover scenarios to update
client arp tables as quickly as possible. Currently, the mac address
of a neighbour is only updated after a locktime period has elapsed
since the last update. In most use cases such delays are unacceptable
for network admins. Moreover, the "updated" field of the neighbour
stucture doesn't record the last time the address of a neighbour
changed but records any change that happens to theneighbour. This is
clearly a bug since locktime uses that field as meaning "addr_updated".
With this observation, I was able to perpetuate a stale address by
sending a stream of gratuitous arp packets spaced less than locktime
apart. With this change the address is updated when a gratuitous arp
is received and the arp_accept sysctl is set.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv4/arp.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7808093..c791d09 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -728,6 +728,7 @@ static int arp_process(struct sk_buff *skb)
 	int addr_type;
 	struct neighbour *n;
 	struct net *net = dev_net(dev);
+	bool is_garp = false;
 
 	/* arp_rcv below verifies the ARP header and verifies the device
 	 * is ARP'able.
@@ -894,10 +895,12 @@ static int arp_process(struct sk_buff *skb)
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
+		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
+			  inet_addr_type(net, sip) == RTN_UNICAST;
+
 		if (n == NULL &&
-		    (arp->ar_op == htons(ARPOP_REPLY) ||
-		     (arp->ar_op == htons(ARPOP_REQUEST) && tip == sip)) &&
-		    inet_addr_type(net, sip) == RTN_UNICAST)
+		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
+		      inet_addr_type(net, sip) == RTN_UNICAST) || is_garp))
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
 
@@ -910,7 +913,9 @@ static int arp_process(struct sk_buff *skb)
 		   agents are active. Taking the first reply prevents
 		   arp trashing and chooses the fastest router.
 		 */
-		override = time_after(jiffies, n->updated + n->parms->locktime);
+		override = time_after(jiffies,
+				      n->updated + n->parms->locktime) ||
+			   is_garp;
 
 		/* Broadcast replies and request packets
 		   do not assert neighbour reachability.
-- 
1.7.4.4
