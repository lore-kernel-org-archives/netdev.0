From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (8/9) bridge - support lots of 1k ports
Date: Tue, 13 Apr 2004 15:33:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413153308.6e0dd462@dell_ss3.pdx.osdl.net>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Support >256 ports on a bridge.  Use the suggestion of reducing
the number of bits of priority and increasing the number of bits
for port number.

Easy to increase to even larger if necessary.

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Tue Apr 13 13:16:56 2004
+++ b/net/bridge/br_if.c	Tue Apr 13 13:16:56 2004
@@ -24,9 +24,6 @@
 
 #include "br_private.h"
 
-/* Limited to 256 ports because of STP protocol pdu */
-#define  BR_MAX_PORTS	256
-
 /*
  * Determine initial path cost based on speed.
  * using recommendations from 802.1d standard
@@ -166,23 +163,27 @@
 	return br;
 }
 
-static int free_port(struct net_bridge *br)
+/* find an available port number */
+static int find_portno(struct net_bridge *br)
 {
 	int index;
 	struct net_bridge_port *p;
-	long inuse[BR_MAX_PORTS/(sizeof(long)*8)];
+	unsigned long *inuse;
+
+	inuse = kmalloc(BITS_TO_LONGS(BR_MAX_PORTS)*sizeof(unsigned long),
+			GFP_ATOMIC);
+	if (!inuse)
+		return -ENOMEM;
 
-	/* find free port number */
-	memset(inuse, 0, sizeof(inuse));
+	CLEAR_BITMAP(inuse, BR_MAX_PORTS);
+	set_bit(0, inuse);	/* zero is reserved */
 	list_for_each_entry(p, &br->port_list, list) {
 		set_bit(p->port_no, inuse);
 	}
-
 	index = find_first_zero_bit(inuse, BR_MAX_PORTS);
-	if (index >= BR_MAX_PORTS)
-		return -EXFULL;
+	kfree(inuse);
 
-	return index;
+	return (index >= BR_MAX_PORTS) ? -EXFULL : index;
 }
 
 /* called under bridge lock */
@@ -193,7 +194,7 @@
 	int index;
 	struct net_bridge_port *p;
 	
-	index = free_port(br);
+	index = find_portno(br);
 	if (index < 0)
 		return ERR_PTR(index);
 
@@ -206,7 +207,7 @@
 	dev_hold(dev);
 	p->dev = dev;
 	p->path_cost = cost;
-	p->priority = 0x80;
+ 	p->priority = 0x8000 >> BR_PORT_BITS;
 	dev->br_port = p;
 	p->port_no = index;
 	br_init_port(p);
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Tue Apr 13 13:16:56 2004
+++ b/net/bridge/br_ioctl.c	Tue Apr 13 13:16:56 2004
@@ -91,9 +91,15 @@
 
 	case BRCTL_GET_PORT_LIST:
 	{
-		int num = arg1 ? arg1 : 256;	/* compatiablity */
-		int ret = 0;
-		int *indices;
+		int num, *indices;
+
+		num = arg1;
+		if (num < 0)
+			return -EINVAL;
+		if (num == 0)
+			num = 256;
+		if (num > BR_MAX_PORTS)
+			num = BR_MAX_PORTS;
 
 		indices = kmalloc(num*sizeof(int), GFP_KERNEL);
 		if (indices == NULL)
@@ -103,9 +109,9 @@
 
 		br_get_port_ifindices(br, indices, num);
 		if (copy_to_user((void *)arg0, indices, num*sizeof(int)))
-			ret =  -EFAULT;
+			num =  -EFAULT;
 		kfree(indices);
-		return ret;
+		return num;
 	}
 
 	case BRCTL_SET_BRIDGE_FORWARD_DELAY:
@@ -204,6 +210,9 @@
 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
+
+		if (arg1 >= (1<<(16-BR_PORT_BITS)))
+			return -ERANGE;
 
 		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, arg0)) == NULL) 
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Tue Apr 13 13:16:56 2004
+++ b/net/bridge/br_private.h	Tue Apr 13 13:16:56 2004
@@ -24,6 +24,9 @@
 
 #define BR_HOLD_TIME (1*HZ)
 
+#define BR_PORT_BITS	10
+#define BR_MAX_PORTS	(1<<BR_PORT_BITS)
+
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
 typedef __u16 port_id;
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Tue Apr 13 13:16:56 2004
+++ b/net/bridge/br_stp_if.c	Tue Apr 13 13:16:56 2004
@@ -19,15 +19,21 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-static inline __u16 br_make_port_id(const struct net_bridge_port *p)
+
+/* Port id is composed of priority and port number.
+ * NB: least significant bits of priority are dropped to
+ *     make room for more ports.
+ */
+static inline port_id br_make_port_id(__u8 priority, __u16 port_no)
 {
-	return (p->priority << 8) | p->port_no;
+	return ((u16)priority << BR_PORT_BITS) 
+		| (port_no & ((1<<BR_PORT_BITS)-1));
 }
 
 /* called under bridge lock */
 void br_init_port(struct net_bridge_port *p)
 {
-	p->port_id = br_make_port_id(p);
+	p->port_id = br_make_port_id(p->priority, p->port_no);
 	br_become_designated_port(p);
 	p->state = BR_STATE_BLOCKING;
 	p->topology_change_ack = 0;
@@ -185,15 +191,13 @@
 /* called under bridge lock */
 void br_stp_set_port_priority(struct net_bridge_port *p, u8 newprio)
 {
-	__u16 new_port_id;
-
-	p->priority = newprio & 0xFF;
-	new_port_id = br_make_port_id(p);
+	port_id new_port_id = br_make_port_id(newprio, p->port_no);
 
 	if (br_is_designated_port(p))
 		p->designated_port = new_port_id;
 
 	p->port_id = new_port_id;
+	p->priority = newprio;
 	if (!memcmp(&p->br->bridge_id, &p->designated_bridge, 8) &&
 	    p->port_id < p->designated_port) {
 		br_become_designated_port(p);
