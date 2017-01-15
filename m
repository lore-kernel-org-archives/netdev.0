From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sun, 15 Jan 2017 19:36:52 +0200
Message-ID: <040c6876-a323-0a35-229f-46bc33b6de11@mellanox.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <20170108171251.GF1971@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>, "David S. Miller" <davem@davemloft.net>,
        <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0089.outbound.protection.outlook.com ([104.47.1.89]:50208
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751223AbdAORhF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 12:37:05 -0500
In-Reply-To: <20170108171251.GF1971@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/01/2017 19:12, Jiri Pirko wrote:
> Mon, Jan 02, 2017 at 03:59:49PM CET, jhs@mojatatu.com wrote:
>>
>> We have been using a cookie as well for actions (which we have been
>> using but have been too lazy to submit so far). I am going to port
>> it over to the newer kernels and post it.
>
> Hard to deal with something we can't look at :)
>
>
>> In our case that is intended to be opaque to the kernel i.e kernel
>> never inteprets it; in that case it is similar to the kernel
>> FIB protocol field.
>
> In case of this patch, kernel also never interprets it. What makes you
> think otherwise. Bot kernel, it is always a binary blob.
>
>
>>
>> In your case - could this cookie have been a class/flowid
>> (a 32 bit)?
>> And would it not make more sense for it the cookie to be
>> generic to all classifiers? i.e why is it specific to flower?
>
> Correct, makes sense to have it generic for all cls and perhaps also
> acts.
>
>

Hi all,
I've started implementing a general cookie for all classifiers,
I added the cookie on tcf_proto struct but then I realized that it won't 
work as I want. What I want is cookie per internal element (those that 
are identified by handles), which we can have many per one tcf_proto:

tc filter add dev <DEV> parent ffff: prio 1 cookie 0x123 basic action drop
tc filter add dev <DEV> parent ffff: prio 1 cookie 0x456 "port6" basic 
action drop
tc filter add dev <DEV> parent ffff: prio 1 cookie 0x777 basic action drop

So there is three options to do that:
1) Implement it in each classifier, using some generic function. (kinda 
like stats, where classifiler_dump() calls tcf_exts_dump_stats())
2) Have a global hash table for cookies [prio,handle]->[cookie]
3) Have it on flower only for now :)

With the first one we will have to change each classifier (or leave it 
unsupported as default).
Second is less code to change (instead of changing each classifier), but 
might be slower. I'm afraid how it will affect dumping several filters.
Third is this patch.

Thanks,
Paul.



>>
>> cheers,
>> jamal
>>
>> On 17-01-02 08:13 AM, Paul Blakey wrote:
>>> This is to support saving extra data that might be helpful on retrieval.
>>> First use case is upcoming openvswitch flow offloads, extra data will
>>> include UFID and port mappings for each added flow.
>>>
>>> Signed-off-by: Paul Blakey <paulb@mellanox.com>
>>> Reviewed-by: Roi Dayan <roid@mellanox.com>
>>> Acked-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  include/uapi/linux/pkt_cls.h |  3 +++
>>>  net/sched/cls_flower.c       | 22 +++++++++++++++++++++-
>>>  2 files changed, 24 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>>> index cb4bcdc..ca9bbe3 100644
>>> --- a/include/uapi/linux/pkt_cls.h
>>> +++ b/include/uapi/linux/pkt_cls.h
>>> @@ -471,10 +471,13 @@ enum {
>>>  	TCA_FLOWER_KEY_ICMPV6_TYPE,	/* u8 */
>>>  	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
>>>
>>> +	TCA_FLOWER_COOKIE,		/* binary */
>>> +
>>>  	__TCA_FLOWER_MAX,
>>>  };
>>>
>>>  #define TCA_FLOWER_MAX (__TCA_FLOWER_MAX - 1)
>>> +#define FLOWER_MAX_COOKIE_SIZE 128
>>>
>>>  enum {
>>>  	TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT = (1 << 0),
>>> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
>>> index 333f8e2..e2f5b25 100644
>>> --- a/net/sched/cls_flower.c
>>> +++ b/net/sched/cls_flower.c
>>> @@ -85,6 +85,8 @@ struct cls_fl_filter {
>>>  	struct rcu_head	rcu;
>>>  	struct tc_to_netdev tc;
>>>  	struct net_device *hw_dev;
>>> +	size_t cookie_len;
>>> +	long cookie[0];
>>>  };
>>>
>>>  static unsigned short int fl_mask_range(const struct fl_flow_mask *mask)
>>> @@ -794,6 +796,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>>>  	struct cls_fl_filter *fnew;
>>>  	struct nlattr *tb[TCA_FLOWER_MAX + 1];
>>>  	struct fl_flow_mask mask = {};
>>> +	const struct nlattr *attr;
>>> +	size_t cookie_len = 0;
>>> +	void *cookie;
>>>  	int err;
>>>
>>>  	if (!tca[TCA_OPTIONS])
>>> @@ -806,10 +811,22 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>>>  	if (fold && handle && fold->handle != handle)
>>>  		return -EINVAL;
>>>
>>> -	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
>>> +	if (tb[TCA_FLOWER_COOKIE]) {
>>> +		attr = tb[TCA_FLOWER_COOKIE];
>>> +		cookie_len = nla_len(attr);
>>> +		cookie = nla_data(attr);
>>> +		if (cookie_len > FLOWER_MAX_COOKIE_SIZE)
>>> +			return -EINVAL;
>>> +	}
>>> +
>>> +	fnew = kzalloc(sizeof(*fnew) + cookie_len, GFP_KERNEL);
>>>  	if (!fnew)
>>>  		return -ENOBUFS;
>>>
>>> +	fnew->cookie_len = cookie_len;
>>> +	if (cookie_len)
>>> +		memcpy(fnew->cookie, cookie, cookie_len);
>>> +
>>>  	err = tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
>>>  	if (err < 0)
>>>  		goto errout;
>>> @@ -1151,6 +1168,9 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>>>
>>>  	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
>>>
>>> +	if (f->cookie_len)
>>> +		nla_put(skb, TCA_FLOWER_COOKIE, f->cookie_len, f->cookie);
>>> +
>>>  	if (tcf_exts_dump(skb, &f->exts))
>>>  		goto nla_put_failure;
>>>
>>>
>>
