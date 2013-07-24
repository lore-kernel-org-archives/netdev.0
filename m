From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH net-next V2] net: split rt_genid for ipv4 and ipv6
Date: Wed, 24 Jul 2013 09:30:26 +0800
Message-ID: <51EF2E32.8020606@windriver.com>
References: <1374543420-12657-1-git-send-email-fan.du@windriver.com> <51EEFAF9.2030300@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<jmorris@namei.org>, <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51666 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3GXB3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 21:29:15 -0400
In-Reply-To: <51EEFAF9.2030300@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8824=E6=97=A5 05:51, Nicolas Dichtel wrote:
> Le 23/07/2013 03:37, Fan Du a =C3=A9crit :
>> Current net name space has only one genid for both IPv4 and IPv6, it=
 has below drawbacks:
>>
>> - Add/delete an IPv4 address will invalidate all IPv6 routing table =
entries.
>> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 rout=
ing table entries
>> even when the policy is only applied for one address family.
>>
>> Thus, this patch attempt to split one genid for two to cater for IPv=
4 and IPv6 separately
>> in a fine granularity.
>>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>
>> V2:
>> -Fix compile issue when IPv6 not enabled
>> -Put genid into struct netns_ipv4/ipv6
>> ---
>> include/net/net_namespace.h | 39 ++++++++++++++++++++++++++++++++++-=
----
>> include/net/netns/ipv4.h | 1 +
>> include/net/netns/ipv6.h | 1 +
>> net/ipv4/route.c | 16 ++++++++--------
>> net/ipv6/af_inet6.c | 1 +
>> net/ipv6/route.c | 4 ++--
>> net/xfrm/xfrm_policy.c | 8 +++++++-
>> 7 files changed, 54 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace=
=2Eh
>> index 84e37b1..763e63f 100644
>> --- a/include/net/net_namespace.h
>> +++ b/include/net/net_namespace.h
>> @@ -119,7 +119,6 @@ struct net {
>> struct netns_ipvs *ipvs;
>> #endif
>> struct sock *diag_nlsk;
>> - atomic_t rt_genid;
>> atomic_t fnhe_genid;
>> };
>>
>> @@ -333,14 +332,44 @@ static inline void unregister_net_sysctl_table=
(struct ctl_table_header *header)
>> }
>> #endif
>>
>> -static inline int rt_genid(struct net *net)
>> +static inline int rt_genid_ipv4(struct net *net)
>> {
>> - return atomic_read(&net->rt_genid);
>> + return atomic_read(&net->ipv4.rt_genid_ipv4);
>> }
>>
>> -static inline void rt_genid_bump(struct net *net)
>> +static inline void rt_genid_bump_ipv4(struct net *net)
>> {
>> - atomic_inc(&net->rt_genid);
>> + atomic_inc(&net->ipv4.rt_genid_ipv4);
>> +}
>> +
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +static inline int rt_genid_ipv6(struct net *net)
>> +{
>> + return atomic_read(&net->ipv6.rt_genid_ipv6);
>> +}
>> +
>> +static inline void rt_genid_bump_ipv6(struct net *net)
>> +{
>> + atomic_inc(&net->ipv6.rt_genid_ipv6);
>> +}
>> +#else
>> +static inline int rt_genid_ipv6(struct net *net)
>> +{
>> + return 0;
>> +}
>> +
>> +static inline void rt_genid_bump_ipv6(struct net *net)
>> +{
>> +}
>> +#endif
>> +
>> +/* For callers who don't really care about whether it's IPv4 or IPv=
6 */
>> +static inline void rt_genid_bump_all(struct net *net)
>> +{
>> + atomic_inc(&net->ipv4.rt_genid_ipv4);
>> +#if IS_ENABLED(CONFIG_IPV6)
>> + atomic_inc(&net->ipv6.rt_genid_ipv6);
>> +#endif
>> }
>>
>> static inline int fnhe_genid(struct net *net)
>> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
>> index 2ba9de8..d87af01 100644
>> --- a/include/net/netns/ipv4.h
>> +++ b/include/net/netns/ipv4.h
>> @@ -77,5 +77,6 @@ struct netns_ipv4 {
>> struct fib_rules_ops *mr_rules_ops;
>> #endif
>> #endif
>> + atomic_t rt_genid_ipv4;
> Just nitpiking: maybe _ipv4 is redundant? It's already in 'struct net=
ns_ipv4'.
> Same for IPv6.
>
Hallo Nicolas

That's not nitpicking at all :), will chop _ipv4/6 off in next version.
Thanks for your comments.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
