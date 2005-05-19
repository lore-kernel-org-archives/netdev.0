From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 14:00:32 -0500
Message-ID: <20050519190032.GA19620@us.ibm.com>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro> <200505191106.53136.jdmason@us.ibm.com> <Pine.LNX.4.62.0505192019090.8076@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0505192019090.8076@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I combined my previous patch with your patch, and came up with the
following.  I have tested it on my system, and it works exactly the way
I wanted.  What do you think?

Thanks,
Jon

Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
Signed-off-by: Jon Mason <jdmason@us.ibm.com>


--- linux-2.6.11-xenU/net/bridge/br_private.h	2005-03-02 01:37:50.000000000 -0600
+++ linux-2.6.11-xen0/net/bridge/br_private.h	2005-05-19 08:12:23.000000000 -0500
@@ -27,6 +27,10 @@
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
 
+#define BR_FEAT_MASK   (NETIF_F_HW_CSUM | NETIF_F_SG \
+		| NETIF_F_FRAGLIST | NETIF_F_IP_CSUM \
+		| NETIF_F_HIGHDMA | NETIF_F_TSO)
+
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
 typedef __u16 port_id;
--- linux-2.6.11-xenU/net/bridge/br_device.c	2005-05-19 06:19:42.000000000 -0500
+++ linux-2.6.11-xen0/net/bridge/br_device.c	2005-05-19 08:11:19.000000000 -0500
@@ -107,4 +107,5 @@ void br_dev_setup(struct net_device *dev
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = NULL;
 	dev->priv_flags = IFF_EBRIDGE;
+	dev->features = BR_FEAT_MASK;
 }
--- linux-2.6.11-xenU/net/bridge/br_if.c	2005-05-19 08:43:03.000000000 -0500
+++ linux-2.6.11-xen0/net/bridge/br_if.c	2005-05-19 08:43:58.000000000 -0500
@@ -314,6 +314,27 @@ int br_min_mtu(const struct net_bridge *
 	return mtu;
 }
 
+/*
+ * If slave device (@dev) doesn't support special features,
+ * turn them off globally.
+ */
+static inline void br_features_change(struct net_bridge *br, struct net_device *dev)
+{
+	br->dev->features &= dev->features | NETIF_F_HW_CSUM | NETIF_F_SG;
+}
+
+/*
+ * Recomputes features using slave's features
+ */
+static void br_features_recompute(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+
+	br->dev->features = BR_FEAT_MASK;
+	list_for_each_entry(p, &br->port_list, list)
+		br_features_change(br, p->dev);
+}
+
 /* called with RTNL */
 int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
@@ -332,6 +353,8 @@ int br_add_if(struct net_bridge *br, str
 	if (IS_ERR(p = new_nbp(br, dev, br_initial_port_cost(dev))))
 		return PTR_ERR(p);
 
+	br_features_change(br, dev);
+
  	if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
 		destroy_nbp(p);
  
@@ -368,6 +391,7 @@ int br_del_if(struct net_bridge *br, str
 
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
+	br_features_recompute(br);
 	spin_unlock_bh(&br->lock);
 
 	return 0;
