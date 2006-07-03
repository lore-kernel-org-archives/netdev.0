From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 4/7] net_device list cleanup: drivers and non-IP protocols
Date: Mon, 3 Jul 2006 12:18:54 +0400
Message-ID: <20060630164715.F22285@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stuart Cheshire <cheshire@cs.stanford.edu>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	patrick@tykepenguin.com, acme@conectiva.com.br,
	ralf@linux-mips.org, sri@us.ibm.com, per.liden@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:34568 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750953AbWGCQcA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:32:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>; from "Andrey Savochkin" on Fri, Jun 30, 2006 at 03:08:23PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup of net_device list use in network device drivers and protocols
other than IP.

The cleanup consists of
 - converting the to list_head, to make the list double-linked (thus making
   remove operation O(1)), and list walks more readable;
 - introducing of for_each_netdev wrapper over list_for_each.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
---
Requires "bridge: br_dump_ifinfo index fix"

 drivers/net/wireless/strip.c |    4 +---
 net/8021q/vlan.c             |    4 ++--
 net/8021q/vlanproc.c         |   10 +++++-----
 net/bridge/br_if.c           |    4 ++--
 net/bridge/br_ioctl.c        |    4 +++-
 net/bridge/br_netlink.c      |    3 ++-
 net/decnet/af_decnet.c       |   11 +++++++----
 net/decnet/dn_dev.c          |   17 ++++++++++-------
 net/decnet/dn_fib.c          |    2 +-
 net/decnet/dn_route.c        |   13 +++++++------
 net/llc/llc_core.c           |    7 +++++--
 net/netrom/nr_route.c        |    5 +++--
 net/rose/rose_route.c        |    8 +++++---
 net/sctp/protocol.c          |    2 +-
 net/tipc/eth_media.c         |   11 +++++++----
 15 files changed, 61 insertions(+), 44 deletions(-)

--- ./drivers/net/wireless/strip.c.vedevbase-onet	Mon Jul  3 15:13:46 2006
+++ ./drivers/net/wireless/strip.c	Mon Jul  3 16:12:11 2006
@@ -1969,8 +1969,7 @@ static struct net_device *get_strip_dev(
 		      sizeof(zero_address))) {
 		struct net_device *dev;
 		read_lock_bh(&dev_base_lock);
-		dev = dev_base;
-		while (dev) {
+		for_each_netdev(dev) {
 			if (dev->type == strip_info->dev->type &&
 			    !memcmp(dev->dev_addr,
 				    &strip_info->true_dev_addr,
@@ -1981,7 +1980,6 @@ static struct net_device *get_strip_dev(
 				read_unlock_bh(&dev_base_lock);
 				return (dev);
 			}
-			dev = dev->next;
 		}
 		read_unlock_bh(&dev_base_lock);
 	}
--- ./net/8021q/vlan.c.vedevbase-onet	Mon Jul  3 15:14:17 2006
+++ ./net/8021q/vlan.c	Mon Jul  3 16:12:11 2006
@@ -121,8 +121,8 @@ static void __exit vlan_cleanup_devices(
 	struct net_device *dev, *nxt;
 
 	rtnl_lock();
-	for (dev = dev_base; dev; dev = nxt) {
-		nxt = dev->next;
+	for (dev = first_netdev(); dev; dev = nxt) {
+		nxt = next_netdev(dev);
 		if (dev->priv_flags & IFF_802_1Q_VLAN) {
 			unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
 					    VLAN_DEV_INFO(dev)->vlan_id);
--- ./net/8021q/vlanproc.c.vedevbase-onet	Mon Jul  3 15:14:17 2006
+++ ./net/8021q/vlanproc.c	Mon Jul  3 16:12:11 2006
@@ -241,7 +241,7 @@ int vlan_proc_rem_dev(struct net_device 
 static struct net_device *vlan_skip(struct net_device *dev) 
 {
 	while (dev && !(dev->priv_flags & IFF_802_1Q_VLAN)) 
-		dev = dev->next;
+		dev = next_netdev(dev);
 
 	return dev;
 }
@@ -257,8 +257,8 @@ static void *vlan_seq_start(struct seq_f
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 	
-	for (dev = vlan_skip(dev_base); dev && i < *pos; 
-	     dev = vlan_skip(dev->next), ++i);
+	for (dev = vlan_skip(first_netdev()); dev && i < *pos; 
+	     dev = vlan_skip(next_netdev(dev)), ++i);
 		
 	return  (i == *pos) ? dev : NULL;
 } 
@@ -268,8 +268,8 @@ static void *vlan_seq_next(struct seq_fi
 	++*pos;
 
 	return vlan_skip((v == SEQ_START_TOKEN)  
-			    ? dev_base 
-			    : ((struct net_device *)v)->next);
+			    ? first_netdev()
+			    : next_netdev((struct net_device *)v));
 }
 
 static void vlan_seq_stop(struct seq_file *seq, void *v)
--- ./net/bridge/br_if.c.vedevbase-onet	Mon Jul  3 15:14:19 2006
+++ ./net/bridge/br_if.c	Mon Jul  3 16:12:11 2006
@@ -474,8 +474,8 @@ void __exit br_cleanup_bridges(void)
 	struct net_device *dev, *nxt;
 
 	rtnl_lock();
-	for (dev = dev_base; dev; dev = nxt) {
-		nxt = dev->next;
+	for (dev = first_netdev(); dev; dev = nxt) {
+		nxt = next_netdev(dev);
 		if (dev->priv_flags & IFF_EBRIDGE)
 			del_br(dev->priv);
 	}
--- ./net/bridge/br_ioctl.c.vedevbase-onet	Mon Mar 20 08:53:29 2006
+++ ./net/bridge/br_ioctl.c	Mon Jul  3 16:12:11 2006
@@ -27,7 +27,9 @@ static int get_bridge_ifindices(int *ind
 	struct net_device *dev;
 	int i = 0;
 
-	for (dev = dev_base; dev && i < num; dev = dev->next) {
+	for_each_netdev(dev) {
+		if (i >= num)
+			break;
 		if (dev->priv_flags & IFF_EBRIDGE) 
 			indices[i++] = dev->ifindex;
 	}
--- ./net/bridge/br_netlink.c.vedevbase-onet	Mon Jul  3 16:12:11 2006
+++ ./net/bridge/br_netlink.c	Mon Jul  3 16:12:11 2006
@@ -109,7 +109,8 @@ static int br_dump_ifinfo(struct sk_buff
 	int err = 0;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base, idx = 0; dev; dev = dev->next) {
+	idx = 0;
+	for_each_netdev(dev) {
 		struct net_bridge_port *p = dev->br_port;
 
 		/* not a bridge port */
--- ./net/decnet/af_decnet.c.vedevbase-onet	Mon Jul  3 15:14:19 2006
+++ ./net/decnet/af_decnet.c	Mon Jul  3 16:12:11 2006
@@ -720,7 +720,7 @@ static int dn_bind(struct socket *sock, 
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
 	struct sockaddr_dn *saddr = (struct sockaddr_dn *)uaddr;
-	struct net_device *dev;
+	struct net_device *pdev, *dev;
 	int rv;
 
 	if (addr_len != sizeof(struct sockaddr_dn))
@@ -744,12 +744,15 @@ static int dn_bind(struct socket *sock, 
 
 	if (!(saddr->sdn_flags & SDF_WILD)) {
 		if (dn_ntohs(saddr->sdn_nodeaddrl)) {
+			dev = NULL;
 			read_lock(&dev_base_lock);
-			for(dev = dev_base; dev; dev = dev->next) {
-				if (!dev->dn_ptr)
+			for_each_netdev(pdev) {
+				if (!pdev->dn_ptr)
 					continue;
-				if (dn_dev_islocal(dev, dn_saddr2dn(saddr)))
+				if (dn_dev_islocal(pdev, dn_saddr2dn(saddr))) {
+					dev = pdev;
 					break;
+				}
 			}
 			read_unlock(&dev_base_lock);
 			if (dev == NULL)
--- ./net/decnet/dn_dev.c.vedevbase-onet	Mon Jul  3 15:14:19 2006
+++ ./net/decnet/dn_dev.c	Mon Jul  3 16:12:11 2006
@@ -775,13 +775,14 @@ static int dn_dev_dump_ifaddr(struct sk_
 	s_idx = cb->args[0];
 	s_dn_idx = dn_idx = cb->args[1];
 	read_lock(&dev_base_lock);
-	for(dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
+	idx = 0;
+	for_each_netdev(dev) {
 		if (idx < s_idx)
-			continue;
+			goto cont;
 		if (idx > s_idx)
 			s_dn_idx = 0;
 		if ((dn_db = dev->dn_ptr) == NULL)
-			continue;
+			goto cont;
 
 		for(ifa = dn_db->ifa_list, dn_idx = 0; ifa; ifa = ifa->ifa_next, dn_idx++) {
 			if (dn_idx < s_dn_idx)
@@ -794,6 +795,8 @@ static int dn_dev_dump_ifaddr(struct sk_
 					       NLM_F_MULTI) <= 0)
 				goto done;
 		}
+cont:
+		idx++;
 	}
 done:
 	read_unlock(&dev_base_lock);
@@ -1264,7 +1267,7 @@ void dn_dev_devices_off(void)
 	struct net_device *dev;
 
 	rtnl_lock();
-	for(dev = dev_base; dev; dev = dev->next)
+	for_each_netdev(dev)
 		dn_dev_down(dev);
 	rtnl_unlock();
 
@@ -1275,7 +1278,7 @@ void dn_dev_devices_on(void)
 	struct net_device *dev;
 
 	rtnl_lock();
-	for(dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		if (dev->flags & IFF_UP)
 			dn_dev_up(dev);
 	}
@@ -1296,7 +1299,7 @@ int unregister_dnaddr_notifier(struct no
 static inline struct net_device *dn_dev_get_next(struct seq_file *seq, struct net_device *dev)
 {
 	do {
-		dev = dev->next;
+		dev = next_netdev(dev);
 	} while(dev && !dev->dn_ptr);
 
 	return dev;
@@ -1306,7 +1309,7 @@ static struct net_device *dn_dev_get_idx
 {
 	struct net_device *dev;
 
-	dev = dev_base;
+	dev = first_netdev();
 	if (dev && !dev->dn_ptr)
 		dev = dn_dev_get_next(seq, dev);
 	if (pos) {
--- ./net/decnet/dn_fib.c.vedevbase-onet	Mon Jul  3 15:14:19 2006
+++ ./net/decnet/dn_fib.c	Mon Jul  3 16:12:11 2006
@@ -630,7 +630,7 @@ static void dn_fib_del_ifaddr(struct dn_
 
 	/* Scan device list */
 	read_lock(&dev_base_lock);
-	for(dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		dn_db = dev->dn_ptr;
 		if (dn_db == NULL)
 			continue;
--- ./net/decnet/dn_route.c.vedevbase-onet	Mon Jul  3 15:14:19 2006
+++ ./net/decnet/dn_route.c	Mon Jul  3 16:12:47 2006
@@ -922,16 +922,17 @@ static int dn_route_output_slow(struct d
 			goto out;
 		}
 		read_lock(&dev_base_lock);
-		for(dev_out = dev_base; dev_out; dev_out = dev_out->next) {
+		for_each_netdev(dev_out) {
 			if (!dev_out->dn_ptr)
 				continue;
-			if (dn_dev_islocal(dev_out, oldflp->fld_src))
-				break;
+			if (dn_dev_islocal(dev_out, oldflp->fld_src)) {
+				dev_hold(dev_out);
+				read_unlock(&dev_base_lock);
+				goto source_ok;
+			}
 		}
 		read_unlock(&dev_base_lock);
-		if (dev_out == NULL)
-			goto out;
-		dev_hold(dev_out);
+		goto out;
 source_ok:
 		;
 	}
--- ./net/llc/llc_core.c.vedevbase-onet	Mon Jul  3 15:10:43 2006
+++ ./net/llc/llc_core.c	Mon Jul  3 16:12:11 2006
@@ -161,8 +161,11 @@ static struct packet_type llc_tr_packet_
 
 static int __init llc_init(void)
 {
-	if (dev_base->next)
-		memcpy(llc_station_mac_sa, dev_base->next->dev_addr, ETH_ALEN);
+	struct net_device *dev;
+
+	dev = next_netdev(first_netdev());
+	if (dev)
+		memcpy(llc_station_mac_sa, dev->dev_addr, ETH_ALEN);
 	else
 		memset(llc_station_mac_sa, 0, ETH_ALEN);
 	dev_add_pack(&llc_packet_type);
--- ./net/netrom/nr_route.c.vedevbase-onet	Mon Jul  3 15:14:22 2006
+++ ./net/netrom/nr_route.c	Mon Jul  3 16:12:11 2006
@@ -595,7 +595,7 @@ struct net_device *nr_dev_first(void)
 	struct net_device *dev, *first = NULL;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_NETROM)
 			if (first == NULL || strncmp(dev->name, first->name, 3) < 0)
 				first = dev;
@@ -615,12 +615,13 @@ struct net_device *nr_dev_get(ax25_addre
 	struct net_device *dev;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_NETROM && ax25cmp(addr, (ax25_address *)dev->dev_addr) == 0) {
 			dev_hold(dev);
 			goto out;
 		}
 	}
+	dev = NULL;
 out:
 	read_unlock(&dev_base_lock);
 	return dev;
--- ./net/rose/rose_route.c.vedevbase-onet	Mon Jul  3 15:10:43 2006
+++ ./net/rose/rose_route.c	Mon Jul  3 16:12:11 2006
@@ -600,7 +600,7 @@ struct net_device *rose_dev_first(void)
 	struct net_device *dev, *first = NULL;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE)
 			if (first == NULL || strncmp(dev->name, first->name, 3) < 0)
 				first = dev;
@@ -618,12 +618,13 @@ struct net_device *rose_dev_get(rose_add
 	struct net_device *dev;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE && rosecmp(addr, (rose_address *)dev->dev_addr) == 0) {
 			dev_hold(dev);
 			goto out;
 		}
 	}
+	dev = NULL;
 out:
 	read_unlock(&dev_base_lock);
 	return dev;
@@ -634,10 +635,11 @@ static int rose_dev_exists(rose_address 
 	struct net_device *dev;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE && rosecmp(addr, (rose_address *)dev->dev_addr) == 0)
 			goto out;
 	}
+	dev = NULL;
 out:
 	read_unlock(&dev_base_lock);
 	return dev != NULL;
--- ./net/sctp/protocol.c.vedevbase-onet	Mon Jul  3 15:14:22 2006
+++ ./net/sctp/protocol.c	Mon Jul  3 16:12:11 2006
@@ -177,7 +177,7 @@ static void __sctp_get_local_addr_list(v
 	struct sctp_af *af;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		__list_for_each(pos, &sctp_address_families) {
 			af = list_entry(pos, struct sctp_af, list);
 			af->copy_addrlist(&sctp_local_addr_list, dev);
--- ./net/tipc/eth_media.c.vedevbase-onet	Mon Jul  3 15:14:23 2006
+++ ./net/tipc/eth_media.c	Mon Jul  3 16:14:31 2006
@@ -120,16 +120,19 @@ static int recv_msg(struct sk_buff *buf,
 
 static int enable_bearer(struct tipc_bearer *tb_ptr)
 {
-	struct net_device *dev = dev_base;
+	struct net_device *pdev, *dev;
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
 
 	/* Find device with specified name */
 
-	while (dev && dev->name && strncmp(dev->name, driver_name, IFNAMSIZ)) {	
-		dev = dev->next;
-	}
+	dev = NULL;
+	for_each_netdev(pdev)
+		if (pdev->name && !strncmp(pdev->name, driver_name, IFNAMSIZ)) {
+			dev = pdev;
+			break;
+		}
 	if (!dev)
 		return -ENODEV;
 
