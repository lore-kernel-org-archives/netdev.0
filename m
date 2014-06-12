From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: ipv4: do not waste time in
 __udp4_lib_mcast_demux_lookup
Date: Thu, 12 Jun 2014 16:13:06 -0700
Message-ID: <1402614786.3645.500.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	David Held <drheld@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:65245 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaFLXNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 19:13:08 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so1442738pad.6
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 16:13:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Its too easy to add thousand of UDP sockets on a particular bucket,
and slow down an innocent multicast receiver.

Early demux is supposed to be an optimization, we should avoid spending
too much time in it.

It is interesting to note __udp4_lib_demux_lookup() only tries to
match first socket in the chain.

10 is the threshold we already have in __udp4_lib_lookup() to switch
to secondary hash.

Fixes: 421b3885bf6d5 ("udp: ipv4: Add udp early demux")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: David Held <drheld@google.com>
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 net/ipv4/udp.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 185ed3e59802..7064dbfa8101 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1861,6 +1861,10 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 	unsigned int count, slot = udp_hashfn(net, hnum, udp_table.mask);
 	struct udp_hslot *hslot = &udp_table.hash[slot];
 
+	/* Do not bother scanning a too big list */
+	if (hslot->count > 10)
+		return NULL;
+
 	rcu_read_lock();
 begin:
 	count = 0;
