From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH v2] vxlan: Update vxlan fdb 'used' field after each usage
Date: Fri, 17 May 2013 09:39:07 -0700
Message-ID: <1368808747.14093.23.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, stephen@networkplumber.org,
	dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:43546 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753577Ab3EQQjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 12:39:15 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Fri, 17 May 2013 12:39:14 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0886E38C8047
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 12:39:11 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4HGd9RG158048
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 12:39:10 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4HGd8mv022094
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 10:39:08 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some instances where vxlan fdb 'used' field is not updated after the entry 
is used.

v2: rename vxlan_find_mac() as __vxlan_find_mac() and create a new vxlan_find_mac()
that also updates ->used field.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ba81f3c..3b1d2ee 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -301,7 +301,7 @@ static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
 }
 
 /* Look up Ethernet address in forwarding table */
-static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
+static struct vxlan_fdb *__vxlan_find_mac(struct vxlan_dev *vxlan,
 					const u8 *mac)
 
 {
@@ -316,6 +316,18 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 	return NULL;
 }
 
+static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
+					const u8 *mac)
+{
+	struct vxlan_fdb *f;
+
+	f = __vxlan_find_mac(vxlan, mac);
+	if (f)
+		f->used = jiffies;
+
+	return f;
+}
+
 /* Add/update destinations for multicast */
 static int vxlan_fdb_append(struct vxlan_fdb *f,
 			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
@@ -353,7 +365,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	struct vxlan_fdb *f;
 	int notify = 0;
 
-	f = vxlan_find_mac(vxlan, mac);
+	f = __vxlan_find_mac(vxlan, mac);
 	if (f) {
 		if (flags & NLM_F_EXCL) {
 			netdev_dbg(vxlan->dev,
@@ -563,7 +575,6 @@ static void vxlan_snoop(struct net_device *dev,
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
-		f->used = jiffies;
 		if (likely(f->remote.remote_ip == src_ip))
 			return;
 
