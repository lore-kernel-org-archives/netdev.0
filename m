From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add
Date: Tue, 3 Sep 2013 02:13:31 +0200
Message-ID: <20130903001331.GA8820@order.stressinduktion.org>
References: <20130902213128.GB14301@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sasha Levin <sasha.levin@oracle.com>
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33608 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab3ICANc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 20:13:32 -0400
Content-Disposition: inline
In-Reply-To: <20130902213128.GB14301@marquez.int.rhx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Mon, Sep 02, 2013 at 10:31:28PM +0100, Michele Baldessari wrote:
> with the latest linux master git tree from Linus
> (248d296d6d9df384996c2ed95676b367d876d48c - 2 Sep) I can reproduceably oops 
> the kernel with the following commands:
> ip addrlabel flush
> ip addrlabel add prefix ::1/128              label 0
> ip addrlabel add prefix ::/0                 label 1

Thanks for the report! This patch should fix this issue:

[PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add

Commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a ("hlist: drop
the node parameter from iterators") changed the behavior of
hlist_for_each_entry_safe to leave the p argument NULL.

Fix this up by tracking the last argument.

Reported-by: Michele Baldessari <michele@acksyn.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrlabel.c | 48 +++++++++++++++++++++++-------------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index f083a58..b30ad37 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -251,38 +251,36 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 /* add a label */
 static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 {
+	struct hlist_node *n;
+	struct ip6addrlbl_entry *last = NULL, *p = NULL;
 	int ret = 0;
 
-	ADDRLABEL(KERN_DEBUG "%s(newp=%p, replace=%d)\n",
-			__func__,
-			newp, replace);
+	ADDRLABEL(KERN_DEBUG "%s(newp=%p, replace=%d)\n", __func__, newp,
+		  replace);
 
-	if (hlist_empty(&ip6addrlbl_table.head)) {
-		hlist_add_head_rcu(&newp->list, &ip6addrlbl_table.head);
-	} else {
-		struct hlist_node *n;
-		struct ip6addrlbl_entry *p = NULL;
-		hlist_for_each_entry_safe(p, n,
-					  &ip6addrlbl_table.head, list) {
-			if (p->prefixlen == newp->prefixlen &&
-			    net_eq(ip6addrlbl_net(p), ip6addrlbl_net(newp)) &&
-			    p->ifindex == newp->ifindex &&
-			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
-				if (!replace) {
-					ret = -EEXIST;
-					goto out;
-				}
-				hlist_replace_rcu(&p->list, &newp->list);
-				ip6addrlbl_put(p);
-				goto out;
-			} else if ((p->prefixlen == newp->prefixlen && !p->ifindex) ||
-				   (p->prefixlen < newp->prefixlen)) {
-				hlist_add_before_rcu(&newp->list, &p->list);
+	hlist_for_each_entry_safe(p, n,	&ip6addrlbl_table.head, list) {
+		if (p->prefixlen == newp->prefixlen &&
+		    net_eq(ip6addrlbl_net(p), ip6addrlbl_net(newp)) &&
+		    p->ifindex == newp->ifindex &&
+		    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
+			if (!replace) {
+				ret = -EEXIST;
 				goto out;
 			}
+			hlist_replace_rcu(&p->list, &newp->list);
+			ip6addrlbl_put(p);
+			goto out;
+		} else if ((p->prefixlen == newp->prefixlen && !p->ifindex) ||
+			   (p->prefixlen < newp->prefixlen)) {
+			hlist_add_before_rcu(&newp->list, &p->list);
+			goto out;
 		}
-		hlist_add_after_rcu(&p->list, &newp->list);
+		last = p;
 	}
+	if (last)
+		hlist_add_after_rcu(&last->list, &newp->list);
+	else
+		hlist_add_head_rcu(&newp->list, &ip6addrlbl_table.head);
 out:
 	if (!ret)
 		ip6addrlbl_table.seq++;
-- 
1.8.3.1
