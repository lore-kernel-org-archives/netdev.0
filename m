From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Fri, 2 Mar 2007 14:09:29 -0800
Message-ID: <20070302140929.262e8460@freekitty>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net>
	<20070302.132638.38710461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43213 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030589AbXCBWOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 17:14:25 -0500
In-Reply-To: <20070302.132638.38710461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Mar 2007 13:26:38 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 28 Feb 2007 17:18:46 -0800
> 
> > I was measuring bridging/routing performance and noticed this.
> > 
> > The current code runs the "all packet" type handlers before calling the
> > bridge hook.  If an application (like some DHCP clients) is using AF_PACKET,
> > this means that each received packet gets run through the Berkeley Packet Filter
> > code in sk_run_filter (slow).
> 
> I know we closed this out by saying that even though performance
> sucks, we can't really apply this without breaking things.

wrong.

> What would be broken is if the DHCP client isn't specifying
> a device ifindex when it binds the AF_PACKET socket.  That
> would be an easy way to fix this performance problem at the
> application level.
> 
> The DHCP client should only care about a particular interface's
> traffic, the one it wants to listen on.


My assumption is that when bridging, the normal stack path only has
to receive those packets that it would receive if it was not doing
bridging.

A better version of the patch is:
==============

The current code runs the "all packet" type handlers before calling the
bridge hook.  If an application (like some DHCP clients) is using AF_PACKET,
this means that each received packet gets run through the Berkeley Packet Filter
code in sk_run_filter. This is significant overhead.

By moving the bridging hook to run first, the packets flowing through
the bridge get filtered out there first. This results in a 14%
improvement in performance.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- netem.orig/net/core/dev.c
+++ netem/net/core/dev.c
@@ -1702,9 +1702,12 @@ struct net_bridge_fdb_entry *(*br_fdb_ge
 						unsigned char *addr);
 void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
-static __inline__ int handle_bridge(struct sk_buff **pskb,
-				    struct packet_type **pt_prev, int *ret,
-				    struct net_device *orig_dev)
+/*
+ * If bridge module is loaded call bridging hook.
+ * when it returns 1, this is a non-local packet
+ */
+int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb) __read_mostly;
+static int handle_bridge(struct sk_buff **pskb)
 {
 	struct net_bridge_port *port;
 
@@ -1712,15 +1715,10 @@ static __inline__ int handle_bridge(stru
 	    (port = rcu_dereference((*pskb)->dev->br_port)) == NULL)
 		return 0;
 
-	if (*pt_prev) {
-		*ret = deliver_skb(*pskb, *pt_prev, orig_dev);
-		*pt_prev = NULL;
-	}
-
 	return br_handle_frame_hook(port, pskb);
 }
 #else
-#define handle_bridge(skb, pt_prev, ret, orig_dev)	(0)
+#define handle_bridge(pskb)	0
 #endif
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -1799,6 +1797,9 @@ int netif_receive_skb(struct sk_buff *sk
 	}
 #endif
 
+	if (handle_bridge(&skb))
+		goto out;
+
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
@@ -1826,9 +1827,6 @@ int netif_receive_skb(struct sk_buff *sk
 ncls:
 #endif
 
-	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
-		goto out;
-
 	type = skb->protocol;
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
 		if (ptype->type == type &&



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
