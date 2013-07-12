From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Fri, 12 Jul 2013 11:15:10 +0800
Message-ID: <51DF74BE.6000001@windriver.com>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com> <51D2E3C8.5050100@gmail.com> <51D389F9.4030804@windriver.com> <51D425B7.20204@gmail.com> <51D4DEFF.8030305@windriver.com> <51D6D3A0.7050106@gmail.com> <51DC282C.9090007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nhorman@tuxdriver.com>, <nicolas.dichtel@6wind.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45722 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798Ab3GLDQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 23:16:04 -0400
In-Reply-To: <51DC282C.9090007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8809=E6=97=A5 23:11, Vlad Yasevich wrote:
> On 07/05/2013 10:09 AM, Vlad Yasevich wrote:
>> On 07/03/2013 10:33 PM, Fan Du wrote:
>>>
>>>
>>> On 2013=E5=B9=B407=E6=9C=8803=E6=97=A5 21:23, Vlad Yasevich wrote:
>>>> On 07/02/2013 10:18 PM, Fan Du wrote:
>>>>>
>>>>>
>>>>> On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wrote=
:
>>>>>> On 07/02/2013 02:39 AM, Fan Du wrote:
>>>>>>> When sctp sits on IPv6, sctp_transport_dst_check pass cookie as=
 ZERO,
>>>>>>> as a result ip6_dst_check always fail out. This behaviour makes
>>>>>>> transport->dst useless, because every sctp_packet_transmit must=
 look
>>>>>>> for valid dst(Is this what supposed to be?)
>>>>>>>
>>>>>>> One aggressive way is to call rt_genid_bump which invalid all d=
st to
>>>>>>> make new dst for transport, apparently it also hurts others.
>>>>>>> I'm sure this may not be the best for all, so any commnets?
>>>>>>>
>>>>>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>>>>>> ---
>>>>>>> include/net/sctp/sctp.h | 18 ++++++++++++------
>>>>>>> net/sctp/ipv6.c | 2 ++
>>>>>>> 2 files changed, 14 insertions(+), 6 deletions(-)
>>>>>>>
>>>>>>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>>>>>>> index cd89510..f05af01 100644
>>>>>>> --- a/include/net/sctp/sctp.h
>>>>>>> +++ b/include/net/sctp/sctp.h
>>>>>>> @@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union
>>>>>>> sctp_addr *addr)
>>>>>>> addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
>>>>>>> }
>>>>>>>
>>>>>>> -/* The cookie is always 0 since this is how it's used in the
>>>>>>> - * pmtu code.
>>>>>>> - */
>>>>>>> +/* Set cookie with the right one for IPv6 and zero for others =
*/
>>>>>>> static inline struct dst_entry *sctp_transport_dst_check(struct
>>>>>>> sctp_transport *t)
>>>>>>> {
>>>>>>> - if (t->dst && !dst_check(t->dst, 0)) {
>>>>>>> - dst_release(t->dst);
>>>>>>> - t->dst =3D NULL;
>>>>>>> +
>>>>>>> + if (t->dst) {
>>>>>>> + struct rt6_info *rt =3D (struct rt6_info *)t->dst;
>>>>>>> + u32 cookie =3D 0;
>>>>>>> +
>>>>>>> + if ((t->af_specific->sa_family =3D=3D AF_INET6) && rt->rt6i_n=
ode)
>>>>>>> + cookie =3D rt->rt6i_node->fn_sernum;
>>>>>>> + if (!dst_check(t->dst, cookie)) {
>>>>>>> + dst_release(t->dst);
>>>>>>> + t->dst =3D NULL;
>>>>>>> + }
>>>>>>> }
>>>>>>
>>>>>> I think it would be better if we stored the dst_cookie in the
>>>>>> transport structure and initialized it at lookup time. If you do=
 that,
>>>>>> then if the route table changes, we'd correctly detect it withou=
t
>>>>>> artificially bumping rt_genid (and hurting ipv4).
>>>>>
>>>>> Hi Vlad/Neil
>>>>>
>>>>> Is this what you mean?
>>>>
>>>> Yes, exactly.
>>>>
>>>
>>> Hi Vlad
>>>
>>> I thinks twice about below patch, this is actually a chicken-egg is=
sue.
>>> Look below scenario:
>>> (1) The first time we push packet through a transport, dst_cookie i=
s 0,
>>> so sctp_transport_dst_check also pass cookie as 0, then return dst
>>> as NULL.
>>> Then we lookup dst by sctp_transport_route, and in there we
>>> initiate dst_cookie
>>> with rt->rt6i_node->fn_sernum
>>>
>>> (2) Then the next time we push packet through this transport again,
>>> we pass dst_cookie(rt->rt6i_node->fn_sernum) to ip6_dst_check, and
>>> return valid dst without bothering to lookup dst again.
>>
>> No, if the route was removed rt6i_node will be NULL, and NULL will b=
e
>> returned from ip6_dst_check(). If the route still exists then we'll
>> compare the serial number with a cookie.
>>
>>>
>>> BUT, suppose when deleting the source address of this dst after
>>> transport->dst_cookie
>>> has been well initialized. transport->dst_cookie still holds
>>> rt->rt6i_node->fn_sernum,
>>> meaning ip6_dst_check will return valid dst, which it shouldn't in =
this
>>> case, the
>>> result will be association ABORT.
>>
>> No, removing the address cause the route for that prefix to be remov=
ed
>> as well. This will set rt6i_node to NULL.
>>
>>>
>>> Other way is invalid all transport->dst which using the deleting ad=
dress
>>> as source address
>>> without bumping gen_id, problem is the traverse times depends heavi=
ly on
>>> transport number,
>>> and also need to take account locking issue it will introduce.
>>>
>>> >
>>> > No, you are not missing anything. IPv4 doesn't use the cookie and
>>> always seems to pass it as 0.
>>> >
>>> > Yes, ipv4 will bump the gen_id thus invalidating all routes (ther=
e
>>> has been disagreement about it).
>>> > IPv6 doesn't do that. In ipv6, when the addresses are added or
>>> removed, routes are also added or removed and
>>> > any time the route is added it will have a new serial number. So,=
 you
>>> don't have to disturb ipv4 cache when ipv6 routing info changes.
>>>
>>> Thank you very much for your explanation!
>>>
>>> IPv6 don't bump gen_id, when adding/deleting address, and tag an se=
rial
>>> number with each route.
>>> Doing this way loose the semantic of dst_check, because SCTP depend=
s no
>>> dst_check fulfill its
>>> duty to actually check whether the holding dst is still valid, well=
 most
>>> other Layer 4 protocol
>>> simply rely on ip6_route_output/ip6_dst_lookup_flow to grab dst eve=
ry
>>> time sending data out.
>>
>> Look at how other protocols (tcp, dccp) do this. It is sufficient to
>> cache the route serial number into the dst_cookie at the time the ro=
ute
>> was lookup-up and cached. Then the cookie is passed to dst_check to
>> validate the route.
>
>
> Hi Fan
>
> Have you tried the updated patch you sent? Based on what the tcp/udp =
code is doing, the updated patch should work correctly. If it does, can=
 you re-post with attribution/sign-off

Hello Vlad and Neil

Could you please kindly review below patch?

Thanks


 From ec43c8ec27e16a72d87d6d4b07a1f494083261a2 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Fri, 12 Jul 2013 10:22:35 +0800
Subject: [PATCH] sctp: Don't lookup dst if transport dst is still valid

When sctp sits on IPv6, current sctp_transport_dst_check pass ZERO
ip6_dst_check, which result in dst lookup every time for IPv6.
We use dst_cookie to check against fn_sernum to avoid unnecessary
lookup.

But problem still arise when we attempt to delete address
in multi-home mode, deleting an IPv6 address does not invalidate
any dst which source address is the same at the deleted one.
Which means sctp cannot rely on ip6_dst_check in this scenario.

To enforce multi-home functionality, introducing a sctp_genid similar
with rt genid, but only in sctp territory, so we don't hurt any other
rt validness against other layer 4 protocol.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
  include/net/netns/sctp.h   |    5 +++++
  include/net/sctp/sctp.h    |   11 +++++++++--
  include/net/sctp/structs.h |    3 +++
  net/sctp/ipv6.c            |   24 +++++++++++++++++++++---
  net/sctp/protocol.c        |    7 +++++++
  5 files changed, 45 insertions(+), 5 deletions(-)

diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
index 3573a81..83204db 100644
--- a/include/net/netns/sctp.h
+++ b/include/net/netns/sctp.h
@@ -129,6 +129,11 @@ struct netns_sctp {

  	/* Threshold for autoclose timeout, in seconds. */
  	unsigned long max_autoclose;
+
+#if IS_ENABLED(CONFIG_IPV6)=09
+	/* sctp IPv6 specific */
+	atomic_t	addr_genid;
+#endif
  };

  #endif /* __NETNS_SCTP_H__ */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d8e37ec..c344ea8 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -613,11 +613,18 @@ static inline void sctp_v4_map_v6(union sctp_addr=
 *addr)
   */
  static inline struct dst_entry *sctp_transport_dst_check(struct sctp_=
transport *t)
  {
-	if (t->dst && !dst_check(t->dst, 0)) {
+	struct sctp_af *af =3D t->af_specific;
+
+	/* We handle two sceanario here:
+	 * One: using dst_cookie to check against any routing information cha=
nge
+	 * Two: using sctp_cookie to check against address deletion
+	 * Either of them force a new dst lookup for transport
+	 */
+	if ((t->dst && !dst_check(t->dst, t->dst_cookie)) ||
+		af->check_addr_change(t)) {
  		dst_release(t->dst);
  		t->dst =3D NULL;
  	}
-
  	return t->dst;
  }

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e745c92..9849915 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -492,6 +492,7 @@ struct sctp_af {
  	void		(*seq_dump_addr)(struct seq_file *seq,
  					 union sctp_addr *addr);
  	void		(*ecn_capable)(struct sock *sk);
+	int 		(*check_addr_change)(struct sctp_transport *t);
  	__u16		net_header_len;
  	int		sockaddr_len;
  	sa_family_t	sa_family;
@@ -946,6 +947,8 @@ struct sctp_transport {
  	__u64 hb_nonce;

  	struct rcu_head rcu;
+	u32 dst_cookie;
+	u32 addr_cookie;
  };

  struct sctp_transport *sctp_transport_new(struct net *, const union s=
ctp_addr *,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 09ffcc9..343cd10 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -137,6 +137,8 @@ static int sctp_inet6addr_event(struct notifier_blo=
ck *this, unsigned long ev,
  		break;
  	}

+	/* force a lookup on all transport->dst for stcp IPv6 ONLY */=09
+	atomic_inc(&net->sctp.addr_genid);
  	return NOTIFY_DONE;
  }

@@ -348,12 +350,20 @@ static void sctp_v6_get_dst(struct sctp_transport=
 *t, union sctp_addr *saddr,
  out:
  	if (!IS_ERR_OR_NULL(dst)) {
  		struct rt6_info *rt;
+		struct net *net;

  		rt =3D (struct rt6_info *)dst;
  		t->dst =3D dst;
-
+		net =3D dev_net(rt->rt6i_idev->dev);	=09
+=09
  		pr_debug("rt6_dst:%pI6 rt6_src:%pI6\n", &rt->rt6i_dst.addr,
-			 &fl6->saddr);
+			&fl6->saddr);
+=09
+		/* use fn_sernum to detect routing change */
+		t->dst_cookie =3D rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+
+		/* record addr_genid to check against address delete */
+		t->addr_cookie =3D atomic_read(&net->sctp.addr_genid);
  	} else {
  		t->dst =3D NULL;

@@ -724,6 +734,14 @@ static void sctp_v6_ecn_capable(struct sock *sk)
  	inet6_sk(sk)->tclass |=3D INET_ECN_ECT_0;
  }

+static int sctp_v6_check_addr_change(struct sctp_transport *t)
+{
+	struct rt6_info *rt =3D (struct rt6_info *)t->dst;
+	struct net *net =3D dev_net(rt->rt6i_idev->dev);
+=09
+	return (t->addr_cookie !=3D atomic_read(&net->sctp.addr_genid) ? 1 : =
0);
+}
+
  /* Initialize a PF_INET6 socket msg_name. */
  static void sctp_inet6_msgname(char *msgname, int *addr_len)
  {
@@ -1008,6 +1026,7 @@ static struct sctp_af sctp_af_inet6 =3D {
  	.is_ce		   =3D sctp_v6_is_ce,
  	.seq_dump_addr	   =3D sctp_v6_seq_dump_addr,
  	.ecn_capable	   =3D sctp_v6_ecn_capable,
+	.check_addr_change =3D sctp_v6_check_addr_change,
  	.net_header_len	   =3D sizeof(struct ipv6hdr),
  	.sockaddr_len	   =3D sizeof(struct sockaddr_in6),
  #ifdef CONFIG_COMPAT
@@ -1076,7 +1095,6 @@ int sctp_v6_add_protocol(void)

  	if (inet6_add_protocol(&sctpv6_protocol, IPPROTO_SCTP) < 0)
  		return -EAGAIN;
-
  	return 0;
  }

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4a17494d..b9335d7 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -595,6 +595,12 @@ static void sctp_v4_ecn_capable(struct sock *sk)
  	INET_ECN_xmit(sk);
  }

+static int sctp_v4_check_addr_change(struct sctp_transport *t)
+{
+	/* Always return 0, as IPv4 bump rt genid when address changes */
+	return 0;
+}
+
  static void sctp_addr_wq_timeout_handler(unsigned long arg)
  {
  	struct net *net =3D (struct net *)arg;
@@ -1064,6 +1070,7 @@ static struct sctp_af sctp_af_inet =3D {
  	.is_ce		   =3D sctp_v4_is_ce,
  	.seq_dump_addr	   =3D sctp_v4_seq_dump_addr,
  	.ecn_capable	   =3D sctp_v4_ecn_capable,
+	.check_addr_change =3D sctp_v4_check_addr_change,
  	.net_header_len	   =3D sizeof(struct iphdr),
  	.sockaddr_len	   =3D sizeof(struct sockaddr_in),
  #ifdef CONFIG_COMPAT



> Thanks
> -vlad
>
>>
>> -vlad
>>>
>>> So please pronounce a final judgment.
>>>
>>>> -vlad
>>>>
>>>>>
>>>>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>>>>> index cd89510..0a646a5 100644
>>>>> --- a/include/net/sctp/sctp.h
>>>>> +++ b/include/net/sctp/sctp.h
>>>>> @@ -724,7 +724,7 @@ static inline void sctp_v4_map_v6(union sctp_=
addr
>>>>> *addr)
>>>>> */
>>>>> static inline struct dst_entry *sctp_transport_dst_check(struct
>>>>> sctp_transport *t)
>>>>> {
>>>>> - if (t->dst && !dst_check(t->dst, 0)) {
>>>>> + if (t->dst && !dst_check(t->dst, t->dst_cookie)) {
>>>>> dst_release(t->dst);
>>>>> t->dst =3D NULL;
>>>>> }
>>>>> diff --git a/include/net/sctp/structs.h b/include/net/sctp/struct=
s.h
>>>>> index 1bd4c41..cafdd19 100644
>>>>> --- a/include/net/sctp/structs.h
>>>>> +++ b/include/net/sctp/structs.h
>>>>> @@ -946,6 +946,8 @@ struct sctp_transport {
>>>>> __u64 hb_nonce;
>>>>>
>>>>> struct rcu_head rcu;
>>>>> +
>>>>> + u32 dst_cookie;
>>>>> };
>>>>>
>>>>> struct sctp_transport *sctp_transport_new(struct net *, const uni=
on
>>>>> sctp_addr *,
>>>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>>>> index 8ee553b..82a420f 100644
>>>>> --- a/net/sctp/ipv6.c
>>>>> +++ b/net/sctp/ipv6.c
>>>>> @@ -350,6 +350,7 @@ out:
>>>>> struct rt6_info *rt;
>>>>> rt =3D (struct rt6_info *)dst;
>>>>> t->dst =3D dst;
>>>>> + t->dst_cookie =3D rt->rt6i_node ? rt->rt6i_node->fn_sernum
>>>>> : 0;
>>>>> SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
>>>>> &rt->rt6i_dst.addr, &fl6->saddr);
>>>>> } else {
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>> -vlad
>>>>>>
>>>>>>>
>>>>>>> return t->dst;
>>>>>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>>>>>> index 8ee553b..cfae77e 100644
>>>>>>> --- a/net/sctp/ipv6.c
>>>>>>> +++ b/net/sctp/ipv6.c
>>>>>>> @@ -137,6 +137,8 @@ static int sctp_inet6addr_event(struct
>>>>>>> notifier_block *this, unsigned long ev,
>>>>>>> break;
>>>>>>> }
>>>>>>>
>>>>>>> + /* invalid all transport dst forcing to look up new dst */
>>>>>>> + rt_genid_bump(net);
>>>>>>> return NOTIFY_DONE;
>>>>>>> }
>>>>>>>
>>>>>>>
>>>>>>
>>>>>>
>>>>>
>>>>
>>>>
>>>
>>
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
