From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH 1/2 V2] vxlan fdb replace an existing entry
Date: Fri, 12 Jul 2013 09:10:15 +0200
Message-ID: <1373613016-6856-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:44092 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756928Ab3GLHKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 03:10:31 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Fri, 12 Jul 2013 08:04:48 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1A6902190019
	for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 08:14:22 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6C7AGvC31195208
	for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 07:10:16 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6C7AQEe002618
	for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 01:10:26 -0600
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
