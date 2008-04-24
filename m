From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] [ROSE] [AX25] rose_get_route() added
Date: Fri, 25 Apr 2008 00:04:32 +0200
Message-ID: <200804250004.33322.bpidoux@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-hams" <linux-hams@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch offers a new function, named rose_get_route(), called
by rose_route_frame() in order to find a route each time a packet
must be routed toward a specific address handled by one of the adjacent
nodes in a list.

It returns the address of the adjacent node if it is connected,
otherwise it returns a NULL. In that case, the calling function
will initiate a new connection as before, when it was calling
rose_get_neigh(). However, the new thing is that if a route is
already opened via an adjacent node, the frame is routed immediately.

This function has been tested for months now and it works fine.
It adds a fast automatic frame routing mechanism from nodes to nodes,
while identifaction of packets remains all along with callsigns
of calling and destination AX25 station.
---
 include/net/rose.h    |    1 +
 net/rose/rose_route.c |   30 +++++++++++++++++++++++++++---
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/net/rose.h b/include/net/rose.h
index e5bb084..de88459 100644
--- a/include/net/rose.h
+++ b/include/net/rose.h
@@ -201,6 +201,7 @@ extern void rose_link_device_down(struct net_device *);
 extern struct net_device *rose_dev_first(void);
 extern struct net_device *rose_dev_get(rose_address *);
 extern struct rose_route *rose_route_free_lci(unsigned int, struct rose_neigh 
*);
+extern struct rose_neigh *rose_get_route(rose_address *);
 extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char *, 
unsigned char *);
 extern int  rose_rt_ioctl(unsigned int, void __user *);
 extern void rose_link_failed(ax25_cb *, int);
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 5053a53..ad0ebdc 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -662,6 +662,31 @@ struct rose_route *rose_route_free_lci(unsigned int lci, 
struct rose_neigh *neig
 }
 
 /*
+ *	Find an opened route given a ROSE address.
+ */
+struct rose_neigh *rose_get_route(rose_address *addr)
+{
+	struct rose_node *node;
+	struct rose_neigh *res = NULL;
+	int i;
+
+	spin_lock_bh(&rose_node_list_lock);
+	for (node = rose_node_list; node != NULL; node = node->next) {
+		if (rosecmpm(addr, &node->address, node->mask) == 0) {
+			for (i = 0; i < node->count; i++) {
+				if (node->neighbour[i]->restarted) {
+					res = node->neighbour[i];
+					goto out;
+				}
+			}
+		}
+	}
+out:
+	spin_unlock_bh(&rose_node_list_lock);
+	return res;
+}
+
+/*
  *	Find a neighbour given a ROSE address.
  */
 struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char *cause,
@@ -842,7 +867,6 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 	struct sock *sk;
 	unsigned short frametype;
 	unsigned int lci, new_lci;
-	unsigned char cause, diagnostic;
 	struct net_device *dev;
 	int len, res = 0;
 	char buf[11];
@@ -1018,8 +1042,8 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 		rose_route = rose_route->next;
 	}
 
-	if ((new_neigh = rose_get_neigh(dest_addr, &cause, &diagnostic)) == NULL) {
-		rose_transmit_clear_request(rose_neigh, lci, cause, diagnostic);
+	if ((new_neigh = rose_get_route(dest_addr)) == NULL) {
+		rose_transmit_clear_request(rose_neigh, lci, ROSE_NOT_OBTAINABLE, 0);
 		goto out;
 	}
 
-- 
1.5.5


