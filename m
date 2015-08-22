From: Akemi Yagi <amyagi@gmail.com>
Subject: Re: [PATCH v2 net-next] netfilter: ipset: Fixing unnamed union init
Date: Sat, 22 Aug 2015 11:21:39 -0700
Message-ID: <CABA31DphMtieQ=Cg86N8FeJB0RcaqLqhh77dEpdNxtp7a4yHug@mail.gmail.com>
References: <1440222251-21132-1-git-send-email-eladr@mellanox.com> <alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Elad Raz <eladr@mellanox.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Vinson Lee <vlee@twopensource.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Anton Danilov <littlesmilingcloud@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Cong Wang <cwang@twopensource.com>,
	Alan Bartlett <ajb@elrepo.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was wondering about that, too. The referenced patch,

net-netfilter-ipset-work-around-gcc-444-initializer-bug.patch

was confirmed to fix the issue. What I cannot figure out is the
procedure by which this patch gets added to Linus' tree. It was in the
-mm tree back in mid June but still is not in the current 4.2-rc7.
Without this fix, Linux 4.2 will not build under RHEL-6 (for example).

Akemi

On Sat, Aug 22, 2015 at 11:11 AM, Jozsef Kadlecsik
<kadlec@blackhole.kfki.hu> wrote:
> On Sat, 22 Aug 2015, Elad Raz wrote:
>
>> In continue to proposed Vinson Lee's post [1], this patch fixes compilation
>> issues founded at gcc 4.4.7. The initialization of .cidr field of unnamed
>> unions causes compilation error in gcc 4.4.x.
>
> There's already a (couple of weeks old) patch in the -mm tree to fix the
> gcc compatilibity issue, see the last comment in the thread you refer to:
>
>> Visible links
>> [1] https://lkml.org/lkml/2015/7/5/74
>
> So I'm unsure whether a new patch should be submitted for this.
>
> Best regards,
> Jozsef
>
>> Signed-off-by: Elad Raz <eladr@mellanox.com>
>> ---
>>  net/netfilter/ipset/ip_set_hash_netnet.c     | 20 ++++++++++++++++++--
>>  net/netfilter/ipset/ip_set_hash_netportnet.c | 20 ++++++++++++++++++--
>>  2 files changed, 36 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
>> index 3c862c0..a93dfeb 100644
>> --- a/net/netfilter/ipset/ip_set_hash_netnet.c
>> +++ b/net/netfilter/ipset/ip_set_hash_netnet.c
>> @@ -131,6 +131,13 @@ hash_netnet4_data_next(struct hash_netnet4_elem *next,
>>  #define HOST_MASK    32
>>  #include "ip_set_hash_gen.h"
>>
>> +static void
>> +hash_netnet4_init(struct hash_netnet4_elem *e)
>> +{
>> +     e->cidr[0] = HOST_MASK;
>> +     e->cidr[1] = HOST_MASK;
>> +}
>> +
>>  static int
>>  hash_netnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
>>                 const struct xt_action_param *par,
>> @@ -160,7 +167,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
>>  {
>>       const struct hash_netnet *h = set->data;
>>       ipset_adtfn adtfn = set->variant->adt[adt];
>> -     struct hash_netnet4_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
>> +     struct hash_netnet4_elem e = { };
>>       struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
>>       u32 ip = 0, ip_to = 0, last;
>>       u32 ip2 = 0, ip2_from = 0, ip2_to = 0, last2;
>> @@ -169,6 +176,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
>>       if (tb[IPSET_ATTR_LINENO])
>>               *lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
>>
>> +     hash_netnet4_init(&e);
>>       if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
>>                    !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
>>               return -IPSET_ERR_PROTOCOL;
>> @@ -357,6 +365,13 @@ hash_netnet6_data_next(struct hash_netnet4_elem *next,
>>  #define IP_SET_EMIT_CREATE
>>  #include "ip_set_hash_gen.h"
>>
>> +static void
>> +hash_netnet6_init(struct hash_netnet6_elem *e)
>> +{
>> +     e->cidr[0] = HOST_MASK;
>> +     e->cidr[1] = HOST_MASK;
>> +}
>> +
>>  static int
>>  hash_netnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
>>                 const struct xt_action_param *par,
>> @@ -385,13 +400,14 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
>>                 enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
>>  {
>>       ipset_adtfn adtfn = set->variant->adt[adt];
>> -     struct hash_netnet6_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
>> +     struct hash_netnet6_elem e = { };
>>       struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
>>       int ret;
>>
>>       if (tb[IPSET_ATTR_LINENO])
>>               *lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
>>
>> +     hash_netnet6_init(&e);
>>       if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
>>                    !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
>>               return -IPSET_ERR_PROTOCOL;
>> diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
>> index 0c68734..9a14c23 100644
>> --- a/net/netfilter/ipset/ip_set_hash_netportnet.c
>> +++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
>> @@ -142,6 +142,13 @@ hash_netportnet4_data_next(struct hash_netportnet4_elem *next,
>>  #define HOST_MASK    32
>>  #include "ip_set_hash_gen.h"
>>
>> +static void
>> +hash_netportnet4_init(struct hash_netportnet4_elem *e)
>> +{
>> +     e->cidr[0] = HOST_MASK;
>> +     e->cidr[1] = HOST_MASK;
>> +}
>> +
>>  static int
>>  hash_netportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
>>                     const struct xt_action_param *par,
>> @@ -175,7 +182,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
>>  {
>>       const struct hash_netportnet *h = set->data;
>>       ipset_adtfn adtfn = set->variant->adt[adt];
>> -     struct hash_netportnet4_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
>> +     struct hash_netportnet4_elem e = { };
>>       struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
>>       u32 ip = 0, ip_to = 0, ip_last, p = 0, port, port_to;
>>       u32 ip2_from = 0, ip2_to = 0, ip2_last, ip2;
>> @@ -185,6 +192,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
>>       if (tb[IPSET_ATTR_LINENO])
>>               *lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
>>
>> +     hash_netportnet4_init(&e);
>>       if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
>>                    !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
>>                    !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
>> @@ -412,6 +420,13 @@ hash_netportnet6_data_next(struct hash_netportnet4_elem *next,
>>  #define IP_SET_EMIT_CREATE
>>  #include "ip_set_hash_gen.h"
>>
>> +static void
>> +hash_netportnet6_init(struct hash_netportnet6_elem *e)
>> +{
>> +     e->cidr[0] = HOST_MASK;
>> +     e->cidr[1] = HOST_MASK;
>> +}
>> +
>>  static int
>>  hash_netportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
>>                     const struct xt_action_param *par,
>> @@ -445,7 +460,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
>>  {
>>       const struct hash_netportnet *h = set->data;
>>       ipset_adtfn adtfn = set->variant->adt[adt];
>> -     struct hash_netportnet6_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
>> +     struct hash_netportnet6_elem e = { };
>>       struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
>>       u32 port, port_to;
>>       bool with_ports = false;
>> @@ -454,6 +469,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
>>       if (tb[IPSET_ATTR_LINENO])
>>               *lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
>>
>> +     hash_netportnet6_init(&e);
>>       if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
>>                    !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
>>                    !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
>> --
>> 2.3.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> -
> E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
> PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
> Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
>           H-1525 Budapest 114, POB. 49, Hungary
