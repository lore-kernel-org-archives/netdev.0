From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 4/6] bridge: Allow user to program hw addresses to uplink devices.
Date: Fri, 19 Apr 2013 16:52:48 -0400
Message-ID: <1366404770-28523-5-git-send-email-vyasevic@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462Ab3DSUw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:57 -0400
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bridge fdb handling to program hw addresses to the
bridge master device which will sync them to uplink devices.
The use sets a new flag in the ndmsg structure to say that
a given address should be added to or removed from uplinks.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/neighbour.h |    6 ++--
 net/bridge/br_fdb.c            |   50 ++++++++++++++++++++++++++++------------
 net/core/rtnetlink.c           |    4 +-
 3 files changed, 40 insertions(+), 20 deletions(-)

diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index f175212..fd1587d 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -34,11 +34,11 @@ enum {
  */
 
 #define NTF_USE		0x01
-#define NTF_PROXY	0x08	/* == ATF_PUBL */
-#define NTF_ROUTER	0x80
-
 #define NTF_SELF	0x02
 #define NTF_MASTER	0x04
+#define NTF_PROXY	0x08	/* == ATF_PUBL */
+#define NTF_UPLINK	0x10
+#define NTF_ROUTER	0x80
 
 /*
  *	Neighbor Cache Entry States.
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index c581f12..5585e00 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -671,7 +671,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	       const unsigned char *addr, u16 nlh_flags)
 {
 	struct net_bridge_port *p;
-	int err = 0;
+	int err = -EINVAL;
 	struct net_port_vlans *pv;
 	unsigned short vid = VLAN_N_VID;
 
@@ -680,6 +680,16 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
+	p = br_port_get_rtnl(dev);
+	if (p == NULL) {
+		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
+			dev->name);
+		return -EINVAL;
+	}
+
+	if (is_multicast_ether_addr(addr))
+		goto uplink;
+
 	if (tb[NDA_VLAN]) {
 		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
 			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
@@ -695,13 +705,6 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		}
 	}
 
-	p = br_port_get_rtnl(dev);
-	if (p == NULL) {
-		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
-			dev->name);
-		return -EINVAL;
-	}
-
 	pv = nbp_get_vlan_info(p);
 	if (vid != VLAN_N_VID) {
 		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
@@ -729,6 +732,13 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		}
 	}
 
+uplink:
+	/* Check to see if  the user requested this address be added to
+	 * uplink
+	 */
+	if (ndm->ndm_flags & NTF_UPLINK)
+		err = ndo_dflt_fdb_add(ndm, tb, p->br->dev, addr, nlh_flags);
+
 out:
 	return err;
 }
@@ -765,10 +775,20 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  const unsigned char *addr)
 {
 	struct net_bridge_port *p;
-	int err;
+	int err = -EINVAL;
 	struct net_port_vlans *pv;
 	unsigned short vid = VLAN_N_VID;
 
+	p = br_port_get_rtnl(dev);
+	if (p == NULL) {
+		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
+			dev->name);
+		return -EINVAL;
+	}
+
+	if (is_multicast_ether_addr(addr))
+		goto uplink;
+
 	if (tb[NDA_VLAN]) {
 		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
 			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
@@ -783,12 +803,6 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			return -EINVAL;
 		}
 	}
-	p = br_port_get_rtnl(dev);
-	if (p == NULL) {
-		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
-			dev->name);
-		return -EINVAL;
-	}
 
 	pv = nbp_get_vlan_info(p);
 	if (vid != VLAN_N_VID) {
@@ -814,6 +828,12 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			err &= __br_fdb_delete(p, addr, vid);
 		}
 	}
+uplink:
+	/* Check to see if  the user requested this address be removed
+	 * from uplink
+	 */
+	if (ndm->ndm_flags & NTF_UPLINK)
+		err = ndo_dflt_fdb_del(ndm, tb, p->br->dev, addr);
 out:
 	return err;
 }
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 589d0ab..1d3c223 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2042,7 +2042,7 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
 	/* If aging addresses are supported device will need to
 	 * implement its own handler for this.
 	 */
-	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
+	if (ndm->ndm_state && !(ndm->ndm_state & (NUD_PERMANENT | NUD_NOARP))) {
 		pr_info("%s: FDB only supports static addresses\n", dev->name);
 		return err;
 	}
@@ -2142,7 +2142,7 @@ int ndo_dflt_fdb_del(struct ndmsg *ndm,
 	/* If aging addresses are supported device will need to
 	 * implement its own handler for this.
 	 */
-	if (ndm->ndm_state & NUD_PERMANENT) {
+	if (ndm->ndm_state & (NUD_PERMANENT | NUD_NOARP)) {
 		pr_info("%s: FDB only supports static addresses\n", dev->name);
 		return -EINVAL;
 	}
-- 
1.7.7.6
