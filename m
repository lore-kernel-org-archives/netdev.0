From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 1/2] vxlan fdb replace an existing entry
Date: Thu, 11 Jul 2013 12:28:19 +0200
Message-ID: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:41165 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083Ab3GKK23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 06:28:29 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Thu, 11 Jul 2013 11:24:14 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 696982190059
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 11:32:19 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6BASEJa42598494
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 10:28:14 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6BASOPn011563
	for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 04:28:25 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to replace an existing entry found in the
vxlan fdb database. The entry in question is identified
by its unicast mac address and the destination information
is changed. If the entry is not found, it is added in the
forwarding database. This is similar to changing an entry
in the neighbour table.

Multicast mac addresses can not be changed with the replace
option.

This is useful for virtual machine migration when the
destination of a target virtual machine changes. The replace
feature can be used instead of delete followed by add.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/net/vxlan.c | 40 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 227b54a..17681c6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -42,7 +42,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-#define VXLAN_VERSION	"0.1"
+#define VXLAN_VERSION	"0.1tmr3"
 
 #define PORT_HASH_BITS	8
 #define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
@@ -407,6 +407,26 @@ static struct vxlan_rdst *vxlan_fdb_find_rdst(struct vxlan_fdb *f,
 	return NULL;
 }
 
+/* Replace destination of unicast mac */
+static int vxlan_fdb_replace(struct vxlan_fdb *f,
+			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+{
+	struct vxlan_rdst *rd;
+
+	rd = vxlan_fdb_find_rdst(f, ip, port, vni, ifindex);
+	if (rd)
+		return 0;
+
+	rd = list_first_entry_or_null(&f->remotes, struct vxlan_rdst, list);
+	if (!rd)
+		return 0;
+	rd->remote_ip = ip;
+	rd->remote_port = port;
+	rd->remote_vni = vni;
+	rd->remote_ifindex = ifindex;
+	return 1;
+}
+
 /* Add/update destinations for multicast */
 static int vxlan_fdb_append(struct vxlan_fdb *f,
 			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
@@ -457,6 +477,19 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			f->updated = jiffies;
 			notify = 1;
 		}
+		if ((flags & NLM_F_REPLACE)) {
+			/* Only change unicasts */
+			if (!(is_multicast_ether_addr(f->eth_addr) ||
+			     is_zero_ether_addr(f->eth_addr))) {
+				int rc = vxlan_fdb_replace(f, ip, port, vni,
+							   ifindex);
+
+				if (rc < 0)
+					return rc;
+				notify |= rc;
+			} else
+				return -EOPNOTSUPP;
+		}
 		if ((flags & NLM_F_APPEND) &&
 		    (is_multicast_ether_addr(f->eth_addr) ||
 		     is_zero_ether_addr(f->eth_addr))) {
@@ -473,6 +506,11 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		if (vxlan->addrmax && vxlan->addrcnt >= vxlan->addrmax)
 			return -ENOSPC;
 
+		/* Disallow replace to add a multicast entry */
+		if ((flags & NLM_F_REPLACE) &&
+		    (is_multicast_ether_addr(mac) || is_zero_ether_addr(mac)))
+			return -EOPNOTSUPP;
+
 		netdev_dbg(vxlan->dev, "add %pM -> %pI4\n", mac, &ip);
 		f = kmalloc(sizeof(*f), GFP_ATOMIC);
 		if (!f)
-- 
1.8.1.4
