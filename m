From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/2] bridge: mdb: add support for more attributes and export timer
Date: Tue, 16 Feb 2016 12:46:54 +0100
Message-ID: <1455623214-2951-3-git-send-email-razor@blackwall.org>
References: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33467 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbcBPLrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 06:47:37 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so187637637wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 03:47:36 -0800 (PST)
In-Reply-To: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Currently mdb entries are exported directly as a structure inside
MDBA_MDB_ENTRY_INFO attribute, we can't really extend it without
breaking user-space. In order to export new mdb fields, I've converted
the MDBA_MDB_ENTRY_INFO into a nested attribute which starts like before
with struct br_mdb_entry (without header, as it's casted directly in
iproute2) and continues with MDBA_MDB_EATTR_ attributes. This way we
keep compatibility with older users and can export new data.
I've tested this with iproute2, both with and without support for the
added attribute and it works fine.
So basically we again have MDBA_MDB_ENTRY_INFO with struct br_mdb_entry
inside but it may contain also some additional MDBA_MDB_EATTR_ attributes
such as MDBA_MDB_EATTR_TIMER which can be parsed by user-space.

So the new structure is:
[MDBA_MDB] = {
     [MDBA_MDB_ENTRY] = {
         [MDBA_MDB_ENTRY_INFO]
         [MDBA_MDB_ENTRY_INFO] { <- Nested attribute
             struct br_mdb_entry <- nla_put_nohdr()
             [MDBA_MDB_ENTRY attributes] <- normal netlink attributes
         }
     }
}

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h | 13 ++++++++++++-
 net/bridge/br_mdb.c            | 16 +++++++++++++++-
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index ec3547234998..0890b217580d 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -137,7 +137,10 @@ struct bridge_vlan_info {
 /* Bridge multicast database attributes
  * [MDBA_MDB] = {
  *     [MDBA_MDB_ENTRY] = {
- *         [MDBA_MDB_ENTRY_INFO]
+ *         [MDBA_MDB_ENTRY_INFO] {
+ *		struct br_mdb_entry
+ *		[MDBA_MDB_EATTR attributes]
+ *         }
  *     }
  * }
  * [MDBA_ROUTER] = {
@@ -166,6 +169,14 @@ enum {
 };
 #define MDBA_MDB_ENTRY_MAX (__MDBA_MDB_ENTRY_MAX - 1)
 
+/* per mdb entry additional attributes */
+enum {
+	MDBA_MDB_EATTR_UNSPEC,
+	MDBA_MDB_EATTR_TIMER,
+	__MDBA_MDB_EATTR_MAX
+};
+#define MDBA_MDB_EATTR_MAX (__MDBA_MDB_EATTR_MAX - 1)
+
 enum {
 	MDBA_ROUTER_UNSPEC,
 	MDBA_ROUTER_PORT,
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index e66619171386..cf51b7bcb5d5 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -88,11 +88,13 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 			for (pp = &mp->ports;
 			     (p = rcu_dereference(*pp)) != NULL;
 			      pp = &p->next) {
+				struct nlattr *nest_ent;
 				struct br_mdb_entry e;
 
 				port = p->port;
 				if (!port)
 					continue;
+
 				memset(&e, 0, sizeof(e));
 				e.ifindex = port->dev->ifindex;
 				e.vid = p->addr.vid;
@@ -104,11 +106,23 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 					e.addr.u.ip6 = p->addr.u.ip6;
 #endif
 				e.addr.proto = p->addr.proto;
-				if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
+				nest_ent = nla_nest_start(skb,
+							  MDBA_MDB_ENTRY_INFO);
+				if (!nest_ent) {
+					nla_nest_cancel(skb, nest2);
+					err = -EMSGSIZE;
+					goto out;
+				}
+				if (nla_put_nohdr(skb, sizeof(e), &e) ||
+				    nla_put_u32(skb,
+						MDBA_MDB_EATTR_TIMER,
+						br_timer_value(&p->timer))) {
+					nla_nest_cancel(skb, nest_ent);
 					nla_nest_cancel(skb, nest2);
 					err = -EMSGSIZE;
 					goto out;
 				}
+				nla_nest_end(skb, nest_ent);
 			}
 			nla_nest_end(skb, nest2);
 		skip:
-- 
2.4.3
