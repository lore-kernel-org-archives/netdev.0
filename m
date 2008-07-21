From: David Miller <davem@davemloft.net>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 14:01:20 -0700 (PDT)
Message-ID: <20080721.140120.135667045.davem@davemloft.net>
References: <4884F3D7.4070604@lwfinger.net>
	<20080721.134608.75595942.davem@davemloft.net>
	<4884F6E9.6090809@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, mingo@elte.hu, ischram@telenet.be,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, j@w1.fi
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750836AbYGUVBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 17:01:21 -0400
In-Reply-To: <4884F6E9.6090809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Jul 2008 22:51:53 +0200

> David Miller wrote:
> > From: Larry Finger <Larry.Finger@lwfinger.net>
> > Date: Mon, 21 Jul 2008 15:38:47 -0500
> > 
> >> David Miller wrote:
> >>> No further backtrace?  That will tell us what driver is causing
> >>> this.
> >> Yes, I have a full backtrace.
> >>
> >> It starts with possible recursive locking in NetworkManager, and goes directly 
> >> into the Warning - this came from a later pull of Linus's tree.
> > 
> > That helps a lot, I'm looking at this now.
> 
> I'm guessing this needs similar lockdep class initializations
> to _xmit_lock since it essentially has the same nesting rules.

Yes, I figured that out just now :-)

Maybe something like the following should do it?

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9737c06..a641eea 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5041,6 +5041,7 @@ static int bond_check_params(struct bond_params *params)
 }
 
 static struct lock_class_key bonding_netdev_xmit_lock_key;
+static struct lock_class_key bonding_netdev_addr_lock_key;
 
 static void bond_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -5052,6 +5053,8 @@ static void bond_set_lockdep_class_one(struct net_device *dev,
 
 static void bond_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock,
+			  &bonding_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 }
 
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index b6500b2..58f4b1d 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -123,6 +123,7 @@ static LIST_HEAD(bpq_devices);
  * off into a separate class since they always nest.
  */
 static struct lock_class_key bpq_netdev_xmit_lock_key;
+static struct lock_class_key bpq_netdev_addr_lock_key;
 
 static void bpq_set_lockdep_class_one(struct net_device *dev,
 				      struct netdev_queue *txq,
@@ -133,6 +134,7 @@ static void bpq_set_lockdep_class_one(struct net_device *dev,
 
 static void bpq_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock, &bpq_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bpq_set_lockdep_class_one, NULL);
 }
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index efbc155..4239450 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -276,6 +276,7 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
  * separate class since they always nest.
  */
 static struct lock_class_key macvlan_netdev_xmit_lock_key;
+static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
@@ -295,6 +296,8 @@ static void macvlan_set_lockdep_class_one(struct net_device *dev,
 
 static void macvlan_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock,
+			  &macvlan_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, macvlan_set_lockdep_class_one, NULL);
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 13d5882..3153fe9 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3101,6 +3101,7 @@ static void prism2_clear_set_tim_queue(local_info_t *local)
  * This is a natural nesting, which needs a split lock type.
  */
 static struct lock_class_key hostap_netdev_xmit_lock_key;
+static struct lock_class_key hostap_netdev_addr_lock_key;
 
 static void prism2_set_lockdep_class_one(struct net_device *dev,
 					 struct netdev_queue *txq,
@@ -3112,6 +3113,8 @@ static void prism2_set_lockdep_class_one(struct net_device *dev,
 
 static void prism2_set_lockdep_class(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock,
+			  &hostap_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, prism2_set_lockdep_class_one, NULL);
 }
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f42bc2b..4bf014e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -569,6 +569,7 @@ static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
  * separate class since they always nest.
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
+static struct lock_class_key vlan_netdev_addr_lock_key;
 
 static void vlan_dev_set_lockdep_one(struct net_device *dev,
 				     struct netdev_queue *txq,
@@ -581,6 +582,9 @@ static void vlan_dev_set_lockdep_one(struct net_device *dev,
 
 static void vlan_dev_set_lockdep_class(struct net_device *dev, int subclass)
 {
+	lockdep_set_class_and_subclass(&dev->addr_list_lock,
+				       &vlan_netdev_addr_lock_key,
+				       subclass);
 	netdev_for_each_tx_queue(dev, vlan_dev_set_lockdep_one, &subclass);
 }
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index fccc250..532e4fa 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -73,6 +73,7 @@ static const struct proto_ops nr_proto_ops;
  * separate class since they always nest.
  */
 static struct lock_class_key nr_netdev_xmit_lock_key;
+static struct lock_class_key nr_netdev_addr_lock_key;
 
 static void nr_set_lockdep_one(struct net_device *dev,
 			       struct netdev_queue *txq,
@@ -83,6 +84,7 @@ static void nr_set_lockdep_one(struct net_device *dev,
 
 static void nr_set_lockdep_key(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock, &nr_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, nr_set_lockdep_one, NULL);
 }
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index dbc963b..a7f1ce1 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -74,6 +74,7 @@ ax25_address rose_callsign;
  * separate class since they always nest.
  */
 static struct lock_class_key rose_netdev_xmit_lock_key;
+static struct lock_class_key rose_netdev_addr_lock_key;
 
 static void rose_set_lockdep_one(struct net_device *dev,
 				 struct netdev_queue *txq,
@@ -84,6 +85,7 @@ static void rose_set_lockdep_one(struct net_device *dev,
 
 static void rose_set_lockdep_key(struct net_device *dev)
 {
+	lockdep_set_class(&dev->addr_list_lock, &rose_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, rose_set_lockdep_one, NULL);
 }
 
