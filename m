From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge (2.6.5) -- correctl handle up to 256 ports per
 bridge
Date: Thu, 1 Apr 2004 13:57:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401135746.0f985897@dell_ss3.pdx.osdl.net>
References: <406B251B.9050907@usr.fi>
	<20040401093618.49cca9fa@dell_ss3.pdx.osdl.net>
	<406CA0D7.6020500@usr.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Keskinen <weeti@usr.fi>, bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <406CA0D7.6020500@usr.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bridge code is limited to 256 ports per bridge because the Spanning
Tree Protocol has limit of one octet for port number.  This code
fixes:
	* bogus unlock in error path when port list is full.
	* passes different error status for out of memory, vs
	  port list full.
	* O(n) vs O(n^2) lookup for free port number
	* since port and priority are both limited to one byte
	  don't store them as int's
	* makes limit explicit in code

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Thu Apr  1 12:55:31 2004
+++ b/net/bridge/br_if.c	Thu Apr  1 12:55:31 2004
@@ -24,6 +24,9 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
+/* Limited to 256 ports because of STP protocol pdu */
+#define  BR_MAX_PORTS	256
+
 static int br_initial_port_cost(struct net_device *dev)
 {
 	if (!strncmp(dev->name, "lec", 3))
@@ -126,34 +129,46 @@
 	return br;
 }
 
+static int free_port(struct net_bridge *br)
+{
+	int index;
+	struct net_bridge_port *p;
+	long inuse[BR_MAX_PORTS/(sizeof(long)*8)];
+
+	/* find free port number */
+	memset(inuse, 0, sizeof(inuse));
+	list_for_each_entry(p, &br->port_list, list) {
+		set_bit(p->port_no, inuse);
+	}
+
+	index = find_first_zero_bit(inuse, BR_MAX_PORTS);
+	if (index >= BR_MAX_PORTS)
+		return -EXFULL;
+
+	return index;
+}
+
 /* called under bridge lock */
 static struct net_bridge_port *new_nbp(struct net_bridge *br, struct net_device *dev)
 {
-	int i;
+	int index;
 	struct net_bridge_port *p;
+	
+	index = free_port(br);
+	if (index < 0)
+		return ERR_PTR(index);
 
 	p = kmalloc(sizeof(*p), GFP_ATOMIC);
 	if (p == NULL)
-		return p;
+		return ERR_PTR(-ENOMEM);
 
 	memset(p, 0, sizeof(*p));
 	p->br = br;
 	p->dev = dev;
 	p->path_cost = br_initial_port_cost(dev);
 	p->priority = 0x80;
-
-	for (i=1;i<255;i++)
-		if (br_get_port(br, i) == NULL)
-			break;
-
-	if (i == 255) {
-		kfree(p);
-		return NULL;
-	}
-
 	dev->br_port = p;
-
-	p->port_no = i;
+	p->port_no = index;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 
@@ -218,10 +233,10 @@
 		return -ELOOP;
 
 	dev_hold(dev);
-	if ((p = new_nbp(br, dev)) == NULL) {
-		spin_unlock_bh(&br->lock);
+	p = new_nbp(br, dev);
+	if (IS_ERR(p)) {
 		dev_put(dev);
-		return -EXFULL;
+		return PTR_ERR(p);
 	}
 
 	dev_set_promiscuity(dev, 1);
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Thu Apr  1 12:55:31 2004
+++ b/net/bridge/br_private.h	Thu Apr  1 12:55:31 2004
@@ -57,7 +57,8 @@
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
-	int				port_no;
+	__u8				port_no;
+	__u8				priority;
 
 	/* STP */
 	port_id				port_id;
@@ -69,7 +70,6 @@
 	port_id				designated_port;
 	unsigned			topology_change_ack:1;
 	unsigned			config_pending:1;
-	int				priority;
 
 	struct timer_list		forward_delay_timer;
 	struct timer_list		hold_timer;
