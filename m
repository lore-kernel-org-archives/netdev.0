From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: try to not exhaust ip_local_port_range
 in connect()
Date: Sun, 24 May 2015 14:49:35 -0700
Message-ID: <1432504175.4060.155.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33528 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbbEXVti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2015 17:49:38 -0400
Received: by igbpi8 with SMTP id pi8so25925996igb.0
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 14:49:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A long standing problem on busy servers is the tiny available TCP port
range (/proc/sys/net/ipv4/ip_local_port_range) and the default
sequential allocation of source ports in connect() system call.

If a host is having a lot of active TCP sessions, chances are
very high that all ports are in use by at least one flow,
and subsequent bind(0) attempts fail, or have to scan a big portion of
space to find a slot.

In this patch, I changed the starting point in __inet_hash_connect()
so that we try to favor even [1] ports, leaving odd ports for bind()
users.

We still perform a sequential search, so there is no guarantee, but
if connect() targets are very different, end result is we leave
more ports available to bind(), and we spread them all over the range,
lowering time for both connect() and bind() to find a slot.

This strategy only works well if /proc/sys/net/ipv4/ip_local_port_range
is even, ie if start/end values have different parity.

Therefore, default /proc/sys/net/ipv4/ip_local_port_range was changed to
32768 - 60999 (instead of 32768 - 61000)

There is no change on security aspects here, only some poor hashing
schemes could be eventually impacted by this change.

[1] : The odd/even property depends on ip_local_port_range values parity

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt |    8 +++++---
 net/ipv4/af_inet.c                     |    2 +-
 net/ipv4/inet_hashtables.c             |   10 ++++++++--
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index cb083e0d682c6faae13aea21aa1a88868a39c632..5fae7704daab292cf900158666c2d4bb80dd2424 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -751,8 +751,10 @@ IP Variables:
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the
-	second the last local port number. The default values are
-	32768 and 61000 respectively.
+	second the last local port number.
+	If possible, it is better these numbers have different parity.
+	(one even and one odd values)
+	The default values are 32768 and 60999 respectively.
 
 ip_local_reserved_ports - list of comma separated ranges
 	Specify the ports which are reserved for known third-party
@@ -775,7 +777,7 @@ ip_local_reserved_ports - list of comma separated ranges
 	ip_local_port_range, e.g.:
 
 	$ cat /proc/sys/net/ipv4/ip_local_port_range
-	32000	61000
+	32000	60999
 	$ cat /proc/sys/net/ipv4/ip_local_reserved_ports
 	8080,9148
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 235d36afece3b53f5fd5f795f28d15f6f2a79ab6..6ad0f7a711c97b4dabcd328509b9a38ef8a159f5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1595,7 +1595,7 @@ static __net_init int inet_init_net(struct net *net)
 	 */
 	seqlock_init(&net->ipv4.ip_local_ports.lock);
 	net->ipv4.ip_local_ports.range[0] =  32768;
-	net->ipv4.ip_local_ports.range[1] =  61000;
+	net->ipv4.ip_local_ports.range[1] =  60999;
 
 	seqlock_init(&net->ipv4.ping_group_range.lock);
 	/*
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 3766bddb3e8a7303123aa7e32507f6f7801c10d5..8c0fc6fbc1afa08baf07ca86e98aa966a3f8e826 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -501,8 +501,14 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
 
+		/* By starting with offset being an even number,
+		 * we tend to leave about 50% of ports for other uses,
+		 * like bind(0).
+		 */
+		offset &= ~1;
+
 		local_bh_disable();
-		for (i = 1; i <= remaining; i++) {
+		for (i = 0; i < remaining; i++) {
 			port = low + (i + offset) % remaining;
 			if (inet_is_local_reserved_port(net, port))
 				continue;
@@ -546,7 +552,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		return -EADDRNOTAVAIL;
 
 ok:
-		hint += i;
+		hint += (i + 2) & ~1;
 
 		/* Head lock still held and bh's disabled */
 		inet_bind_hash(sk, tb, port);
