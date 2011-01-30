From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Add compat ioctl support for the ipv4 multicast ioctl SIOCGETSGCNT
Date: Sat, 29 Jan 2011 18:15:56 -0800
Message-ID: <m18vy3uof7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57952 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab1A3CQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 21:16:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


SIOCGETSGCNT is not a unique ioctl value as it it maps tio SIOCPROTOPRIVATE +1,
which unfortunately means the existing infrastructure for compat networking
ioctls is insufficient.  A trivial compact ioctl implementation would conflict
with:

SIOCAX25ADDUID
SIOCAIPXPRISLT
SIOCGETSGCNT_IN6
SIOCGETSGCNT
SIOCRSSCAUSE
SIOCX25SSUBSCRIP
SIOCX25SDTEFACILITIES

To make this work I have updated the compat_ioctl decode path to mirror the
the normal ioctl decode path.  I have added an ipv4 inet_compat_ioctl function
so that I can have ipv4 specific compat ioctls.   I have added a compat_ioctl
function into struct proto so I can break out ioctls by which kind of ip socket
I am using.  I have added a compat_raw_ioctl function because SIOCGETSGCNT only
works on raw sockets.  I have added a ipmr_compat_ioctl that mirrors the normal
ipmr_ioctl.

This was necessary because unfortunately the struct layout for the SIOCGETSGCNT
has unsigned longs in it so changes between 32bit and 64bit kernels.

This change was sufficient to run a 32bit ip multicast routing daemon on a
64bit kernel.

Reported-by: Bill Fenner <fenner@aristanetworks.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/mroute.h |    1 +
 include/net/sock.h     |    2 ++
 net/ipv4/af_inet.c     |   16 ++++++++++++++++
 net/ipv4/ipmr.c        |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/raw.c         |   19 +++++++++++++++++++
 5 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 0fa7a3a..b21d567 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -150,6 +150,7 @@ static inline int ip_mroute_opt(int opt)
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, unsigned int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
+extern int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
 extern int ip_mr_init(void);
 #else
 static inline
diff --git a/include/net/sock.h b/include/net/sock.h
index 73a4f97..221212e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -734,6 +734,8 @@ struct proto {
 					int level,
 					int optname, char __user *optval,
 					int __user *option);
+	int			(*compat_ioctl)(struct sock *sk,
+					unsigned int cmd, unsigned long arg);
 #endif
 	int			(*sendmsg)(struct kiocb *iocb, struct sock *sk,
 					   struct msghdr *msg, size_t len);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f581f77..8bda7c9 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -880,6 +880,19 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 }
 EXPORT_SYMBOL(inet_ioctl);
 
+#ifdef CONFIG_COMPAT
+int inet_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct sock *sk = sock->sk;
+	int err = -ENOIOCTLCMD;
+
+	if (sk->sk_prot->compat_ioctl)
+		err = sk->sk_prot->compat_ioctl(sk, cmd, arg);
+
+	return err;
+}
+#endif
+
 const struct proto_ops inet_stream_ops = {
 	.family		   = PF_INET,
 	.owner		   = THIS_MODULE,
@@ -903,6 +916,7 @@ const struct proto_ops inet_stream_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
+	.compat_ioctl	   = inet_compat_ioctl,
 #endif
 };
 EXPORT_SYMBOL(inet_stream_ops);
@@ -929,6 +943,7 @@ const struct proto_ops inet_dgram_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
+	.compat_ioctl	   = inet_compat_ioctl,
 #endif
 };
 EXPORT_SYMBOL(inet_dgram_ops);
@@ -959,6 +974,7 @@ static const struct proto_ops inet_sockraw_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
+	.compat_ioctl	   = inet_compat_ioctl,
 #endif
 };
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 86dd569..b294da7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -60,6 +60,7 @@
 #include <linux/notifier.h>
 #include <linux/if_arp.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/compat.h>
 #include <net/ipip.h>
 #include <net/checksum.h>
 #include <net/netlink.h>
@@ -1434,6 +1435,51 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	}
 }
 
+#ifdef CONFIG_COMPAT
+struct compat_sioc_sg_req {
+	struct in_addr src;
+	struct in_addr grp;
+	compat_ulong_t pktcnt;
+	compat_ulong_t bytecnt;
+	compat_ulong_t wrong_if;
+};
+
+int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
+{
+	struct sioc_sg_req sr;
+	struct mfc_cache *c;
+	struct net *net = sock_net(sk);
+	struct mr_table *mrt;
+
+	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
+	if (mrt == NULL)
+		return -ENOENT;
+
+	switch (cmd) {
+	case SIOCGETSGCNT:
+		if (copy_from_user(&sr, arg, sizeof(sr)))
+			return -EFAULT;
+
+		rcu_read_lock();
+		c = ipmr_cache_find(mrt, sr.src.s_addr, sr.grp.s_addr);
+		if (c) {
+			sr.pktcnt = c->mfc_un.res.pkt;
+			sr.bytecnt = c->mfc_un.res.bytes;
+			sr.wrong_if = c->mfc_un.res.wrong_if;
+			rcu_read_unlock();
+
+			if (copy_to_user(arg, &sr, sizeof(sr)))
+				return -EFAULT;
+			return 0;
+		}
+		rcu_read_unlock();
+		return -EADDRNOTAVAIL;
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+#endif
+
 
 static int ipmr_device_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1f85ef2..f5967b0 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -76,6 +76,7 @@
 #include <linux/seq_file.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/compat.h>
 
 static struct raw_hashinfo raw_v4_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
@@ -839,6 +840,23 @@ static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	}
 }
 
+#ifdef CONFIG_COMPAT
+static int compat_raw_ioctl(struct sock *sk, unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCOUTQ:
+	case SIOCINQ:
+		return -ENOIOCTLCMD;
+	default:
+#ifdef CONFIG_IP_MROUTE
+		return ipmr_compat_ioctl(sk, cmd, compat_ptr(arg));
+#else
+		return -ENOIOCTLCMD;
+#endif	
+	}
+}
+#endif
+
 struct proto raw_prot = {
 	.name		   = "RAW",
 	.owner		   = THIS_MODULE,
@@ -861,6 +879,7 @@ struct proto raw_prot = {
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_raw_setsockopt,
 	.compat_getsockopt = compat_raw_getsockopt,
+	.compat_ioctl	   = compat_raw_ioctl,
 #endif
 };
 
-- 
1.6.5.2.143.g8cc62

