From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 1/2] bonding: modify the old and add new xmit
 hash functions
Date: Wed, 25 Sep 2013 18:36:33 +0200
Message-ID: <52431111.8000301@redhat.com>
References: <1380122398-7370-1-git-send-email-nikolay@redhat.com> <1380122398-7370-2-git-send-email-nikolay@redhat.com> <20130925162606.GA27752@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab3IYQgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 12:36:40 -0400
In-Reply-To: <20130925162606.GA27752@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2013 06:26 PM, Veaceslav Falico wrote:
> On Wed, Sep 25, 2013 at 05:19:57PM +0200, Nikolay Aleksandrov wrote:
>> This patch adds two new hash policy modes which use skb_flow_dissect:
>> 3 - Encapsulated layer 2+3
>> 4 - Encapsulated layer 3+4
>> There should be a good improvement for tunnel users in those modes.
>> It also changes the old hash functions to:
>> hash ^= (__force u32)flow.dst ^ (__force u32)flow.src;
>> hash ^= (hash >> 16);
>> hash ^= (hash >> 8);
>>
>> Where hash will be initialized either to L2 hash, that is
>> SRCMAC[5] XOR DSTMAC[5], or to flow->ports which should be extracted
>> from the upper layer. Flow's dst and src are also extracted based on the
>> xmit policy either directly from the buffer or by using skb_flow_dissect,
>> but in both cases if the protocol is IPv6 then dst and src are obtained by
>> ipv6_addr_hash() on the real addresses. In case of a non-dissectable
>> packet, the algorithms fall back to L2 hashing.
>> The bond_set_mode_ops() function is now obsolete and thus deleted
>> because it was used only to set the proper hash policy. Also we trim a
>> pointer from struct bonding because we no longer need to keep the hash
>> function, now there's only a single hash function - bond_xmit_hash that
>> works based on bond->params.xmit_policy.
>>
>> The hash function and skb_flow_dissect were suggested by Eric Dumazet.
>> The layer names were suggested by Andy Gospodarek, because I suck at
>> semantics.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>> One line is intentionally left at 82 chars since it's the whole function
>> and IMO looks better that way.
>>
>> drivers/net/bonding/bond_3ad.c   |   2 +-
>> drivers/net/bonding/bond_main.c  | 211
>> +++++++++++++++------------------------
>> drivers/net/bonding/bond_sysfs.c |   2 -
>> drivers/net/bonding/bonding.h    |   3 +-
>> include/uapi/linux/if_bonding.h  |   2 +
>> 5 files changed, 86 insertions(+), 134 deletions(-)
> 
> Nice!!! Though some comments below.
> 
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 0d8f427..b3ab703 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2442,7 +2442,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct
>> net_device *dev)
>>         goto out;
>>     }
>>
>> -    slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
>> +    slave_agg_no = bond_xmit_hash(bond, skb, slaves_in_agg);
>>
>>     bond_for_each_slave(bond, slave) {
>>         struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>> diff --git a/drivers/net/bonding/bond_main.c
>> b/drivers/net/bonding/bond_main.c
>> index 55bbb8b..73e416b 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -78,6 +78,7 @@
>> #include <net/netns/generic.h>
>> #include <net/pkt_sched.h>
>> #include <linux/rculist.h>
>> +#include <net/flow_keys.h>
>> #include "bonding.h"
>> #include "bond_3ad.h"
>> #include "bond_alb.h"
>> @@ -159,7 +160,8 @@ MODULE_PARM_DESC(min_links, "Minimum number of
>> available links before turning on
>> module_param(xmit_hash_policy, charp, 0);
>> MODULE_PARM_DESC(xmit_hash_policy, "balance-xor and 802.3ad hashing
>> method; "
>>                    "0 for layer 2 (default), 1 for layer 3+4, "
>> -                   "2 for layer 2+3");
>> +                   "2 for layer 2+3, 3 for encap layer 2+3, "
>> +                   "4 for encap layer 3+4");
>> module_param(arp_interval, int, 0);
>> MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
>> module_param_array(arp_ip_target, charp, NULL, 0);
>> @@ -217,6 +219,8 @@ const struct bond_parm_tbl xmit_hashtype_tbl[] = {
>> {    "layer2",        BOND_XMIT_POLICY_LAYER2},
>> {    "layer3+4",        BOND_XMIT_POLICY_LAYER34},
>> {    "layer2+3",        BOND_XMIT_POLICY_LAYER23},
>> +{    "encap2+3",        BOND_XMIT_POLICY_ENCAP23},
>> +{    "encap3+4",        BOND_XMIT_POLICY_ENCAP34},
>> {    NULL,            -1},
>> };
>>
>> @@ -3026,99 +3030,99 @@ static struct notifier_block bond_netdev_notifier
>> = {
>>
>> /*---------------------------- Hashing Policies
>> -----------------------------*/
>>
>> -/*
>> - * Hash for the output device based upon layer 2 data
>> - */
>> -static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
>> +/* L2 hash helper */
>> +static inline u32 bond_eth_hash(struct sk_buff *skb)
>> {
>>     struct ethhdr *data = (struct ethhdr *)skb->data;
>>
>>     if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
>> -        return (data->h_dest[5] ^ data->h_source[5]) % count;
>> +        return data->h_dest[5] ^ data->h_source[5];
>>
>>     return 0;
>> }
>>
>> -/*
>> - * Hash for the output device based upon layer 2 and layer 3 data. If
>> - * the packet is not IP, fall back on bond_xmit_hash_policy_l2()
>> - */
>> -static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
>> +static void bond_flow_get_ports(struct sk_buff *skb, struct flow_keys *fk,
>> +                int offset)
>> +{
>> +    __be32 *ports;
>> +
>> +    ports = skb_header_pointer(skb, offset, sizeof(fk->ports), &fk->ports);
>> +    if (ports)
>> +        fk->ports = *ports;
>> +}
>> +
>> +/* Extract the appropriate headers based on bond's xmit policy */
>> +static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
>> +                  struct flow_keys *fk)
>> {
>> -    const struct ethhdr *data;
>> +    const struct ipv6hdr *iph6;
>>     const struct iphdr *iph;
>> -    const struct ipv6hdr *ipv6h;
>> -    u32 v6hash;
>> -    const __be32 *s, *d;
>> +    int noff, proto = -1, poff = -1;
> 
> Nitpick: Useless initialization of poff.
> 
Yeah, I saw it after posting and have this in the prepared v2 :-)

>> +    bool ret = false;
>> +
>> +    if (bond->params.xmit_policy > BOND_XMIT_POLICY_LAYER23)
>> +        return skb_flow_dissect(skb, fk);
>>
>> -    if (skb->protocol == htons(ETH_P_IP) &&
>> -        pskb_network_may_pull(skb, sizeof(*iph))) {
>> +    fk->ports = 0;
>> +    noff = skb_network_offset(skb);
>> +    if (skb->protocol == htons(ETH_P_IP)) {
>> +        if (!pskb_may_pull(skb, noff + sizeof(*iph)))
>> +            goto out;
>>         iph = ip_hdr(skb);
>> -        data = (struct ethhdr *)skb->data;
>> -        return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>> -            (data->h_dest[5] ^ data->h_source[5])) % count;
>> -    } else if (skb->protocol == htons(ETH_P_IPV6) &&
>> -           pskb_network_may_pull(skb, sizeof(*ipv6h))) {
>> -        ipv6h = ipv6_hdr(skb);
>> -        data = (struct ethhdr *)skb->data;
>> -        s = &ipv6h->saddr.s6_addr32[0];
>> -        d = &ipv6h->daddr.s6_addr32[0];
>> -        v6hash = (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
>> -        v6hash ^= (v6hash >> 24) ^ (v6hash >> 16) ^ (v6hash >> 8);
>> -        return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
>> -    }
>> -
>> -    return bond_xmit_hash_policy_l2(skb, count);
>> +        fk->src = iph->saddr;
>> +        fk->dst = iph->daddr;
>> +        noff += iph->ihl << 2;
>> +        if (!ip_is_fragment(iph))
>> +            proto = iph->protocol;
>> +    } else if (skb->protocol == htons(ETH_P_IPV6)) {
>> +        if (!pskb_may_pull(skb, noff + sizeof(*iph6)))
>> +            goto out;
>> +        iph6 = ipv6_hdr(skb);
>> +        fk->src = (__force __be32)ipv6_addr_hash(&iph6->saddr);
>> +        fk->dst = (__force __be32)ipv6_addr_hash(&iph6->daddr);
>> +        noff += sizeof(*iph6);
>> +        proto = iph6->nexthdr;
>> +    }
> 
> else
>     return false;
> 
> ?
> 
Hehe, I actually had that in v1 few months ago, I was wondering why I did
it that way...

> Otherwise we might report false-positive for vlans, per example, without
> populating the flow keys.
> 
Right.

>> +    if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34) {
>> +        poff = proto_ports_offset(proto);
>> +        if (poff >= 0)
>> +            bond_flow_get_ports(skb, fk, poff + noff);
>> +    }
> 
> One idea would be to move the same initialization code from
> skb_flow_dissect() to an external function and re-use it here?
> 
Yep, I could do an inline skb_flow_get_ports() and re-use it.

>> +    ret = true;
>> +
>> +out:
>> +    return ret;
>> }
>>
>> -/*
>> - * Hash for the output device based upon layer 3 and layer 4 data. If
>> - * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
>> - * altogether not IP, fall back on bond_xmit_hash_policy_l2()
>> +/**
>> + * bond_xmit_hash - generate a hash value based on the xmit policy
>> + * @bond: bonding device
>> + * @skb: buffer to use for headers
>> + * @count: modulo value
>> + *
>> + * This function will extract the necessary headers from the skb buffer
>> and use
>> + * them to generate a hash based on the xmit_policy set in the bonding
>> device
>> + * which will be reduced modulo count before returning.
>>  */
>> -static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
>> +int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count)
>> {
>> -    u32 layer4_xor = 0;
>> -    const struct iphdr *iph;
>> -    const struct ipv6hdr *ipv6h;
>> -    const __be32 *s, *d;
>> -    const __be16 *l4 = NULL;
>> -    __be16 _l4[2];
>> -    int noff = skb_network_offset(skb);
>> -    int poff;
>> -
>> -    if (skb->protocol == htons(ETH_P_IP) &&
>> -        pskb_may_pull(skb, noff + sizeof(*iph))) {
>> -        iph = ip_hdr(skb);
>> -        poff = proto_ports_offset(iph->protocol);
>> +    struct flow_keys flow;
>> +    u32 hash;
>>
>> -        if (!ip_is_fragment(iph) && poff >= 0) {
>> -            l4 = skb_header_pointer(skb, noff + (iph->ihl << 2) + poff,
>> -                        sizeof(_l4), &_l4);
>> -            if (l4)
>> -                layer4_xor = ntohs(l4[0] ^ l4[1]);
>> -        }
>> -        return (layer4_xor ^
>> -            ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>> -    } else if (skb->protocol == htons(ETH_P_IPV6) &&
>> -           pskb_may_pull(skb, noff + sizeof(*ipv6h))) {
>> -        ipv6h = ipv6_hdr(skb);
>> -        poff = proto_ports_offset(ipv6h->nexthdr);
>> -        if (poff >= 0) {
>> -            l4 = skb_header_pointer(skb, noff + sizeof(*ipv6h) + poff,
>> -                        sizeof(_l4), &_l4);
>> -            if (l4)
>> -                layer4_xor = ntohs(l4[0] ^ l4[1]);
>> -        }
>> -        s = &ipv6h->saddr.s6_addr32[0];
>> -        d = &ipv6h->daddr.s6_addr32[0];
>> -        layer4_xor ^= (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
>> -        layer4_xor ^= (layer4_xor >> 24) ^ (layer4_xor >> 16) ^
>> -                   (layer4_xor >> 8);
>> -        return layer4_xor % count;
>> -    }
>> +    if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
>> +        !bond_flow_dissect(bond, skb, &flow))
>> +        return bond_eth_hash(skb) % count;
>> +
>> +    if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23 ||
>> +        bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23)
>> +        hash = bond_eth_hash(skb);
>> +    else
>> +        hash = (__force u32)flow.ports;
>> +    hash ^= (__force u32)flow.dst ^ (__force u32)flow.src;
>> +    hash ^= (hash >> 16);
>> +    hash ^= (hash >> 8);
>>
>> -    return bond_xmit_hash_policy_l2(skb, count);
>> +    return hash % count;
>> }
>>
>> /*-------------------------- Device entry points
>> ----------------------------*/
>> @@ -3700,8 +3704,7 @@ static int bond_xmit_activebackup(struct sk_buff
>> *skb, struct net_device *bond_d
>>     return NETDEV_TX_OK;
>> }
>>
>> -/*
>> - * In bond_xmit_xor() , we determine the output device by using a pre-
>> +/* In bond_xmit_xor() , we determine the output device by using a pre-
>>  * determined xmit_hash_policy(), If the selected device is not enabled,
>>  * find the next active slave.
>>  */
>> @@ -3709,8 +3712,7 @@ static int bond_xmit_xor(struct sk_buff *skb,
>> struct net_device *bond_dev)
>> {
>>     struct bonding *bond = netdev_priv(bond_dev);
>>
>> -    bond_xmit_slave_id(bond, skb,
>> -               bond->xmit_hash_policy(skb, bond->slave_cnt));
>> +    bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb,
>> bond->slave_cnt));
>>
>>     return NETDEV_TX_OK;
>> }
>> @@ -3746,22 +3748,6 @@ static int bond_xmit_broadcast(struct sk_buff
>> *skb, struct net_device *bond_dev)
>>
>> /*------------------------- Device initialization
>> ---------------------------*/
>>
>> -static void bond_set_xmit_hash_policy(struct bonding *bond)
>> -{
>> -    switch (bond->params.xmit_policy) {
>> -    case BOND_XMIT_POLICY_LAYER23:
>> -        bond->xmit_hash_policy = bond_xmit_hash_policy_l23;
>> -        break;
>> -    case BOND_XMIT_POLICY_LAYER34:
>> -        bond->xmit_hash_policy = bond_xmit_hash_policy_l34;
>> -        break;
>> -    case BOND_XMIT_POLICY_LAYER2:
>> -    default:
>> -        bond->xmit_hash_policy = bond_xmit_hash_policy_l2;
>> -        break;
>> -    }
>> -}
>> -
>> /*
>>  * Lookup the slave that corresponds to a qid
>>  */
>> @@ -3871,38 +3857,6 @@ static netdev_tx_t bond_start_xmit(struct sk_buff
>> *skb, struct net_device *dev)
>>     return ret;
>> }
>>
>> -/*
>> - * set bond mode specific net device operations
>> - */
>> -void bond_set_mode_ops(struct bonding *bond, int mode)
>> -{
>> -    struct net_device *bond_dev = bond->dev;
>> -
>> -    switch (mode) {
>> -    case BOND_MODE_ROUNDROBIN:
>> -        break;
>> -    case BOND_MODE_ACTIVEBACKUP:
>> -        break;
>> -    case BOND_MODE_XOR:
>> -        bond_set_xmit_hash_policy(bond);
>> -        break;
>> -    case BOND_MODE_BROADCAST:
>> -        break;
>> -    case BOND_MODE_8023AD:
>> -        bond_set_xmit_hash_policy(bond);
>> -        break;
>> -    case BOND_MODE_ALB:
>> -        /* FALLTHRU */
>> -    case BOND_MODE_TLB:
>> -        break;
>> -    default:
>> -        /* Should never happen, mode already checked */
>> -        pr_err("%s: Error: Unknown bonding mode %d\n",
>> -               bond_dev->name, mode);
>> -        break;
>> -    }
>> -}
>> -
>> static int bond_ethtool_get_settings(struct net_device *bond_dev,
>>                      struct ethtool_cmd *ecmd)
>> {
>> @@ -4004,7 +3958,6 @@ static void bond_setup(struct net_device *bond_dev)
>>     ether_setup(bond_dev);
>>     bond_dev->netdev_ops = &bond_netdev_ops;
>>     bond_dev->ethtool_ops = &bond_ethtool_ops;
>> -    bond_set_mode_ops(bond, bond->params.mode);
>>
>>     bond_dev->destructor = bond_destructor;
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c
>> b/drivers/net/bonding/bond_sysfs.c
>> index c29b836..dba3b9b 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -352,7 +352,6 @@ static ssize_t bonding_store_mode(struct device *d,
>>     /* don't cache arp_validate between modes */
>>     bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
>>     bond->params.mode = new_value;
>> -    bond_set_mode_ops(bond, bond->params.mode);
>>     pr_info("%s: setting mode to %s (%d).\n",
>>         bond->dev->name, bond_mode_tbl[new_value].modename,
>>         new_value);
>> @@ -392,7 +391,6 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
>>         ret = -EINVAL;
>>     } else {
>>         bond->params.xmit_policy = new_value;
>> -        bond_set_mode_ops(bond, bond->params.mode);
>>         pr_info("%s: setting xmit hash policy to %s (%d).\n",
>>             bond->dev->name,
>>             xmit_hashtype_tbl[new_value].modename, new_value);
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 03cf3fd..4db9ec4 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -245,7 +245,6 @@ struct bonding {
>>     char     proc_file_name[IFNAMSIZ];
>> #endif /* CONFIG_PROC_FS */
>>     struct   list_head bond_list;
>> -    int      (*xmit_hash_policy)(struct sk_buff *, int);
>>     u16      rr_tx_counter;
>>     struct   ad_bond_info ad_info;
>>     struct   alb_bond_info alb_info;
>> @@ -446,7 +445,7 @@ int bond_release(struct net_device *bond_dev, struct
>> net_device *slave_dev);
>> void bond_mii_monitor(struct work_struct *);
>> void bond_loadbalance_arp_mon(struct work_struct *);
>> void bond_activebackup_arp_mon(struct work_struct *);
>> -void bond_set_mode_ops(struct bonding *bond, int mode);
>> +int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
>> int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
>> void bond_select_active_slave(struct bonding *bond);
>> void bond_change_active_slave(struct bonding *bond, struct slave
>> *new_active);
>> diff --git a/include/uapi/linux/if_bonding.h
>> b/include/uapi/linux/if_bonding.h
>> index a17edda..9635a62 100644
>> --- a/include/uapi/linux/if_bonding.h
>> +++ b/include/uapi/linux/if_bonding.h
>> @@ -91,6 +91,8 @@
>> #define BOND_XMIT_POLICY_LAYER2        0 /* layer 2 (MAC only), default */
>> #define BOND_XMIT_POLICY_LAYER34    1 /* layer 3+4 (IP ^ (TCP || UDP)) */
>> #define BOND_XMIT_POLICY_LAYER23    2 /* layer 2+3 (IP ^ MAC) */
>> +#define BOND_XMIT_POLICY_ENCAP23    3 /* encapsulated layer 2+3 */
>> +#define BOND_XMIT_POLICY_ENCAP34    4 /* encapsulated layer 3+4 */
>>
>> typedef struct ifbond {
>>     __s32 bond_mode;
>> -- 
>> 1.8.1.4
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
