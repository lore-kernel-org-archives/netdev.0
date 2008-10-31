From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 5/7] drivers: replace NIPQUAD()
Date: Thu, 30 Oct 2008 17:13:46 -0700
Message-ID: <1225412026.5574.36.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:39632 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbYJaANx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:13:53 -0400
Received: by wf-out-1314.google.com with SMTP id 27so879384wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:13:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/firmware/iscsi_ibft.c            |    3 +--
 drivers/infiniband/hw/nes/nes_cm.c       |   21 +++++++++------------
 drivers/infiniband/hw/nes/nes_utils.c    |    5 ++---
 drivers/infiniband/ulp/iser/iser_verbs.c |    8 ++++----
 drivers/net/bonding/bond_main.c          |   22 ++++++++++------------
 drivers/net/bonding/bond_sysfs.c         |   28 ++++++++++++++--------------
 drivers/scsi/iscsi_tcp.c                 |    2 +-
 drivers/scsi/qla4xxx/ql4_os.c            |    3 +--
 8 files changed, 42 insertions(+), 50 deletions(-)

diff --git a/drivers/firmware/iscsi_ibft.c b/drivers/firmware/iscsi_ibft.c
index acb82af..3ab3e4a 100644
--- a/drivers/firmware/iscsi_ibft.c
+++ b/drivers/firmware/iscsi_ibft.c
@@ -284,8 +284,7 @@ static ssize_t sprintf_ipaddr(char *buf, u8 *ip)
 		/*
 		 * IPV4
 		 */
-		str += sprintf(buf, NIPQUAD_FMT, ip[12],
-			       ip[13], ip[14], ip[15]);
+		str += sprintf(buf, "%pI4", ip + 12);
 	} else {
 		/*
 		 * IPv6
diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 6058d05..2854a6f 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -823,8 +823,8 @@ static struct nes_cm_node *find_node(struct nes_cm_core *cm_core,
 	/* get a handle on the hte */
 	hte = &cm_core->connected_nodes;
 
-	nes_debug(NES_DBG_CM, "Searching for an owner node: " NIPQUAD_FMT ":%x from core %p->%p\n",
-		  HIPQUAD(loc_addr), loc_port, cm_core, hte);
+	nes_debug(NES_DBG_CM, "Searching for an owner node: %pI4:%x from core %p->%p\n",
+		  &loc_addr, loc_port, cm_core, hte);
 
 	/* walk list and find cm_node associated with this session ID */
 	spin_lock_irqsave(&cm_core->ht_lock, flags);
@@ -873,8 +873,8 @@ static struct nes_cm_listener *find_listener(struct nes_cm_core *cm_core,
 	}
 	spin_unlock_irqrestore(&cm_core->listen_list_lock, flags);
 
-	nes_debug(NES_DBG_CM, "Unable to find listener for " NIPQUAD_FMT ":%x\n",
-		  HIPQUAD(dst_addr), dst_port);
+	nes_debug(NES_DBG_CM, "Unable to find listener for %pI4:%x\n",
+		  &dst_addr, dst_port);
 
 	/* no listener */
 	return NULL;
@@ -1082,10 +1082,9 @@ static struct nes_cm_node *make_cm_node(struct nes_cm_core *cm_core,
 	cm_node->loc_port = cm_info->loc_port;
 	cm_node->rem_port = cm_info->rem_port;
 	cm_node->send_write0 = send_first;
-	nes_debug(NES_DBG_CM, "Make node addresses : loc = " NIPQUAD_FMT
-			":%x, rem = " NIPQUAD_FMT ":%x\n",
-			HIPQUAD(cm_node->loc_addr), cm_node->loc_port,
-			HIPQUAD(cm_node->rem_addr), cm_node->rem_port);
+	nes_debug(NES_DBG_CM, "Make node addresses : loc = %pI4:%x, rem = %pI4:%x\n",
+		  &cm_node->loc_addr, cm_node->loc_port,
+		  &cm_node->rem_addr, cm_node->rem_port);
 	cm_node->listener = listener;
 	cm_node->netdev = nesvnic->netdev;
 	cm_node->cm_id = cm_info->cm_id;
@@ -2066,10 +2065,8 @@ static void mini_cm_recv_pkt(struct nes_cm_core *cm_core,
 	nfo.rem_addr = ntohl(iph->saddr);
 	nfo.rem_port = ntohs(tcph->source);
 
-	nes_debug(NES_DBG_CM, "Received packet: dest=" NIPQUAD_FMT
-		  ":0x%04X src=" NIPQUAD_FMT ":0x%04X\n",
-		  NIPQUAD(iph->daddr), tcph->dest,
-		  NIPQUAD(iph->saddr), tcph->source);
+	nes_debug(NES_DBG_CM, "Received packet: dest=%pI4:0x%04X src=%pI4:0x%04X\n",
+		  &iph->daddr, tcph->dest, &iph->saddr, tcph->source);
 
 	do {
 		cm_node = find_node(cm_core,
diff --git a/drivers/infiniband/hw/nes/nes_utils.c b/drivers/infiniband/hw/nes/nes_utils.c
index fb8cbd7..9f16f7a 100644
--- a/drivers/infiniband/hw/nes/nes_utils.c
+++ b/drivers/infiniband/hw/nes/nes_utils.c
@@ -679,9 +679,8 @@ int nes_arp_table(struct nes_device *nesdev, u32 ip_addr, u8 *mac_addr, u32 acti
 
 	/* DELETE or RESOLVE */
 	if (arp_index == nesadapter->arp_table_size) {
-		nes_debug(NES_DBG_NETDEV, "MAC for " NIPQUAD_FMT " not in ARP table - cannot %s\n",
-			  HIPQUAD(ip_addr),
-			  action == NES_ARP_RESOLVE ? "resolve" : "delete");
+		nes_debug(NES_DBG_NETDEV, "MAC for %pI4 not in ARP table - cannot %s\n",
+			  &ip_addr, action == NES_ARP_RESOLVE ? "resolve" : "delete");
 		return -1;
 	}
 
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 26ff621..e418b96 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -515,14 +515,14 @@ int iser_connect(struct iser_conn   *ib_conn,
 	struct sockaddr *src, *dst;
 	int err = 0;
 
-	sprintf(ib_conn->name,"%d.%d.%d.%d:%d",
-		NIPQUAD(dst_addr->sin_addr.s_addr), dst_addr->sin_port);
+	sprintf(ib_conn->name, "%pI4:%d",
+		&dst_addr->sin_addr.s_addr, dst_addr->sin_port);
 
 	/* the device is known only --after-- address resolution */
 	ib_conn->device = NULL;
 
-	iser_err("connecting to: %d.%d.%d.%d, port 0x%x\n",
-		 NIPQUAD(dst_addr->sin_addr), dst_addr->sin_port);
+	iser_err("connecting to: %pI4, port 0x%x\n",
+		 &dst_addr->sin_addr, dst_addr->sin_port);
 
 	ib_conn->state = ISER_CONN_PENDING;
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f2da031..819a8f1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2568,8 +2568,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		if (rv) {
 			if (net_ratelimit()) {
 				printk(KERN_WARNING DRV_NAME
-			     ": %s: no route to arp_ip_target %u.%u.%u.%u\n",
-				       bond->dev->name, NIPQUAD(fl.fl4_dst));
+			     ": %s: no route to arp_ip_target %pI4\n",
+				       bond->dev->name, &fl.fl4_dst);
 			}
 			continue;
 		}
@@ -2605,8 +2605,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 
 		if (net_ratelimit()) {
 			printk(KERN_WARNING DRV_NAME
-	       ": %s: no path to arp_ip_target %u.%u.%u.%u via rt.dev %s\n",
-			       bond->dev->name, NIPQUAD(fl.fl4_dst),
+	       ": %s: no path to arp_ip_target %pI4 via rt.dev %s\n",
+			       bond->dev->name, &fl.fl4_dst,
 			       rt->u.dst.dev ? rt->u.dst.dev->name : "NULL");
 		}
 		ip_rt_put(rt);
@@ -2655,10 +2655,8 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 
 	targets = bond->params.arp_targets;
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
-		dprintk("bva: sip %u.%u.%u.%u tip %u.%u.%u.%u t[%d] "
-			"%u.%u.%u.%u bhti(tip) %d\n",
-		       NIPQUAD(sip), NIPQUAD(tip), i, NIPQUAD(targets[i]),
-		       bond_has_this_ip(bond, tip));
+		dprintk("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
+			&sip, &tip, i, &targets[i], bond_has_this_ip(bond, tip));
 		if (sip == targets[i]) {
 			if (bond_has_this_ip(bond, tip))
 				slave->last_arp_rx = jiffies;
@@ -2710,10 +2708,10 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	arp_ptr += 4 + dev->addr_len;
 	memcpy(&tip, arp_ptr, 4);
 
-	dprintk("bond_arp_rcv: %s %s/%d av %d sv %d sip %u.%u.%u.%u"
-		" tip %u.%u.%u.%u\n", bond->dev->name, slave->dev->name,
-		slave->state, bond->params.arp_validate,
-		slave_do_arp_validate(bond, slave), NIPQUAD(sip), NIPQUAD(tip));
+	dprintk("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
+		bond->dev->name, slave->dev->name, slave->state,
+		bond->params.arp_validate, slave_do_arp_validate(bond, slave),
+		&sip, &tip);
 
 	/*
 	 * Backup slaves won't see the ARP reply, but do come through
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 99c79a4..9f3a0ef 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -672,8 +672,8 @@ static ssize_t bonding_show_arp_targets(struct device *d,
 
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
 		if (bond->params.arp_targets[i])
-			res += sprintf(buf + res, "%u.%u.%u.%u ",
-			       NIPQUAD(bond->params.arp_targets[i]));
+			res += sprintf(buf + res, "%pI4 ",
+				       &bond->params.arp_targets[i]);
 	}
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
@@ -695,8 +695,8 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 	if (buf[0] == '+') {
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
 			printk(KERN_ERR DRV_NAME
-			       ": %s: invalid ARP target %u.%u.%u.%u specified for addition\n",
- 			       bond->dev->name, NIPQUAD(newtarget));
+			       ": %s: invalid ARP target %pI4 specified for addition\n",
+ 			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -704,8 +704,8 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
 			if (targets[i] == newtarget) { /* duplicate */
 				printk(KERN_ERR DRV_NAME
-				       ": %s: ARP target %u.%u.%u.%u is already present\n",
-				       bond->dev->name, NIPQUAD(newtarget));
+				       ": %s: ARP target %pI4 is already present\n",
+				       bond->dev->name, &newtarget);
 				if (done)
 					targets[i] = 0;
 				ret = -EINVAL;
@@ -713,8 +713,8 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			}
 			if (targets[i] == 0 && !done) {
 				printk(KERN_INFO DRV_NAME
-				       ": %s: adding ARP target %d.%d.%d.%d.\n",
-				       bond->dev->name, NIPQUAD(newtarget));
+				       ": %s: adding ARP target %pI4.\n",
+				       bond->dev->name, &newtarget);
 				done = 1;
 				targets[i] = newtarget;
 			}
@@ -731,8 +731,8 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 	else if (buf[0] == '-')	{
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
 			printk(KERN_ERR DRV_NAME
-			       ": %s: invalid ARP target %d.%d.%d.%d specified for removal\n",
-			       bond->dev->name, NIPQUAD(newtarget));
+			       ": %s: invalid ARP target %pI4 specified for removal\n",
+			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -740,16 +740,16 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
 			if (targets[i] == newtarget) {
 				printk(KERN_INFO DRV_NAME
-				       ": %s: removing ARP target %d.%d.%d.%d.\n",
-				       bond->dev->name, NIPQUAD(newtarget));
+				       ": %s: removing ARP target %pI4.\n",
+				       bond->dev->name, &newtarget);
 				targets[i] = 0;
 				done = 1;
 			}
 		}
 		if (!done) {
 			printk(KERN_INFO DRV_NAME
-			       ": %s: unable to remove nonexistent ARP target %d.%d.%d.%d.\n",
-			       bond->dev->name, NIPQUAD(newtarget));
+			       ": %s: unable to remove nonexistent ARP target %pI4.\n",
+			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
 		}
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 24d0902..e11bce6 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -1601,7 +1601,7 @@ static int iscsi_tcp_get_addr(struct iscsi_conn *conn, struct socket *sock,
 	case AF_INET:
 		sin = (struct sockaddr_in *)addr;
 		spin_lock_bh(&conn->session->lock);
-		sprintf(buf, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+		sprintf(buf, "%pI4", &sin->sin_addr.s_addr);
 		*port = be16_to_cpu(sin->sin_port);
 		spin_unlock_bh(&conn->session->lock);
 		break;
diff --git a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
index db7ea3b..eb3a414 100644
--- a/drivers/scsi/qla4xxx/ql4_os.c
+++ b/drivers/scsi/qla4xxx/ql4_os.c
@@ -206,8 +206,7 @@ static int qla4xxx_conn_get_param(struct iscsi_cls_conn *conn,
 		break;
 	case ISCSI_PARAM_CONN_ADDRESS:
 		/* TODO: what are the ipv6 bits */
-		len = sprintf(buf, "%u.%u.%u.%u\n",
-			      NIPQUAD(ddb_entry->ip_addr));
+		len = sprintf(buf, "%pI4\n", &ddb_entry->ip_addr);
 		break;
 	default:
 		return -ENOSYS;
-- 
1.6.0.3.756.gb776d


