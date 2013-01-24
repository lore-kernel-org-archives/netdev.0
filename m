From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ipv4: introduce address lifetime
Date: Thu, 24 Jan 2013 20:41:41 +0100
Message-ID: <1359056501-6752-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, edumazet@google.com,
	stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	psimerda@redhat.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	nhorman@tuxdriver.com, dcbw@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39171 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab3AXTls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 14:41:48 -0500
Received: by mail-wi0-f178.google.com with SMTP id hn3so799532wib.17
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 11:41:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some usecase when lifetime of ipv4 addresses might be helpful=
=2E
=46or example:
1) initramfs networkmanager uses a DHCP daemon to learn network
configuration parameters
2) initramfs networkmanager addresses, routes and DNS configuration
3) initramfs networkmanager is requested to stop
4) initramfs networkmanager stops all daemons including dhclient
5) there are addresses and routes configured but no daemon running. If
the system doesn't start networkmanager for some reason, addresses and
routes will be used forever, which violates RFC 2131.

This patch is essentially a backport of ivp6 address lifetime mechanism
for ipv4 addresses.

Current "ip" tool supports this without any patch (since it does not
distinguish between ipv4 and ipv6 addresses in this perspective.

Also, this should be back-compatible with all current netlink users.

Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/inetdevice.h |   6 ++
 include/net/addrconf.h     |   4 +
 net/ipv4/devinet.c         | 215 +++++++++++++++++++++++++++++++++++++=
++++++--
 net/ipv6/addrconf.c        |   4 -
 4 files changed, 220 insertions(+), 9 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index a9d8289..ea1e3b8 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -166,6 +166,12 @@ struct in_ifaddr {
 	unsigned char		ifa_flags;
 	unsigned char		ifa_prefixlen;
 	char			ifa_label[IFNAMSIZ];
+
+	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
+	__u32			ifa_valid_lft;
+	__u32			ifa_preferred_lft;
+	unsigned long		ifa_cstamp; /* created timestamp */
+	unsigned long		ifa_tstamp; /* updated timestamp */
 };
=20
 extern int register_inetaddr_notifier(struct notifier_block *nb);
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 6c58d50..40be2a0 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -15,6 +15,10 @@
=20
 #define IPV6_MAX_ADDRESSES		16
=20
+#define ADDRCONF_TIMER_FUZZ_MINUS	(HZ > 50 ? HZ / 50 : 1)
+#define ADDRCONF_TIMER_FUZZ		(HZ / 4)
+#define ADDRCONF_TIMER_FUZZ_MAX		(HZ)
+
 #include <linux/in.h>
 #include <linux/in6.h>
=20
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a8e4f26..5281314 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -63,6 +63,7 @@
 #include <net/ip_fib.h>
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
+#include <net/addrconf.h>
=20
 #include "fib_lookup.h"
=20
@@ -93,6 +94,7 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MA=
X+1] =3D {
 	[IFA_ADDRESS]   	=3D { .type =3D NLA_U32 },
 	[IFA_BROADCAST] 	=3D { .type =3D NLA_U32 },
 	[IFA_LABEL]     	=3D { .type =3D NLA_STRING, .len =3D IFNAMSIZ - 1 },
+	[IFA_CACHEINFO]		=3D { .len =3D sizeof(struct ifa_cacheinfo) },
 };
=20
 #define IN4_ADDR_HSIZE_SHIFT	8
@@ -417,6 +419,10 @@ static void inet_del_ifa(struct in_device *in_dev,=
 struct in_ifaddr **ifap,
 	__inet_del_ifa(in_dev, ifap, destroy, NULL, 0);
 }
=20
+static void check_lifetime(struct work_struct *work);
+
+static DECLARE_DELAYED_WORK(check_lifetime_work, check_lifetime);
+
 static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *n=
lh,
 			     u32 portid)
 {
@@ -462,6 +468,9 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa,=
 struct nlmsghdr *nlh,
=20
 	inet_hash_insert(dev_net(in_dev->dev), ifa);
=20
+	cancel_delayed_work(&check_lifetime_work);
+	schedule_delayed_work(&check_lifetime_work, 0);
+
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
 	   listeners of netlink will know about new ifaddr */
@@ -573,7 +582,107 @@ errout:
 	return err;
 }
=20
-static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghd=
r *nlh)
+#define INFINITY_LIFE_TIME	0xFFFFFFFF
+
+static void check_lifetime(struct work_struct *work)
+{
+	unsigned long now, next, next_sec, next_sched;
+	struct in_ifaddr *ifa;
+	struct hlist_node *node;
+	int i;
+
+	now =3D jiffies;
+	next =3D round_jiffies_up(now + ADDR_CHECK_FREQUENCY);
+
+	rcu_read_lock();
+	for (i =3D 0; i < IN4_ADDR_HSIZE; i++) {
+		hlist_for_each_entry_rcu(ifa, node,
+					 &inet_addr_lst[i], hash) {
+			unsigned long age;
+
+			if (ifa->ifa_flags & IFA_F_PERMANENT)
+				continue;
+
+			/* We try to batch several events at once. */
+			age =3D (now - ifa->ifa_tstamp +
+			       ADDRCONF_TIMER_FUZZ_MINUS) / HZ;
+
+			if (ifa->ifa_valid_lft !=3D INFINITY_LIFE_TIME &&
+			    age >=3D ifa->ifa_valid_lft) {
+				struct in_ifaddr **ifap ;
+
+				rtnl_lock();
+				for (ifap =3D &ifa->ifa_dev->ifa_list;
+				     *ifap !=3D NULL; ifap =3D &ifa->ifa_next) {
+					if (*ifap =3D=3D ifa)
+						inet_del_ifa(ifa->ifa_dev,
+							     ifap, 1);
+				}
+				rtnl_unlock();
+			} else if (ifa->ifa_preferred_lft =3D=3D
+				   INFINITY_LIFE_TIME) {
+				continue;
+			} else if (age >=3D ifa->ifa_preferred_lft) {
+				if (time_before(ifa->ifa_tstamp +
+						ifa->ifa_valid_lft * HZ, next))
+					next =3D ifa->ifa_tstamp +
+					       ifa->ifa_valid_lft * HZ;
+
+				if (!(ifa->ifa_flags & IFA_F_DEPRECATED)) {
+					ifa->ifa_flags |=3D IFA_F_DEPRECATED;
+					rtmsg_ifa(RTM_NEWADDR, ifa, NULL, 0);
+				}
+			} else if (time_before(ifa->ifa_tstamp +
+					       ifa->ifa_preferred_lft * HZ,
+					       next)) {
+				next =3D ifa->ifa_tstamp +
+				       ifa->ifa_preferred_lft * HZ;
+			}
+		}
+	}
+	rcu_read_unlock();
+
+	next_sec =3D round_jiffies_up(next);
+	next_sched =3D next;
+
+	/* If rounded timeout is accurate enough, accept it. */
+	if (time_before(next_sec, next + ADDRCONF_TIMER_FUZZ))
+		next_sched =3D next_sec;
+
+	now =3D jiffies;
+	/* And minimum interval is ADDRCONF_TIMER_FUZZ_MAX. */
+	if (time_before(next_sched, now + ADDRCONF_TIMER_FUZZ_MAX))
+		next_sched =3D now + ADDRCONF_TIMER_FUZZ_MAX;
+
+	schedule_delayed_work(&check_lifetime_work, next_sched - now);
+}
+
+static void set_ifa_lifetime(struct in_ifaddr *ifa, __u32 valid_lft,
+			     __u32 prefered_lft)
+{
+	unsigned long timeout;
+
+	ifa->ifa_flags &=3D ~(IFA_F_PERMANENT | IFA_F_DEPRECATED);
+
+	timeout =3D addrconf_timeout_fixup(valid_lft, HZ);
+	if (addrconf_finite_timeout(timeout))
+		ifa->ifa_valid_lft =3D timeout;
+	else
+		ifa->ifa_flags |=3D IFA_F_PERMANENT;
+
+	timeout =3D addrconf_timeout_fixup(prefered_lft, HZ);
+	if (addrconf_finite_timeout(timeout)) {
+		if (timeout =3D=3D 0)
+			ifa->ifa_flags |=3D IFA_F_DEPRECATED;
+		ifa->ifa_preferred_lft =3D timeout;
+	}
+	ifa->ifa_tstamp =3D jiffies;
+	if (!ifa->ifa_cstamp)
+		ifa->ifa_cstamp =3D ifa->ifa_tstamp;
+}
+
+static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghd=
r *nlh,
+				       __u32 *pvalid_lft, __u32 *pprefered_lft)
 {
 	struct nlattr *tb[IFA_MAX+1];
 	struct in_ifaddr *ifa;
@@ -633,24 +742,73 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net=
 *net, struct nlmsghdr *nlh)
 	else
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
=20
+	if (tb[IFA_CACHEINFO]) {
+		struct ifa_cacheinfo *ci;
+
+		ci =3D nla_data(tb[IFA_CACHEINFO]);
+		if (!ci->ifa_valid || ci->ifa_prefered > ci->ifa_valid) {
+			err =3D -EINVAL;
+			goto errout;
+		}
+		*pvalid_lft =3D ci->ifa_valid;
+		*pprefered_lft =3D ci->ifa_prefered;
+	}
+
 	return ifa;
=20
 errout:
 	return ERR_PTR(err);
 }
=20
+static struct in_ifaddr *find_matching_ifa(struct in_ifaddr *ifa)
+{
+	struct in_device *in_dev =3D ifa->ifa_dev;
+	struct in_ifaddr *ifa1, **ifap;
+
+	if (!ifa->ifa_local)
+		return NULL;
+
+	for (ifap =3D &in_dev->ifa_list; (ifa1 =3D *ifap) !=3D NULL;
+	     ifap =3D &ifa1->ifa_next) {
+		if (ifa1->ifa_mask =3D=3D ifa->ifa_mask &&
+		    inet_ifa_match(ifa1->ifa_address, ifa) &&
+		    ifa1->ifa_local =3D=3D ifa->ifa_local)
+			return ifa1;
+	}
+	return NULL;
+}
+
 static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,=
 void *arg)
 {
 	struct net *net =3D sock_net(skb->sk);
 	struct in_ifaddr *ifa;
+	struct in_ifaddr *ifa_existing;
+	__u32 valid_lft =3D INFINITY_LIFE_TIME;
+	__u32 prefered_lft =3D INFINITY_LIFE_TIME;
=20
 	ASSERT_RTNL();
=20
-	ifa =3D rtm_to_ifaddr(net, nlh);
+	ifa =3D rtm_to_ifaddr(net, nlh, &valid_lft, &prefered_lft);
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
=20
-	return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
+	ifa_existing =3D find_matching_ifa(ifa);
+	if (!ifa_existing) {
+		/* It would be best to check for !NLM_F_CREATE here but
+		 * userspace alreay relies on not having to provide this.
+		 */
+		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
+		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
+	} else {
+		inet_free_ifa(ifa);
+
+		if (nlh->nlmsg_flags & NLM_F_EXCL ||
+		    !(nlh->nlmsg_flags & NLM_F_REPLACE))
+			return -EEXIST;
+
+		set_ifa_lifetime(ifa_existing, valid_lft, prefered_lft);
+	}
+	return 0;
 }
=20
 /*
@@ -852,6 +1010,7 @@ int devinet_ioctl(struct net *net, unsigned int cm=
d, void __user *arg)
 			ifa->ifa_prefixlen =3D 32;
 			ifa->ifa_mask =3D inet_make_mask(32);
 		}
+		set_ifa_lifetime(ifa, INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 		ret =3D inet_set_ifa(dev, ifa);
 		break;
=20
@@ -1190,6 +1349,8 @@ static int inetdev_event(struct notifier_block *t=
his, unsigned long event,
 				ifa->ifa_dev =3D in_dev;
 				ifa->ifa_scope =3D RT_SCOPE_HOST;
 				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
+				set_ifa_lifetime(ifa, INFINITY_LIFE_TIME,
+						 INFINITY_LIFE_TIME);
 				inet_insert_ifa(ifa);
 			}
 		}
@@ -1246,11 +1407,30 @@ static size_t inet_nlmsg_size(void)
 	       + nla_total_size(IFNAMSIZ); /* IFA_LABEL */
 }
=20
+static inline u32 cstamp_delta(unsigned long cstamp)
+{
+	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
+}
+
+static int put_cacheinfo(struct sk_buff *skb, unsigned long cstamp,
+			 unsigned long tstamp, u32 preferred, u32 valid)
+{
+	struct ifa_cacheinfo ci;
+
+	ci.cstamp =3D cstamp_delta(cstamp);
+	ci.tstamp =3D cstamp_delta(tstamp);
+	ci.ifa_prefered =3D preferred;
+	ci.ifa_valid =3D valid;
+
+	return nla_put(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+}
+
 static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa=
,
 			    u32 portid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
+	u32 preferred, valid;
=20
 	nlh =3D nlmsg_put(skb, portid, seq, event, sizeof(*ifm), flags);
 	if (nlh =3D=3D NULL)
@@ -1259,10 +1439,31 @@ static int inet_fill_ifaddr(struct sk_buff *skb=
, struct in_ifaddr *ifa,
 	ifm =3D nlmsg_data(nlh);
 	ifm->ifa_family =3D AF_INET;
 	ifm->ifa_prefixlen =3D ifa->ifa_prefixlen;
-	ifm->ifa_flags =3D ifa->ifa_flags|IFA_F_PERMANENT;
+	ifm->ifa_flags =3D ifa->ifa_flags;
 	ifm->ifa_scope =3D ifa->ifa_scope;
 	ifm->ifa_index =3D ifa->ifa_dev->dev->ifindex;
=20
+	if (!(ifm->ifa_flags & IFA_F_PERMANENT)) {
+		preferred =3D ifa->ifa_preferred_lft;
+		valid =3D ifa->ifa_valid_lft;
+		if (preferred !=3D INFINITY_LIFE_TIME) {
+			long tval =3D (jiffies - ifa->ifa_tstamp) / HZ;
+
+			if (preferred > tval)
+				preferred -=3D tval;
+			else
+				preferred =3D 0;
+			if (valid !=3D INFINITY_LIFE_TIME) {
+				if (valid > tval)
+					valid -=3D tval;
+				else
+					valid =3D 0;
+			}
+		}
+	} else {
+		preferred =3D INFINITY_LIFE_TIME;
+		valid =3D INFINITY_LIFE_TIME;
+	}
 	if ((ifa->ifa_address &&
 	     nla_put_be32(skb, IFA_ADDRESS, ifa->ifa_address)) ||
 	    (ifa->ifa_local &&
@@ -1270,7 +1471,9 @@ static int inet_fill_ifaddr(struct sk_buff *skb, =
struct in_ifaddr *ifa,
 	    (ifa->ifa_broadcast &&
 	     nla_put_be32(skb, IFA_BROADCAST, ifa->ifa_broadcast)) ||
 	    (ifa->ifa_label[0] &&
-	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)))
+	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)) ||
+	    put_cacheinfo(skb, ifa->ifa_cstamp, ifa->ifa_tstamp,
+			  preferred, valid))
 		goto nla_put_failure;
=20
 	return nlmsg_end(skb, nlh);
@@ -1988,6 +2191,8 @@ void __init devinet_init(void)
 	register_gifconf(PF_INET, inet_gifconf);
 	register_netdevice_notifier(&ip_netdev_notifier);
=20
+	schedule_delayed_work(&check_lifetime_work, 0);
+
 	rtnl_af_register(&inet_af_ops);
=20
 	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL, NULL);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 80d5980..7f7332b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -110,10 +110,6 @@ static inline u32 cstamp_delta(unsigned long cstam=
p)
 	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
 }
=20
-#define ADDRCONF_TIMER_FUZZ_MINUS	(HZ > 50 ? HZ/50 : 1)
-#define ADDRCONF_TIMER_FUZZ		(HZ / 4)
-#define ADDRCONF_TIMER_FUZZ_MAX		(HZ)
-
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
--=20
1.8.1
