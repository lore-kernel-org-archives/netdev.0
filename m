From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 04/14] x25: use list_for_each_entry*
Date: Fri, 18 Dec 2015 23:33:28 +0800
Message-ID: <dde58fdf29fa7d2dbae30a127ea560606e806b58.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
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
 net/x25/x25_forward.c | 20 ++++++--------------
 net/x25/x25_link.c    | 23 ++++++-----------------
 net/x25/x25_route.c   | 29 +++++++----------------------
 3 files changed, 19 insertions(+), 53 deletions(-)

diff --git a/net/x25/x25_forward.c b/net/x25/x25_forward.c
index cf561f1..4394eb6 100644
--- a/net/x25/x25_forward.c
+++ b/net/x25/x25_forward.c
@@ -24,7 +24,6 @@ int x25_forward_call(struct x25_address *dest_addr, struct x25_neigh *from,
 {
 	struct x25_route *rt;
 	struct x25_neigh *neigh_new = NULL;
-	struct list_head *entry;
 	struct x25_forward *x25_frwd, *new_frwd;
 	struct sk_buff *skbn;
 	short same_lci = 0;
@@ -51,8 +50,7 @@ int x25_forward_call(struct x25_address *dest_addr, struct x25_neigh *from,
 	 * established LCI? It shouldn't happen, just in case..
 	 */
 	read_lock_bh(&x25_forward_list_lock);
-	list_for_each(entry, &x25_forward_list) {
-		x25_frwd = list_entry(entry, struct x25_forward, node);
+	list_for_each_entry(x25_frwd, &x25_forward_list, node) {
 		if (x25_frwd->lci == lci) {
 			pr_warn("call request for lci which is already registered!, transmitting but not registering new pair\n");
 			same_lci = 1;
@@ -97,15 +95,13 @@ out_no_route:
 int x25_forward_data(int lci, struct x25_neigh *from, struct sk_buff *skb) {
 
 	struct x25_forward *frwd;
-	struct list_head *entry;
 	struct net_device *peer = NULL;
 	struct x25_neigh *nb;
 	struct sk_buff *skbn;
 	int rc = 0;
 
 	read_lock_bh(&x25_forward_list_lock);
-	list_for_each(entry, &x25_forward_list) {
-		frwd = list_entry(entry, struct x25_forward, node);
+	list_for_each_entry(frwd, &x25_forward_list, node) {
 		if (frwd->lci == lci) {
 			/* The call is established, either side can send */
 			if (from->dev == frwd->dev1) {
@@ -136,13 +132,11 @@ out:
 
 void x25_clear_forward_by_lci(unsigned int lci)
 {
-	struct x25_forward *fwd;
-	struct list_head *entry, *tmp;
+	struct x25_forward *fwd, *tmp;
 
 	write_lock_bh(&x25_forward_list_lock);
 
-	list_for_each_safe(entry, tmp, &x25_forward_list) {
-		fwd = list_entry(entry, struct x25_forward, node);
+	list_for_each_entry_safe(fwd, tmp, &x25_forward_list, node) {
 		if (fwd->lci == lci) {
 			list_del(&fwd->node);
 			kfree(fwd);
@@ -154,13 +148,11 @@ void x25_clear_forward_by_lci(unsigned int lci)
 
 void x25_clear_forward_by_dev(struct net_device *dev)
 {
-	struct x25_forward *fwd;
-	struct list_head *entry, *tmp;
+	struct x25_forward *fwd, *tmp;
 
 	write_lock_bh(&x25_forward_list_lock);
 
-	list_for_each_safe(entry, tmp, &x25_forward_list) {
-		fwd = list_entry(entry, struct x25_forward, node);
+	list_for_each_entry_safe(fwd, tmp, &x25_forward_list, node) {
 		if ((fwd->dev1 == dev) || (fwd->dev2 == dev)){
 			list_del(&fwd->node);
 			kfree(fwd);
diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
index fd5ffb2..61cc8a2 100644
--- a/net/x25/x25_link.c
+++ b/net/x25/x25_link.c
@@ -296,14 +296,11 @@ static void __x25_remove_neigh(struct x25_neigh *nb)
  */
 void x25_link_device_down(struct net_device *dev)
 {
-	struct x25_neigh *nb;
-	struct list_head *entry, *tmp;
+	struct x25_neigh *nb, *tmp;
 
 	write_lock_bh(&x25_neigh_list_lock);
 
-	list_for_each_safe(entry, tmp, &x25_neigh_list) {
-		nb = list_entry(entry, struct x25_neigh, node);
-
+	list_for_each_entry_safe(nb, tmp, &x25_neigh_list, node) {
 		if (nb->dev == dev) {
 			__x25_remove_neigh(nb);
 			dev_put(dev);
@@ -319,12 +316,9 @@ void x25_link_device_down(struct net_device *dev)
 struct x25_neigh *x25_get_neigh(struct net_device *dev)
 {
 	struct x25_neigh *nb, *use = NULL;
-	struct list_head *entry;
 
 	read_lock_bh(&x25_neigh_list_lock);
-	list_for_each(entry, &x25_neigh_list) {
-		nb = list_entry(entry, struct x25_neigh, node);
-
+	list_for_each_entry(nb, &x25_neigh_list, node) {
 		if (nb->dev == dev) {
 			use = nb;
 			break;
@@ -394,18 +388,13 @@ out_dev_put:
  */
 void __exit x25_link_free(void)
 {
-	struct x25_neigh *nb;
-	struct list_head *entry, *tmp;
+	struct x25_neigh *nb, *tmp;
 
 	write_lock_bh(&x25_neigh_list_lock);
 
-	list_for_each_safe(entry, tmp, &x25_neigh_list) {
-		struct net_device *dev;
-
-		nb = list_entry(entry, struct x25_neigh, node);
-		dev = nb->dev;
+	list_for_each_entry_safe(nb, tmp, &x25_neigh_list, node) {
 		__x25_remove_neigh(nb);
-		dev_put(dev);
+		dev_put(nb->dev);
 	}
 	write_unlock_bh(&x25_neigh_list_lock);
 }
diff --git a/net/x25/x25_route.c b/net/x25/x25_route.c
index 277c8d2..50562d7 100644
--- a/net/x25/x25_route.c
+++ b/net/x25/x25_route.c
@@ -32,14 +32,11 @@ static int x25_add_route(struct x25_address *address, unsigned int sigdigits,
 			 struct net_device *dev)
 {
 	struct x25_route *rt;
-	struct list_head *entry;
 	int rc = -EINVAL;
 
 	write_lock_bh(&x25_route_list_lock);
 
-	list_for_each(entry, &x25_route_list) {
-		rt = list_entry(entry, struct x25_route, node);
-
+	list_for_each_entry(rt, &x25_route_list, node) {
 		if (!memcmp(&rt->address, address, sigdigits) &&
 		    rt->sigdigits == sigdigits)
 			goto out;
@@ -83,14 +80,11 @@ static int x25_del_route(struct x25_address *address, unsigned int sigdigits,
 			 struct net_device *dev)
 {
 	struct x25_route *rt;
-	struct list_head *entry;
 	int rc = -EINVAL;
 
 	write_lock_bh(&x25_route_list_lock);
 
-	list_for_each(entry, &x25_route_list) {
-		rt = list_entry(entry, struct x25_route, node);
-
+	list_for_each_entry(rt, &x25_route_list, node) {
 		if (!memcmp(&rt->address, address, sigdigits) &&
 		    rt->sigdigits == sigdigits && rt->dev == dev) {
 			__x25_remove_route(rt);
@@ -108,14 +102,11 @@ static int x25_del_route(struct x25_address *address, unsigned int sigdigits,
  */
 void x25_route_device_down(struct net_device *dev)
 {
-	struct x25_route *rt;
-	struct list_head *entry, *tmp;
+	struct x25_route *rt, *tmp;
 
 	write_lock_bh(&x25_route_list_lock);
 
-	list_for_each_safe(entry, tmp, &x25_route_list) {
-		rt = list_entry(entry, struct x25_route, node);
-
+	list_for_each_entry_safe(rt, tmp, &x25_route_list, node) {
 		if (rt->dev == dev)
 			__x25_remove_route(rt);
 	}
@@ -154,13 +145,10 @@ struct net_device *x25_dev_get(char *devname)
 struct x25_route *x25_get_route(struct x25_address *addr)
 {
 	struct x25_route *rt, *use = NULL;
-	struct list_head *entry;
 
 	read_lock_bh(&x25_route_list_lock);
 
-	list_for_each(entry, &x25_route_list) {
-		rt = list_entry(entry, struct x25_route, node);
-
+	list_for_each_entry(rt, &x25_route_list, node) {
 		if (!memcmp(&rt->address, addr, rt->sigdigits)) {
 			if (!use)
 				use = rt;
@@ -214,13 +202,10 @@ out:
  */
 void __exit x25_route_free(void)
 {
-	struct x25_route *rt;
-	struct list_head *entry, *tmp;
+	struct x25_route *rt, *tmp;
 
 	write_lock_bh(&x25_route_list_lock);
-	list_for_each_safe(entry, tmp, &x25_route_list) {
-		rt = list_entry(entry, struct x25_route, node);
+	list_for_each_entry_safe(rt, tmp, &x25_route_list, node)
 		__x25_remove_route(rt);
-	}
 	write_unlock_bh(&x25_route_list_lock);
 }
-- 
2.5.0
