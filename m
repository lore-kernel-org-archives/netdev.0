From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 03/14] ipv4, ipv6: use list_for_each_entry*
Date: Fri, 18 Dec 2015 23:33:27 +0800
Message-ID: <0167bba2ecf8c4fcb6b0b3135a4e957309986498.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry*() instead of list_for_each*() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/ipv4/af_inet.c    | 6 ++----
 net/ipv4/tcp_output.c | 6 ++----
 net/ipv6/addrconf.c   | 8 +++-----
 net/ipv6/af_inet6.c   | 7 ++-----
 4 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 11c4ca1..bb11ec1 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1028,7 +1028,6 @@ static struct inet_protosw inetsw_array[] =
 
 void inet_register_protosw(struct inet_protosw *p)
 {
-	struct list_head *lh;
 	struct inet_protosw *answer;
 	int protocol = p->protocol;
 	struct list_head *last_perm;
@@ -1040,14 +1039,13 @@ void inet_register_protosw(struct inet_protosw *p)
 
 	/* If we are trying to override a permanent protocol, bail. */
 	last_perm = &inetsw[p->type];
-	list_for_each(lh, &inetsw[p->type]) {
-		answer = list_entry(lh, struct inet_protosw, list);
+	list_for_each_entry(answer, &inetsw[p->type], list) {
 		/* Check only the non-wild match. */
 		if ((INET_PROTOSW_PERMANENT & answer->flags) == 0)
 			break;
 		if (protocol == answer->protocol)
 			goto out_permanent;
-		last_perm = lh;
+		last_perm = &answer->list;
 	}
 
 	/* Add the new entry after the last permanent entry if any, so that
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a800cee..8810694 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -751,16 +751,14 @@ static void tcp_tasklet_func(unsigned long data)
 	struct tsq_tasklet *tsq = (struct tsq_tasklet *)data;
 	LIST_HEAD(list);
 	unsigned long flags;
-	struct list_head *q, *n;
-	struct tcp_sock *tp;
+	struct tcp_sock *tp, *n;
 	struct sock *sk;
 
 	local_irq_save(flags);
 	list_splice_init(&tsq->head, &list);
 	local_irq_restore(flags);
 
-	list_for_each_safe(q, n, &list) {
-		tp = list_entry(q, struct tcp_sock, tsq_node);
+	list_for_each_entry_safe(tp, n, &list, tsq_node) {
 		list_del(&tp->tsq_node);
 
 		sk = (struct sock *)tp;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7082fb7..e293647 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -865,21 +865,19 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 static void
 ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 {
-	struct list_head *p;
+	struct inet6_ifaddr *ifa;
 	int ifp_scope = ipv6_addr_src_scope(&ifp->addr);
 
 	/*
 	 * Each device address list is sorted in order of scope -
 	 * global before linklocal.
 	 */
-	list_for_each(p, &idev->addr_list) {
-		struct inet6_ifaddr *ifa
-			= list_entry(p, struct inet6_ifaddr, if_list);
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
 		if (ifp_scope >= ipv6_addr_src_scope(&ifa->addr))
 			break;
 	}
 
-	list_add_tail(&ifp->if_list, p);
+	list_add_tail(&ifp->if_list, &ifa->if_list);
 }
 
 static u32 inet6_addr_hash(const struct in6_addr *addr)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 8ec0df7..a4fb172 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -568,7 +568,6 @@ static const struct net_proto_family inet6_family_ops = {
 
 int inet6_register_protosw(struct inet_protosw *p)
 {
-	struct list_head *lh;
 	struct inet_protosw *answer;
 	struct list_head *last_perm;
 	int protocol = p->protocol;
@@ -584,14 +583,12 @@ int inet6_register_protosw(struct inet_protosw *p)
 	answer = NULL;
 	ret = -EPERM;
 	last_perm = &inetsw6[p->type];
-	list_for_each(lh, &inetsw6[p->type]) {
-		answer = list_entry(lh, struct inet_protosw, list);
-
+	list_for_each_entry(answer, &inetsw6[p->type], list) {
 		/* Check only the non-wild match. */
 		if (INET_PROTOSW_PERMANENT & answer->flags) {
 			if (protocol == answer->protocol)
 				break;
-			last_perm = lh;
+			last_perm = &answer->list;
 		}
 
 		answer = NULL;
-- 
2.5.0
