From: Per Hedeland <per@hedeland.org>
Subject: [PATCH] [bonding 2.4] Fixes for balance-xor and balance-rr
Date: Sat, 24 Jan 2004 13:33:43 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401241233.i0OCXhqk021515@pluto.hedeland.org>
References: <200401112145.i0BLjGWJ095607@pluto.hedeland.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
In-Reply-To: <200401112145.i0BLjGWJ095607@pluto.hedeland.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Per Hedeland <per@hedeland.org> wrote:
>
>However when looking at this I realized that the xor mode has a pretty
>serious bug/flaw in the fault-tolerance department: The modulus is done
>with the total number of slaves, and slaves that are down are only
>skipped in that find-slave logic. I.e. if you (e.g.) have a bond with 3
>links where link 1 is down, link 2 will get 2/3 of the traffic and link
>3 get 1/3 - not good I think.

Enclosed is a fix for this against current netdev-2.4.  I also noticed
that there seems to be another serious bug in bond_xmit_xor(): If all
slaves are down, it will neither dev_queue_xmit() nor dev_kfree_skb().
Ditto for bond_xmit_roundrobin() - the patch should fix both. Comments
appreciated.

Also enclosed are some stats from a balance-xor-ip bond with 4 slaves
(eth2-eth5) where the first two are down - as expected, the patch
changes the transmit load distribution from ~ 75/25 to close to 50/50 on
the two remaining ones (eth4, eth5).

--Per Hedeland
per@hedeland.org

====================================================================
Before fix:

eth4      Link encap:Ethernet  HWaddr 00:C0:95:C9:1A:28
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:451676 errors:0 dropped:0 overruns:0 frame:0
          TX packets:300809 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:192971475 (184.0 Mb)  TX bytes:145298331 (138.5 Mb)
          Interrupt:20 Base address:0x5400

eth5      Link encap:Ethernet  HWaddr 00:C0:95:C9:1A:28
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:169355 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:208 (208.0 b)  TX bytes:51126318 (48.7 Mb)
          Interrupt:21 Base address:0x7000

-------------------------------------------------------------------
After fix:

eth4      Link encap:Ethernet  HWaddr 00:C0:95:C9:1A:28
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:453036 errors:0 dropped:0 overruns:0 frame:0
          TX packets:223884 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:193532059 (184.5 Mb)  TX bytes:93244842 (88.9 Mb)
          Interrupt:20 Base address:0x5400

eth5      Link encap:Ethernet  HWaddr 00:C0:95:C9:1A:28
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:249256 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:208 (208.0 b)  TX bytes:103875515 (99.0 Mb)
          Interrupt:21 Base address:0x7000

====================================================================

diff -ruN a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Fri Jan 23 18:03:31 2004
+++ b/drivers/net/bonding/bond_main.c	Fri Jan 23 18:12:23 2004
@@ -2010,6 +2010,7 @@
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
+ 	int up_slaves = 0;
 	int i;
 
 	read_lock(&bond->lock);
@@ -2046,6 +2047,7 @@
 		case BOND_LINK_UP:	/* the link was up */
 			if (link_state == BMSR_LSTATUS) {
 				/* link stays up, nothing more to do */
+				up_slaves++;
 				break;
 			} else { /* link going down */
 				slave->link  = BOND_LINK_FAIL;
@@ -2115,6 +2117,7 @@
 			} else {
 				/* link up again */
 				slave->link  = BOND_LINK_UP;
+				up_slaves++;
 				slave->jiffies = jiffies;
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status up again after %d "
@@ -2163,6 +2166,7 @@
 				if (slave->delay == 0) {
 					/* now the link has been up for long time enough */
 					slave->link = BOND_LINK_UP;
+					up_slaves++;
 					slave->jiffies = jiffies;
 
 					if (bond->params.mode == BOND_MODE_8023AD) {
@@ -2237,6 +2241,8 @@
 		write_unlock(&bond->curr_slave_lock);
 	}
 
+	bond->up_slave_cnt = up_slaves;
+
 re_arm:
 	if (bond->params.miimon) {
 		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
@@ -2270,6 +2276,7 @@
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
+ 	int up_slaves = 0;
 	int i;
 
 	read_lock(&bond->lock);
@@ -2303,6 +2310,7 @@
 
 				slave->link  = BOND_LINK_UP;
 				slave->state = BOND_STATE_ACTIVE;
+				up_slaves++;
 
 				/* primary_slave has no meaning in round-robin
 				 * mode. the window of a slave being up and
@@ -2349,7 +2357,9 @@
 				if (slave == oldcurrent) {
 					do_failover = 1;
 				}
-			}
+			} else {
+				up_slaves++;
+			}				
 		}
 
 		/* note: if switch is in round-robin mode, all links
@@ -2379,6 +2389,8 @@
 		write_unlock(&bond->curr_slave_lock);
 	}
 
+	bond->up_slave_cnt = up_slaves;
+
 re_arm:
 	if (bond->params.arp_interval) {
 		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
@@ -3601,14 +3613,14 @@
 		}
 	}
 
-out:
-	read_unlock(&bond->lock);
-	return 0;
-
 free_out:
 	/* no suitable interface, frame not sent */
 	dev_kfree_skb(skb);
 	goto out;
+
+out:
+	read_unlock(&bond->lock);
+	return 0;
 }
 
 /*
@@ -3665,47 +3677,42 @@
 {
 	struct bonding *bond = bond_dev->priv;
 	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct slave *slave, *start_at;
+	struct slave *slave;
+	int slave_cnt;
 	int slave_no;
 	int i;
 
 	read_lock(&bond->lock);
 
-	if (!BOND_IS_OK(bond)) {
+	slave_cnt = bond->up_slave_cnt;
+	if (!BOND_IS_OK(bond) || slave_cnt == 0) {
 		goto free_out;
 	}
 
-	slave_no = (data->h_dest[5]^bond_dev->dev_addr[5]) % bond->slave_cnt;
+	slave_no = (data->h_dest[5]^bond_dev->dev_addr[5]) % slave_cnt;
 
 	bond_for_each_slave(bond, slave, i) {
-		slave_no--;
-		if (slave_no < 0) {
-			break;
-		}
-	}
-
-	start_at = slave;
-
-	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
 		    (slave->state == BOND_STATE_ACTIVE)) {
-			skb->dev = slave->dev;
-			skb->priority = 1;
-			dev_queue_xmit(skb);
+			slave_no--;
+			if (slave_no < 0) {
+				skb->dev = slave->dev;
+				skb->priority = 1;
+				dev_queue_xmit(skb);
 
-			goto out;
+				goto out;
+			}
 		}
 	}
 
-out:
-	read_unlock(&bond->lock);
-	return 0;
-
 free_out:
 	/* no suitable interface, frame not sent */
 	dev_kfree_skb(skb);
-	goto out;
+
+out:
+	read_unlock(&bond->lock);
+	return 0;
 }
 
 /*
diff -ruN a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Fri Jan 23 18:14:51 2004
+++ b/drivers/net/bonding/bonding.h	Fri Jan 23 18:15:39 2004
@@ -180,6 +180,7 @@
 	struct   slave *current_arp_slave;
 	struct   slave *primary_slave;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
+	s32      up_slave_cnt;	/* never change outside periodic monitors */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	struct   timer_list mii_timer;
