From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/21] userns: Use kgids for sysctl_ping_group_range
Date: Mon, 13 Aug 2012 13:18:21 -0700
Message-ID: <1344889115-21610-7-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Store sysctl_ping_group_range as a paire of kgid_t values
  instead of a pair of gid_t values.
- Move the kgid conversion work from ping_init_sock into ipv4_ping_group_range
- For invalid cases reset to the default disabled state.

With the kgid_t conversion made part of the original value sanitation
from userspace understand how the code will react becomes clearer
and it becomes possible to set the sysctl ping group range from
something other than the initial user namespace.

Cc: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/netns/ipv4.h   |    3 ++-
 init/Kconfig               |    1 -
 net/ipv4/ping.c            |   18 ++++++------------
 net/ipv4/sysctl_net_ipv4.c |   42 +++++++++++++++++++++++++++---------------
 4 files changed, 35 insertions(+), 29 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 1474dd6..3516dc0 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -5,6 +5,7 @@
 #ifndef __NETNS_IPV4_H__
 #define __NETNS_IPV4_H__
 
+#include <linux/uidgid.h>
 #include <net/inet_frag.h>
 
 struct tcpm_hash_bucket;
@@ -62,7 +63,7 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
 
-	unsigned int sysctl_ping_group_range[2];
+	kgid_t sysctl_ping_group_range[2];
 	long sysctl_tcp_mem[3];
 
 	atomic_t rt_genid;
diff --git a/init/Kconfig b/init/Kconfig
index 25a6ebb..f857f97 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -948,7 +948,6 @@ config UIDGID_CONVERTED
 	depends on NETFILTER_XT_MATCH_RECENT = n
 	depends on NETFILTER_XT_TARGET_LOG = n
 	depends on NETFILTER_NETLINK_LOG = n
-	depends on INET = n
 	depends on IPV6 = n
 	depends on AF_RXRPC = n
 	depends on NET_KEY = n
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index bee5eeb..8f3d054 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -185,10 +185,10 @@ exit:
 	return sk;
 }
 
-static void inet_get_ping_group_range_net(struct net *net, gid_t *low,
-					  gid_t *high)
+static void inet_get_ping_group_range_net(struct net *net, kgid_t *low,
+					  kgid_t *high)
 {
-	gid_t *data = net->ipv4.sysctl_ping_group_range;
+	kgid_t *data = net->ipv4.sysctl_ping_group_range;
 	unsigned int seq;
 
 	do {
@@ -203,19 +203,13 @@ static void inet_get_ping_group_range_net(struct net *net, gid_t *low,
 static int ping_init_sock(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
-	gid_t group = current_egid();
-	gid_t range[2];
+	kgid_t group = current_egid();
 	struct group_info *group_info = get_current_groups();
 	int i, j, count = group_info->ngroups;
 	kgid_t low, high;
 
-	inet_get_ping_group_range_net(net, range, range+1);
-	low = make_kgid(&init_user_ns, range[0]);
-	high = make_kgid(&init_user_ns, range[1]);
-	if (!gid_valid(low) || !gid_valid(high) || gid_lt(high, low))
-		return -EACCES;
-
-	if (range[0] <= group && group <= range[1])
+	inet_get_ping_group_range_net(net, &low, &high);
+	if (gid_lte(low, group) && gid_lte(group, high))
 		return 0;
 
 	for (i = 0; i < group_info->nblocks; i++) {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1b5ce96..3e78c79 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -76,9 +76,9 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 }
 
 
-static void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t *high)
+static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low, kgid_t *high)
 {
-	gid_t *data = table->data;
+	kgid_t *data = table->data;
 	unsigned int seq;
 	do {
 		seq = read_seqbegin(&sysctl_local_ports.lock);
@@ -89,12 +89,12 @@ static void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low,
 }
 
 /* Update system visible IP port range */
-static void set_ping_group_range(struct ctl_table *table, gid_t range[2])
+static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t high)
 {
-	gid_t *data = table->data;
+	kgid_t *data = table->data;
 	write_seqlock(&sysctl_local_ports.lock);
-	data[0] = range[0];
-	data[1] = range[1];
+	data[0] = low;
+	data[1] = high;
 	write_sequnlock(&sysctl_local_ports.lock);
 }
 
@@ -103,21 +103,33 @@ static int ipv4_ping_group_range(ctl_table *table, int write,
 				 void __user *buffer,
 				 size_t *lenp, loff_t *ppos)
 {
+	struct user_namespace *user_ns = current_user_ns();
 	int ret;
-	gid_t range[2];
+	gid_t urange[2];
+	kgid_t low, high;
 	ctl_table tmp = {
-		.data = &range,
-		.maxlen = sizeof(range),
+		.data = &urange,
+		.maxlen = sizeof(urange),
 		.mode = table->mode,
 		.extra1 = &ip_ping_group_range_min,
 		.extra2 = &ip_ping_group_range_max,
 	};
 
-	inet_get_ping_group_range_table(table, range, range + 1);
+	inet_get_ping_group_range_table(table, &low, &high);
+	urange[0] = from_kgid_munged(user_ns, low);
+	urange[1] = from_kgid_munged(user_ns, high);
 	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 
-	if (write && ret == 0)
-		set_ping_group_range(table, range);
+	if (write && ret == 0) {
+		low = make_kgid(user_ns, urange[0]);
+		high = make_kgid(user_ns, urange[1]);
+		if (!gid_valid(low) || !gid_valid(high) ||
+		    (urange[1] < urange[0]) || gid_lt(high, low)) {
+			low = make_kgid(&init_user_ns, 1);
+			high = make_kgid(&init_user_ns, 0);
+		}
+		set_ping_group_range(table, low, high);
+	}
 
 	return ret;
 }
@@ -786,7 +798,7 @@ static struct ctl_table ipv4_net_table[] = {
 	{
 		.procname	= "ping_group_range",
 		.data		= &init_net.ipv4.sysctl_ping_group_range,
-		.maxlen		= sizeof(init_net.ipv4.sysctl_ping_group_range),
+		.maxlen		= sizeof(gid_t)*2,
 		.mode		= 0644,
 		.proc_handler	= ipv4_ping_group_range,
 	},
@@ -830,8 +842,8 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	 * Sane defaults - nobody may create ping sockets.
 	 * Boot scripts should set this to distro-specific group.
 	 */
-	net->ipv4.sysctl_ping_group_range[0] = 1;
-	net->ipv4.sysctl_ping_group_range[1] = 0;
+	net->ipv4.sysctl_ping_group_range[0] = make_kgid(&init_user_ns, 1);
+	net->ipv4.sysctl_ping_group_range[1] = make_kgid(&init_user_ns, 0);
 
 	tcp_init_mem(net);
 
-- 
1.7.5.4
