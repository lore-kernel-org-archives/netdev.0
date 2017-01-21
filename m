From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH v3 net-next] Introduce a sysctl that modifies the value of
 PROT_SOCK.
Date: Fri, 20 Jan 2017 17:49:11 -0800
Message-ID: <20170121014911.GB2598@templeofstupid.com>
References: <1484231997.15816.36.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161231125505.7f0c7dff@xeon-e3>
 <20170112065225.GB2345@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:59924 "EHLO
        homiemail-a51.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752638AbdAUBtO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 20:49:14 -0500
Received: from homiemail-a51.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a51.g.dreamhost.com (Postfix) with ESMTP id 235DD6003E26
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 17:49:13 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a51.g.dreamhost.com (Postfix) with ESMTPSA id D47236003E1D
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 17:49:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484231997.15816.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add net.ipv4.ip_unprivileged_port_start, which is a per namespace sysctl
that denotes the first unprivileged inet port in the namespace.  To
disable all privileged ports set this to zero.  It also checks for
overlap with the local port range.  The privileged and local range may
not overlap.

The use case for this change is to allow containerized processes to bind
to priviliged ports, but prevent them from ever being allowed to modify
their container's network configuration.  The latter is accomplished by
ensuring that the network namespace is not a child of the user
namespace.  This modification was needed to allow the container manager
to disable a namespace's priviliged port restrictions without exposing
control of the network namespace to processes in the user namespace.

Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 Documentation/networking/ip-sysctl.txt |  9 ++++++
 include/net/ip.h                       | 10 +++++++
 include/net/netns/ipv4.h               |  1 +
 net/ipv4/af_inet.c                     |  5 +++-
 net/ipv4/sysctl_net_ipv4.c             | 50 +++++++++++++++++++++++++++++++++-
 net/ipv6/af_inet6.c                    |  3 +-
 net/netfilter/ipvs/ip_vs_ctl.c         |  7 ++---
 net/sctp/socket.c                      | 10 ++++---
 security/selinux/hooks.c               |  3 +-
 9 files changed, 86 insertions(+), 12 deletions(-)

Changes v1 -> v2:

Remove LOWPORT_SYSCTL config option.  This is now always enabled as long
as CONFIG_SYSCTL is.

Changes v2 -> v3:

Add documentation to ip-sysctl.txt.
Rename "protected" variables and functions to "privileged."

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index aa1bb49..17f2e77 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -822,6 +822,15 @@ ip_local_reserved_ports - list of comma separated ranges
 
 	Default: Empty
 
+ip_unprivileged_port_start - INTEGER
+	This is a per-namespace sysctl.  It defines the first
+	unprivileged port in the network namespace.  Privileged ports
+	require root or CAP_NET_BIND_SERVICE in order to bind to them.
+	To disable all privileged ports, set this to 0.  It may not
+	overlap with the ip_local_reserved_ports range.
+
+	Default: 1024
+
 ip_nonlocal_bind - BOOLEAN
 	If set, allows processes to bind() to non-local IP addresses,
 	which can be quite useful - but may break some applications.
diff --git a/include/net/ip.h b/include/net/ip.h
index ab6761a..bf264a8 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -263,11 +263,21 @@ static inline bool sysctl_dev_name_is_allowed(const char *name)
 	return strcmp(name, "default") != 0  && strcmp(name, "all") != 0;
 }
 
+static inline int inet_prot_sock(struct net *net)
+{
+	return net->ipv4.sysctl_ip_prot_sock;
+}
+
 #else
 static inline int inet_is_local_reserved_port(struct net *net, int port)
 {
 	return 0;
 }
+
+static inline int inet_prot_sock(struct net *net)
+{
+	return PROT_SOCK;
+}
 #endif
 
 __be32 inet_current_timestamp(void);
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 8e3f5b6..e365732 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -135,6 +135,7 @@ struct netns_ipv4 {
 
 #ifdef CONFIG_SYSCTL
 	unsigned long *sysctl_local_reserved_ports;
+	int sysctl_ip_prot_sock;
 #endif
 
 #ifdef CONFIG_IP_MROUTE
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index aae410b..28fe8da 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -479,7 +479,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	snum = ntohs(addr->sin_port);
 	err = -EACCES;
-	if (snum && snum < PROT_SOCK &&
+	if (snum && snum < inet_prot_sock(net) &&
 	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		goto out;
 
@@ -1700,6 +1700,9 @@ static __net_init int inet_init_net(struct net *net)
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
 	net->ipv4.sysctl_ip_dynaddr = 0;
 	net->ipv4.sysctl_ip_early_demux = 1;
+#ifdef CONFIG_SYSCTL
+	net->ipv4.sysctl_ip_prot_sock = PROT_SOCK;
+#endif
 
 	return 0;
 }
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c8d2836..1b86199 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -35,6 +35,8 @@ static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 static int tcp_adv_win_scale_min = -31;
 static int tcp_adv_win_scale_max = 31;
+static int ip_privileged_port_min;
+static int ip_privileged_port_max = 65535;
 static int ip_ttl_min = 1;
 static int ip_ttl_max = 255;
 static int tcp_syn_retries_min = 1;
@@ -79,7 +81,12 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 
 	if (write && ret == 0) {
-		if (range[1] < range[0])
+		/* Ensure that the upper limit is not smaller than the lower,
+		 * and that the lower does not encroach upon the privileged
+		 * port limit.
+		 */
+		if ((range[1] < range[0]) ||
+		    (range[0] < net->ipv4.sysctl_ip_prot_sock))
 			ret = -EINVAL;
 		else
 			set_local_port_range(net, range);
@@ -88,6 +95,40 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 	return ret;
 }
 
+/* Validate changes from /proc interface. */
+static int ipv4_privileged_ports(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+	    ipv4.sysctl_ip_prot_sock);
+	int ret;
+	int pports;
+	int range[2];
+	struct ctl_table tmp = {
+		.data = &pports,
+		.maxlen = sizeof(pports),
+		.mode = table->mode,
+		.extra1 = &ip_privileged_port_min,
+		.extra2 = &ip_privileged_port_max,
+	};
+
+	pports = net->ipv4.sysctl_ip_prot_sock;
+
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0) {
+		inet_get_local_port_range(net, &range[0], &range[1]);
+		/* Ensure that the local port range doesn't overlap with the
+		 * privileged port range.
+		 */
+		if (range[0] < pports)
+			ret = -EINVAL;
+		else
+			net->ipv4.sysctl_ip_prot_sock = pports;
+	}
+
+	return ret;
+}
 
 static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low, kgid_t *high)
 {
@@ -964,6 +1005,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "ip_unprivileged_port_start",
+		.maxlen		= sizeof(int),
+		.data		= &init_net.ipv4.sysctl_ip_prot_sock,
+		.mode		= 0644,
+		.proc_handler	= ipv4_privileged_ports,
+	},
 	{ }
 };
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index aa42123..04db406 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -302,7 +302,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		return -EINVAL;
 
 	snum = ntohs(addr->sin6_port);
-	if (snum && snum < PROT_SOCK && !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
+	if (snum && snum < inet_prot_sock(net) &&
+	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
 	lock_sock(sk);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 55e0169..8b7416f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -426,10 +426,9 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol
 	 */
 	svc = __ip_vs_service_find(ipvs, af, protocol, vaddr, vport);
 
-	if (svc == NULL
-	    && protocol == IPPROTO_TCP
-	    && atomic_read(&ipvs->ftpsvc_counter)
-	    && (vport == FTPDATA || ntohs(vport) >= PROT_SOCK)) {
+	if (!svc && protocol == IPPROTO_TCP &&
+	    atomic_read(&ipvs->ftpsvc_counter) &&
+	    (vport == FTPDATA || ntohs(vport) >= inet_prot_sock(ipvs->net))) {
 		/*
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bee4dd3..d699d2c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -360,7 +360,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 		}
 	}
 
-	if (snum && snum < PROT_SOCK &&
+	if (snum && snum < inet_prot_sock(net) &&
 	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
@@ -1152,8 +1152,10 @@ static int __sctp_connect(struct sock *sk,
 				 * accept new associations, but it SHOULD NOT
 				 * be permitted to open new associations.
 				 */
-				if (ep->base.bind_addr.port < PROT_SOCK &&
-				    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE)) {
+				if (ep->base.bind_addr.port <
+				    inet_prot_sock(net) &&
+				    !ns_capable(net->user_ns,
+				    CAP_NET_BIND_SERVICE)) {
 					err = -EACCES;
 					goto out_free;
 				}
@@ -1818,7 +1820,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 			 * but it SHOULD NOT be permitted to open new
 			 * associations.
 			 */
-			if (ep->base.bind_addr.port < PROT_SOCK &&
+			if (ep->base.bind_addr.port < inet_prot_sock(net) &&
 			    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE)) {
 				err = -EACCES;
 				goto out_unlock;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c7c6619..53cb6da 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4365,7 +4365,8 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 
 			inet_get_local_port_range(sock_net(sk), &low, &high);
 
-			if (snum < max(PROT_SOCK, low) || snum > high) {
+			if (snum < max(inet_prot_sock(sock_net(sk)), low) ||
+			    snum > high) {
 				err = sel_netport_sid(sk->sk_protocol,
 						      snum, &sid);
 				if (err)
-- 
2.7.4
