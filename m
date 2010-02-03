From: Amerigo Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Tue, 2 Feb 2010 23:30:07 -0500
Message-ID: <20100203043332.3817.27932.sendpatchset@localhost.localdomain>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Amerigo Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports,
it can be used like ip_local_port_range, but this is used to
reserve ports for third-party applications which use fixed
port numbers within ip_local_port_range.

This only affects the applications which call socket functions
like bind(2) with port number 0, to prevent the kernel getting the ports
within the specified range for them. For applications which use fixed
port number, it will have no effects.

Any comments are welcome.

Signed-off-by: WANG Cong <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
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
index fb63371..f70acad 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -181,8 +181,10 @@ extern void snmp_mib_free(void *ptr[2]);
 extern struct local_ports {
 	seqlock_t	lock;
 	int		range[2];
-} sysctl_local_ports;
+} sysctl_local_ports, sysctl_local_reserved_ports;
 extern void inet_get_local_port_range(int *low, int *high);
+extern void inet_get_local_reserved_ports(int *from, int *to);
+extern int inet_is_reserved_local_port(int port);
 
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ee16475..ee13e48 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -37,6 +37,11 @@ struct local_ports sysctl_local_ports __read_mostly = {
 	.range = { 32768, 61000 },
 };
 
+struct local_ports sysctl_local_reserved_ports __read_mostly = {
+	.lock = SEQLOCK_UNLOCKED,
+	.range = { 0, 0 },
+};
+
 void inet_get_local_port_range(int *low, int *high)
 {
 	unsigned seq;
@@ -49,6 +54,28 @@ void inet_get_local_port_range(int *low, int *high)
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
+void inet_get_local_reserved_ports(int *from, int *to)
+{
+	unsigned int seq;
+	do {
+		seq = read_seqbegin(&sysctl_local_reserved_ports.lock);
+
+		*from = sysctl_local_reserved_ports.range[0];
+		*to = sysctl_local_reserved_ports.range[1];
+	} while (read_seqretry(&sysctl_local_reserved_ports.lock, seq));
+}
+
+int inet_is_reserved_local_port(int port)
+{
+	int min, max;
+
+	inet_get_local_reserved_ports(&min, &max);
+	if (min && max)
+		return (port >= min && port <= max);
+	return 0;
+}
+EXPORT_SYMBOL(inet_is_reserved_local_port);
+
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
 {
@@ -105,6 +132,8 @@ again:
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
 		smallest_rover = rover = net_random() % remaining + low;
+		if (inet_is_reserved_local_port(rover))
+			goto again;
 
 		smallest_size = -1;
 		do {
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
index 7e3712c..9adf1a5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -23,6 +23,7 @@
 
 static int zero;
 static int tcp_retr1_max = 255;
+static int ip_local_reserved_ports_min[] = {0, 0 };
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 
@@ -63,6 +64,51 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 	return ret;
 }
 
+static void set_reserved_port_range(int range[2])
+{
+	write_seqlock(&sysctl_local_reserved_ports.lock);
+	sysctl_local_reserved_ports.range[0] = range[0];
+	sysctl_local_reserved_ports.range[1] = range[1];
+	write_sequnlock(&sysctl_local_reserved_ports.lock);
+}
+
+static int ipv4_local_reserved_ports(ctl_table *table, int write,
+				     void __user *buffer,
+				     size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int range[2];
+	int reserved_range[2];
+	ctl_table tmp = {
+		.data = &reserved_range,
+		.maxlen = sizeof(reserved_range),
+		.mode = table->mode,
+		.extra1 = &ip_local_reserved_ports_min,
+		.extra2 = &ip_local_port_range_max,
+	};
+
+	inet_get_local_reserved_ports(reserved_range, reserved_range+1);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0) {
+		inet_get_local_port_range(range, range + 1);
+		if (!reserved_range[0] && !reserved_range[1]) {
+			set_reserved_port_range(reserved_range);
+		} else {
+			if (reserved_range[1] < reserved_range[0])
+				ret = -EINVAL;
+			else if (reserved_range[0] < range[0])
+				ret = -EINVAL;
+			else if (reserved_range[1] > range[1])
+				ret = -EINVAL;
+			else
+				set_reserved_port_range(reserved_range);
+		}
+	}
+
+	return ret;
+}
+
 static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -298,6 +344,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
 	},
+	{
+		.procname	= "ip_local_reserved_ports",
+		.data		= &sysctl_local_reserved_ports.range,
+		.maxlen		= sizeof(sysctl_local_reserved_ports.range),
+		.mode		= 0644,
+		.proc_handler	= ipv4_local_reserved_ports,
+	},
 #ifdef CONFIG_IP_MULTICAST
 	{
 		.procname	= "igmp_max_memberships",
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f0126fd..83045ca 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -210,8 +210,11 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
 
+again:
 		rand = net_random();
 		first = (((u64)rand * remaining) >> 32) + low;
+		if (inet_is_reserved_local_port(first))
+			goto again;
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 		 */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 67fdac9..d685141 100644
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
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
