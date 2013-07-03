From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Wed, 3 Jul 2013 10:18:33 +0800
Message-ID: <51D389F9.4030804@windriver.com>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com> <51D2E3C8.5050100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nhorman@tuxdriver.com>, <nicolas.dichtel@6wind.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37953 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215Ab3GCCUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 22:20:34 -0400
In-Reply-To: <51D2E3C8.5050100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wrote:
> On 07/02/2013 02:39 AM, Fan Du wrote:
>> When sctp sits on IPv6, sctp_transport_dst_check pass cookie as ZERO=
,
>> as a result ip6_dst_check always fail out. This behaviour makes
>> transport->dst useless, because every sctp_packet_transmit must look
>> for valid dst(Is this what supposed to be?)
>>
>> One aggressive way is to call rt_genid_bump which invalid all dst to
>> make new dst for transport, apparently it also hurts others.
>> I'm sure this may not be the best for all, so any commnets?
>>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>> ---
>> include/net/sctp/sctp.h | 18 ++++++++++++------
>> net/sctp/ipv6.c | 2 ++
>> 2 files changed, 14 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>> index cd89510..f05af01 100644
>> --- a/include/net/sctp/sctp.h
>> +++ b/include/net/sctp/sctp.h
>> @@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union sctp_a=
ddr *addr)
>> addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
>> }
>>
>> -/* The cookie is always 0 since this is how it's used in the
>> - * pmtu code.
>> - */
>> +/* Set cookie with the right one for IPv6 and zero for others */
>> static inline struct dst_entry *sctp_transport_dst_check(struct sctp=
_transport *t)
>> {
>> - if (t->dst && !dst_check(t->dst, 0)) {
>> - dst_release(t->dst);
>> - t->dst =3D NULL;
>> +
>> + if (t->dst) {
>> + struct rt6_info *rt =3D (struct rt6_info *)t->dst;
>> + u32 cookie =3D 0;
>> +
>> + if ((t->af_specific->sa_family =3D=3D AF_INET6) && rt->rt6i_node)
>> + cookie =3D rt->rt6i_node->fn_sernum;
>> + if (!dst_check(t->dst, cookie)) {
>> + dst_release(t->dst);
>> + t->dst =3D NULL;
>> + }
>> }
>
> I think it would be better if we stored the dst_cookie in the transpo=
rt structure and initialized it at lookup time. If you do that, then if=
 the route table changes, we'd correctly detect it without artificially=
 bumping rt_genid (and hurting ipv4).

Hi Vlad/Neil

Is this what you mean?

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index cd89510..0a646a5 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -724,7 +724,7 @@ static inline void sctp_v4_map_v6(union sctp_addr *=
addr)
   */
  static inline struct dst_entry *sctp_transport_dst_check(struct sctp_=
transport *t)
  {
-       if (t->dst && !dst_check(t->dst, 0)) {
+       if (t->dst && !dst_check(t->dst, t->dst_cookie)) {
                 dst_release(t->dst);
                 t->dst =3D NULL;
         }
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 1bd4c41..cafdd19 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -946,6 +946,8 @@ struct sctp_transport {
         __u64 hb_nonce;

         struct rcu_head rcu;
+
+       u32 dst_cookie;
  };

  struct sctp_transport *sctp_transport_new(struct net *, const union s=
ctp_addr *,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 8ee553b..82a420f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -350,6 +350,7 @@ out:
                 struct rt6_info *rt;
                 rt =3D (struct rt6_info *)dst;
                 t->dst =3D dst;
+               t->dst_cookie =3D rt->rt6i_node ? rt->rt6i_node->fn_ser=
num : 0;
                 SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
                         &rt->rt6i_dst.addr, &fl6->saddr);
         } else {





> -vlad
>
>>
>> return t->dst;
>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>> index 8ee553b..cfae77e 100644
>> --- a/net/sctp/ipv6.c
>> +++ b/net/sctp/ipv6.c
>> @@ -137,6 +137,8 @@ static int sctp_inet6addr_event(struct notifier_=
block *this, unsigned long ev,
>> break;
>> }
>>
>> + /* invalid all transport dst forcing to look up new dst */
>> + rt_genid_bump(net);
>> return NOTIFY_DONE;
>> }
>>
>>
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
