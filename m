From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v5 4/6] vxlan: allow removal of single destination from fdb entry
Date: Tue, 25 Jun 2013 16:01:54 +0300
Message-ID: <1372165316-17647-5-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:51486 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751670Ab3FYNCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 09:02:23 -0400
Received: by mail-we0-f178.google.com with SMTP id u53so9329416wes.9
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 06:02:21 -0700 (PDT)
In-Reply-To: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the last item is deleted from the remote destinations list, the
fdb entry is destroyed.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 44 ++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 40 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ee7cc71..c182520 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -105,6 +105,7 @@ struct vxlan_rdst {
 	u32			 remote_vni;
 	u32			 remote_ifindex;
 	struct list_head	 list;
+	struct rcu_head		 rcu;
 };
 
 /* Forwarding table entry */
@@ -496,6 +497,12 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	return 0;
 }
 
+static void vxlan_fdb_free_rdst(struct rcu_head *head)
+{
+	struct vxlan_rdst *rd = container_of(head, struct vxlan_rdst, rcu);
+	kfree(rd);
+}
+
 static void vxlan_fdb_free(struct rcu_head *head)
 {
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
@@ -605,14 +612,43 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
-	int err = -ENOENT;
+	struct vxlan_rdst *rd = NULL;
+	__be32 ip;
+	__be16 port;
+	u32 vni, ifindex;
+	int err;
+
+	err = vxlan_fdb_parse(tb, vxlan, &ip, &port, &vni, &ifindex);
+	if (err)
+		return err;
+
+	err = -ENOENT;
 
 	spin_lock_bh(&vxlan->hash_lock);
 	f = vxlan_find_mac(vxlan, addr);
-	if (f) {
-		vxlan_fdb_destroy(vxlan, f);
-		err = 0;
+	if (!f)
+		goto out;
+
+	if (ip != htonl(INADDR_ANY)) {
+		rd = vxlan_fdb_find_rdst(f, ip, port, vni, ifindex);
+		if (!rd)
+			goto out;
+	}
+
+	err = 0;
+
+	/* remove a destination if it's not the only one on the list,
+	 * otherwise destroy the fdb entry
+	 */
+	if (rd && !list_is_singular(&f->remotes)) {
+		list_del_rcu(&rd->list);
+		call_rcu(&rd->rcu, vxlan_fdb_free_rdst);
+		goto out;
 	}
+
+	vxlan_fdb_destroy(vxlan, f);
+
+out:
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
-- 
1.8.1.5
