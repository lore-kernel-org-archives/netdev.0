From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [RFC PATCH] bridge: mdb: add support for more attributes
	and export timer
Date: Tue,  2 Feb 2016 18:22:05 +0100
Message-ID: <1454433725-3004-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi,
Sending this as an RFC to see first if it's acceptable at all to change the
exported attribute and if the approach is okay with everyone.
Since currently mdb entries are exported directly as a structure inside
MDBA_MDB_ENTRY_INFO attribute, we can't really extend it without
breaking user-space. In order to export new mdb fields, I've converted
the MDBA_MDB_ENTRY_INFO into a nested attribute which starts like before
with struct br_mdb_entry (without header, as it's casted directly in
iproute2) and continues with MDBA_MDB_ENTRY_ attributes. This way we
keep compatibility with older users and can export new data.
I've tested this with iproute2, both with and without support for the
added attribute and it works fine.
So basically we again have MDBA_MDB_ENTRY_INFO with struct br_mdb_entry
inside but it may contain also some additional MDBA_MDB_ENTRY_ attributes
such as MDBA_MDB_ENTRY_TIMER which can be parsed by user-space.

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

Alternatively I can add a whole new dump format which can be requested
by user-space by adding a netlink attribute in the request (e.g. MDBA_MDB_EXT).
That format will be using only netlink attributes for all MDB information and
will be dumped like that only upon request.

Any feedback on this would be much appreciated.

Thank you,
 Nik

---
 include/uapi/linux/if_bridge.h |  6 +++++-
 net/bridge/br_mdb.c            | 14 +++++++++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 18db14477bdd..8c595cdc3bba 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -137,7 +137,10 @@ struct bridge_vlan_info {
 /* Bridge multicast database attributes
  * [MDBA_MDB] = {
  *     [MDBA_MDB_ENTRY] = {
- *         [MDBA_MDB_ENTRY_INFO]
+ *         [MDBA_MDB_ENTRY_INFO] {
+ *		struct br_mdb_entry
+ *		[MDBA_MDB_ENTRY attributes]
+ *         }
  *     }
  * }
  * [MDBA_ROUTER] = {
@@ -162,6 +165,7 @@ enum {
 enum {
 	MDBA_MDB_ENTRY_UNSPEC,
 	MDBA_MDB_ENTRY_INFO,
+	MDBA_MDB_ENTRY_TIMER,
 	__MDBA_MDB_ENTRY_MAX,
 };
 #define MDBA_MDB_ENTRY_MAX (__MDBA_MDB_ENTRY_MAX - 1)
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 30e105f57f0d..33436601b959 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -82,7 +82,9 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 			      pp = &p->next) {
 				port = p->port;
 				if (port) {
+					struct nlattr *nest_ent;
 					struct br_mdb_entry e;
+
 					memset(&e, 0, sizeof(e));
 					e.ifindex = port->dev->ifindex;
 					e.state = p->state;
@@ -94,11 +96,21 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 						e.addr.u.ip6 = p->addr.u.ip6;
 #endif
 					e.addr.proto = p->addr.proto;
-					if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
+					nest_ent = nla_nest_start(skb, MDBA_MDB_ENTRY_INFO);
+					if (!nest_ent) {
+						nla_nest_cancel(skb, nest2);
+						err = -EMSGSIZE;
+						goto out;
+					}
+					if (nla_put_nohdr(skb, sizeof(e), &e) ||
+					    nla_put_u32(skb, MDBA_MDB_ENTRY_TIMER,
+							br_timer_value(&p->timer))) {
+						nla_nest_cancel(skb, nest_ent);
 						nla_nest_cancel(skb, nest2);
 						err = -EMSGSIZE;
 						goto out;
 					}
+					nla_nest_end(skb, nest_ent);
 				}
 			}
 			nla_nest_end(skb, nest2);
-- 
2.4.3
