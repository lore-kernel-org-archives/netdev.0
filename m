From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] [ROSE] improving AX25 routing frames via ROSE network
Date: Sat, 7 Jun 2008 19:44:07 +0200
Message-ID: <200806071944.07304.bpidoux@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	"linux-hams" <linux-hams@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ROSE network is organized through nodes connected via hamradio or Internet.
AX25 packet radio frames sent to a remote ROSE address destination are routed
through these nodes.

Without the present patch, automatic routing mechanism did not work optimally
due to an improper parameter checking.

rose_get_neigh() function is called either by rose_connect() or by
rose_route_frame().

In the case of a call from rose_connect(), f0 timer is checked to find if a connection
is already pending. In that case it returns the address of the neighbour, or returns a NULL otherwise.

When called by rose_route_frame() the purpose was to route a packet AX25 frame
through an adjacent node given a destination rose address.
However, in that case, t0 timer checked does not indicate if the adjacent node
is actually connected even if the timer is not null. Thus, for each frame sent, the
function often tried to start a new connexion even if the adjacent node was already connected.

The patch adds a "new" parameter that is true when the function is called by
rose route_frame().
This instructs rose_get_neigh() to check node parameter "restarted". 
If restarted is true it means that the route to the destination address is opened via a neighbour
node already connected.
If "restarted" is false the function returns a NULL.
In that case the calling function will initiate a new connection as before.

This results in a fast routing of frames, from nodes to nodes, until
destination is reached, as originaly specified by ROSE protocole.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 include/net/rose.h    |    2 +-
 net/rose/af_rose.c    |    4 ++--
 net/rose/rose_route.c |   29 ++++++++++++++++++-----------
 3 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/include/net/rose.h b/include/net/rose.h
index e5bb084..cbd5364 100644
--- a/include/net/rose.h
+++ b/include/net/rose.h
@@ -201,7 +201,7 @@ extern void rose_link_device_down(struct net_device *);
 extern struct net_device *rose_dev_first(void);
 extern struct net_device *rose_dev_get(rose_address *);
 extern struct rose_route *rose_route_free_lci(unsigned int, struct rose_neigh *);
-extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char *, unsigned char *);
+extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char *, unsigned char *, int);
 extern int  rose_rt_ioctl(unsigned int, void __user *);
 extern void rose_link_failed(ax25_cb *, int);
 extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 1ebf652..f7f7ec8 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -759,7 +759,7 @@ static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_le
 	sock->state = SS_UNCONNECTED;
 
 	rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause,
-					 &diagnostic);
+					 &diagnostic, 0);
 	if (!rose->neighbour) {
 		err = -ENETUNREACH;
 		goto out_release;
@@ -855,7 +855,7 @@ rose_try_next_neigh:
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 	/* Try next neighbour */
-		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic);
+		rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause, &diagnostic, 0);
 		if (rose->neighbour)
 			goto rose_try_next_neigh;
 
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index bd59387..a81066a 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -662,27 +662,34 @@ struct rose_route *rose_route_free_lci(unsigned int lci, struct rose_neigh *neig
 }
 
 /*
- *	Find a neighbour given a ROSE address.
+ *	Find a neighbour or a route given a ROSE address.
  */
 struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char *cause,
-	unsigned char *diagnostic)
+	unsigned char *diagnostic, int new)
 {
 	struct rose_neigh *res = NULL;
 	struct rose_node *node;
 	int failed = 0;
 	int i;
 
-	spin_lock_bh(&rose_node_list_lock);
+	if (!new) spin_lock_bh(&rose_node_list_lock);
 	for (node = rose_node_list; node != NULL; node = node->next) {
 		if (rosecmpm(addr, &node->address, node->mask) == 0) {
 			for (i = 0; i < node->count; i++) {
-				if (!rose_ftimer_running(node->neighbour[i])) {
-					res = node->neighbour[i];
-					goto out;
-				} else
-					failed = 1;
+				if (new) {
+					if (node->neighbour[i]->restarted) {
+						res = node->neighbour[i];
+						goto out;
+					}
+				}
+				else {
+					if (!rose_ftimer_running(node->neighbour[i])) {
+						res = node->neighbour[i];
+						goto out;
+					} else
+						failed = 1;
+				}
 			}
-			break;
 		}
 	}
 
@@ -695,7 +702,7 @@ struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char *cause,
 	}
 
 out:
-	spin_unlock_bh(&rose_node_list_lock);
+	if (!new) spin_unlock_bh(&rose_node_list_lock);
 
 	return res;
 }
@@ -1018,7 +1025,7 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 		rose_route = rose_route->next;
 	}
 
-	if ((new_neigh = rose_get_neigh(dest_addr, &cause, &diagnostic)) == NULL) {
+	if ((new_neigh = rose_get_neigh(dest_addr, &cause, &diagnostic, 1)) == NULL) {
 		rose_transmit_clear_request(rose_neigh, lci, cause, diagnostic);
 		goto out;
 	}
-- 
1.5.5

