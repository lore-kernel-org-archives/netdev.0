From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 7/8] ipv6: introduce idgen_delay and idgen_retries knobs
Date: Mon, 23 Mar 2015 18:02:01 +0100
Message-ID: <e30867bb91318b02b48b6a5f8891371f86bbcbec.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:37832 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752366AbbCWRCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:02:15 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id B71E520A25
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 13:02:12 -0400 (EDT)
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is specified by RFC 7217.

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/netns/ipv6.h   |  2 ++
 net/ipv6/addrconf.c        | 11 ++++-------
 net/ipv6/af_inet6.c        |  2 ++
 net/ipv6/sysctl_net_ipv6.c | 16 ++++++++++++++++
 4 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index ca0db12..d2527bf 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -32,6 +32,8 @@ struct netns_sysctl_ipv6 {
 	int icmpv6_time;
 	int anycast_src_echo_reply;
 	int fwmark_reflect;
+	int idgen_retries;
+	int idgen_delay;
 };
=20
 struct netns_ipv6 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9b51fdb..d2d2383 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1712,6 +1712,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *if=
p)
 {
 	struct in6_addr addr;
 	struct inet6_dev *idev =3D ifp->idev;
+	struct net *net =3D dev_net(ifp->idev->dev);
=20
 	if (addrconf_dad_end(ifp)) {
 		in6_ifa_put(ifp);
@@ -1730,11 +1731,9 @@ void addrconf_dad_failure(struct inet6_ifaddr *i=
fp)
 		struct inet6_ifaddr *ifp2;
 		u32 valid_lft, preferred_lft;
 		int pfxlen =3D ifp->prefix_len;
-		const unsigned int idgen_retries =3D 3;
-		const unsigned int idgen_delay =3D 1 * HZ;
 		int retries =3D ifp->stable_privacy_retry + 1;
=20
-		if (retries > idgen_retries) {
+		if (retries > net->ipv6.sysctl.idgen_retries) {
 			net_info_ratelimited("%s: privacy stable address generation failed =
because of DAD conflicts!\n",
 					     ifp->idev->dev->name);
 			goto errdad;
@@ -1769,7 +1768,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *if=
p)
 		ifp2->state =3D INET6_IFADDR_STATE_PREDAD;
 		spin_unlock_bh(&ifp2->lock);
=20
-		addrconf_mod_dad_work(ifp2, idgen_delay);
+		addrconf_mod_dad_work(ifp2, net->ipv6.sysctl.idgen_delay);
 		in6_ifa_put(ifp2);
 lock_errdad:
 		spin_lock_bh(&ifp->lock);
@@ -2899,8 +2898,6 @@ static int ipv6_generate_stable_address(struct in=
6_addr *address,
 					u8 dad_count,
 					const struct inet6_dev *idev)
 {
-	static const int idgen_retries =3D 3;
-
 	static DEFINE_SPINLOCK(lock);
 	static __u32 digest[SHA_DIGEST_WORDS];
 	static __u32 workspace[SHA_WORKSPACE_WORDS];
@@ -2950,7 +2947,7 @@ retry:
=20
 	if (ipv6_reserved_interfaceid(temp)) {
 		dad_count++;
-		if (dad_count > idgen_retries)
+		if (dad_count > dev_net(idev->dev)->ipv6.sysctl.idgen_retries)
 			return -1;
 		goto retry;
 	}
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6bafcc2..d8dcc52 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,6 +766,8 @@ static int __net_init inet6_net_init(struct net *ne=
t)
 	net->ipv6.sysctl.icmpv6_time =3D 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency =3D 1;
 	net->ipv6.sysctl.auto_flowlabels =3D 0;
+	net->ipv6.sysctl.idgen_retries =3D 3;
+	net->ipv6.sysctl.idgen_delay =3D 1 * HZ;
 	atomic_set(&net->ipv6.fib6_sernum, 1);
=20
 	err =3D ipv6_init_mibs(net);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index c5c10fa..30f5a4a 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -54,6 +54,20 @@ static struct ctl_table ipv6_table_template[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec
 	},
+	{
+		.procname	=3D "idgen_retries",
+		.data		=3D &init_net.ipv6.sysctl.idgen_retries,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec,
+	},
+	{
+		.procname	=3D "idgen_delay",
+		.data		=3D &init_net.ipv6.sysctl.idgen_delay,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_jiffies,
+	},
 	{ }
 };
=20
@@ -93,6 +107,8 @@ static int __net_init ipv6_sysctl_net_init(struct ne=
t *net)
 	ipv6_table[2].data =3D &net->ipv6.sysctl.flowlabel_consistency;
 	ipv6_table[3].data =3D &net->ipv6.sysctl.auto_flowlabels;
 	ipv6_table[4].data =3D &net->ipv6.sysctl.fwmark_reflect;
+	ipv6_table[5].data =3D &net->ipv6.sysctl.idgen_retries;
+	ipv6_table[6].data =3D &net->ipv6.sysctl.idgen_delay;
=20
 	ipv6_route_table =3D ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
--=20
2.1.0
