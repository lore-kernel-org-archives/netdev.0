From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH v3 1/2] net: netrom: nr_route: refactor code in nr_add_node
Date: Fri, 27 Oct 2017 00:51:04 -0500
Message-ID: <963dcdd9de537456065de7786f8a21acdf756e85.1509080630.git.garsilva@embeddedor.com>
References: <cover.1509080630.git.garsilva@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1509080630.git.garsilva@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code refactoring in order to make the code easier to read and maintain.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
Changes in v2:
 Make use of the swap macro and remove inline keyword.

Changes in v3:
 Update subject.

 net/netrom/nr_route.c | 59 ++++++++++++++-------------------------------------
 1 file changed, 16 insertions(+), 43 deletions(-)

diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 0c59354..fba4b4c 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -80,6 +80,19 @@ static struct nr_neigh *nr_neigh_get_dev(ax25_address *callsign,
 
 static void nr_remove_neigh(struct nr_neigh *);
 
+/*      re-sort the routes in quality order.    */
+static void re_sort_routes(struct nr_node *nr_node, int x, int y)
+{
+	if (nr_node->routes[y].quality > nr_node->routes[x].quality) {
+		if (nr_node->which == x)
+			nr_node->which = y;
+		else if (nr_node->which == y)
+			nr_node->which = x;
+
+		swap(nr_node->routes[x], nr_node->routes[y]);
+	}
+}
+
 /*
  *	Add a new route to a node, and in the process add the node and the
  *	neighbour if it is new.
@@ -90,7 +103,6 @@ static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
 {
 	struct nr_node  *nr_node;
 	struct nr_neigh *nr_neigh;
-	struct nr_route nr_route;
 	int i, found;
 	struct net_device *odev;
 
@@ -251,49 +263,10 @@ static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
 	/* Now re-sort the routes in quality order */
 	switch (nr_node->count) {
 	case 3:
-		if (nr_node->routes[1].quality > nr_node->routes[0].quality) {
-			switch (nr_node->which) {
-			case 0:
-				nr_node->which = 1;
-				break;
-			case 1:
-				nr_node->which = 0;
-				break;
-			}
-			nr_route           = nr_node->routes[0];
-			nr_node->routes[0] = nr_node->routes[1];
-			nr_node->routes[1] = nr_route;
-		}
-		if (nr_node->routes[2].quality > nr_node->routes[1].quality) {
-			switch (nr_node->which) {
-			case 1:  nr_node->which = 2;
-				break;
-
-			case 2:  nr_node->which = 1;
-				break;
-
-			default:
-				break;
-			}
-			nr_route           = nr_node->routes[1];
-			nr_node->routes[1] = nr_node->routes[2];
-			nr_node->routes[2] = nr_route;
-		}
+		re_sort_routes(nr_node, 0, 1);
+		re_sort_routes(nr_node, 1, 2);
 	case 2:
-		if (nr_node->routes[1].quality > nr_node->routes[0].quality) {
-			switch (nr_node->which) {
-			case 0:  nr_node->which = 1;
-				break;
-
-			case 1:  nr_node->which = 0;
-				break;
-
-			default: break;
-			}
-			nr_route           = nr_node->routes[0];
-			nr_node->routes[0] = nr_node->routes[1];
-			nr_node->routes[1] = nr_route;
-			}
+		re_sort_routes(nr_node, 0, 1);
 	case 1:
 		break;
 	}
-- 
2.7.4
