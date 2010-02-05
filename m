From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 12/13] net: ipx: use seq_list_foo() helpers
Date: Fri, 05 Feb 2010 09:47:40 +0800
Message-ID: <4B6B78BC.80103@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51120 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932877Ab0BEBrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:47:25 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/ipx/ipx_proc.c |   89 +++++++---------------------------------------------
 1 files changed, 12 insertions(+), 77 deletions(-)

diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index 5761784..cd44358 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -13,45 +13,15 @@
 #include <net/tcp_states.h>
 #include <net/ipx.h>
 
-static __inline__ struct ipx_interface *ipx_get_interface_idx(loff_t pos)
-{
-	struct ipx_interface *i;
-
-	list_for_each_entry(i, &ipx_interfaces, node)
-		if (!pos--)
-			goto out;
-	i = NULL;
-out:
-	return i;
-}
-
-static struct ipx_interface *ipx_interfaces_next(struct ipx_interface *i)
-{
-	struct ipx_interface *rc = NULL;
-
-	if (i->node.next != &ipx_interfaces)
-		rc = list_entry(i->node.next, struct ipx_interface, node);
-	return rc;
-}
-
 static void *ipx_seq_interface_start(struct seq_file *seq, loff_t *pos)
 {
-	loff_t l = *pos;
-
 	spin_lock_bh(&ipx_interfaces_lock);
-	return l ? ipx_get_interface_idx(--l) : SEQ_START_TOKEN;
+	return seq_list_start_head(&ipx_interfaces, *pos);
 }
 
 static void *ipx_seq_interface_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct ipx_interface *i;
-
-	++*pos;
-	if (v == SEQ_START_TOKEN)
-		i = ipx_interfaces_head();
-	else
-		i = ipx_interfaces_next(v);
-	return i;
+	return seq_list_next(v, &ipx_interfaces, pos);
 }
 
 static void ipx_seq_interface_stop(struct seq_file *seq, void *v)
@@ -63,7 +33,7 @@ static int ipx_seq_interface_show(struct seq_file *seq, void *v)
 {
 	struct ipx_interface *i;
 
-	if (v == SEQ_START_TOKEN) {
+	if (v == &ipx_interfaces) {
 		seq_puts(seq, "Network    Node_Address   Primary  Device     "
 			      "Frame_Type");
 #ifdef IPX_REFCNT_DEBUG
@@ -73,7 +43,7 @@ static int ipx_seq_interface_show(struct seq_file *seq, void *v)
 		goto out;
 	}
 
-	i = v;
+	i = list_entry(v, struct ipx_interface, node);
 	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(i->if_netnum));
 	seq_printf(seq, "%02X%02X%02X%02X%02X%02X   ",
 			i->if_node[0], i->if_node[1], i->if_node[2],
@@ -89,53 +59,16 @@ out:
 	return 0;
 }
 
-static struct ipx_route *ipx_routes_head(void)
-{
-	struct ipx_route *rc = NULL;
-
-	if (!list_empty(&ipx_routes))
-		rc = list_entry(ipx_routes.next, struct ipx_route, node);
-	return rc;
-}
-
-static struct ipx_route *ipx_routes_next(struct ipx_route *r)
-{
-	struct ipx_route *rc = NULL;
-
-	if (r->node.next != &ipx_routes)
-		rc = list_entry(r->node.next, struct ipx_route, node);
-	return rc;
-}
-
-static __inline__ struct ipx_route *ipx_get_route_idx(loff_t pos)
-{
-	struct ipx_route *r;
-
-	list_for_each_entry(r, &ipx_routes, node)
-		if (!pos--)
-			goto out;
-	r = NULL;
-out:
-	return r;
-}
-
 static void *ipx_seq_route_start(struct seq_file *seq, loff_t *pos)
 {
-	loff_t l = *pos;
 	read_lock_bh(&ipx_routes_lock);
-	return l ? ipx_get_route_idx(--l) : SEQ_START_TOKEN;
+	return seq_list_start_head(&ipx_routes, *pos);
 }
 
 static void *ipx_seq_route_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct ipx_route *r;
-
 	++*pos;
-	if (v == SEQ_START_TOKEN)
-		r = ipx_routes_head();
-	else
-		r = ipx_routes_next(v);
-	return r;
+	return seq_list_next(v, &ipx_routes, pos);
 }
 
 static void ipx_seq_route_stop(struct seq_file *seq, void *v)
@@ -147,11 +80,13 @@ static int ipx_seq_route_show(struct seq_file *seq, void *v)
 {
 	struct ipx_route *rt;
 
-	if (v == SEQ_START_TOKEN) {
+	if (v == &ipx_routes) {
 		seq_puts(seq, "Network    Router_Net   Router_Node\n");
 		goto out;
 	}
-	rt = v;
+
+	rt = list_entry(v, struct ipx_route, node);
+
 	seq_printf(seq, "%08lX   ", (unsigned long int)ntohl(rt->ir_net));
 	if (rt->ir_routed)
 		seq_printf(seq, "%08lX     %02X%02X%02X%02X%02X%02X\n",
@@ -226,9 +161,9 @@ static void *ipx_seq_socket_next(struct seq_file *seq, void *v, loff_t *pos)
 	spin_unlock_bh(&i->if_sklist_lock);
 	sk = NULL;
 	for (;;) {
-		i = ipx_interfaces_next(i);
-		if (!i)
+		if (i->node.next == &ipx_interfaces)
 			break;
+		i = list_entry(i->node.next, struct ipx_interface, node);
 		spin_lock_bh(&i->if_sklist_lock);
 		if (!hlist_empty(&i->if_sklist)) {
 			sk = sk_head(&i->if_sklist);
-- 
1.6.3

