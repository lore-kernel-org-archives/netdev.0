From: Patrick Schaaf <netdev@bof.de>
Subject: bonding: optionally listen to VRRP announcements in active-backup ARP monitoring setup
Date: Sun, 18 May 2014 15:32 +0200
Message-ID: <1415635.ta4uzNuAlV@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:46055 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbaERNjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 09:39:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev + bonding maintainers,

I found myself in a situation where the "traditional" ARP monitoring in 
active-backup bonding mode failed to properly work.

The situation is this:

1) my box connects through two different VLANs, each going to uplink switches
2) the two uplink connections, while different VLANs on my side, are the same 
VLAN on the uplink infrastructure, so normally the ARP broadcast goes out over 
VLAN A to the uplink infrastructure, comes back through the second uplink into 
my VLAN B, where it makes the backup link of the bond "up"
3) at the uplink, we now have to cope with a combined router/switch box 
(Juniper I think, but not sure), that is both actively doing the switching for 
the shared VLAN on the uplink side of things previously described, _and_ is 
the VRRP default gateway we have to use, i.e. "has" the exact IP address that 
we need to target in our ARP monitoring
4) and, as it unfortunately turns out, that box "eats" the ARP broadcast when 
it itself "has" that VRRP default gateway address. Yes, really, it properly 
floods the broadcasts for all other IPs in the uplink network, but not for the 
VRRP IP address...

The simplest "solution" I came up with, for that issue, was to make the 
bonding code aware of VRRP a bit.

The patch below adds a bonding parameter "arp_vrrp_vrid". When set to the VRID 
of the uplink, it activates listening to the VRRP multicast on _all_ links in 
the bond. And when it sees the correct VRID in a VRRP announcement on any 
link, it updates that slaves last_arp_rx, just like a properly validated ARP 
reply would, thus solving the issue we had.

The patch is against 3.10.40, as that is what I'm running. I would like to get 
some feedback here, whether this addition to the could would be accepted in 
the kernel trees - when positive, I'll see that I patch + test with a current 
version of the kernel - please also indicate which tree I'd best target for 
that.

best regards
  Patrick

diff -urN linux-3.10.40/drivers/net/bonding/bond_3ad.c linux-3.10.40-
bond_arp_vrrp_listen/drivers/net/bonding/bond_3ad.c
--- linux-3.10.40/drivers/net/bonding/bond_3ad.c        2014-05-13 
14:00:04.000000000 +0200
+++ linux-3.10.40-bond_arp_vrrp_listen/drivers/net/bonding/bond_3ad.c   
2014-05-18 15:03:14.956973476 +0200
@@ -2470,7 +2470,7 @@
        return NETDEV_TX_OK;
 }

-int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
+int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
                         struct slave *slave)
 {
        int ret = RX_HANDLER_ANOTHER;
diff -urN linux-3.10.40/drivers/net/bonding/bond_3ad.h linux-3.10.40-
bond_arp_vrrp_listen/drivers/net/bonding/bond_3ad.h
--- linux-3.10.40/drivers/net/bonding/bond_3ad.h        2014-05-13 
14:00:04.000000000 +0200
+++ linux-3.10.40-bond_arp_vrrp_listen/drivers/net/bonding/bond_3ad.h   
2014-05-18 15:03:14.956973476 +0200
@@ -277,7 +277,7 @@
 int  __bond_3ad_get_active_agg_info(struct bonding *bond,
                                    struct ad_info *ad_info);
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
-int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
+int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
                         struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 void bond_3ad_update_lacp_rate(struct bonding *bond);
diff -urN linux-3.10.40/drivers/net/bonding/bond_alb.c linux-3.10.40-
bond_arp_vrrp_listen/drivers/net/bonding/bond_alb.c
--- linux-3.10.40/drivers/net/bonding/bond_alb.c        2014-05-13 
14:00:04.000000000 +0200
+++ linux-3.10.40-bond_arp_vrrp_listen/drivers/net/bonding/bond_alb.c   
2014-05-18 15:03:14.956973476 +0200
@@ -346,7 +346,7 @@
        _unlock_rx_hashtbl_bh(bond);
 }

-static int rlb_arp_recv(const struct sk_buff *skb, struct bonding *bond,
+static int rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
                        struct slave *slave)
 {
        struct arp_pkt *arp, _arp;
diff -urN linux-3.10.40/drivers/net/bonding/bonding.h linux-3.10.40-
bond_arp_vrrp_listen/drivers/net/bonding/bonding.h
--- linux-3.10.40/drivers/net/bonding/bonding.h 2014-05-13 14:00:04.000000000 
+0200
+++ linux-3.10.40-bond_arp_vrrp_listen/drivers/net/bonding/bonding.h    
2014-05-18 15:03:14.956973476 +0200
@@ -157,6 +157,7 @@
        int tx_queues;
        int all_slaves_active;
        int resend_igmp;
+       int arp_vrrp_vrid;
 };

 struct bond_parm_tbl {
@@ -183,7 +184,8 @@
        s8     new_link;
        u8     backup:1,   /* indicates backup slave. Value corresponds with
                              BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
-              inactive:1; /* indicates inactive slave */
+              inactive:1, /* indicates inactive slave */
+              arp_vrrp_listening:1;    /* slave listens to VRRP multicast? */
        u8     duplex;
        u32    original_mtu;
        u32    link_failure_count;
@@ -219,7 +221,7 @@
        struct   slave *primary_slave;
        bool     force_primary;
        s32      slave_cnt; /* never change this value outside the 
attach/detach wrappers */
-       int     (*recv_probe)(const struct sk_buff *, struct bonding *,
+       int     (*recv_probe)(struct sk_buff *, struct bonding *,
                              struct slave *);
        rwlock_t lock;
        rwlock_t curr_slave_lock;
diff -urN linux-3.10.40/drivers/net/bonding/bond_main.c linux-3.10.40-
bond_arp_vrrp_listen/drivers/net/bonding/bond_main.c
--- linux-3.10.40/drivers/net/bonding/bond_main.c       2014-05-13 
14:00:04.000000000 +0200
+++ linux-3.10.40-bond_arp_vrrp_listen/drivers/net/bonding/bond_main.c  
2014-05-18 15:04:19.397017344 +0200
@@ -101,6 +101,7 @@
 static int min_links;
 static char *ad_select;
 static char *xmit_hash_policy;
+static char *arp_vrrp_vrid;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
 static char *arp_validate;
@@ -158,6 +159,9 @@
 MODULE_PARM_DESC(xmit_hash_policy, "balance-xor and 802.3ad hashing method; "
                                   "0 for layer 2 (default), 1 for layer 3+4, 
"
                                   "2 for layer 2+3");
+module_param(arp_vrrp_vrid, charp, 0);
+MODULE_PARM_DESC(arp_vrrp_vrid, "ARP mode VRRP listening; "
+                              "-1 or disable for none (default), 0-255 as 
VRID to look for");
 module_param(arp_interval, int, 0);
 MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
 module_param_array(arp_ip_target, charp, NULL, 0);
@@ -186,6 +190,9 @@

 int bond_net_id __read_mostly;

+static u8 bond_vrrp_multicast[ETH_ALEN] =
+       { 0x01, 0x00, 0x5e, 0x00, 0x00, 0x12 };
+
 static __be32 arp_target[BOND_MAX_ARP_TARGETS];
 static int arp_ip_count;
 static int bond_mode   = BOND_MODE_ROUNDROBIN;
@@ -1460,7 +1467,7 @@
        struct sk_buff *skb = *pskb;
        struct slave *slave;
        struct bonding *bond;
-       int (*recv_probe)(const struct sk_buff *, struct bonding *,
+       int (*recv_probe)(struct sk_buff *, struct bonding *,
                          struct slave *);
        int ret = RX_HANDLER_ANOTHER;

@@ -1749,6 +1756,13 @@

        bond_add_vlans_on_slave(bond, slave_dev);

+       /*
+        * Set the new_slave's arp_vrrp_vrid to 0. VRRP multicast will
+        * be enabled during the first bond_ab_arp_inspect run, when
+        * desired by the bond->arp_vrrp_vrid setting being >= 0.
+        */
+       new_slave->arp_vrrp_listening = 0;
+
        write_lock_bh(&bond->lock);

        bond_attach_slave(bond, new_slave);
@@ -2039,6 +2053,14 @@
                bond_3ad_unbind_slave(slave);
        }

+       /* unregister VRRP multicast */
+       if (slave->arp_vrrp_listening) {
+               pr_debug("%s/%s: stop VRRP listening\n",
+                       bond_dev->name, slave_dev->name);
+               dev_mc_del(slave_dev, bond_vrrp_multicast);
+               slave->arp_vrrp_listening = 0;
+       }
+
        pr_info("%s: releasing %s interface %s\n",
                bond_dev->name,
                bond_is_active_slave(slave) ? "active" : "backup",
@@ -2693,7 +2715,46 @@
        }
 }

-static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
+static void bond_ab_vrrp_rcv(
+       struct sk_buff *skb,
+       struct bonding *bond,
+       struct slave *slave
+) {
+       int noff = skb_network_offset(skb);
+       struct ethhdr *eth;
+       const struct iphdr *iph;
+       const u8 *vrrph;
+
+       /* some stuff found in ip_rcv() */
+       if (unlikely(!pskb_may_pull(skb, noff+sizeof(*iph))))
+               return;
+       iph = ip_hdr(skb);
+       if (iph->ihl < 5 || iph->version != 4)
+               return;
+       /* VRRP RFC 3768 5.2.1ff - IP protocol 112, TTL _must_ be 255 */
+       if (iph->protocol != 112 || iph->ttl != 255)
+               return;
+       /* we want a peek at the first few bytes of the VRRP header */
+       if (unlikely(!pskb_may_pull(skb, noff + iph->ihl*4 + 4)))
+               return;
+       eth = (struct ethhdr *) skb_mac_header(skb);
+       iph = ip_hdr(skb);
+       vrrph = ((u8 *) iph) + iph->ihl*4;
+       if (unlikely(vrrph[0] != 0x21)) /* VRRP v2, type ADVERTISEMENT ? */
+               return;
+
+       /* These are not the VRIDs you are looking for... */
+       if (vrrph[1] != bond->params.arp_vrrp_vrid)
+               return;
+
+       pr_debug("%s/%s: VRRP vrid %u from %pM - link good\n",
+               bond->dev->name, slave->dev->name, vrrph[1], eth->h_source);
+
+       /* Consider this equivalent to a validated, received ARP reply */
+       slave->last_arp_rx = jiffies;
+}
+
+static int bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
                        struct slave *slave)
 {
        struct arphdr *arp = (struct arphdr *)skb->data;
@@ -2701,8 +2762,15 @@
        __be32 sip, tip;
        int alen;

-       if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
+       if (skb->protocol != __cpu_to_be16(ETH_P_ARP)) {
+               if (bond->params.arp_vrrp_vrid >= 0 && skb->protocol == 
__cpu_to_be16(ETH_P_IP)) {
+                       struct ethhdr *eth = (struct ethhdr *) 
skb_mac_header(skb);
+                       if (!memcmp(eth->h_dest, bond_vrrp_multicast, 
ETH_ALEN)) {
+                               bond_ab_vrrp_rcv(skb, bond, slave);
+                       }
+               }
                return RX_HANDLER_ANOTHER;
+       }

        read_lock(&bond->lock);
        alen = arp_hdr_len(bond->dev);
@@ -2903,6 +2971,20 @@
        extra_ticks = delta_in_ticks / 2;

        bond_for_each_slave(bond, slave, i) {
+
+               if (bond->params.arp_vrrp_vrid < 0 && slave-
>arp_vrrp_listening) {
+                       pr_info("%s/%s: stop VRRP listening\n",
+                               bond->dev->name, slave->dev->name);
+                       dev_mc_del(slave->dev, bond_vrrp_multicast);
+                       slave->arp_vrrp_listening = 0;
+               } else if (bond->params.arp_vrrp_vrid >= 0 && !slave-
>arp_vrrp_listening) {
+                       pr_info("%s/%s: listen for VRRP vrid %d\n",
+                               bond->dev->name, slave->dev->name,
+                               bond->params.arp_vrrp_vrid);
+                       dev_mc_add(slave->dev, bond_vrrp_multicast);
+                       slave->arp_vrrp_listening = 1;
+               }
+
                slave->new_link = BOND_LINK_NOCHANGE;

                if (slave->link != BOND_LINK_UP) {
@@ -4496,7 +4578,7 @@

 static int bond_check_params(struct bond_params *params)
 {
-       int arp_validate_value, fail_over_mac_value, primary_reselect_value, 
i;
+       int arp_vrrp_vrid_value, arp_validate_value, fail_over_mac_value, 
primary_reselect_value, i;

        /*
         * Convert string parameters.
@@ -4698,6 +4780,21 @@
                arp_interval = 0;
        }

+       arp_vrrp_vrid_value = -1; /* default: disable */
+       if (arp_vrrp_vrid) {
+               if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
+                       pr_err("arp_vrrp_vrid only supported in active-backup 
mode\n");
+                       return -EINVAL;
+               }
+
+               if (arp_vrrp_vrid && strcmp(arp_vrrp_vrid, "disable")) {
+                       if (1 != sscanf(arp_vrrp_vrid, "%d", 
&arp_vrrp_vrid_value) || arp_vrrp_vrid_value < -1 || arp_vrrp_vrid_value > 
255) {
+                               pr_err("Error: invalid arp_vrrp_vrid 
\"%s\"\n", arp_vrrp_vrid);
+                               return -EINVAL;
+                       }
+               }
+       }
+
        if (arp_validate) {
                if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
                        pr_err("arp_validate only supported in active-backup 
mode\n");
@@ -4780,6 +4877,7 @@
        params->xmit_policy = xmit_hashtype;
        params->miimon = miimon;
        params->num_peer_notif = num_peer_notif;
+       params->arp_vrrp_vrid = arp_vrrp_vrid_value;
        params->arp_interval = arp_interval;
        params->arp_validate = arp_validate_value;
        params->updelay = updelay;
diff -urN linux-3.10.40/drivers/net/bonding/bond_sysfs.c linux-3.10.40-
bond_arp_vrrp_listen/drivers/net/bonding/bond_sysfs.c
--- linux-3.10.40/drivers/net/bonding/bond_sysfs.c      2014-05-13 
14:00:04.000000000 +0200
+++ linux-3.10.40-bond_arp_vrrp_listen/drivers/net/bonding/bond_sysfs.c 
2014-05-18 15:03:14.956973476 +0200
@@ -411,6 +411,59 @@
                   bonding_show_xmit_hash, bonding_store_xmit_hash);

 /*
+ * Show and set arp_vrrp_vrid.
+ */
+static ssize_t bonding_show_arp_vrrp_vrid(struct device *d,
+                                        struct device_attribute *attr,
+                                        char *buf)
+{
+       struct bonding *bond = to_bond(d);
+
+       if (bond->params.arp_vrrp_vrid < 0)
+               return sprintf(buf, "disable\n");
+       return sprintf(buf, "%d\n", bond->params.arp_vrrp_vrid);
+}
+
+static ssize_t bonding_store_arp_vrrp_vrid(struct device *d,
+                                         struct device_attribute *attr,
+                                         const char *buf, size_t count)
+{
+       int new_value;
+       struct bonding *bond = to_bond(d);
+
+       if (!strcmp(buf, "disable")) {
+               new_value = -1;
+       } else if (1 != sscanf(buf, "%d", &new_value) || new_value < -1 || 
new_value > 255) {
+               pr_err("%s: Ignoring invalid arp_vrrp_vrid value %s\n",
+                      bond->dev->name, buf);
+               return -EINVAL;
+       }
+       if (new_value != -1 && bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+               pr_err("%s: arp_vrrp_vrid only supported in active-backup 
mode.\n",
+                      bond->dev->name);
+               return -EINVAL;
+       }
+
+       if (bond->params.arp_vrrp_vrid == new_value)
+               return count;
+
+       if (new_value < 0) {
+               pr_info("%s: disabling arp_vrrp_vrid handling\n",
+                       bond->dev->name);
+       } else {
+               pr_info("%s: setting arp_vrrp_vrid to (%d).\n",
+                       bond->dev->name, new_value);
+       }
+
+       bond->params.arp_vrrp_vrid = new_value;
+
+       return count;
+}
+
+static DEVICE_ATTR(arp_vrrp_vrid, S_IRUGO | S_IWUSR, 
bonding_show_arp_vrrp_vrid,
+                  bonding_store_arp_vrrp_vrid);
+
+/*
  * Show and set arp_validate.
  */
 static ssize_t bonding_show_arp_validate(struct device *d,
@@ -1651,6 +1704,7 @@
        &dev_attr_slaves.attr,
        &dev_attr_mode.attr,
        &dev_attr_fail_over_mac.attr,
+       &dev_attr_arp_vrrp_vrid.attr,
        &dev_attr_arp_validate.attr,
        &dev_attr_arp_interval.attr,
        &dev_attr_arp_ip_target.attr,
