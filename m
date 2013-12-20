From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/1] ipv4: arp: Always update neighbour address when a gratuitous arp is received
Date: Thu, 19 Dec 2013 21:41:12 -0800
Message-ID: <1387518072-8076-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:46358 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab3LTFlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 00:41:35 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so2156883pad.24
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 21:41:34 -0800 (PST)
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
apart.

Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
---
 net/ipv4/arp.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7808093..ab13347 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -910,7 +910,10 @@ static int arp_process(struct sk_buff *skb)
 		   agents are active. Taking the first reply prevents
 		   arp trashing and chooses the fastest router.
 		 */
-		override = time_after(jiffies, n->updated + n->parms->locktime);
+		override = time_after(jiffies,
+				      n->updated + n->parms->locktime) ||
+			   (tip == sip &&
+			    inet_addr_type(net, sip) == RTN_UNICAST);
 
 		/* Broadcast replies and request packets
 		   do not assert neighbour reachability.
-- 
1.7.4.4
