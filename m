From: Florian Westphal <fw@strlen.de>
Subject: Re: 2.6.35, netfilter/iptables not working with 32bit userspace +
 64bit kernel?
Date: Fri, 13 Aug 2010 14:19:55 +0200
Message-ID: <20100813121955.GI15614@Chamillionaire.breakpoint.cc>
References: <20100813134706.509472n222yo71d6@hayate.sektori.org>
 <1281701885.4470.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1281701885.4470.22.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> CC netfilter-devel to get more people in touch
>=20
> Thanks !
>=20
> Le vendredi 13 ao=FBt 2010 =E0 13:47 +0300, Jussi Kivilinna a =E9crit=
 :
> > Hello!
> >=20
> > I have server/firewall running Debian lenny with 32bit userspace an=
d =20
> > 64bit kernel. After upgrading from 2.6.34 to 2.6.35, I couldn't get=
 =20
> > any new chains work. Simply doing (with 32bit iptables)
> >=20
> >    iptables -N new_chain
> >    iptables -A OUTPUT -j new_chain
> >    iptables -A OUTPUT -j ACCEPT
> >=20
> > cause output to freeze. "iptables -L -vn" shows:
> >=20
> > Chain OUTPUT (policy ACCEPT 3397 packets, 637K bytes)
> >   pkts bytes target     prot opt in     out     source         dest=
ination
> >      3   252 new_chain  all  --  *      *       0.0.0.0/0      0.0.=
0.0/0
> >      0     0 ACCEPT     all  --  *      *       0.0.0.0/0      0.0.=
0.0/0
> >=20
> > Ping shows "ping: sendmsg: Operation not permitted".
> >=20
> > With recompiled 64bit iptables, example above works fine.

You need this patch:

commit f3c5c1bfd430858d3a05436f82c51e53104feb6b
(netfilter: xtables: make ip_tables reentrant) forgot to
also compute the jumpstack size in the compat handlers.

Result is that "iptables -I INPUT -j userchain" turns into -j DROP.

Reported by Sebastian Roesner on #netfilter, closes
http://bugzilla.netfilter.org/show_bug.cgi?id=3D669.

Note: arptables change is compile-tested only.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/netfilter/arp_tables.c |    3 +++
 net/ipv4/netfilter/ip_tables.c  |    3 +++
 net/ipv6/netfilter/ip6_tables.c |    3 +++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 6bccba3..4829766 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1418,6 +1418,9 @@ static int translate_compat_table(const char *nam=
e,
 		if (ret !=3D 0)
 			break;
 		++i;
+		if (strcmp(arpt_get_target(iter1)->u.user.name,
+		    XT_ERROR_TARGET) =3D=3D 0)
+			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index c439721..3d3b695 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1749,6 +1749,9 @@ translate_compat_table(struct net *net,
 		if (ret !=3D 0)
 			break;
 		++i;
+		if (strcmp(ipt_get_target(iter1)->u.user.name,
+		    XT_ERROR_TARGET) =3D=3D 0)
+			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index 5359ef4..bad3c7f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1764,6 +1764,9 @@ translate_compat_table(struct net *net,
 		if (ret !=3D 0)
 			break;
 		++i;
+		if (strcmp(ip6t_get_target(iter1)->u.user.name,
+		    XT_ERROR_TARGET) =3D=3D 0)
+			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
--=20
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
