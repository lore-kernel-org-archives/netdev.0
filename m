From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next] inet: introduce a sysctl ip_local_ports_strict_use
Date: Wed, 22 Jul 2015 17:07:37 -0700
Message-ID: <1437610057-13197-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: edumazet@google.com, davem@davemloft.net,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36792 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbbGWAHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 20:07:55 -0400
Received: by pachj5 with SMTP id hj5so146520346pac.3
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 17:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mesos network isolator [1] uses a port range based solution to isolate
network traffic to different containers. One problem with this solution
is that when some application _explicitly_ binds to a port which is not
in its own range, bind() still succeeds but no traffic would even go to
that port.

For a real example, named randomly selects some port to bind() for
security concern. (It doesn't use bind(0) to let kernel to select port
because it is not random enough, kernel usually just picks the next
available.) When running named on a Mesos controlled host, named would
silently fail when it binds a port assigned to a Mesos container.

This patch aims to fix this by introducing a new sysctl
ip_local_ports_strict_use, which forces such bind() to fail early when
the given port is out of the range defined by ip_local_port_range but
within the _default_ ephemeral port range defined by Linux,
[32768 - 60999]. Well-known ports (that is [1-32767]) are not affected
at all.

We could possibly make this sysctl accept a port range, rather than
just a boolean, to explicitly specify the forbidden port range, but we
would need to corporate with ip_local_port_range too, not sure if that
would be better than this patch.

1. https://github.com/apache/mesos/blob/master/docs/network-monitoring.md

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  7 +++++++
 include/net/ip.h                       |  4 ++++
 include/net/netns/ipv4.h               |  1 +
 net/ipv4/af_inet.c                     |  4 ++--
 net/ipv4/inet_connection_sock.c        | 19 +++++++++++++++++++
 net/ipv4/inet_hashtables.c             |  3 +++
 net/ipv4/sysctl_net_ipv4.c             |  7 +++++++
 net/ipv4/udp.c                         |  3 +++
 net/sctp/socket.c                      |  5 ++++-
 9 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1a5ab21b..9564fc3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -787,6 +787,13 @@ ip_local_reserved_ports - list of comma separated ranges
 
 	Default: Empty
 
+ip_local_ports_strict_use - INTEGER
+	If set, disallows applications to bind() to or connect() with a specific
+	port which is out of the range defined by ip_local_port_range but
+	within the default ephemeral port range defined by Linux,
+	[32768 - 60999].
+	Default: 0
+
 ip_nonlocal_bind - BOOLEAN
 	If set, allows processes to bind() to non-local IP addresses,
 	which can be quite useful - but may break some applications.
diff --git a/include/net/ip.h b/include/net/ip.h
index 0750a18..fe0a2c4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -212,6 +212,10 @@ static inline u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_o
 #endif
 
 void inet_get_local_port_range(struct net *net, int *low, int *high);
+bool inet_check_local_ports_strict_use(struct net *net, unsigned short snum);
+
+#define DEFAULT_EPHEMERAL_MIN_PORT 32768
+#define DEFAULT_EPHEMERAL_MAX_PORT 60999
 
 #ifdef CONFIG_SYSCTL
 static inline int inet_is_local_reserved_port(struct net *net, int port)
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index c68926b..516b6e6 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -80,6 +80,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_ecn;
 	int sysctl_tcp_ecn_fallback;
 
+	int sysctl_local_ports_strict_use;
 	int sysctl_ip_no_pmtu_disc;
 	int sysctl_ip_fwd_use_pmtu;
 	int sysctl_ip_nonlocal_bind;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9532ee8..fbc767a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1597,8 +1597,8 @@ static __net_init int inet_init_net(struct net *net)
 	 * Set defaults for local port range
 	 */
 	seqlock_init(&net->ipv4.ip_local_ports.lock);
-	net->ipv4.ip_local_ports.range[0] =  32768;
-	net->ipv4.ip_local_ports.range[1] =  60999;
+	net->ipv4.ip_local_ports.range[0] =  DEFAULT_EPHEMERAL_MIN_PORT;
+	net->ipv4.ip_local_ports.range[1] =  DEFAULT_EPHEMERAL_MAX_PORT;
 
 	seqlock_init(&net->ipv4.ping_group_range.lock);
 	/*
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 60021d0..34b74cb 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -43,6 +43,23 @@ void inet_get_local_port_range(struct net *net, int *low, int *high)
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
+bool inet_check_local_ports_strict_use(struct net *net, unsigned short snum)
+{
+	int low, high;
+
+	inet_get_local_port_range(net, &low, &high);
+
+	if (net->ipv4.sysctl_local_ports_strict_use) {
+		if ((snum < low || snum > high) &&
+		    (snum >= DEFAULT_EPHEMERAL_MIN_PORT &&
+		     snum <= DEFAULT_EPHEMERAL_MAX_PORT))
+			return true;
+	}
+
+	return false;
+}
+EXPORT_SYMBOL(inet_check_local_ports_strict_use);
+
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb, bool relax)
 {
@@ -175,6 +192,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		 */
 		snum = rover;
 	} else {
+		if (inet_check_local_ports_strict_use(net, snum))
+			goto fail;
 have_snum:
 		head = &hashinfo->bhash[inet_bhashfn(net, snum,
 				hashinfo->bhash_size)];
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index f8b3701..8cfb350 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -562,6 +562,9 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 
 		ret = 0;
 		goto out;
+	} else {
+		if (inet_check_local_ports_strict_use(net, snum))
+			return 1;
 	}
 
 	head = &hinfo->bhash[inet_bhashfn(net, snum, hinfo->bhash_size)];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 433231c..384a076 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -850,6 +850,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_do_large_bitmap,
 	},
 	{
+		.procname	= "ip_local_ports_strict_use",
+		.data		= &init_net.ipv4.sysctl_local_ports_strict_use,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "ip_no_pmtu_disc",
 		.data		= &init_net.ipv4.sysctl_ip_no_pmtu_disc,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604..92d6b48 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -256,6 +256,9 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		} while (++first != last);
 		goto fail;
 	} else {
+		if (inet_check_local_ports_strict_use(net, snum))
+			goto fail;
+
 		hslot = udp_hashslot(udptable, net, snum);
 		spin_lock_bh(&hslot->lock);
 		if (hslot->count > 10) {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1425ec2..8dc59fa 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6141,6 +6141,7 @@ static struct sctp_bind_bucket *sctp_bucket_create(
 static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 {
 	struct sctp_bind_hashbucket *head; /* hash list */
+	struct net *net = sock_net(sk);
 	struct sctp_bind_bucket *pp;
 	unsigned short snum;
 	int ret;
@@ -6155,7 +6156,6 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		/* Search for an available port. */
 		int low, high, remaining, index;
 		unsigned int rover;
-		struct net *net = sock_net(sk);
 
 		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
@@ -6190,6 +6190,9 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		 */
 		snum = rover;
 	} else {
+		if (inet_check_local_ports_strict_use(net, snum))
+			goto fail;
+
 		/* We are given an specific port number; we verify
 		 * that it is not being used. If it is used, we will
 		 * exahust the search in the hash list corresponding
-- 
1.8.3.1
