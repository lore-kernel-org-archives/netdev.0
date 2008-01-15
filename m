From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH 1/4] [ROSE] simplified rose_get_route()
Date: Tue, 15 Jan 2008 16:00:35 +0100
Message-ID: <478CCA93.9090503@ccr.jussieu.fr>
References: <47630274.1080706@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@c
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:51448 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076AbYAOPAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 10:00:38 -0500
In-Reply-To: <47630274.1080706@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch is send to replace preceding commit :

 From fd66cc115e058b2fc63a0e26aa73f1d27113105a Mon Sep 17 00:00:00 2001
From: Bernard Pidoux <f6bvp@amsat.org>
Date: Thu, 10 Jan 2008 23:10:44 +0100
Subject: [PATCH 1/4] [ROSE] new rose_get_route() function


I removed unnecessary lines of code copied from rose_get_neigh().
The function is now called with fewer arguments and if
a NULL is returned then the next call to rose_transmit_clear_request()
will manage the error code. I verified that the frame routing was
actually handled as required on a FPAC/ROSE node with heavy BBS traffic 
through 8 adjacent nodes connected through radio ports and Internet 
AXUDP / AXIP connections.


 From 6708b3853a5ecf5c185942b3757223e451af1960 Mon Sep 17 00:00:00 2001
From: Bernard Pidoux <f6bvp@amsat.org>
Date: Sun, 13 Jan 2008 20:25:40 +0100
Subject: [PATCH 1/4] [ROSE] simplified rose_get_route()

rose_get_neigh() was called by two different functions.
Firstly, by rose_connect() in order to establish connections to
adjacent rose nodes. This worked correctly.
Secondly, it was called by rose_route_frame() to find a route
via an adjacent node. This was not working efficiently, for the
whole node neighbour list was not checked and the proper test
was not performed in order to check if a node was already connected.
We create new function rose_get_route() to achieve this.
It returns a ROSE node address for sending a frame via a connected node
to the specified destination address.If a NULL is returned, the
previous program behavior is performed. ROSE tries to initiate a connect 
to the appropriate adjacent node.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
  net/rose/rose_route.c |   24 +++++++++++++++++++++---
  1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 540c0f2..5d6fac4 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -662,6 +662,25 @@ struct rose_route *rose_route_free_lci(unsigned int 
lci, struct rose_neigh *neig
  }

  /*
+ *     Find an opened route given a ROSE address.
+ */
+static struct rose_neigh *rose_get_route(rose_address *addr)
+{
+       struct rose_node *node;
+       int i;
+
+       for (node = rose_node_list; node != NULL; node = node->next) {
+               if (rosecmpm(addr, &node->address, node->mask) == 0) {
+                       for (i = 0; i < node->count; i++) {
+                               if (node->neighbour[i]->restarted)
+                                       return node->neighbour[i];
+                       }
+               }
+       }
+       return NULL;
+}
+
+/*
   *     Find a neighbour given a ROSE address.
   */
  struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char 
*cause,
@@ -842,7 +861,6 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
         struct sock *sk;
         unsigned short frametype;
         unsigned int lci, new_lci;
-       unsigned char cause, diagnostic;
         struct net_device *dev;
         int len, res = 0;
         char buf[11];
@@ -1019,8 +1037,8 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb 
*ax25)
                 rose_route = rose_route->next;
         }

-       if ((new_neigh = rose_get_neigh(dest_addr, &cause, &diagnostic)) 
== NULL) {
-               rose_transmit_clear_request(rose_neigh, lci, cause, 
diagnostic);
+       if ((new_neigh = rose_get_route(dest_addr)) == NULL) {
+               rose_transmit_clear_request(rose_neigh, lci, 
ROSE_NOT_OBTAINABLE, 0);
                 goto out;
         }

--
1.5.3.7

