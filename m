From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] bridge: mdb: fix delmdb state in the
	notification
Date: Tue, 28 Jul 2015 13:10:44 +0200
Message-ID: <1438081844-18801-1-git-send-email-razor@blackwall.org>
Cc: amwang@redhat.com, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	cwang@twopensource.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Since mdb states were introduced when deleting an entry the state was
left as it was set in the delete request from the user which leads to
the following output when doing a monitor (for example):
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
(monitor) dev br0 port eth3 grp 239.0.0.1 permanent
$ bridge mdb del dev br0 port eth3 grp 239.0.0.1 permanent
(monitor) dev br0 port eth3 grp 239.0.0.1 temp
^^^
Note the "temp" state in the delete notification which is wrong since
the entry was permanent, the state in a delete is always reported as
"temp" regardless of the real state of the entry.

After this patch:
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
(monitor) dev br0 port eth3 grp 239.0.0.1 permanent
$ bridge mdb del dev br0 port eth3 grp 239.0.0.1 permanent
(monitor) dev br0 port eth3 grp 239.0.0.1 permanent

There's one important note to make here that the state is actually not
matched when doing a delete, so one can delete a permanent entry by
stating "temp" in the end of the command, I've chosen this fix in order
not to break user-space tools which rely on this (incorrect) behaviour.

So to give an example after this patch and using the wrong state:
$ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
(monitor) dev br0 port eth3 grp 239.0.0.1 permanent
$ bridge mdb del dev br0 port eth3 grp 239.0.0.1 temp
(monitor) dev br0 port eth3 grp 239.0.0.1 permanent

Note the state of the entry that got deleted is correct in the
notification.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: ccb1c31a7a87 ("bridge: add flags to distinguish permanent mdb entires")
---
I propose to fix the state matching in net-next but we may risk breaking
some user-space tools which rely on this behaviour.

 net/bridge/br_mdb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 1198a3dbad95..c94321955db7 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -445,6 +445,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 		if (p->port->state == BR_STATE_DISABLED)
 			goto unlock;
 
+		entry->state = p->state;
 		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
-- 
2.4.3
