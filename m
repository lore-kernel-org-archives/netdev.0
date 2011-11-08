From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] neigh: increase unres_qlen by one magnitude
Date: Tue, 08 Nov 2011 21:11:25 +0100
Message-ID: <1320783085.2588.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39714 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab1KHUL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 15:11:28 -0500
Received: by wyh15 with SMTP id 15so902030wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 12:11:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unres_qlen is the number of frames we are able to queue per unresolved
neighbour. Its default value (3) was never changed and is responsible
for strange drops, especially if IP fragments are used, or multiple
sessions start in parallel. TCP initial congestion window is now bigger
than 3.

$ arp -d 192.168.20.108 ; ping -c 2 -s 8000 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 8000(8028) bytes of data.
8008 bytes from 192.168.20.108: icmp_seq=2 ttl=64 time=0.322 ms

--- 192.168.20.108 ping statistics ---
2 packets transmitted, 1 received, 50% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.322/0.322/0.322/0.000 ms

Since available memory per machine increased quite a lot since 1999, I
believe its safe to expand unres_qlen to a more reasonable value.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    4 ++++
 net/atm/clip.c                         |    2 +-
 net/decnet/dn_neigh.c                  |    2 +-
 net/ipv4/arp.c                         |    2 +-
 net/ipv6/ndisc.c                       |    2 +-
 5 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index cb7f314..ff44664 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -31,6 +31,10 @@ neigh/default/gc_thresh3 - INTEGER
 	when using large numbers of interfaces and when communicating
 	with large numbers of directly-connected peers.
 
+neigh/default/unres_qlen - INTEGER
+	The maximum number of packets which may be queued for each
+	unresolved address by other network layers.
+
 mtu_expires - INTEGER
 	Time, in seconds, that cached PMTU information is kept.
 
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8523940..50ebab6 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -329,7 +329,7 @@ static struct neigh_table clip_tbl = {
 		.gc_staletime 		= 60 * HZ,
 		.reachable_time 	= 30 * HZ,
 		.delay_probe_time 	= 5 * HZ,
-		.queue_len 		= 3,
+		.queue_len 		= 32,
 		.ucast_probes 		= 3,
 		.mcast_probes 		= 3,
 		.anycast_delay 		= 1 * HZ,
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7f0eb08..c26abe2 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -107,7 +107,7 @@ struct neigh_table dn_neigh_table = {
 		.gc_staletime =	60 * HZ,
 		.reachable_time =		30 * HZ,
 		.delay_probe_time =	5 * HZ,
-		.queue_len =		3,
+		.queue_len =		32,
 		.ucast_probes =	0,
 		.app_probes =		0,
 		.mcast_probes =	0,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96a164a..66e7eb0 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -177,7 +177,7 @@ struct neigh_table arp_tbl = {
 		.gc_staletime		= 60 * HZ,
 		.reachable_time		= 30 * HZ,
 		.delay_probe_time	= 5 * HZ,
-		.queue_len		= 3,
+		.queue_len		= 32,
 		.ucast_probes		= 3,
 		.mcast_probes		= 3,
 		.anycast_delay		= 1 * HZ,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 44e5b7f..0250a88 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -141,7 +141,7 @@ struct neigh_table nd_tbl = {
 		.gc_staletime		= 60 * HZ,
 		.reachable_time		= ND_REACHABLE_TIME,
 		.delay_probe_time	= 5 * HZ,
-		.queue_len		= 3,
+		.queue_len		= 32,
 		.ucast_probes		= 3,
 		.mcast_probes		= 3,
 		.anycast_delay		= 1 * HZ,
