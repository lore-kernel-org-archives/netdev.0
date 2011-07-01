From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2] nfnetlink: add RCU in nfnetlink_rcv_msg()
Date: Fri, 01 Jul 2011 17:27:58 +0200
Message-ID: <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309416426.2532.119.camel@edumazet-laptop>
	 <4E0C278B.7010403@yandex.ru>
	 <1309433652.1994.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E0C651A.1000300@trash.net>
	 <1309446900.1994.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E0C8902.8070303@earthlink.net> <4E0C8D7F.3000902@trash.net>
	 <1309453730.5846.31.camel@tiger.regit.org>
	 <1309455919.2515.3.camel@edumazet-laptop>
	 <1309503610.2515.18.camel@edumazet-laptop>
	 <20110701074936.GR16021@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Leblond <eric@regit.org>, sclark46@earthlink.net,
	Kuzin Andrey <kuzinandrey@yandex.ru>,
	Anders Nilsson Plymoth <lanilsson@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110701074936.GR16021@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 01 juillet 2011 =C3=A0 09:49 +0200, Florian Westphal a =C3=A9=
crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Number one offender is the nfnl_lock mutex hold each time we give a
> > verdict.
>=20
> Yes, the nfnl mutex is fairly annoying for nfqueue.
>=20
> Unfortunately it is not possible to just remove it
> completely since it also protects against module removal.
>=20

I believe it can, just add appropriate synchronization points.

> But I guess even having to grab a refcount would be
> a huge win as opposed to holding on to the nfnl mutex...
>=20
> We'd also need to audit all ->call implementations; most
> of them assume the nfnl_mutex is being hold.

CC netdev

We can do another way : Introduce a new ->call_rcu() implementation
and convert places where we prefer not holding nfnf_mutex.

If/when all places are converted, remove the ->call() field for good.

With following two patches, I was able to reach more than 2.000.000 pps
without losses on my setup (limited by my lab setup), instead of less
than 500.000 pps

Thanks

[PATCH 1/2] nfnetlink: add RCU in nfnetlink_rcv_msg()

Goal of this patch is to permit nfnetlink providers not mandate
nfnl_mutex being held while nfnetlink_rcv_msg() calls them.

If struct nfnl_callback contains a non NULL call_rcu(), then
nfnetlink_rcv_msg() will use it instead of call() field, holding
rcu_read_lock instead of nfnl_mutex

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Florian Westphal <fw@strlen.de>
CC: Eric Leblond <eric@regit.org>
CC: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink.h |    3 +
 net/netfilter/nfnetlink.c           |   40 +++++++++++++++++++-------
 2 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfil=
ter/nfnetlink.h
index 2b11fc1..74d3386 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -60,6 +60,9 @@ struct nfnl_callback {
 	int (*call)(struct sock *nl, struct sk_buff *skb,=20
 		    const struct nlmsghdr *nlh,
 		    const struct nlattr * const cda[]);
+	int (*call_rcu)(struct sock *nl, struct sk_buff *skb,=20
+		    const struct nlmsghdr *nlh,
+		    const struct nlattr * const cda[]);
 	const struct nla_policy *policy;	/* netlink attribute policy */
 	const u_int16_t attr_count;		/* number of nlattr's */
 };
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index b4a4532..1905976 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -37,7 +37,7 @@ MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_NETFILT=
ER);
=20
 static char __initdata nfversion[] =3D "0.30";
=20
-static const struct nfnetlink_subsystem *subsys_table[NFNL_SUBSYS_COUN=
T];
+static const struct nfnetlink_subsystem __rcu *subsys_table[NFNL_SUBSY=
S_COUNT];
 static DEFINE_MUTEX(nfnl_mutex);
=20
 void nfnl_lock(void)
@@ -59,7 +59,7 @@ int nfnetlink_subsys_register(const struct nfnetlink_=
subsystem *n)
 		nfnl_unlock();
 		return -EBUSY;
 	}
-	subsys_table[n->subsys_id] =3D n;
+	rcu_assign_pointer(subsys_table[n->subsys_id], n);
 	nfnl_unlock();
=20
 	return 0;
@@ -71,7 +71,7 @@ int nfnetlink_subsys_unregister(const struct nfnetlin=
k_subsystem *n)
 	nfnl_lock();
 	subsys_table[n->subsys_id] =3D NULL;
 	nfnl_unlock();
-
+	synchronize_rcu();
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nfnetlink_subsys_unregister);
@@ -83,7 +83,7 @@ static inline const struct nfnetlink_subsystem *nfnet=
link_get_subsys(u_int16_t t
 	if (subsys_id >=3D NFNL_SUBSYS_COUNT)
 		return NULL;
=20
-	return subsys_table[subsys_id];
+	return rcu_dereference(subsys_table[subsys_id]);
 }
=20
 static inline const struct nfnl_callback *
@@ -139,21 +139,27 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb,=
 struct nlmsghdr *nlh)
=20
 	type =3D nlh->nlmsg_type;
 replay:
+	rcu_read_lock();
 	ss =3D nfnetlink_get_subsys(type);
 	if (!ss) {
 #ifdef CONFIG_MODULES
-		nfnl_unlock();
+		rcu_read_unlock();
 		request_module("nfnetlink-subsys-%d", NFNL_SUBSYS_ID(type));
-		nfnl_lock();
+		rcu_read_lock();
 		ss =3D nfnetlink_get_subsys(type);
 		if (!ss)
 #endif
+		{
+			rcu_read_unlock();
 			return -EINVAL;
+		}
 	}
=20
 	nc =3D nfnetlink_find_client(type, ss);
-	if (!nc)
+	if (!nc) {
+		rcu_read_unlock();
 		return -EINVAL;
+	}
=20
 	{
 		int min_len =3D NLMSG_SPACE(sizeof(struct nfgenmsg));
@@ -167,7 +173,23 @@ replay:
 		if (err < 0)
 			return err;
=20
-		err =3D nc->call(net->nfnl, skb, nlh, (const struct nlattr **)cda);
+		if (nc->call_rcu) {
+			err =3D nc->call_rcu(net->nfnl, skb, nlh,
+					   (const struct nlattr **)cda);
+			rcu_read_unlock();
+		} else {
+			rcu_read_unlock();
+			nfnl_lock();
+			if (rcu_dereference_protected(
+					subsys_table[NFNL_SUBSYS_ID(type)],
+					lockdep_is_held(&nfnl_mutex)) !=3D ss ||
+			    nfnetlink_find_client(type, ss) !=3D nc)
+				err =3D -EAGAIN;
+			else
+				err =3D nc->call(net->nfnl, skb, nlh,
+						   (const struct nlattr **)cda);
+			nfnl_unlock();
+		}
 		if (err =3D=3D -EAGAIN)
 			goto replay;
 		return err;
@@ -176,9 +198,7 @@ replay:
=20
 static void nfnetlink_rcv(struct sk_buff *skb)
 {
-	nfnl_lock();
 	netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
-	nfnl_unlock();
 }
=20
 static int __net_init nfnetlink_net_init(struct net *net)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
