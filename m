From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v5 2/6] vxlan: introduce vxlan_fdb_find_rdst
Date: Tue, 25 Jun 2013 16:01:52 +0300
Message-ID: <1372165316-17647-3-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:38817 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751082Ab3FYNCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 09:02:13 -0400
Received: by mail-wi0-f180.google.com with SMTP id c10so721436wiw.7
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 06:02:12 -0700 (PDT)
In-Reply-To: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

which will be reused by vxlan_fdb_delete

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bdfe46e..306bd94 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -388,21 +388,34 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 	return f;
 }
 
-/* Add/update destinations for multicast */
-static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+/* caller should hold vxlan->hash_lock */
+static struct vxlan_rdst *vxlan_fdb_find_rdst(struct vxlan_fdb *f,
+					      __be32 ip, __be16 port,
+					      __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd;
 
-	/* protected by vxlan->hash_lock */
 	list_for_each_entry(rd, &f->remotes, list) {
 		if (rd->remote_ip == ip &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
 		    rd->remote_ifindex == ifindex)
-			return 0;
+			return rd;
 	}
 
+	return NULL;
+}
+
+/* Add/update destinations for multicast */
+static int vxlan_fdb_append(struct vxlan_fdb *f,
+			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
+{
+	struct vxlan_rdst *rd;
+
+	rd = vxlan_fdb_find_rdst(f, ip, port, vni, ifindex);
+	if (rd)
+		return 0;
+
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
-- 
1.8.1.5
