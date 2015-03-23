From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/8] ipv6: introduce secret_stable to ipv6_devconf
Date: Mon, 23 Mar 2015 18:01:56 +0100
Message-ID: <d0eb70f70680a965b5808e2e4cecf3d5bab49a4d.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:47714 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752876AbbCWRCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:02:11 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 1578820915
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 13:02:08 -0400 (EDT)
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427129103.git.hannes@stressinduktion.org>
References: <cover.1427129103.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the procfs logic for the stable_address knob: The
secret is formatted as an ipv6 address and will be stored per interface
and per namespace (default and all slots). We track initialized flag
and return EIO errors until the secret is set.

We don't inherit the secret to newly created namespaces.

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/ipv6.h      |  4 +++
 include/uapi/linux/ipv6.h |  1 +
 net/ipv6/addrconf.c       | 68 +++++++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 73 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4d5169f..82806c6 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -53,6 +53,10 @@ struct ipv6_devconf {
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
 	__s32		accept_ra_mtu;
+	struct ipv6_stable_secret {
+		bool initialized;
+		struct in6_addr secret;
+	} stable_secret;
 	void		*sysctl;
 };
=20
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 437a6a4..5efa54a 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -170,6 +170,7 @@ enum {
 	DEVCONF_ACCEPT_RA_FROM_LOCAL,
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
+	DEVCONF_STABLE_SECRET,
 	DEVCONF_MAX
 };
=20
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 158378e..5b967c8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -46,6 +46,7 @@
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/net.h>
+#include <linux/inet.h>
 #include <linux/in6.h>
 #include <linux/netdevice.h>
 #include <linux/if_addr.h>
@@ -102,6 +103,9 @@
=20
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
=20
+#define IPV6_MAX_STRLEN \
+	sizeof("ffff:ffff:ffff:ffff:ffff:ffff:255.255.255.255")
+
 static inline u32 cstamp_delta(unsigned long cstamp)
 {
 	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
@@ -202,6 +206,9 @@ static struct ipv6_devconf ipv6_devconf __read_most=
ly =3D {
 	.accept_dad		=3D 1,
 	.suppress_frag_ndisc	=3D 1,
 	.accept_ra_mtu		=3D 1,
+	.stable_secret		=3D {
+		.initialized =3D false,
+	}
 };
=20
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly =3D {
@@ -240,6 +247,9 @@ static struct ipv6_devconf ipv6_devconf_dflt __read=
_mostly =3D {
 	.accept_dad		=3D 1,
 	.suppress_frag_ndisc	=3D 1,
 	.accept_ra_mtu		=3D 1,
+	.stable_secret		=3D {
+		.initialized =3D false,
+	},
 };
=20
 /* Check if a valid qdisc is available */
@@ -4430,6 +4440,7 @@ static inline void ipv6_store_devconf(struct ipv6=
_devconf *cnf,
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] =3D cnf->suppress_frag_ndisc;
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] =3D cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] =3D cnf->accept_ra_mtu;
+	/* we omit DEVCONF_STABLE_SECRET for now */
 }
=20
 static inline size_t inet6_ifla6_size(void)
@@ -5074,6 +5085,53 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *=
ctl, int write,
 	return ret;
 }
=20
+static int addrconf_sysctl_stable_secret(struct ctl_table *ctl, int wr=
ite,
+					 void __user *buffer, size_t *lenp,
+					 loff_t *ppos)
+{
+	int err;
+	struct in6_addr addr;
+	char str[IPV6_MAX_STRLEN];
+	struct ctl_table lctl =3D *ctl;
+	struct ipv6_stable_secret *secret =3D ctl->data;
+
+	lctl.maxlen =3D IPV6_MAX_STRLEN;
+	lctl.data =3D str;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (!write && !secret->initialized) {
+		err =3D -EIO;
+		goto out;
+	}
+
+	if (!write) {
+		err =3D snprintf(str, sizeof(str), "%pI6",
+			       &secret->secret);
+		if (err >=3D sizeof(str)) {
+			err =3D -EIO;
+			goto out;
+		}
+	}
+
+	err =3D proc_dostring(&lctl, write, buffer, lenp, ppos);
+	if (err || !write)
+		goto out;
+
+	if (in6_pton(str, -1, addr.in6_u.u6_addr8, -1, NULL) !=3D 1) {
+		err =3D -EIO;
+		goto out;
+	}
+
+	secret->initialized =3D true;
+	secret->secret =3D addr;
+
+out:
+	rtnl_unlock();
+
+	return err;
+}
=20
 static struct addrconf_sysctl_table
 {
@@ -5347,6 +5405,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	=3D proc_dointvec,
 		},
 		{
+			.procname	=3D "stable_secret",
+			.data		=3D &ipv6_devconf.stable_secret,
+			.maxlen		=3D IPV6_MAX_STRLEN,
+			.mode		=3D 0600,
+			.proc_handler	=3D addrconf_sysctl_stable_secret,
+		},
+		{
 			/* sentinel */
 		}
 	},
@@ -5442,6 +5507,9 @@ static int __net_init addrconf_init_net(struct ne=
t *net)
 	dflt->autoconf =3D ipv6_defaults.autoconf;
 	dflt->disable_ipv6 =3D ipv6_defaults.disable_ipv6;
=20
+	dflt->stable_secret.initialized =3D false;
+	all->stable_secret.initialized =3D false;
+
 	net->ipv6.devconf_all =3D all;
 	net->ipv6.devconf_dflt =3D dflt;
=20
--=20
2.1.0
