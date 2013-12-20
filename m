From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/1] ipv4: arp: Always update neighbour address when a gratuitous arp is received
Date: Fri, 20 Dec 2013 10:59:22 -0800
Message-ID: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:39099 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab3LTS7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:59:38 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so2960517pbc.25
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:59:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gratuitous arp packets are useful in switchover scenarios to update
client arp tables as quickly as possible. Currently, the mac address
of a neighbour is only updated after a locktime period has elapsed
since the last update. In most use cases such delays are unacceptable
for network admins. Moreover, the "updated" field of the neighbour
stucture doesn't record the last time the address of a neighbour
changed but records any change that happens to the neighbour. This is
clearly a bug since locktime uses that field as meaning "addr_updated".
With this observation, I was able to perpetuate a stale address by
sending a stream of gratuitous arp packets spaced less than locktime
apart.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv4/arp.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7808093..6597708 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -904,13 +904,19 @@ static int arp_process(struct sk_buff *skb)
 	if (n) {
 		int state = NUD_REACHABLE;
 		int override;
+		bool is_garp = tip == sip &&
+			       inet_addr_type(net, sip) == RTN_UNICAST;
 
 		/* If several different ARP replies follows back-to-back,
 		   use the FIRST one. It is possible, if several proxy
 		   agents are active. Taking the first reply prevents
-		   arp trashing and chooses the fastest router.
+		   arp trashing and chooses the fastest router. In the
+		   case of gratuitous arp we always set override in order
+		   to update the address.
 		 */
-		override = time_after(jiffies, n->updated + n->parms->locktime);
+		override = time_after(jiffies,
+				      n->updated + n->parms->locktime) ||
+			   is_garp;
 
 		/* Broadcast replies and request packets
 		   do not assert neighbour reachability.
-- 
1.7.4.4
