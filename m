From: Per Hedeland <per@hedeland.org>
Subject: [PATCH] [bonding 2.4] Add balance-xor-ip bonding mode
Date: Wed, 7 Jan 2004 21:58:32 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401072058.i07KwWba054481@pluto.hedeland.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds a new bonding policy, similar to the previously existing
balance-xor, but using the IP addresses rather than MAC addresses for IP
packets, with fallback to MAC-based balance-xor for non-IP packets.

The patch is against the netdev-2.4 tree (with Shmulik's 'update comment
blocks' and Amir's 'using per-bond parameters' patches applied).

--Per Hedeland
per@hedeland.org


diff -Nru a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt	Wed Jan  7 16:31:56 2004
+++ b/Documentation/networking/bonding.txt	Wed Jan  7 16:33:42 2004
@@ -368,6 +368,17 @@
 		fails it's hw address is swapped with the new curr_active_slave
 		that was chosen.
 
+	balance-xor-ip or 7
+
+		XOR IP policy: Transmit based on [(source IP address
+		XOR'd with destination IP address) modula slave count].
+		I.e. similar to balance-xor, but uses the IP addresses
+		rather than MAC addresses for IP packets, which provides
+		better load balancing in some cases (e.g. most traffic
+		sent to a default gateway). For non-IP packets, it will
+		fall back to MAC-based balance-xor. This mode provides
+		load balancing and fault tolerance.
+
 primary
 
         A string (eth0, eth2, etc) to equate to a primary device. If this
diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Wed Jan  7 16:26:59 2004
+++ b/drivers/net/bonding/bond_main.c	Wed Jan  7 16:41:28 2004
@@ -476,6 +476,7 @@
 #include <linux/ioport.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/init.h>
@@ -585,6 +586,7 @@
 {	"balance-rr",		BOND_MODE_ROUNDROBIN},
 {	"active-backup",	BOND_MODE_ACTIVEBACKUP},
 {	"balance-xor",		BOND_MODE_XOR},
+{	"balance-xor-ip",	BOND_MODE_XOR_IP},
 {	"broadcast",		BOND_MODE_BROADCAST},
 {	"802.3ad",		BOND_MODE_8023AD},
 {	"balance-tlb",		BOND_MODE_TLB},
@@ -607,6 +609,8 @@
 		return "fault-tolerance (active-backup)";
 	case BOND_MODE_XOR :
 		return "load balancing (xor)";
+	case BOND_MODE_XOR_IP:
+		return "load balancing (xor-ip)";
 	case BOND_MODE_BROADCAST :
 		return "fault-tolerance (broadcast)";
 	case BOND_MODE_8023AD:
@@ -3658,16 +3662,17 @@
 
 /*
  * in XOR mode, we determine the output device by performing xor on
- * the source and destination hw adresses.  If this device is not
+ * the source and destination adresses.  If this device is not
  * enabled, find the next slave following this xor slave.
  */
-static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
+static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev, int use_ip)
 {
 	struct bonding *bond = bond_dev->priv;
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct slave *slave, *start_at;
-	int slave_no;
+	int slave_no = 0;
 	int i;
+	__u32 u;
 
 	read_lock(&bond->lock);
 
@@ -3675,7 +3680,30 @@
 		goto free_out;
 	}
 
-	slave_no = (data->h_dest[5]^bond_dev->dev_addr[5]) % bond->slave_cnt;
+	if (use_ip) {
+		switch (ntohs(skb->protocol)) {
+		case ETH_P_IP:
+			u = skb->nh.iph->saddr ^ skb->nh.iph->daddr;
+			u ^= (u >> 24) ^ (u >> 16) ^ (u >> 8);
+			slave_no = (u & 0xff) % bond->slave_cnt;
+			break;
+		case ETH_P_IPV6:
+			for (u = 0, i = 0; i < 4; i++) {
+				u ^= skb->nh.ipv6h->saddr.s6_addr32[i] ^
+					skb->nh.ipv6h->daddr.s6_addr32[i];
+			}
+			u ^= (u >> 24) ^ (u >> 16) ^ (u >> 8);
+			slave_no = (u & 0xff) % bond->slave_cnt;
+			break;
+		default:
+			use_ip = 0;
+			break;
+		}
+	}
+
+	if (!use_ip) {
+		slave_no = (data->h_dest[5]^bond_dev->dev_addr[5]) % bond->slave_cnt;
+	}
 
 	bond_for_each_slave(bond, slave, i) {
 		slave_no--;
@@ -3708,6 +3736,16 @@
 	goto out;
 }
 
+static int bond_xmit_xor_mac(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	return bond_xmit_xor(skb, bond_dev, 0);
+}
+
+static int bond_xmit_xor_ip(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	return bond_xmit_xor(skb, bond_dev, 1);
+}
+
 /*
  * in broadcast mode, we send everything to all usable interfaces.
  */
@@ -3794,7 +3832,10 @@
 		bond_dev->hard_start_xmit = bond_xmit_activebackup;
 		break;
 	case BOND_MODE_XOR:
-		bond_dev->hard_start_xmit = bond_xmit_xor;
+		bond_dev->hard_start_xmit = bond_xmit_xor_mac;
+		break;
+	case BOND_MODE_XOR_IP:
+		bond_dev->hard_start_xmit = bond_xmit_xor_ip;
 		break;
 	case BOND_MODE_BROADCAST:
 		bond_dev->hard_start_xmit = bond_xmit_broadcast;
@@ -3915,8 +3956,7 @@
 	for (i = 0; tbl[i].modename; i++) {
 		if ((isdigit(*mode_arg) &&
 		     tbl[i].mode == simple_strtol(mode_arg, NULL, 0)) ||
-		    (strncmp(mode_arg, tbl[i].modename,
-			     strlen(tbl[i].modename)) == 0)) {
+		    (strcmp(mode_arg, tbl[i].modename) == 0)) {
 			return tbl[i].mode;
 		}
 	}
diff -Nru a/include/linux/if_bonding.h b/include/linux/if_bonding.h
--- a/include/linux/if_bonding.h	Wed Jan  7 16:24:48 2004
+++ b/include/linux/if_bonding.h	Wed Jan  7 16:33:42 2004
@@ -67,6 +67,7 @@
 #define BOND_MODE_8023AD        4
 #define BOND_MODE_TLB           5
 #define BOND_MODE_ALB		6 /* TLB + RLB (receive load balancing) */
+#define BOND_MODE_XOR_IP	7
 
 /* each slave's link has 4 states */
 #define BOND_LINK_UP    0           /* link is up and running */
