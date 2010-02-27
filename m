From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v6 3/3] net: reserve ports for applications using fixed port numbers
Date: Sat, 27 Feb 2010 03:25:52 +0200
Message-ID: <1267233952-5856-4-git-send-email-opurdila@ixiacom.com>
References: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	WANG Cong <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
allows users to reserve ports for third-party applications.

The reserved ports will not be used by automatic port assignments
(e.g. when calling connect() or bind() with port number 0). Explicit
port allocation behavior is unchanged.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 Documentation/networking/ip-sysctl.txt |   31 +++++++++++++++++++++++++++++++
 drivers/infiniband/core/cma.c          |    7 ++++++-
 include/net/ip.h                       |    6 ++++++
 net/ipv4/af_inet.c                     |    8 +++++++-
 net/ipv4/inet_connection_sock.c        |    6 ++++++
 net/ipv4/inet_hashtables.c             |    2 ++
 net/ipv4/sysctl_net_ipv4.c             |   17 +++++++++++++++++
 net/ipv4/udp.c                         |    3 ++-
 net/sctp/socket.c                      |    2 ++
 9 files changed, 79 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 8b72c88..d0536b5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -588,6 +588,37 @@ ip_local_port_range - 2 INTEGERS
 	(i.e. by default) range 1024-4999 is enough to issue up to
 	2000 connections per second to systems supporting timestamps.
 
+ip_local_reserved_ports - list of comma separated ranges
+	Specify the ports which are reserved for known third-party
+	applications. These ports will not be used by automatic port
+	assignments (e.g. when calling connect() or bind() with port
+	number 0). Explicit port allocation behavior is unchanged.
+
+	The format used for both input and output is a comma separated
+	list of ranges (e.g. "1,2-4,10-10" for ports 1, 2, 3, 4 and
+	10). Writing to the file will clear all previously reserved
+	ports and update the current list with the one given in the
+	input.
+
+	Note that ip_local_port_range and ip_local_reserved_ports
+	settings are independent and both are considered by the kernel
+	when determining which ports are available for automatic port
+	assignments.
+
+	You can reserve ports which are not in the current
+	ip_local_port_range, e.g.:
+
+	$ cat /proc/sys/net/ipv4/ip_local_port_range
+	32000	61000
+	$ cat /proc/sys/net/ipv4/ip_local_reserved_ports
+	8080,9148
+
+	although this is redundant. However such a setting is useful
+	if later the port range is changed to a value that will
+	include the reserved ports.
+
+	Default: Empty
+
 ip_nonlocal_bind - BOOLEAN
 	If set, allows processes to bind() to non-local IP addresses,
 	which can be quite useful - but may break some applications.
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 875e34e..06c9fa5 100644
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
@@ -2995,10 +2997,13 @@ static int __init cma_init(void)
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
index 503994a..3da9004 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -184,6 +184,12 @@ extern struct local_ports {
 } sysctl_local_ports;
 extern void inet_get_local_port_range(int *low, int *high);
 
+extern unsigned long *sysctl_local_reserved_ports;
+static inline int inet_is_reserved_local_port(int port)
+{
+	return test_bit(port, sysctl_local_reserved_ports);
+}
+
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 33b7dff..e283fbe 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1546,9 +1546,13 @@ static int __init inet_init(void)
 
 	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
 
+	sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
+	if (!sysctl_local_reserved_ports)
+		goto out;
+
 	rc = proto_register(&tcp_prot, 1);
 	if (rc)
-		goto out;
+		goto out_free_reserved_ports;
 
 	rc = proto_register(&udp_prot, 1);
 	if (rc)
@@ -1647,6 +1651,8 @@ out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
 	proto_unregister(&tcp_prot);
+out_free_reserved_ports:
+	kfree(sysctl_local_reserved_ports);
 	goto out;
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8da6429..1acb462 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -37,6 +37,9 @@ struct local_ports sysctl_local_ports __read_mostly = {
 	.range = { 32768, 61000 },
 };
 
+unsigned long *sysctl_local_reserved_ports;
+EXPORT_SYMBOL(sysctl_local_reserved_ports);
+
 void inet_get_local_port_range(int *low, int *high)
 {
 	unsigned seq;
@@ -108,6 +111,8 @@ again:
 
 		smallest_size = -1;
 		do {
+			if (inet_is_reserved_local_port(rover))
+				goto next_nolock;
 			head = &hashinfo->bhash[inet_bhashfn(net, rover,
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
@@ -130,6 +135,7 @@ again:
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
index c1bc074..82d3c47 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -298,6 +298,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
 	},
+	{
+		.procname	= "ip_local_reserved_ports",
+		.data		= NULL, /* initialized in sysctl_ipv4_init */
+		.maxlen		= 65536,
+		.mode		= 0644,
+		.proc_handler	= proc_do_large_bitmap,
+	},
 #ifdef CONFIG_IP_MULTICAST
 	{
 		.procname	= "igmp_max_memberships",
@@ -735,6 +742,16 @@ static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
 static __init int sysctl_ipv4_init(void)
 {
 	struct ctl_table_header *hdr;
+	struct ctl_table *i;
+
+	for (i = ipv4_table; i->procname; i++) {
+		if (strcmp(i->procname, "ip_local_reserved_ports") == 0) {
+			i->data = sysctl_local_reserved_ports;
+			break;
+		}
+	}
+	if (!i->procname)
+		return -EINVAL;
 
 	hdr = register_sysctl_paths(net_ipv4_ctl_path, ipv4_table);
 	if (hdr == NULL)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 608a544..bfd0a6a 100644
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
