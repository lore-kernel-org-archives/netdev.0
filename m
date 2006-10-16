From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Mon, 16 Oct 2006 20:27:14 +0200
Message-ID: <200610162027.15100.dpc@asn.pl>
References: <200610162021.12884.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:38852 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1422785AbWJPS1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 14:27:23 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200610162021.12884.dpc@asn.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 16 October 2006 20:21, Dawid Ciezarkiewicz wrote:
> This patch is little thinner then the previous one.

I'm sorry for that. I've just ... nevermind. Here goes the patch.

Should I post patch for ifenslave here, too?



diff -Nur linux-2.6.17.orig/Documentation/networking/bonding.txt linux-2.6.17/Documentation/networking/bonding.txt
--- linux-2.6.17.orig/Documentation/networking/bonding.txt	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/Documentation/networking/bonding.txt	2006-07-28 15:47:55.000000000 +0200
@@ -398,6 +398,19 @@
 		swapped with the new curr_active_slave that was
 		chosen.
 
+	weighted-rr or 7
+
+		Weighted round-robin bonding. In this mode bonding
+		interface will use weights assigned to it's slaves.
+
+		Each slave can have weight assigned via ioctl (ifenslave).
+		These values will be used at the start of each "cycle".
+		Each slave will have token counter restored to it's weight.
+		Then using round-robin mechanism those tokens are "used"
+		to pay for emitted frames. When all token counters are
+		zeroed - new "cycle" begins.
+		
+
 primary
 
 	A string (eth0, eth2, etc) specifying which slave is the
diff -Nur linux-2.6.17.orig/drivers/net/bonding/bond_main.c linux-2.6.17/drivers/net/bonding/bond_main.c
--- linux-2.6.17.orig/drivers/net/bonding/bond_main.c	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/drivers/net/bonding/bond_main.c	2006-07-28 15:31:44.000000000 +0200
@@ -115,7 +115,7 @@
 MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
 		       "1 for active-backup, 2 for balance-xor, "
 		       "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
-		       "6 for balance-alb");
+		       "6 for balance-alb, 7 for weighted-rr");
 module_param(primary, charp, 0);
 MODULE_PARM_DESC(primary, "Primary network device to use");
 module_param(lacp_rate, charp, 0);
@@ -162,6 +162,7 @@
 {	"802.3ad",		BOND_MODE_8023AD},
 {	"balance-tlb",		BOND_MODE_TLB},
 {	"balance-alb",		BOND_MODE_ALB},
+{	"weighted-rr",		BOND_MODE_WEIGHTED_RR},
 {	NULL,			-1},
 };
 
@@ -194,6 +195,8 @@
 		return "transmit load balancing";
 	case BOND_MODE_ALB:
 		return "adaptive load balancing";
+	case BOND_MODE_WEIGHTED_RR:
+		return "weighted round robin (weighted-rr)";
 	default:
 		return "unknown";
 	}
@@ -1198,6 +1201,24 @@
 	return 0;
 }
 
+int bond_set_weight(struct net_device *bond_dev, struct net_device *slave_dev,
+		u16 weight)
+{
+	struct slave* slave;
+	slave = bond_get_slave_by_dev(bond_dev->priv, slave_dev);
+	if (!slave) {
+		return -EINVAL;
+	}
+
+	slave->weight = weight;
+
+	if (weight) {
+		slave->link = BOND_LINK_UP;
+		slave->state = BOND_STATE_ACTIVE;
+	}
+	return 0;
+}
+
 #define BOND_INTERSECT_FEATURES \
 	(NETIF_F_SG|NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM|\
 	NETIF_F_TSO|NETIF_F_UFO)
@@ -1336,6 +1352,9 @@
 	 */
 	new_slave->original_flags = slave_dev->flags;
 
+	/* slave default weight = 1 */
+	new_slave->weight = 1;
+
 	/*
 	 * Save slave's original ("permanent") mac address for modes
 	 * that need it, and for restoring it upon release, and then
@@ -3601,7 +3620,10 @@
 	}
 
 	down_write(&(bonding_rwsem));
-	slave_dev = dev_get_by_name(ifr->ifr_slave);
+	if (cmd != SIOCBONDSETWEIGHT)
+		slave_dev = dev_get_by_name(ifr->ifr_slave);
+	else
+		slave_dev = dev_get_by_name(ifr->ifr_weight_slave);
 
 	dprintk("slave_dev=%p: \n", slave_dev);
 
@@ -3626,6 +3648,9 @@
 		case SIOCBONDCHANGEACTIVE:
 			res = bond_ioctl_change_active(bond_dev, slave_dev);
 			break;
+		case SIOCBONDSETWEIGHT:
+			res = bond_set_weight(bond_dev, slave_dev, ifr->ifr_weight_weight);
+			break;
 		default:
 			res = -EOPNOTSUPP;
 		}
@@ -3881,6 +3906,67 @@
 	return 0;
 }
 
+static int bond_xmit_weighted_rr(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+	struct slave *slave, *start_at;
+	int i;
+	int res = 1;
+	int were_weight_tokens_recharged = 0;
+
+	read_lock(&bond->lock);
+
+	if (!BOND_IS_OK(bond)) {
+		goto out;
+	}
+
+	read_lock(&bond->curr_slave_lock);
+	slave = start_at = bond->curr_active_slave;
+	read_unlock(&bond->curr_slave_lock);
+
+	if (!slave) {
+		goto out;
+	}
+
+try_send:
+	bond_for_each_slave_from(bond, slave, i, start_at) {
+		if (IS_UP(slave->dev) &&
+		    (slave->weight_tokens > 0) &&
+			(slave->link == BOND_LINK_UP) &&
+		    (slave->state == BOND_STATE_ACTIVE)) {
+			
+			res = bond_dev_queue_xmit(bond, skb, slave->dev);
+			(slave->weight_tokens)--;
+			write_lock(&bond->curr_slave_lock);
+			bond->curr_active_slave = slave->next;
+			write_unlock(&bond->curr_slave_lock);
+
+			goto out;
+		}
+	}
+	
+	if (were_weight_tokens_recharged == 0) {
+		read_lock(&bond->curr_slave_lock);
+		slave = start_at = bond->curr_active_slave;
+		read_unlock(&bond->curr_slave_lock);
+
+		bond_for_each_slave_from(bond, slave, i, start_at) {
+			slave->weight_tokens = slave->weight;
+		}
+
+		were_weight_tokens_recharged = 1;
+		goto try_send;
+	}
+
+out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
+	read_unlock(&bond->lock);
+	return 0;
+}
+
 static void bond_activebackup_xmit_copy(struct sk_buff *skb,
                                         struct bonding *bond,
                                         struct slave *slave)
@@ -4088,6 +4174,9 @@
 	case BOND_MODE_ROUNDROBIN:
 		bond_dev->hard_start_xmit = bond_xmit_roundrobin;
 		break;
+	case BOND_MODE_WEIGHTED_RR:
+		bond_dev->hard_start_xmit = bond_xmit_weighted_rr;
+		break;
 	case BOND_MODE_ACTIVEBACKUP:
 		bond_dev->hard_start_xmit = bond_xmit_activebackup;
 		break;
diff -Nur linux-2.6.17.orig/drivers/net/bonding/bond_sysfs.c linux-2.6.17/drivers/net/bonding/bond_sysfs.c
--- linux-2.6.17.orig/drivers/net/bonding/bond_sysfs.c	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/drivers/net/bonding/bond_sysfs.c	2006-07-28 15:25:11.000000000 +0200
@@ -241,10 +241,14 @@
 			res += sprintf(buf + res, "++more++");
 			break;
 		}
-		res += sprintf(buf + res, "%s ", slave->dev->name);
+		if (bond->params.mode == BOND_MODE_WEIGHTED_RR) {
+			res += sprintf(buf + res, "%s %d\n", slave->dev->name,
+					slave->weight);
+		} else {
+			res += sprintf(buf + res, "%s\n", slave->dev->name);
+		}
 	}
 	read_unlock_bh(&bond->lock);
-	res += sprintf(buf + res, "\n");
 	res++;
 	return res;
 }
diff -Nur linux-2.6.17.orig/drivers/net/bonding/bonding.h linux-2.6.17/drivers/net/bonding/bonding.h
--- linux-2.6.17.orig/drivers/net/bonding/bonding.h	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/drivers/net/bonding/bonding.h	2006-07-28 15:25:11.000000000 +0200
@@ -150,6 +150,8 @@
 	struct slave *next;
 	struct slave *prev;
 	s16    delay;
+	u16    weight_tokens;
+	u16    weight;
 	u32    jiffies;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
diff -Nur linux-2.6.17.orig/include/linux/if.h linux-2.6.17/include/linux/if.h
--- linux-2.6.17.orig/include/linux/if.h	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/include/linux/if.h	2006-07-28 15:25:11.000000000 +0200
@@ -172,6 +172,11 @@
 		char	ifru_newname[IFNAMSIZ];
 		void __user *	ifru_data;
 		struct	if_settings ifru_settings;
+		struct {
+			__u16 weight;
+			char slave[IFNAMSIZ];	
+		} ifru_weight;
+
 	} ifr_ifru;
 };
 
@@ -180,6 +185,8 @@
 #define	ifr_addr	ifr_ifru.ifru_addr	/* address		*/
 #define	ifr_dstaddr	ifr_ifru.ifru_dstaddr	/* other end of p-p lnk	*/
 #define	ifr_broadaddr	ifr_ifru.ifru_broadaddr	/* broadcast address	*/
+#define	ifr_weight_weight ifr_ifru.ifru_weight.weight /* bonding weight*/
+#define	ifr_weight_slave  ifr_ifru.ifru_weight.slave  /* bonding weight slave */
 #define	ifr_netmask	ifr_ifru.ifru_netmask	/* interface net mask	*/
 #define	ifr_flags	ifr_ifru.ifru_flags	/* flags		*/
 #define	ifr_metric	ifr_ifru.ifru_ivalue	/* metric		*/
diff -Nur linux-2.6.17.orig/include/linux/if_bonding.h linux-2.6.17/include/linux/if_bonding.h
--- linux-2.6.17.orig/include/linux/if_bonding.h	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/include/linux/if_bonding.h	2006-07-28 15:25:11.000000000 +0200
@@ -70,6 +70,7 @@
 #define BOND_MODE_8023AD        4
 #define BOND_MODE_TLB           5
 #define BOND_MODE_ALB		6 /* TLB + RLB (receive load balancing) */
+#define BOND_MODE_WEIGHTED_RR   7
 
 /* each slave's link has 4 states */
 #define BOND_LINK_UP    0           /* link is up and running */
diff -Nur linux-2.6.17.orig/include/linux/sockios.h linux-2.6.17/include/linux/sockios.h
--- linux-2.6.17.orig/include/linux/sockios.h	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/include/linux/sockios.h	2006-07-28 15:25:11.000000000 +0200
@@ -115,6 +115,7 @@
 #define SIOCBONDSLAVEINFOQUERY 0x8993   /* rtn info about slave state   */
 #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
 #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
+#define SIOCBONDSETWEIGHT      0x899e   /* update weight */
 			
 /* bridge calls */
 #define SIOCBRADDBR     0x89a0		/* create new bridge device     */
diff -Nur linux-2.6.17.orig/net/core/dev.c linux-2.6.17/net/core/dev.c
--- linux-2.6.17.orig/net/core/dev.c	2006-06-18 03:49:35.000000000 +0200
+++ linux-2.6.17/net/core/dev.c	2006-07-28 15:25:11.000000000 +0200
@@ -2495,6 +2495,7 @@
 			    cmd <= SIOCDEVPRIVATE + 15) ||
 			    cmd == SIOCBONDENSLAVE ||
 			    cmd == SIOCBONDRELEASE ||
+			    cmd == SIOCBONDSETWEIGHT ||
 			    cmd == SIOCBONDSETHWADDR ||
 			    cmd == SIOCBONDSLAVEINFOQUERY ||
 			    cmd == SIOCBONDINFOQUERY ||
@@ -2656,6 +2657,7 @@
 		case SIOCBONDRELEASE:
 		case SIOCBONDSETHWADDR:
 		case SIOCBONDCHANGEACTIVE:
+		case SIOCBONDSETWEIGHT:
 		case SIOCBRADDIF:
 		case SIOCBRDELIF:
 			if (!capable(CAP_NET_ADMIN))

