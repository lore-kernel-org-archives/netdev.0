From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [RFC PATCH] macvlan: add FDB bridge ops
Date: Wed, 28 Mar 2012 08:43:56 -0700
Message-ID: <CB987FCC.4A654%roprabhu@cisco.com>
References: <20120321002647.16118.87199.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mst@redhat.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:45375 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab2C1Pn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 11:43:59 -0400
In-Reply-To: <20120321002647.16118.87199.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/12 5:26 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:

> Add support to add/del and dump the forwarding database
> for macvlan passthru mode. The macvlan driver acts like
> a Two Port Mac Relay (TPMR 802.1Q-2011) in the passthru
> case so adding forwarding rules is just adding the addr
> to the uc or mc lists.
> 
> By default the passthru mode puts the lowerdev into a
> promiscuous mode to receive all packets. This behavior
> is not changed by this patch. This is a bit problematic
> and needs to be solved without IMHO breaking existing
> mechanics. Maybe on the first add_fdb we can decrement
> the promisc mode? That seems to work reasonable well and
> keep existing functionality in place... but requires
> an initial add to set things up which is a bit annoying
> so maybe a flag is better. I haven't thought too hard
> about it yet so any ideas welcome
> 
> This patch is a result of Roopa Prabhu's work. Follow up
> patches are needed for VEPA and VEB macvlan modes.
> 
> Only lightly touch tested at this point.
> 
> CC: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  drivers/net/macvlan.c |   42 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 42 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index f975afd..86af56b 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -349,6 +349,7 @@ static int macvlan_stop(struct net_device *dev)
> goto hash_del;
> }
>  
> + dev_uc_unsync(lowerdev, dev);
> dev_mc_unsync(lowerdev, dev);
> if (dev->flags & IFF_ALLMULTI)
> dev_set_allmulti(lowerdev, -1);
> @@ -403,6 +404,7 @@ static void macvlan_set_multicast_list(struct net_device
> *dev)
>  {
> struct macvlan_dev *vlan = netdev_priv(dev);
>  
> + dev_uc_sync(vlan->lowerdev, dev);
> dev_mc_sync(vlan->lowerdev, dev);
>  }
>  
> @@ -542,6 +544,43 @@ static int macvlan_vlan_rx_kill_vid(struct net_device
> *dev,
> return 0;
>  }
>  
> +static int macvlan_fdb_add(struct ndmsg *ndm,
> +      struct net_device *dev,
> +      unsigned char *addr,
> +      u16 flags)
> +{
> + struct macvlan_dev *vlan = netdev_priv(dev);
> + int err = -EINVAL;
> +
> + if (!vlan->port->passthru)
> +  return -EOPNOTSUPP;
> +
> + if (is_unicast_ether_addr(addr))
> +  err = dev_uc_add(dev, addr);
> + else if (is_multicast_ether_addr(addr))
> +  err = dev_mc_add(dev, addr);
> +
> + return err;
> +}
> +
> +static int macvlan_fdb_del(struct ndmsg *ndm,
> +      struct net_device *dev,
> +      unsigned char *addr)
> +{
> + struct macvlan_dev *vlan = netdev_priv(dev);
> + int err = -EINVAL;
> +
> + if (!vlan->port->passthru)
> +  return -EOPNOTSUPP;
> +
> + if (is_unicast_ether_addr(addr))
> +  err = dev_uc_del(dev, addr);
> + else if (is_multicast_ether_addr(addr))
> +  err = dev_mc_del(dev, addr);
> +
> + return err;
> +}
> +
>  static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
> struct ethtool_drvinfo *drvinfo)
>  {
> @@ -577,6 +616,9 @@ static const struct net_device_ops macvlan_netdev_ops = {
> .ndo_validate_addr = eth_validate_addr,
> .ndo_vlan_rx_add_vid = macvlan_vlan_rx_add_vid,
> .ndo_vlan_rx_kill_vid = macvlan_vlan_rx_kill_vid,
> + .ndo_fdb_add  = macvlan_fdb_add,
> + .ndo_fdb_del  = macvlan_fdb_del,
> + .ndo_fdb_dump  = ndo_dflt_fdb_dump,
>  };
>  
>  void macvlan_common_setup(struct net_device *dev)
> 

Thanks John. Looks good.
I added a few things to your patch below. Yes, I think the promisc check is
required. Made an attempt to add a flag below (I did not get a chance to
think about other approaches there too). Briefly tested it with the br
command.


diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f975afd..9bc70ad 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -34,6 +34,9 @@
 
 #define MACVLAN_HASH_SIZE    (1 << BITS_PER_BYTE)
 
+/* macvlan port flags */
+#define MACVLAN_FLAG_PROMISC    0x1
+
 struct macvlan_port {
     struct net_device    *dev;
     struct hlist_head    vlan_hash[MACVLAN_HASH_SIZE];
@@ -41,6 +44,7 @@ struct macvlan_port {
     struct rcu_head        rcu;
     bool             passthru;
     int            count;
+    unsigned int        flags;
 };
 
 static void macvlan_port_destroy(struct net_device *dev);
@@ -313,6 +317,7 @@ static int macvlan_open(struct net_device *dev)
 
     if (vlan->port->passthru) {
         dev_set_promiscuity(lowerdev, 1);
+        vlan->port->flags |= MACVLAN_FLAG_PROMISC;
         goto hash_add;
     }
 
@@ -345,10 +350,14 @@ static int macvlan_stop(struct net_device *dev)
     struct net_device *lowerdev = vlan->lowerdev;
 
     if (vlan->port->passthru) {
-        dev_set_promiscuity(lowerdev, -1);
+        if (vlan->port->flags & MACVLAN_FLAG_PROMISC) {
+            dev_set_promiscuity(lowerdev, -1);
+            vlan->port->flags &= ~MACVLAN_FLAG_PROMISC;
+        }
         goto hash_del;
     }
 
+    dev_uc_unsync(lowerdev, dev);
     dev_mc_unsync(lowerdev, dev);
     if (dev->flags & IFF_ALLMULTI)
         dev_set_allmulti(lowerdev, -1);
@@ -403,6 +412,7 @@ static void macvlan_set_multicast_list(struct net_device
*dev)
 {
     struct macvlan_dev *vlan = netdev_priv(dev);
 
+    dev_uc_sync(vlan->lowerdev, dev);
     dev_mc_sync(vlan->lowerdev, dev);
 }
 
@@ -542,6 +552,58 @@ static int macvlan_vlan_rx_kill_vid(struct net_device
*dev,
     return 0;
 }
 
+static int macvlan_fdb_add(struct ndmsg *ndm,
+               struct net_device *dev,
+               unsigned char *addr,
+               u16 flags)
+{
+    struct macvlan_dev *vlan = netdev_priv(dev);
+    struct net_device *lowerdev = vlan->lowerdev;
+    const struct net_device_ops *ops = lowerdev->netdev_ops;
+    int err = -EINVAL;
+
+    if (!vlan->port->passthru)
+        return -EOPNOTSUPP;
+
+    if (vlan->port->flags & MACVLAN_FLAG_PROMISC) {
+        dev_set_promiscuity (lowerdev, -1);
+        vlan->port->flags &= ~MACVLAN_FLAG_PROMISC;
+    }
+
+    if (ops->ndo_fdb_add)
+        return ops->ndo_fdb_add(ndm, lowerdev, addr, flags);
+
+    if (is_unicast_ether_addr(addr))
+        err = dev_uc_add_excl(lowerdev, addr);
+    else if (is_multicast_ether_addr(addr))
+        err = dev_mc_add(lowerdev, addr);
+
+    return err;
+}
+
+static int macvlan_fdb_del(struct ndmsg *ndm,
+               struct net_device *dev,
+               unsigned char *addr)
+{
+    struct macvlan_dev *vlan = netdev_priv(dev);
+    struct net_device *lowerdev = vlan->lowerdev;
+    const struct net_device_ops *ops = lowerdev->netdev_ops;
+    int err = -EINVAL;
+
+    if (!vlan->port->passthru)
+        return -EOPNOTSUPP;
+
+    if (ops->ndo_fdb_del)
+        return ops->ndo_fdb_del(ndm, lowerdev, addr);
+
+    if (is_unicast_ether_addr(addr))
+        err = dev_uc_del(lowerdev, addr);
+    else if (is_multicast_ether_addr(addr))
+        err = dev_mc_del(lowerdev, addr);
+
+    return err;
+}
+
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
                     struct ethtool_drvinfo *drvinfo)
 {
@@ -577,6 +639,9 @@ static const struct net_device_ops macvlan_netdev_ops =
{
     .ndo_validate_addr    = eth_validate_addr,
     .ndo_vlan_rx_add_vid    = macvlan_vlan_rx_add_vid,
     .ndo_vlan_rx_kill_vid    = macvlan_vlan_rx_kill_vid,
+    .ndo_fdb_add        = macvlan_fdb_add,
+    .ndo_fdb_del        = macvlan_fdb_del,
+    .ndo_fdb_dump        = ndo_dflt_fdb_dump,
 };
 
 void macvlan_common_setup(struct net_device *dev)
