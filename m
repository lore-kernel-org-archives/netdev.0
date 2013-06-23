From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v4 1/2] vxlan: introduce vxlan_rdst_append
Date: Sun, 23 Jun 2013 19:22:22 +0300
Message-ID: <1372004543-24675-2-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:34333 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751803Ab3FWQWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:22:36 -0400
Received: by mail-ea0-f170.google.com with SMTP id h10so5700206eaj.1
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 09:22:34 -0700 (PDT)
In-Reply-To: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to allow remotes list management for both FDB entries and default
destinations

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 212a256..e5fb6568 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -386,14 +386,13 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 	return f;
 }
 
-/* Add/update destinations for multicast */
-static int vxlan_fdb_append(struct vxlan_fdb *f,
+static int vxlan_rdst_append(struct list_head *remotes,
 			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
 	/* protected by vxlan->hash_lock */
-	list_for_each_entry(rd, &f->remotes, list) {
+	list_for_each_entry(rd, remotes, list) {
 		if (rd->remote_ip == ip &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
@@ -409,11 +408,18 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	rd->remote_vni = vni;
 	rd->remote_ifindex = ifindex;
 
-	list_add_tail_rcu(&rd->list, &f->remotes);
+	list_add_tail_rcu(&rd->list, remotes);
 
 	return 1;
 }
 
+/* Add/update destinations for multicast */
+static int vxlan_fdb_append(struct vxlan_fdb *f,
+			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+{
+	return vxlan_rdst_append(&f->remotes, ip, port, vni, ifindex);
+}
+
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, __be32 ip,
-- 
1.8.1.5
