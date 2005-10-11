From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] br: fix race on bridge del if
Date: Tue, 11 Oct 2005 13:33:28 -0700
Message-ID: <20051011133328.26db65d7@localhost.localdomain>
References: <20050818214036.GH10593@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Chris Wright <chrisw@osdl.org>,
        Greg KH
 <greg@kroah.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ryan Harper <ryanh@us.ibm.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050818214036.GH10593@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes the RCU race on bridge delete interface.  Basically,
the network device has to be detached from the bridge in the first
step (pre-RCU), rather than later. At that point, no more bridge traffic
will come in, and the other code will not think that network device
is part of a bridge.

This should also fix the XEN test problems. If there is another
2.6.13-stable, add it as well.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: nexgate-test/net/bridge/br_if.c
===================================================================
--- nexgate-test.orig/net/bridge/br_if.c
+++ nexgate-test/net/bridge/br_if.c
@@ -79,7 +79,6 @@ static void destroy_nbp(struct net_bridg
 {
 	struct net_device *dev = p->dev;
 
-	dev->br_port = NULL;
 	p->br = NULL;
 	p->dev = NULL;
 	dev_put(dev);
@@ -100,6 +99,7 @@ static void del_nbp(struct net_bridge_po
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
+	dev->br_port = NULL;
 	dev_set_promiscuity(dev, -1);
 
 	spin_lock_bh(&br->lock);
