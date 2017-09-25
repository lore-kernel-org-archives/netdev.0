From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next v2 06/12] net: mroute: Check if rule is a default
 rule
Date: Mon, 25 Sep 2017 16:37:03 +0300
Message-ID: <193145c9-4f6c-5bd3-4b19-55f0c8af28c0@mellanox.com>
References: <20170924172212.10096-1-jiri@resnulli.us>
 <20170924172212.10096-7-jiri@resnulli.us>
 <93dcea9d-94eb-39cf-4102-e5c59fb2dfa5@huawei.com>
 <20170925094508.GC1899@nanopsycho>
 <fc1f3324-d2fc-f95c-50d2-25773f3c7683@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0045.outbound.protection.outlook.com ([104.47.2.45]:63072
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935732AbdIYNhO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 09:37:14 -0400
In-Reply-To: <fc1f3324-d2fc-f95c-50d2-25773f3c7683@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2017 01:02 PM, Nikolay Aleksandrov wrote:
> On 25/09/17 12:45, Jiri Pirko wrote:
>> Mon, Sep 25, 2017 at 03:28:21AM CEST, linyunsheng@huawei.com wrote:
>>> Hi, Jiri
>>>
>>> On 2017/9/25 1:22, Jiri Pirko wrote:
>>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>>
>>>> When the ipmr starts, it adds one default FIB rule that matches all packets
>>>> and sends them to the DEFAULT (multicast) FIB table. A more complex rule
>>>> can be added by user to specify that for a specific interface, a packet
>>>> should be look up at either an arbitrary table or according to the l3mdev
>>>> of the interface.
>>>>
>>>> For drivers willing to offload the ipmr logic into a hardware but don't
>>>> want to offload all the FIB rules functionality, provide a function that
>>>> can indicate whether the FIB rule is the default multicast rule, thus only
>>>> one routing table is needed.
>>>>
>>>> This way, a driver can register to the FIB notification chain, get
>>>> notifications about FIB rules added and trigger some kind of an internal
>>>> abort mechanism when a non default rule is added by the user.
>>>>
>>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>>  include/linux/mroute.h |  7 +++++++
>>>>  net/ipv4/ipmr.c        | 10 ++++++++++
>>>>  2 files changed, 17 insertions(+)
>>>>
>>>> diff --git a/include/linux/mroute.h b/include/linux/mroute.h
>>>> index 5566580..b072a84 100644
>>>> --- a/include/linux/mroute.h
>>>> +++ b/include/linux/mroute.h
>>>> @@ -5,6 +5,7 @@
>>>>  #include <linux/pim.h>
>>>>  #include <linux/rhashtable.h>
>>>>  #include <net/sock.h>
>>>> +#include <net/fib_rules.h>
>>>>  #include <net/fib_notifier.h>
>>>>  #include <uapi/linux/mroute.h>
>>>>  
>>>> @@ -19,6 +20,7 @@ int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
>>>>  int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
>>>>  int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
>>>>  int ip_mr_init(void);
>>>> +bool ipmr_rule_default(const struct fib_rule *rule);
>>>>  #else
>>>>  static inline int ip_mroute_setsockopt(struct sock *sock, int optname,
>>>>  				       char __user *optval, unsigned int optlen)
>>>> @@ -46,6 +48,11 @@ static inline int ip_mroute_opt(int opt)
>>>>  {
>>>>  	return 0;
>>>>  }
>>>> +
>>>> +static inline bool ipmr_rule_default(const struct fib_rule *rule)
>>>> +{
>>>> +	return true;
>>>> +}
>>>>  #endif
>>>>  
>>>>  struct vif_device {
>>>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>>>> index 2a795d2..a714f55 100644
>>>> --- a/net/ipv4/ipmr.c
>>>> +++ b/net/ipv4/ipmr.c
>>>> @@ -320,6 +320,16 @@ static unsigned int ipmr_rules_seq_read(struct net *net)
>>>>  }
>>>>  #endif
>>>>  
>>>> +bool ipmr_rule_default(const struct fib_rule *rule)
>>>> +{
>>>> +#if IS_ENABLED(CONFIG_FIB_RULES)
>>>> +	return fib_rule_matchall(rule) && rule->table == RT_TABLE_DEFAULT;
>>>> +#else
>>>> +	return true;
>>>> +#endif
>>> In patch 02, You have the following, can you do the same for the above?
>>> +#ifdef CONFIG_IP_MROUTE
>>> +void ipmr_cache_free(struct mfc_cache *mfc_cache);
>>> +#else
>>> +static inline void ipmr_cache_free(struct mfc_cache *mfc_cache)
>>> +{
>>> +}
>>> +#endif
>> I don't believe this is necessary. The solution you described is often
>> used in headers. But here, I'm ok with the current code.
>>
> +1


Hmm, when re-looking at it, I think I will just use the already existing
#ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES other than adding a new one. It selects
the CONFIG_FIB_RULES, and if CONFIG_IP_MROUTE_MULTIPLE_TABLES is not defined
than only default rules can exist for the IPMR family.

I will fix it for v3.



>
>>>> +}
>>>> +EXPORT_SYMBOL(ipmr_rule_default);
>>>> +
>>>>  static inline int ipmr_hash_cmp(struct rhashtable_compare_arg *arg,
>>>>  				const void *ptr)
>>>>  {
>>>>
