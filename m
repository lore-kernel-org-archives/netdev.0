From: "JUNG, Christian" <christian.jung@saarstahl.com>
Subject: bonding: bug in balance-alb mode (incorrect update-ARP-replies)
Date: Tue, 23 Jan 2007 18:52:21 +0100
Message-ID: <FA8270F9F8D35946ADDBC0F36E6667CE0175C9B8@nts27.saarstahl.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-owner@vger.kernel.org>
Received: from sag2.saarstahl.de ([62.154.234.163]:2617 "HELO
	ig01.int.saarstahl.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S932091AbXAWSIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 13:08:20 -0500
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've discovered a bug in the bonding module of the Linux Kernel, which
appears 
only in bonding-mode balance-alb.

Description:

    You have to setup a box with at least two NICs, a bonding device
enslaving
    those, assign at least two IPs to the bond and make some traffic from a
    different machine to one of those IPs.

    If you delete that IP, the box will regardlessly send ARP-replies to the
    machine which communicated to that IP before removing it.

    This comes from the rx_hashtbl and the receive load balancing algorithm.

    The bug is very serious if bonding is used in a cluster-environment
using
    two nodes which are connected to the same subnet. If an IP-bound service
has
    to failover to the other node, the old node would announce its
MAC-address
    for the IP which isn't owned by the node anymore. So client-traffic in
the
    same net would hit the old node.
    
    A possible workaround could be the usage of balance-tlb instead of
    balance-alb.

I've made a little patch which removes every entry from the rx_hashtbl, if
the
according IP is removed from the bond. The patch was made for Linux Kernel
version 2.6.19.

---8<---
diff -ur linux-2.6.19/drivers/net/bonding/bond_alb.c
linux/drivers/net/bonding/bond_alb.c
--- linux-2.6.19/drivers/net/bonding/bond_alb.c	2006-11-29
22:57:37.000000000 +0100
+++ linux/drivers/net/bonding/bond_alb.c	2007-01-16
17:23:53.000000000 +0100
@@ -1677,3 +1677,38 @@
 	}
 }
 
+void bond_alb_remove_ip_from_rlb(struct bonding *bond, u32 ip) {
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	u32 curr_index;
+
+	dprintk("%s: removing entries from rx_hashtbl for IP %lx\n",
bond->dev->name, ip);
+	_lock_rx_hashtbl(bond);
+
+	curr_index = bond_info->rx_hashtbl_head;
+	while (curr_index != RLB_NULL_INDEX) {
+		struct rlb_client_info *curr =
&(bond_info->rx_hashtbl[curr_index]);
+		u32 next_index = bond_info->rx_hashtbl[curr_index].next;
+		u32 prev_index = bond_info->rx_hashtbl[curr_index].prev;
+
+		if (curr->ip_src == ip) {
+			dprintk("%s: entry %u matched\n", bond->dev->name,
curr_index);
+
+			if (curr_index == bond_info->rx_hashtbl_head) {
+				bond_info->rx_hashtbl_head = next_index;
+			}
+			if (prev_index != RLB_NULL_INDEX) {
+				bond_info->rx_hashtbl[prev_index].next =
next_index;
+			}
+			if (next_index != RLB_NULL_INDEX) {
+				bond_info->rx_hashtbl[next_index].prev =
prev_index;
+			}
+
+			rlb_init_table_entry(curr);
+		}
+
+		curr_index = next_index;
+	}
+
+	_unlock_rx_hashtbl(bond);
+}
+
diff -ur linux-2.6.19/drivers/net/bonding/bond_alb.h
linux/drivers/net/bonding/bond_alb.h
--- linux-2.6.19/drivers/net/bonding/bond_alb.h	2006-11-29
22:57:37.000000000 +0100
+++ linux/drivers/net/bonding/bond_alb.h	2007-01-16
17:23:53.000000000 +0100
@@ -128,5 +128,6 @@
 void bond_alb_monitor(struct bonding *bond);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
+void bond_alb_remove_ip_from_rlb(struct bonding *bond, u32 ip);
 #endif /* __BOND_ALB_H__ */
 
diff -ur linux-2.6.19/drivers/net/bonding/bond_main.c
linux/drivers/net/bonding/bond_main.c
--- linux-2.6.19/drivers/net/bonding/bond_main.c	2006-11-29
22:57:37.000000000 +0100
+++ linux/drivers/net/bonding/bond_main.c	2007-01-16
17:30:49.000000000 +0100
@@ -3356,6 +3356,12 @@
 				return NOTIFY_OK;
 			case NETDEV_DOWN:
 				bond->master_ip =
bond_glean_dev_ip(bond->dev);
+
+				/* remove IP from RLB hashtable if using
balance-alb mode: */
+				if (bond->params.mode == BOND_MODE_ALB) {
+					bond_alb_remove_ip_from_rlb(bond,
ifa->ifa_local);
+				}
+
 				return NOTIFY_OK;
 			default:
 				return NOTIFY_DONE;
---8<---

The function bond_alb_remove_ip_from_rlb is heavily based on the function
rlb_clear_vlan.

And here's a useful patch for debugging purposes (it outputs the rx_hashtbl
in
the proc-file of the bond):

---8<---
diff -ur linux-2.6.19/drivers/net/bonding/bond_alb.c
linux/drivers/net/bonding/bond_alb.c
--- linux-2.6.19/drivers/net/bonding/bond_alb.c	2007-01-16
18:59:32.000000000 +0100
+++ linux/drivers/net/bonding/bond_alb.c	2007-01-16
18:48:15.000000000 +0100
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/pkt_sched.h>
+#include <linux/seq_file.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
 #include <linux/timer.h>
@@ -1677,6 +1678,45 @@
 	}
 }
 
+void bond_alb_info_show(struct seq_file *seq) {
+	struct bonding *bond = seq->private;
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct rlb_client_info *rx_hash_table;
+	u32 index;
+	u32 src, dst;
+
+	seq_puts(seq, "\nALB info\n\n");
+	seq_puts(seq, "    Receive Load Balancing table:\n\n");
+	seq_puts(seq, "    Index Slave    Server          Client
Client-MAC        Asgnd\n");
+
+	_lock_rx_hashtbl(bond);
+
+	rx_hash_table = bond_info->rx_hashtbl;
+
+	if (rx_hash_table != NULL) {
+		for (index = bond_info->rx_hashtbl_head; 
+				index != RLB_NULL_INDEX; 
+				index = rx_hash_table[index].next) {
+			src = ntohl(rx_hash_table[index].ip_src);
+			dst = ntohl(rx_hash_table[index].ip_dst);
+
+			seq_printf(seq,        
+					"    %03u   %8s %03u.%03u.%03u.%03u
%03u.%03u.%03u.%03u %02x:%02x:%02x:%02x:%02x:%02x %3s\n",
+					index,
+					(rx_hash_table[index].slave != NULL
? rx_hash_table[index].slave->dev->name : "none"),
+					((src >> 24) & 0xff), ((src >> 16) &
0xff), ((src >> 8) & 0xff), (src & 0xff), 
+					((dst >> 24) & 0xff), ((dst >> 16) &
0xff), ((dst >> 8) & 0xff), (dst & 0xff), 
+					rx_hash_table[index].mac_dst[0],
rx_hash_table[index].mac_dst[1],
+					rx_hash_table[index].mac_dst[2],
rx_hash_table[index].mac_dst[3],
+					rx_hash_table[index].mac_dst[4],
rx_hash_table[index].mac_dst[5],
+					(rx_hash_table[index].assigned ?
"yes" : "no")
+			);
+		}
+	}	
+
+	_unlock_rx_hashtbl(bond);
+}
+
 void bond_alb_remove_ip_from_rlb(struct bonding *bond, u32 ip) {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	u32 curr_index;
diff -ur linux-2.6.19/drivers/net/bonding/bond_alb.h
linux/drivers/net/bonding/bond_alb.h
--- linux-2.6.19/drivers/net/bonding/bond_alb.h	2007-01-16
18:59:32.000000000 +0100
+++ linux/drivers/net/bonding/bond_alb.h	2007-01-16
19:01:46.000000000 +0100
@@ -128,6 +128,7 @@
 void bond_alb_monitor(struct bonding *bond);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
+void bond_alb_info_show(struct seq_file *seq);
 void bond_alb_remove_ip_from_rlb(struct bonding *bond, u32 ip);
 #endif /* __BOND_ALB_H__ */
 
diff -ur linux-2.6.19/drivers/net/bonding/bond_main.c
linux/drivers/net/bonding/bond_main.c
--- linux-2.6.19/drivers/net/bonding/bond_main.c	2007-01-16
18:59:32.000000000 +0100
+++ linux/drivers/net/bonding/bond_main.c	2007-01-16
18:48:15.000000000 +0100
@@ -3048,6 +3048,10 @@
 				   ad_info.partner_system[5]);
 		}
 	}
+	else
+	if (bond->params.mode == BOND_MODE_ALB) {
+		bond_alb_info_show(seq);
+	}
 }
 
 static void bond_info_show_slave(struct seq_file *seq, const struct slave
*slave)
---8<---

I attach this example to visualize the bug. The box is named 'linux' (which
has
the two IPs 10.0.91.128 and 10.0.91.129) and the other machine (which makes
some traffic) is called 'dave'. Their clocks are synchronized via NTP.

---8<---
linux:~ # modprobe bonding miimon=100 updelay=200 mode=balance-alb
use_carrier=0
linux:~ # ifconfig bond0 10.0.91.128 netmask 255.255.255.0 up
linux:~ # ifenslave bond0 eth1
linux:~ # ifenslave bond0 eth2
linux:~ # ip addr add 10.0.91.129 dev bond0
linux:~ # ip addr sh bond0
18: bond0: <BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc noqueue 
    link/ether 00:02:b3:55:2e:b1 brd ff:ff:ff:ff:ff:ff
    inet 10.0.91.128/24 brd 10.255.255.255 scope global bond0
    inet 10.0.91.129/32 scope global bond0
    inet6 fe80::200:ff:fe00:0/64 scope link 
       valid_lft forever preferred_lft forever
---

dave:~ # ping 10.0.91.129
PING 10.0.91.129 (10.0.91.129) 56(84) bytes of data.
64 bytes from 10.0.91.129: icmp_seq=1 ttl=64 time=3.83 ms
64 bytes from 10.0.91.129: icmp_seq=2 ttl=64 time=0.205 ms
[...]
dave:~ # tcpdump -i bond0 arp host 10.0.91.129
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond0, link-type EN10MB (Ethernet), capture size 96 bytes
11:55:41.829735 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
11:55:41.830993 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
11:55:44.047261 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
11:55:44.047276 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
[...]

---

linux:~ # ip addr del 10.0.91.129 dev bond0
linux:~ # ip addr sh bond0
18: bond0: <BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc noqueue 
    link/ether 00:02:b3:55:2e:b1 brd ff:ff:ff:ff:ff:ff
    inet 10.0.91.128/24 brd 10.255.255.255 scope global bond0
    inet6 fe80::200:ff:fe00:0/64 scope link 
       valid_lft forever preferred_lft forever
linux:~ # date
Tue Jan 16 11:55:57 CET 2007

---

dave:~ # date
Tue Jan 16 11:56:59 CET 2007
dave:~ # tcpdump -i bond0 arp host 10.0.91.129
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on bond0, link-type EN10MB (Ethernet), capture size 96 bytes
11:57:04.305078 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
11:57:04.306248 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
11:57:06.704552 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
11:57:06.704569 arp reply 10.0.91.129 is-at 00:02:b3:55:2e:b1 (oui Unknown)
[...]
---8<---


Bye
Christian Jung

PS I'm sorry but I have to use a mailer which has some handicaps. If the
whitespaces of the patches are munged in any way I can send you the patches
as
attachment.

Another thing: When shutting down a bond (e.g. ifconfig bond0 0.0.0.0 down)
the
slaves keep the master IP address of the bond. Is there a special reason for
this behaviour? 

phone: +49 6898/10-4987
fax: +49 6898/10-54987
http://www.saarstahl.de
