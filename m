From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 3/3] net: reserve ports for applications using fixed port numbers
Date: Thu, 11 Feb 2010 04:09:20 +0200
Message-ID: <1265854160-11763-4-git-send-email-opurdila@ixiacom.com>
References: <1265854160-11763-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vget.kernel.org,
	linux-kernel@vger.kernel.org, WANG Cong <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265854160-11763-1-git-send-email-opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports
(bitmap type) which allows users to reserve ports for third-party
applications.

The reserved ports will not be used by automatic port assignments
(e.g. when calling connect() or bind() with port number 0). Explicit
port allocation behavior is unchanged.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 drivers/infiniband/core/cma.c          |    7 ++++++-
 include/net/ip.h                       |    6 ++++++
 net/ipv4/inet_connection_sock.c        |    5 +++++
 net/ipv4/inet_hashtables.c             |    2 ++
 net/ipv4/sysctl_net_ipv4.c             |    7 +++++++
 net/ipv4/udp.c                         |    3 ++-
 net/sctp/socket.c                      |    2 ++
 8 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 2dc7a1d..23be7a4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -564,6 +564,18 @@ ip_local_port_range - 2 INTEGERS
 	(i.e. by default) range 1024-4999 is enough to issue up to
 	2000 connections per second to systems supporting timestamps.
 
+ip_local_reserved_ports - BITMAP of 65536 ports
+	Specify the ports which are reserved for known third-party
+	applications. These ports will not be used by automatic port assignments
+	(e.g. when calling connect() or bind() with port number 0). Explicit
+	port allocation behavior is unchanged.
+
+	Reserving ports is done by writing positive numbers in this proc entry,
+	clearing them is done by writing negative numbers (e.g. 8080 reserves
+	port number, -8080 makes it available for automatic assignment again).
+
+	Default: Empty
+
 ip_nonlocal_bind - BOOLEAN
 	If set, allows processes to bind() to non-local IP addresses,
 	which can be quite useful - but may break some applications.
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index cc9b594..8248fc6 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1979,6 +1979,8 @@ retry:
 	/* FIXME: add proper port randomization per like inet_csk_get_port */
 	do {
 		ret = idr_get_new_above(ps, bind_list, next_port, &port);
+		if (inet_is_reserved_local_port(port))
+			ret = -EAGAIN;
 	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
 
 	if (ret)
@@ -2997,10 +2999,13 @@ static int __init cma_init(void)
 {
 	int ret, low, high, remaining;
 
-	get_random_bytes(&next_port, sizeof next_port);
 	inet_get_local_port_range(&low, &high);
+again:
+	get_random_bytes(&next_port, sizeof next_port);
 	remaining = (high - low) + 1;
 	next_port = ((unsigned int) next_port % remaining) + low;
+	if (inet_is_reserved_local_port(next_port))
+		goto again;
 
 	cma_wq = create_singlethread_workqueue("rdma_cm");
 	if (!cma_wq)
diff --git a/include/net/ip.h b/include/net/ip.h
index fb63371..ada8589 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -184,6 +184,12 @@ extern struct local_ports {
 } sysctl_local_ports;
 extern void inet_get_local_port_range(int *low, int *high);
 
+extern unsigned long sysctl_local_reserved_ports[65536/8/sizeof(unsigned long)];
+static inline int inet_is_reserved_local_port(int port)
+{
+	return test_bit(port, sysctl_local_reserved_ports);
+}
+
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8da6429..febfc6c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -37,6 +37,8 @@ struct local_ports sysctl_local_ports __read_mostly = {
 	.range = { 32768, 61000 },
 };
 
+unsigned long sysctl_local_reserved_ports[65536/BITS_PER_LONG];
+
 void inet_get_local_port_range(int *low, int *high)
 {
 	unsigned seq;
@@ -108,6 +110,8 @@ again:
 
 		smallest_size = -1;
 		do {
+			if (inet_is_reserved_local_port(rover))
+				goto next_nolock;
 			head = &hashinfo->bhash[inet_bhashfn(net, rover,
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
@@ -130,6 +134,7 @@ again:
 			break;
 		next:
 			spin_unlock(&head->lock);
+		next_nolock:
 			if (++rover > high)
 				rover = low;
 		} while (--remaining > 0);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2b79377..d3e160a 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -456,6 +456,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		local_bh_disable();
 		for (i = 1; i <= remaining; i++) {
 			port = low + (i + offset) % remaining;
+			if (inet_is_reserved_local_port(port))
+				continue;
 			head = &hinfo->bhash[inet_bhashfn(net, port,
 					hinfo->bhash_size)];
 			spin_lock(&head->lock);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7e3712c..48ca149 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -298,6 +298,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
 	},
+	{
+		.procname	= "ip_local_reserved_ports",
+		.data		= sysctl_local_reserved_ports,
+		.maxlen		= 65536,
+		.mode		= 0644,
+		.proc_handler	= proc_dobitmap,
+	},
 #ifdef CONFIG_IP_MULTICAST
 	{
 		.procname	= "igmp_max_memberships",
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4f7d212..705e032 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -232,7 +232,8 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			 */
 			do {
 				if (low <= snum && snum <= high &&
-				    !test_bit(snum >> udptable->log, bitmap))
+				    !test_bit(snum >> udptable->log, bitmap) &&
+				    !inet_is_reserved_local_port(snum))
 					goto found;
 				snum += rand;
 			} while (snum != first);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f6d1e59..1f839d0 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5432,6 +5432,8 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 			rover++;
 			if ((rover < low) || (rover > high))
 				rover = low;
+			if (inet_is_reserved_local_port(rover))
+				continue;
 			index = sctp_phashfn(rover);
 			head = &sctp_port_hashtable[index];
 			sctp_spin_lock(&head->lock);
-- 
1.5.6.5
