From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/2] ipv4: new ip_no_pmtu_disc mode to always discard incoming frag needed msgs
Date: Sat, 14 Dec 2013 05:13:45 +0100
Message-ID: <20131214041345.GO23247@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54761 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab3LNENq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 23:13:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new mode discards all incoming fragmentation-needed notifications
as I guess was originally intended with this knob. To not break backward
compatibility too much, I only added a special case for mode 2 in the
receiving path.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

I am sorry to create a merge conflict if the patch "ipv4: improve
documentation of ip_no_pmtu_disc" gets applied to net first. David, can you
handle that or can I help somehow?

 Documentation/networking/ip-sysctl.txt | 10 ++++++++--
 net/ipv4/icmp.c                        |  4 +++-
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f76d177..d71afa8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -15,12 +15,18 @@ ip_default_ttl - INTEGER
 	forwarded) IP packets. Should be between 1 and 255 inclusive.
 	Default: 64 (as recommended by RFC1700)
 
-ip_no_pmtu_disc - BOOLEAN
-	Disable Path MTU Discovery. If enabled and a
+ip_no_pmtu_disc - INTEGER
+	Disable Path MTU Discovery. If enabled in mode 1 and a
 	fragmentation-required ICMP is received, the PMTU to this
 	destination will be set to min_pmtu (see below). You will need
 	to raise min_pmtu to the smallest interface MTU on your system
 	manually if you want to avoid locally generated fragments.
+
+	In mode 2 incoming Path MTU Discovery messages will be
+	discarded. Outgoing frames are handled the same as in mode 1,
+	implicitly setting IP_PMTUDISC_DONT on every created socket.
+
+	Possible values: 0-2
 	Default: FALSE
 
 min_pmtu - INTEGER
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 1a4ee84..fb3c563 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -705,7 +705,9 @@ static void icmp_unreach(struct sk_buff *skb)
 		case ICMP_PORT_UNREACH:
 			break;
 		case ICMP_FRAG_NEEDED:
-			if (net->ipv4.sysctl_ip_no_pmtu_disc) {
+			if (net->ipv4.sysctl_ip_no_pmtu_disc == 2) {
+				goto out;
+			} else if (net->ipv4.sysctl_ip_no_pmtu_disc) {
 				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
 					       &iph->daddr);
 			} else {
-- 
1.8.3.1
