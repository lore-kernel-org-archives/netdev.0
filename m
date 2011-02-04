From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Provide compat support for SIOCGETMIFCNT_IN6 and
 SIOCGETSGCNT_IN6.
Date: Thu, 03 Feb 2011 17:54:48 -0800 (PST)
Message-ID: <20110203.175448.245404709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755430Ab1BDByN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 20:54:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/mroute6.h |    1 +
 net/ipv6/ip6mr.c        |   74 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c          |   18 +++++++++++
 3 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 6091ab7..9d2deb2 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -136,6 +136,7 @@ extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, unsigned int
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
+extern int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
 extern int ip6_mr_init(void);
 extern void ip6_mr_cleanup(void);
 #else
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 9fab274..5c07092 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1804,6 +1804,80 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	}
 }
 
+#ifdef CONFIG_COMPAT
+struct compat_sioc_sg_req6 {
+	struct sockaddr_in6 src;
+	struct sockaddr_in6 grp;
+	compat_ulong_t pktcnt;
+	compat_ulong_t bytecnt;
+	compat_ulong_t wrong_if;
+};
+
+struct compat_sioc_mif_req6 {
+	mifi_t	mifi;
+	compat_ulong_t icount;
+	compat_ulong_t ocount;
+	compat_ulong_t ibytes;
+	compat_ulong_t obytes;
+};
+
+int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
+{
+	struct compat_sioc_sg_req6 sr;
+	struct compat_sioc_mif_req6 vr;
+	struct mif_device *vif;
+	struct mfc6_cache *c;
+	struct net *net = sock_net(sk);
+	struct mr6_table *mrt;
+
+	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
+	if (mrt == NULL)
+		return -ENOENT;
+
+	switch (cmd) {
+	case SIOCGETMIFCNT_IN6:
+		if (copy_from_user(&vr, arg, sizeof(vr)))
+			return -EFAULT;
+		if (vr.mifi >= mrt->maxvif)
+			return -EINVAL;
+		read_lock(&mrt_lock);
+		vif = &mrt->vif6_table[vr.mifi];
+		if (MIF_EXISTS(mrt, vr.mifi)) {
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
+	case SIOCGETSGCNT_IN6:
+		if (copy_from_user(&sr, arg, sizeof(sr)))
+			return -EFAULT;
+
+		read_lock(&mrt_lock);
+		c = ip6mr_cache_find(mrt, &sr.src.sin6_addr, &sr.grp.sin6_addr);
+		if (c) {
+			sr.pktcnt = c->mfc_un.res.pkt;
+			sr.bytecnt = c->mfc_un.res.bytes;
+			sr.wrong_if = c->mfc_un.res.wrong_if;
+			read_unlock(&mrt_lock);
+
+			if (copy_to_user(arg, &sr, sizeof(sr)))
+				return -EFAULT;
+			return 0;
+		}
+		read_unlock(&mrt_lock);
+		return -EADDRNOTAVAIL;
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+#endif
 
 static inline int ip6mr_forward2_finish(struct sk_buff *skb)
 {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 86c3952..e728804 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1157,6 +1157,23 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	}
 }
 
+#ifdef CONFIG_COMPAT
+static int compat_rawv6_ioctl(struct sock *sk, unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCOUTQ:
+	case SIOCINQ:
+		return -ENOIOCTLCMD;
+	default:
+#ifdef CONFIG_IPV6_MROUTE
+		return ipmr6_compat_ioctl(sk, cmd, compat_ptr(arg));
+#else
+		return -ENOIOCTLCMD;
+#endif
+	}
+}
+#endif
+
 static void rawv6_close(struct sock *sk, long timeout)
 {
 	if (inet_sk(sk)->inet_num == IPPROTO_RAW)
@@ -1215,6 +1232,7 @@ struct proto rawv6_prot = {
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_rawv6_setsockopt,
 	.compat_getsockopt = compat_rawv6_getsockopt,
+	.compat_ioctl	   = compat_rawv6_ioctl,
 #endif
 };
 
-- 
1.7.4

