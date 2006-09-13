From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH] make ipv4 multicast packets only get delivered to sockets
	that are joined to group
Date: Wed, 13 Sep 2006 10:13:55 -0400
Message-ID: <1158156835.15449.40.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55181 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750854AbWIMON5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 10:13:57 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The situation is this:

Two programs have opened IPv4 UDP sockets, set SO_REUSEADDR on them, and
are bound to INADDR_ANY on the same port. One program joins a multicast
group address, the other program joins a different one. When a multicast
packet is sent to this port on one of the group addresses to which these
sockets are bound, both sockets get delivered a copy of the packet. Only
the socket that is bound to the group address to which the packet was
sent should get it.

The issue seems to be that there is no actual check to see if the socket
is joined to the multicast group. This patch adds such a check, and
corrected the problem on my test rig.

I looked briefly at the ipv6 equivalent code, and it appears to already
handle this correctly with a check near the top of inet6_mc_check(). I
have not actually verified this, however.

This patch should apply cleanly to Linus' git tree as of last night.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net> 

--- linux-2.6/net/ipv4/udp.c.mcast-filter
+++ linux-2.6/net/ipv4/udp.c
@@ -286,6 +286,8 @@ static inline struct sock *udp_v4_mcast_
 	struct hlist_node *node;
 	struct sock *s = sk;
 	unsigned short hnum = ntohs(loc_port);
+	struct ip_mc_socklist *mc_list;
+	int matched;
 
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
@@ -299,6 +301,23 @@ static inline struct sock *udp_v4_mcast_
 			continue;
 		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))
 			continue;
+
+		/* only deliver multicast packets to sockets that are
+		 * explicitly joined to the multicast group */
+		if (MULTICAST(loc_addr)) {
+			matched = 0;
+			for (mc_list=inet->mc_list ; mc_list;
+			     mc_list=mc_list->next) {
+				if (mc_list->multi.imr_multiaddr.s_addr ==
+				    loc_addr) {
+					matched = 1;
+					break;
+				}
+			}
+			if (!matched)
+				continue;
+		}
+
 		goto found;
   	}
 	s = NULL;


