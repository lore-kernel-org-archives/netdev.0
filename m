From: Fan Du <fan.du@windriver.com>
Subject: [RFC PATCH net-next] net: split rt_genid for ipv4 and ipv6
Date: Mon, 22 Jul 2013 13:43:30 +0800
Message-ID: <51ECC682.1030409@windriver.com>
References: <51E8B273.1090002@windriver.com>	<20130718.203100.1960741588589171145.davem@davemloft.net>	<51E8EFBC.6040902@windriver.com> <20130719.023318.2201887768706444746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <nicolas.dichtel@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<kuznet@ms2.inr.ac.ru>, <yoshfuji@linux-ipv6.org>,
	<jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40368 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3GVFnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 01:43:25 -0400
In-Reply-To: <20130719.023318.2201887768706444746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding IPsec and other IPv4/IPv6 maintainers in the list.

On 2013=E5=B9=B407=E6=9C=8819=E6=97=A5 17:33, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Fri, 19 Jul 2013 15:50:20 +0800
>
>> The original commit is targeted for XFRM policy inserting/removing,
>> but it uses net genid shared by both IPv4 and IPv6, the side effect =
is
>> add/delete IPv4 address will invalidate IPv6 dst in all.
>>
>> We *do* need to bump genid when add/delete IPv6 address in scenario =
I
>> described here: http://www.spinics.net/lists/netdev/msg243398.html,
>> but definitely not from add/delete IPv4 address. Moreover test shows
>> that DCCP still push thousands of packets on wire after delete its
>> IPv6
>> address in the same scenario I describe before.
>>
>> The impulse to bump genid for IPv6 is much more stronger after this
>> commit even do it unintentionally.
>
> If you really think it will help, and it will still handle the IPSEC
> case, you can make a seperate genid for ipv4 and ipv6 but that might =
not
> work out so cleanly.
>

At least let me give it a try. Any comments would be truly welcome.


 From c79215d64038d62340d77c6ac070d8bb479b2f89 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Mon, 22 Jul 2013 11:31:56 +0800
Subject: [RFC PATCH net-next] net: split rt_genid for ipv4 and ipv6

Current net name space has only one genid for both IPv4 and IPv6, it ha=
s below drawbacks:

- Add/delete an IPv4 address will invalidate all IPv6 routing table ent=
ries.
- Insert/remove XFRM policy will also invalidate both IPv4/IPv6 routing=
 table entries
   even when the policy is only applied for one address family.

Thus, this patch attempt to split one genid for two to cater for IPv4 a=
nd IPv6 separately
in a fine granularity.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
  include/net/net_namespace.h |   33 ++++++++++++++++++++++++++++-----
  net/ipv4/route.c            |   16 ++++++++--------
  net/ipv6/af_inet6.c         |    1 +
  net/ipv6/route.c            |    4 ++--
  net/xfrm/xfrm_policy.c      |    8 +++++++-
  5 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 84e37b1..a08e312 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -119,8 +119,11 @@ struct net {
  	struct netns_ipvs	*ipvs;
  #endif
  	struct sock		*diag_nlsk;
-	atomic_t		rt_genid;
  	atomic_t		fnhe_genid;
+	atomic_t                rt_genid_ipv4;
+#if IS_ENABLED(CONFIG_IPV6)
+	atomic_t                rt_genid_ipv6;
+#endif
  };

  /*
@@ -333,14 +336,34 @@ static inline void unregister_net_sysctl_table(st=
ruct ctl_table_header *header)
  }
  #endif

-static inline int rt_genid(struct net *net)
+static inline int rt_genid_ipv4(struct net *net)
+{
+	return atomic_read(&net->rt_genid_ipv4);
+}
+
+static inline void rt_genid_bump_ipv4(struct net *net)
  {
-	return atomic_read(&net->rt_genid);
+	atomic_inc(&net->rt_genid_ipv4);
  }

-static inline void rt_genid_bump(struct net *net)
+#if IS_ENABLED(CONFIG_IPV6)
+static inline int rt_genid_ipv6(struct net *net)
  {
-	atomic_inc(&net->rt_genid);
+	return atomic_read(&net->rt_genid_ipv6);
+}
+
+static inline void rt_genid_bump_ipv6(struct net *net)
+{
+	atomic_inc(&net->rt_genid_ipv6);
+}
+#endif
+
+static inline void rt_genid_bump_all(struct net *net)
+{
+	atomic_inc(&net->rt_genid_ipv4);
+#if IS_ENABLED(CONFIG_IPV6)
+	atomic_inc(&net->rt_genid_ipv6);
+#endif
  }

  static inline int fnhe_genid(struct net *net)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a9a54a2..df6095d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -435,12 +435,12 @@ static inline int ip_rt_proc_init(void)

  static inline bool rt_is_expired(const struct rtable *rth)
  {
-	return rth->rt_genid !=3D rt_genid(dev_net(rth->dst.dev));
+	return rth->rt_genid !=3D rt_genid_ipv4(dev_net(rth->dst.dev));
  }

  void rt_cache_flush(struct net *net)
  {
-	rt_genid_bump(net);
+	rt_genid_bump_ipv4(net);
  }

  static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *ds=
t,
@@ -1458,7 +1458,7 @@ static int ip_route_input_mc(struct sk_buff *skb,=
 __be32 daddr, __be32 saddr,
  #endif
  	rth->dst.output =3D ip_rt_bug;

-	rth->rt_genid	=3D rt_genid(dev_net(dev));
+	rth->rt_genid	=3D rt_genid_ipv4(dev_net(dev));
  	rth->rt_flags	=3D RTCF_MULTICAST;
  	rth->rt_type	=3D RTN_MULTICAST;
  	rth->rt_is_input=3D 1;
@@ -1589,7 +1589,7 @@ static int __mkroute_input(struct sk_buff *skb,
  		goto cleanup;
  	}

-	rth->rt_genid =3D rt_genid(dev_net(rth->dst.dev));
+	rth->rt_genid =3D rt_genid_ipv4(dev_net(rth->dst.dev));
  	rth->rt_flags =3D flags;
  	rth->rt_type =3D res->type;
  	rth->rt_is_input =3D 1;
@@ -1760,7 +1760,7 @@ local_input:
  	rth->dst.tclassid =3D itag;
  #endif

-	rth->rt_genid =3D rt_genid(net);
+	rth->rt_genid =3D rt_genid_ipv4(net);
  	rth->rt_flags 	=3D flags|RTCF_LOCAL;
  	rth->rt_type	=3D res.type;
  	rth->rt_is_input =3D 1;
@@ -1945,7 +1945,7 @@ add:

  	rth->dst.output =3D ip_output;

-	rth->rt_genid =3D rt_genid(dev_net(dev_out));
+	rth->rt_genid =3D rt_genid_ipv4(dev_net(dev_out));
  	rth->rt_flags	=3D flags;
  	rth->rt_type	=3D type;
  	rth->rt_is_input =3D 0;
@@ -2227,7 +2227,7 @@ struct dst_entry *ipv4_blackhole_route(struct net=
 *net, struct dst_entry *dst_or
  		rt->rt_iif =3D ort->rt_iif;
  		rt->rt_pmtu =3D ort->rt_pmtu;

-		rt->rt_genid =3D rt_genid(net);
+		rt->rt_genid =3D rt_genid_ipv4(net);
  		rt->rt_flags =3D ort->rt_flags;
  		rt->rt_type =3D ort->rt_type;
  		rt->rt_gateway =3D ort->rt_gateway;
@@ -2665,7 +2665,7 @@ static __net_initdata struct pernet_operations sy=
sctl_route_ops =3D {

  static __net_init int rt_genid_init(struct net *net)
  {
-	atomic_set(&net->rt_genid, 0);
+	atomic_set(&net->rt_genid_ipv4, 0);
  	atomic_set(&net->fnhe_genid, 0);
  	get_random_bytes(&net->ipv4.dev_addr_genid,
  			 sizeof(net->ipv4.dev_addr_genid));
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a5ac969..af6855c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,6 +766,7 @@ static int __net_init inet6_net_init(struct net *ne=
t)

  	net->ipv6.sysctl.bindv6only =3D 0;
  	net->ipv6.sysctl.icmpv6_time =3D 1*HZ;
+	atomic_set(&net->rt_genid_ipv6, 0);

  	err =3D ipv6_init_mibs(net);
  	if (err)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a8c891a..45ca9af 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -283,7 +283,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct=
 net *net,

  		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
  		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
-		rt->rt6i_genid =3D rt_genid(net);
+		rt->rt6i_genid =3D rt_genid_ipv6(net);
  		INIT_LIST_HEAD(&rt->rt6i_siblings);
  		rt->rt6i_nsiblings =3D 0;
  	}
@@ -1062,7 +1062,7 @@ static struct dst_entry *ip6_dst_check(struct dst=
_entry *dst, u32 cookie)
  	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
  	 * into this function always.
  	 */
-	if (rt->rt6i_genid !=3D rt_genid(dev_net(rt->dst.dev)))
+	if (rt->rt6i_genid !=3D rt_genid_ipv6(dev_net(rt->dst.dev)))
  		return NULL;

  	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum =3D=3D cookie))
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e52cab3..dbd36e0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -660,7 +660,13 @@ int xfrm_policy_insert(int dir, struct xfrm_policy=
 *policy, int excl)
  	xfrm_pol_hold(policy);
  	net->xfrm.policy_count[dir]++;
  	atomic_inc(&flow_cache_genid);
-	rt_genid_bump(net);
+
+	/* After previous checking, p->family can either be AF_INET or AF_INE=
T6 */
+	if (policy->family =3D=3D AF_INET)=09
+		rt_genid_bump_ipv4(net);
+	else
+		rt_genid_bump_ipv6(net);
+
  	if (delpol) {
  		xfrm_policy_requeue(delpol, policy);
  		__xfrm_policy_unlink(delpol, dir);
--=20
1.7.9.5






--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
