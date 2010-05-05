From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 3/3] net: reserve ports for applications using fixed port numbers
Date: Wed, 5 May 2010 06:27:06 -0400
Message-ID: <20100505103104.5600.24369.sendpatchset@localhost.localdomain>
References: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>, xiaosuo@gmail.com,
	David Miller <davem@davemloft.net>, adobriyan@gmail.com,
	ebiederm@xmission.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934449Ab0EEK1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 06:27:23 -0400
In-Reply-To: <20100505103033.5600.77502.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(Dropped the infiniband part, because Tetsuo modified the related code,
I will send a separate patch for it once this is accepted.)

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

Index: linux-2.6/Documentation/networking/ip-sysctl.txt
===================================================================
--- linux-2.6.orig/Documentation/networking/ip-sysctl.txt
+++ linux-2.6/Documentation/networking/ip-sysctl.txt
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
Index: linux-2.6/include/net/ip.h
===================================================================
--- linux-2.6.orig/include/net/ip.h
+++ linux-2.6/include/net/ip.h
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
 
Index: linux-2.6/net/ipv4/af_inet.c
===================================================================
--- linux-2.6.orig/net/ipv4/af_inet.c
+++ linux-2.6/net/ipv4/af_inet.c
@@ -1552,9 +1552,13 @@ static int __init inet_init(void)
 
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
@@ -1653,6 +1657,8 @@ out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
 	proto_unregister(&tcp_prot);
+out_free_reserved_ports:
+	kfree(sysctl_local_reserved_ports);
 	goto out;
 }
 
Index: linux-2.6/net/ipv4/inet_connection_sock.c
===================================================================
--- linux-2.6.orig/net/ipv4/inet_connection_sock.c
+++ linux-2.6/net/ipv4/inet_connection_sock.c
@@ -37,6 +37,9 @@ struct local_ports sysctl_local_ports __
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
Index: linux-2.6/net/ipv4/inet_hashtables.c
===================================================================
--- linux-2.6.orig/net/ipv4/inet_hashtables.c
+++ linux-2.6/net/ipv4/inet_hashtables.c
@@ -456,6 +456,8 @@ int __inet_hash_connect(struct inet_time
 		local_bh_disable();
 		for (i = 1; i <= remaining; i++) {
 			port = low + (i + offset) % remaining;
+			if (inet_is_reserved_local_port(port))
+				continue;
 			head = &hinfo->bhash[inet_bhashfn(net, port,
 					hinfo->bhash_size)];
 			spin_lock(&head->lock);
Index: linux-2.6/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-2.6.orig/net/ipv4/sysctl_net_ipv4.c
+++ linux-2.6/net/ipv4/sysctl_net_ipv4.c
@@ -299,6 +299,13 @@ static struct ctl_table ipv4_table[] = {
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
@@ -736,6 +743,16 @@ static __net_initdata struct pernet_oper
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
Index: linux-2.6/net/ipv4/udp.c
===================================================================
--- linux-2.6.orig/net/ipv4/udp.c
+++ linux-2.6/net/ipv4/udp.c
@@ -233,7 +233,8 @@ int udp_lib_get_port(struct sock *sk, un
 			 */
 			do {
 				if (low <= snum && snum <= high &&
-				    !test_bit(snum >> udptable->log, bitmap))
+				    !test_bit(snum >> udptable->log, bitmap) &&
+				    !inet_is_reserved_local_port(snum))
 					goto found;
 				snum += rand;
 			} while (snum != first);
Index: linux-2.6/net/sctp/socket.c
===================================================================
--- linux-2.6.orig/net/sctp/socket.c
+++ linux-2.6/net/sctp/socket.c
@@ -5436,6 +5436,8 @@ static long sctp_get_port_local(struct s
 			rover++;
 			if ((rover < low) || (rover > high))
 				rover = low;
+			if (inet_is_reserved_local_port(rover))
+				continue;
 			index = sctp_phashfn(rover);
 			head = &sctp_port_hashtable[index];
 			sctp_spin_lock(&head->lock);
