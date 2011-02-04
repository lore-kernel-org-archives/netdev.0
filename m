From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Support compat SIOCGETVIFCNT ioctl in ipv4.
Date: Thu, 03 Feb 2011 17:54:45 -0800 (PST)
Message-ID: <20110203.175445.179941989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753721Ab1BDByJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 20:54:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipmr.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index fce10a0..8b65a12 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1444,9 +1444,19 @@ struct compat_sioc_sg_req {
 	compat_ulong_t wrong_if;
 };
 
+struct compat_sioc_vif_req {
+	vifi_t	vifi;		/* Which iface */
+	compat_ulong_t icount;
+	compat_ulong_t ocount;
+	compat_ulong_t ibytes;
+	compat_ulong_t obytes;
+};
+
 int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 {
 	struct compat_sioc_sg_req sr;
+	struct compat_sioc_vif_req vr;
+	struct vif_device *vif;
 	struct mfc_cache *c;
 	struct net *net = sock_net(sk);
 	struct mr_table *mrt;
@@ -1456,6 +1466,26 @@ int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 		return -ENOENT;
 
 	switch (cmd) {
+	case SIOCGETVIFCNT:
+		if (copy_from_user(&vr, arg, sizeof(vr)))
+			return -EFAULT;
+		if (vr.vifi >= mrt->maxvif)
+			return -EINVAL;
+		read_lock(&mrt_lock);
+		vif = &mrt->vif_table[vr.vifi];
+		if (VIF_EXISTS(mrt, vr.vifi)) {
+			vr.icount = vif->pkt_in;
+			vr.ocount = vif->pkt_out;
+			vr.ibytes = vif->bytes_in;
+			vr.obytes = vif->bytes_out;
+			read_unlock(&mrt_lock);
+
+			if (copy_to_user(arg, &vr, sizeof(vr)))
+				return -EFAULT;
+			return 0;
+		}
+		read_unlock(&mrt_lock);
+		return -EADDRNOTAVAIL;
 	case SIOCGETSGCNT:
 		if (copy_from_user(&sr, arg, sizeof(sr)))
 			return -EFAULT;
-- 
1.7.4

