From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2 1/2] ipv4,fib: pass LOOPBACK_IFINDEX instead of 0 to flowi4_iif
Date: Tue, 15 Apr 2014 16:25:34 -0700
Message-ID: <1397604335-12752-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1397604335-12752-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:42000 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaDOX0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 19:26:03 -0400
Received: by mail-pb0-f42.google.com with SMTP id rr13so10196004pbb.29
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 16:26:02 -0700 (PDT)
In-Reply-To: <1397604335-12752-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <cwang@twopensource.com>

As suggested by Julian:

	Simply, flowi4_iif must not contain 0, it does not
	look logical to ignore all ip rules with specified iif.

because in fib_rule_match() we do:

        if (rule->iifindex && (rule->iifindex !=3D fl->flowi_iif))
                goto out;

flowi4_iif should be LOOPBACK_IFINDEX by default.

We need to move LOOPBACK_IFINDEX to include/net/flow.h:

1) It is mostly used by flowi_iif

2) Fix the following compile error if we use it in flow.h
by the patches latter:

In file included from include/linux/netfilter.h:277:0,
                 from include/net/netns/netfilter.h:5,
                 from include/net/net_namespace.h:21,
                 from include/linux/netdevice.h:43,
                 from include/linux/icmpv6.h:12,
                 from include/linux/ipv6.h:61,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:27,
                 from include/linux/nfs_fs.h:30,
                 from init/do_mounts.c:32:
include/net/flow.h: In function =E2=80=98flowi4_init_output=E2=80=99:
include/net/flow.h:84:32: error: =E2=80=98LOOPBACK_IFINDEX=E2=80=99 und=
eclared (first use in this function)

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 include/net/flow.h                | 10 +++++++++-
 include/net/net_namespace.h       |  9 +--------
 net/ipv4/fib_frontend.c           |  2 +-
 net/ipv4/fib_semantics.c          |  1 +
 net/ipv4/ipmr.c                   |  2 +-
 net/ipv4/netfilter/ipt_rpfilter.c |  5 +----
 net/ipv6/ip6mr.c                  |  2 +-
 7 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 64fd248..8109a15 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -11,6 +11,14 @@
 #include <linux/in6.h>
 #include <linux/atomic.h>
=20
+/*
+ * ifindex generation is per-net namespace, and loopback is
+ * always the 1st device in ns (see net_dev_init), thus any
+ * loopback device should get ifindex 1
+ */
+
+#define LOOPBACK_IFINDEX	1
+
 struct flowi_common {
 	int	flowic_oif;
 	int	flowic_iif;
@@ -80,7 +88,7 @@ static inline void flowi4_init_output(struct flowi4 *=
fl4, int oif,
 				      __be16 dport, __be16 sport)
 {
 	fl4->flowi4_oif =3D oif;
-	fl4->flowi4_iif =3D 0;
+	fl4->flowi4_iif =3D LOOPBACK_IFINDEX;
 	fl4->flowi4_mark =3D mark;
 	fl4->flowi4_tos =3D tos;
 	fl4->flowi4_scope =3D scope;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 79387f7..5f9eb26 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -9,6 +9,7 @@
 #include <linux/list.h>
 #include <linux/sysctl.h>
=20
+#include <net/flow.h>
 #include <net/netns/core.h>
 #include <net/netns/mib.h>
 #include <net/netns/unix.h>
@@ -131,14 +132,6 @@ struct net {
 	atomic_t		fnhe_genid;
 };
=20
-/*
- * ifindex generation is per-net namespace, and loopback is
- * always the 1st device in ns (see net_dev_init), thus any
- * loopback device should get ifindex 1
- */
-
-#define LOOPBACK_IFINDEX	1
-
 #include <linux/seq_file_net.h>
=20
 /* Init's network namespace */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1a629f8..255aa99 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -250,7 +250,7 @@ static int __fib_validate_source(struct sk_buff *sk=
b, __be32 src, __be32 dst,
 	bool dev_match;
=20
 	fl4.flowi4_oif =3D 0;
-	fl4.flowi4_iif =3D oif;
+	fl4.flowi4_iif =3D oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr =3D src;
 	fl4.saddr =3D dst;
 	fl4.flowi4_tos =3D tos;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b53f0bf..8a043f0 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -631,6 +631,7 @@ static int fib_check_nh(struct fib_config *cfg, str=
uct fib_info *fi,
 				.daddr =3D nh->nh_gw,
 				.flowi4_scope =3D cfg->fc_scope + 1,
 				.flowi4_oif =3D nh->nh_oif,
+				.flowi4_iif =3D LOOPBACK_IFINDEX,
 			};
=20
 			/* It is not necessary, but requires a bit of thinking */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 2886357..d84dc8d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -455,7 +455,7 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb=
, struct net_device *dev)
 	struct mr_table *mrt;
 	struct flowi4 fl4 =3D {
 		.flowi4_oif	=3D dev->ifindex,
-		.flowi4_iif	=3D skb->skb_iif,
+		.flowi4_iif	=3D skb->skb_iif ? : LOOPBACK_IFINDEX,
 		.flowi4_mark	=3D skb->mark,
 	};
 	int err;
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt=
_rpfilter.c
index c49dcd0..4bfaedf 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -89,11 +89,8 @@ static bool rpfilter_mt(const struct sk_buff *skb, s=
truct xt_action_param *par)
 	if (ipv4_is_multicast(iph->daddr)) {
 		if (ipv4_is_zeronet(iph->saddr))
 			return ipv4_is_local_multicast(iph->daddr) ^ invert;
-		flow.flowi4_iif =3D 0;
-	} else {
-		flow.flowi4_iif =3D LOOPBACK_IFINDEX;
 	}
-
+	flow.flowi4_iif =3D LOOPBACK_IFINDEX;
 	flow.daddr =3D iph->saddr;
 	flow.saddr =3D rpfilter_get_saddr(iph->daddr);
 	flow.flowi4_oif =3D 0;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 8737400..8659067 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -700,7 +700,7 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb=
,
 	struct mr6_table *mrt;
 	struct flowi6 fl6 =3D {
 		.flowi6_oif	=3D dev->ifindex,
-		.flowi6_iif	=3D skb->skb_iif,
+		.flowi6_iif	=3D skb->skb_iif ? : LOOPBACK_IFINDEX,
 		.flowi6_mark	=3D skb->mark,
 	};
 	int err;
--=20
1.8.3.1
