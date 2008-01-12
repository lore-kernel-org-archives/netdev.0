From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Re: [PATCH] [ROSE] finding a connected ROSE neighbor node
Date: Sat, 12 Jan 2008 21:15:12 +0100
Message-ID: <47891FD0.6050609@ccr.jussieu.fr>
References: <47630274.1080706@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:34900 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757287AbYALUPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 15:15:15 -0500
In-Reply-To: <47630274.1080706@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I propose to drop the previously submitted patch for I performed more
investigations on ROSE frame routing and found that it was not
completely satisfactory.

Please find here another commit to net-2.6.25 with explanations.


 From fd66cc115e058b2fc63a0e26aa73f1d27113105a Mon Sep 17 00:00:00 2001
From: Bernard Pidoux <f6bvp@amsat.org>
Date: Thu, 10 Jan 2008 23:10:44 +0100
Subject: [PATCH 1/4] [ROSE] new rose_get_route() function

rose_get_neigh() was called by two different functions.
Firstly, by rose_connect() in order to establish connections to
adjacent rose nodes. This worked correctly.
Secondly, it was called by rose_route_frame() to find a route
via an adjacent node. This was not working efficiently, for the
proper test was not performed in order to check if the node was
already connected.
A new function rose_get_route() is devoted to frame routing.
It returns a ROSE node address for sending a frame to the
specified destination via a connected node.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
  net/rose/rose_route.c |   34 +++++++++++++++++++++++++++++++++-
  1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 540c0f2..ec79567 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -662,6 +662,38 @@ struct rose_route *rose_route_free_lci(unsigned int 
lci, struct rose_neigh *neig
  }

  /*
+ *     Find an opened route given a ROSE address.
+ */
+struct rose_neigh *rose_get_route(rose_address *addr, unsigned char *cause,
+       unsigned char *diagnostic)
+{
+       struct rose_node *node;
+       int failed = 0;
+       int i;
+
+       for (node = rose_node_list; node != NULL; node = node->next) {
+               if (rosecmpm(addr, &node->address, node->mask) == 0) {
+                       for (i = 0; i < node->count; i++) {
+                               if (node->neighbour[i]->restarted)
+                                       return node->neighbour[i];
+                               failed = 1;
+                       }
+               }
+       }
+
+       if (failed) {
+               *cause      = ROSE_OUT_OF_ORDER;
+               *diagnostic = 0;
+       } else {
+               *cause      = ROSE_NOT_OBTAINABLE;
+               *diagnostic = 0;
+       }
+
+       return NULL;
+}
+
+
+/*
   *     Find a neighbour given a ROSE address.
   */
  struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char 
*cause,
@@ -1019,7 +1051,7 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb 
*ax25)
                 rose_route = rose_route->next;
         }

-       if ((new_neigh = rose_get_neigh(dest_addr, &cause, &diagnostic)) 
== NULL) {
+       if ((new_neigh = rose_get_route(dest_addr, &cause, &diagnostic)) 
== NULL) {
                 rose_transmit_clear_request(rose_neigh, lci, cause, 
diagnostic);
                 goto out;
         }
--
1.5.3.7


