From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 3/8] ipv6: generation of stable privacy addresses for link-local and autoconf
Date: Mon, 23 Mar 2015 23:36:01 +0100
Message-ID: <582a3ca90a8c9df6dd25df8d4240e70378f7e75c.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50565 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753483AbbCWWgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:36:18 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id ED03720801
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 18:36:14 -0400 (EDT)
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the stable privacy address generation for
link-local and autoconf addresses as specified in RFC7217.

  RID =3D F(Prefix, Net_Iface, Network_ID, DAD_Counter, secret_key)

is the RID (random identifier). As the hash function F we chose one
round of sha1. Prefix will be either the link-local prefix or the
router advertised one. As Net_Iface we use the MAC address of the
device. DAD_Counter and secret_key are implemented as specified.

We don't use Network_ID, as it couples the code too closely to other
subsystems. It is specified as optional in the RFC.

As Net_Iface we only use the MAC address: we simply have no stable
identifier in the kernel we could possibly use: because this code might
run very early, we cannot depend on names, as they might be changed by
user space early on during the boot process.

A new address generation mode is introduced,
IN6_ADDR_GEN_MODE_STABLE_PRIVACY. With iproute2 one can switch back to
none or eui64 address configuration mode although the stable_secret is
already set.

We refuse writes to ipv6/conf/all/stable_secret but only allow
ipv6/conf/default/stable_secret and the interface specific file to be
written to. The default stable_secret is used as the parameter for the
namespace, the interface specific can overwrite the secret, e.g. when
switching a network configuration from one system to another while
inheriting the secret.

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/uapi/linux/if_link.h |   1 +
 net/ipv6/addrconf.c          | 130 +++++++++++++++++++++++++++++++++++=
++++++--
 2 files changed, 127 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
index f5f5edd..7ffb18d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -216,6 +216,7 @@ enum {
 enum in6_addr_gen_mode {
 	IN6_ADDR_GEN_MODE_EUI64,
 	IN6_ADDR_GEN_MODE_NONE,
+	IN6_ADDR_GEN_MODE_STABLE_PRIVACY,
 };
=20
 /* Bridge section */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5b967c8..6813268 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -131,6 +131,9 @@ static void ipv6_regen_rndid(unsigned long data);
=20
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
+static int ipv6_generate_stable_address(struct in6_addr *addr,
+					u8 dad_count,
+					const struct inet6_dev *idev);
=20
 /*
  *	Configured unicast address hash table
@@ -2302,6 +2305,11 @@ void addrconf_prefix_rcv(struct net_device *dev,=
 u8 *opt, int len, bool sllao)
 				       in6_dev->token.s6_addr + 8, 8);
 				read_unlock_bh(&in6_dev->lock);
 				tokenized =3D true;
+			} else if (in6_dev->addr_gen_mode =3D=3D
+				   IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+				   !ipv6_generate_stable_address(&addr, 0,
+								 in6_dev)) {
+				goto ok;
 			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
 				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
 				in6_dev_put(in6_dev);
@@ -2820,12 +2828,98 @@ static void addrconf_add_linklocal(struct inet6=
_dev *idev, const struct in6_addr
 	}
 }
=20
+static bool ipv6_reserved_interfaceid(struct in6_addr address)
+{
+	if ((address.s6_addr32[2] | address.s6_addr32[3]) =3D=3D 0)
+		return true;
+
+	if (address.s6_addr32[2] =3D=3D htonl(0x02005eff) &&
+	    ((address.s6_addr32[3] & htonl(0xfe000000)) =3D=3D htonl(0xfe0000=
00)))
+		return true;
+
+	if (address.s6_addr32[2] =3D=3D htonl(0xfdffffff) &&
+	    ((address.s6_addr32[3] & htonl(0xffffff80)) =3D=3D htonl(0xffffff=
80)))
+		return true;
+
+	return false;
+}
+
+static int ipv6_generate_stable_address(struct in6_addr *address,
+					u8 dad_count,
+					const struct inet6_dev *idev)
+{
+	static const int idgen_retries =3D 3;
+
+	static DEFINE_SPINLOCK(lock);
+	static __u32 digest[SHA_DIGEST_WORDS];
+	static __u32 workspace[SHA_WORKSPACE_WORDS];
+
+	static union {
+		char __data[SHA_MESSAGE_BYTES];
+		struct {
+			struct in6_addr secret;
+			__be64 prefix;
+			unsigned char hwaddr[MAX_ADDR_LEN];
+			u8 dad_count;
+		} __packed;
+	} data;
+
+	struct in6_addr secret;
+	struct in6_addr temp;
+	struct net *net =3D dev_net(idev->dev);
+
+	BUILD_BUG_ON(sizeof(data.__data) !=3D sizeof(data));
+
+	if (idev->cnf.stable_secret.initialized)
+		secret =3D idev->cnf.stable_secret.secret;
+	else if (net->ipv6.devconf_dflt->stable_secret.initialized)
+		secret =3D net->ipv6.devconf_dflt->stable_secret.secret;
+	else
+		return -1;
+
+retry:
+	spin_lock_bh(&lock);
+
+	sha_init(digest);
+	memset(&data, 0, sizeof(data));
+	memset(workspace, 0, sizeof(workspace));
+	memcpy(data.hwaddr, idev->dev->perm_addr, idev->dev->addr_len);
+	data.prefix =3D ((__be64)address->s6_addr32[0] << 32) |
+		       (__be64)address->s6_addr32[1];
+	data.secret =3D secret;
+	data.dad_count =3D dad_count;
+
+	sha_transform(digest, data.__data, workspace);
+
+	temp =3D *address;
+	temp.s6_addr32[2] =3D digest[0];
+	temp.s6_addr32[3] =3D digest[1];
+
+	spin_unlock_bh(&lock);
+
+	if (ipv6_reserved_interfaceid(temp)) {
+		dad_count++;
+		if (dad_count > idgen_retries)
+			return -1;
+		goto retry;
+	}
+
+	*address =3D temp;
+	return 0;
+}
+
 static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_rout=
e)
 {
-	if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_EUI64) {
-		struct in6_addr addr;
+	struct in6_addr addr;
+
+	ipv6_addr_set(&addr, htonl(0xFE800000), 0, 0, 0);
=20
-		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
+	if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY) {
+		if (!ipv6_generate_stable_address(&addr, 0, idev))
+			addrconf_add_linklocal(idev, &addr);
+		else if (prefix_route)
+			addrconf_prefix_route(&addr, 64, idev->dev, 0, 0);
+	} else if (idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_EUI64) {
 		/* addrconf_add_linklocal also adds a prefix_route and we
 		 * only need to care about prefix routes if ipv6_generate_eui64
 		 * couldn't generate one.
@@ -4675,8 +4769,15 @@ static int inet6_set_link_af(struct net_device *=
dev, const struct nlattr *nla)
 		u8 mode =3D nla_get_u8(tb[IFLA_INET6_ADDR_GEN_MODE]);
=20
 		if (mode !=3D IN6_ADDR_GEN_MODE_EUI64 &&
-		    mode !=3D IN6_ADDR_GEN_MODE_NONE)
+		    mode !=3D IN6_ADDR_GEN_MODE_NONE &&
+		    mode !=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY)
+			return -EINVAL;
+
+		if (mode =3D=3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+		    !idev->cnf.stable_secret.initialized &&
+		    !dev_net(dev)->ipv6.devconf_dflt->stable_secret.initialized)
 			return -EINVAL;
+
 		idev->addr_gen_mode =3D mode;
 		err =3D 0;
 	}
@@ -5093,8 +5194,12 @@ static int addrconf_sysctl_stable_secret(struct =
ctl_table *ctl, int write,
 	struct in6_addr addr;
 	char str[IPV6_MAX_STRLEN];
 	struct ctl_table lctl =3D *ctl;
+	struct net *net =3D ctl->extra2;
 	struct ipv6_stable_secret *secret =3D ctl->data;
=20
+	if (&net->ipv6.devconf_all->stable_secret =3D=3D ctl->data)
+		return -EIO;
+
 	lctl.maxlen =3D IPV6_MAX_STRLEN;
 	lctl.data =3D str;
=20
@@ -5127,6 +5232,23 @@ static int addrconf_sysctl_stable_secret(struct =
ctl_table *ctl, int write,
 	secret->initialized =3D true;
 	secret->secret =3D addr;
=20
+	if (&net->ipv6.devconf_dflt->stable_secret =3D=3D ctl->data) {
+		struct net_device *dev;
+
+		for_each_netdev(net, dev) {
+			struct inet6_dev *idev =3D __in6_dev_get(dev);
+
+			if (idev) {
+				idev->addr_gen_mode =3D
+					IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
+			}
+		}
+	} else {
+		struct inet6_dev *idev =3D ctl->extra1;
+
+		idev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
+	}
+
 out:
 	rtnl_unlock();
=20
--=20
2.1.0
