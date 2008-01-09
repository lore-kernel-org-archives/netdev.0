From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-2.6.25 15/19] [NETNS] Provide correct namespace for
	fibnl netlink socket.
Date: Wed,  9 Jan 2008 21:04:36 +0300
Message-ID: <1199901880-6812-15-git-send-email-den@openvz.org>
References: <47850C57.60907@openvz.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47850C57.60907-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes the netlink socket to be per namespace. That allows to have
each namespace its own socket for routing queries.

Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 include/net/netns/ipv4.h |    2 ++
 net/ipv4/fib_frontend.c  |   24 ++++++++++++++++--------
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 629ec6c..031d761 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -9,6 +9,7 @@ struct ctl_table_header;
 struct ipv4_devconf;
 struct fib_rules_ops;
 struct hlist_head;
+struct sock;
 
 struct netns_ipv4 {
 #ifdef CONFIG_SYSCTL
@@ -18,5 +19,6 @@ struct netns_ipv4 {
 	struct fib_rules_ops	*rules_ops;
 #endif
 	struct hlist_head	*fib_table_hash;
+	struct sock		*fibnl;
 };
 #endif
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7fe54a3..a5e8167 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -49,8 +49,6 @@
 
 #define FFprint(a...) printk(KERN_DEBUG a)
 
-static struct sock *fibnl;
-
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
 static int __net_init fib4_rules_init(struct net *net)
@@ -845,11 +843,13 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb )
 
 static void nl_fib_input(struct sk_buff *skb)
 {
+	struct net *net;
 	struct fib_result_nl *frn;
 	struct nlmsghdr *nlh;
 	struct fib_table *tb;
 	u32 pid;
 
+	net = skb->sk->sk_net;
 	nlh = nlmsg_hdr(skb);
 	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
 	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn)))
@@ -861,28 +861,36 @@ static void nl_fib_input(struct sk_buff *skb)
 	nlh = nlmsg_hdr(skb);
 
 	frn = (struct fib_result_nl *) NLMSG_DATA(nlh);
-	tb = fib_get_table(&init_net, frn->tb_id_in);
+	tb = fib_get_table(net, frn->tb_id_in);
 
 	nl_fib_lookup(frn, tb);
 
 	pid = NETLINK_CB(skb).pid;       /* pid of sending process */
 	NETLINK_CB(skb).pid = 0;         /* from kernel */
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
-	netlink_unicast(fibnl, skb, pid, MSG_DONTWAIT);
+	netlink_unicast(net->ipv4.fibnl, skb, pid, MSG_DONTWAIT);
 }
 
 static int nl_fib_lookup_init(struct net *net)
 {
-	fibnl = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, 0,
-				      nl_fib_input, NULL, THIS_MODULE);
-	if (fibnl == NULL)
+	struct sock *sk;
+	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, 0,
+				   nl_fib_input, NULL, THIS_MODULE);
+	if (sk == NULL)
 		return -EAFNOSUPPORT;
+	/* Don't hold an extra reference on the namespace */
+	put_net(sk->sk_net);
+	net->ipv4.fibnl = sk;
 	return 0;
 }
 
 static void nl_fib_lookup_exit(struct net *net)
 {
-	sock_put(fibnl);
+	/* At the last minute lie and say this is a socket for the
+	 * initial network namespace. So the socket will  be safe to free.
+	 */
+	net->ipv4.fibnl->sk_net = get_net(&init_net);
+	sock_put(net->ipv4.fibnl);
 }
 
 static void fib_disable_ip(struct net_device *dev, int force)
