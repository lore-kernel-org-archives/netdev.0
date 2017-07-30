From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v12 1/4] net netlink: Add new type NLA_BITFIELD32
Date: Sun, 30 Jul 2017 15:59:10 -0400
Message-ID: <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-2-git-send-email-jhs@emojatatu.com>
 <20170730184242.GA1872@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34973 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754481AbdG3T7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 15:59:13 -0400
Received: by mail-it0-f66.google.com with SMTP id v127so18510518itd.2
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 12:59:13 -0700 (PDT)
In-Reply-To: <20170730184242.GA1872@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri,

This is getting exhausting, seriously.
I posted the code you are commenting one two days ago so i dont have to
repost.

On D. Ahern: I dont think we are disagreeing anymore on the need to
generalize the check. He is saying it should be a helper and I already
had the validation data; either works. I dont see the gapping need
to remove the validation data.

cheers,
jamal

On 17-07-30 02:42 PM, Jiri Pirko wrote:
> Sun, Jul 30, 2017 at 07:24:49PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Generic bitflags attribute content sent to the kernel by user.
>> With this netlink attr type the user can either set or unset a
>> flag in the kernel.
>>
>> The value is a bitmap that defines the bit values being set
>> The selector is a bitmask that defines which value bit is to be
>> considered.
>>
>> A check is made to ensure the rules that a kernel subsystem always
>> conforms to bitflags the kernel already knows about. i.e
>> if the user tries to set a bit flag that is not understood then
>> the _it will be rejected_.
>>
>> In the most basic form, the user specifies the attribute policy as:
>> [ATTR_GOO] = { .type = NLA_BITFIELD32, .validation_data = &myvalidflags },
>>
>> where myvalidflags is the bit mask of the flags the kernel understands.
>>
>> If the user _does not_ provide myvalidflags then the attribute will
>> also be rejected.
>>
>> Examples:
>> value = 0x0, and selector = 0x1
>> implies we are selecting bit 1 and we want to set its value to 0.
>>
>> value = 0x2, and selector = 0x2
>> implies we are selecting bit 2 and we want to set its value to 1.
>>
>> Suggested-by: Jiri Pirko <jiri@mellanox.com>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>> include/net/netlink.h        | 16 ++++++++++++++++
>> include/uapi/linux/netlink.h | 17 +++++++++++++++++
>> lib/nlattr.c                 | 30 ++++++++++++++++++++++++++++++
>> 3 files changed, 63 insertions(+)
>>
>> diff --git a/include/net/netlink.h b/include/net/netlink.h
>> index ef8e6c3..82dd298 100644
>> --- a/include/net/netlink.h
>> +++ b/include/net/netlink.h
>> @@ -178,6 +178,7 @@ enum {
>> 	NLA_S16,
>> 	NLA_S32,
>> 	NLA_S64,
>> +	NLA_BITFIELD32,
>> 	__NLA_TYPE_MAX,
>> };
>>
>> @@ -206,6 +207,7 @@ enum {
>>   *    NLA_MSECS            Leaving the length field zero will verify the
>>   *                         given type fits, using it verifies minimum length
>>   *                         just like "All other"
>> + *    NLA_BITFIELD32      A 32-bit bitmap/bitselector attribute
>>   *    All other            Minimum length of attribute payload
>>   *
>>   * Example:
>> @@ -213,11 +215,13 @@ enum {
>>   * 	[ATTR_FOO] = { .type = NLA_U16 },
>>   *	[ATTR_BAR] = { .type = NLA_STRING, .len = BARSIZ },
>>   *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
>> + *	[ATTR_GOO] = { .type = NLA_BITFIELD32, .validation_data = &myvalidflags },
> 
> Checkpatch warns you about the line to long, please wrap it.
> 
> Btw, I did not see you reached a consensus with DavidA regarding this.
> Did I miss it?
> 
> 
>>   * };
>>   */
>> struct nla_policy {
>> 	u16		type;
>> 	u16		len;
>> +	void            *validation_data;
>> };
>>
>> /**
>> @@ -1203,6 +1207,18 @@ static inline struct in6_addr nla_get_in6_addr(const struct nlattr *nla)
>> }
>>
>> /**
>> + * nla_get_bitfield32 - return payload of 32 bitfield attribute
>> + * @nla: nla_bitfield32 attribute
>> + */
>> +static inline struct nla_bitfield32 nla_get_bitfield32(const struct nlattr *nla)
>> +{
>> +	struct nla_bitfield32 tmp;
>> +
>> +	nla_memcpy(&tmp, nla, sizeof(tmp));
>> +	return tmp;
>> +}
>> +
>> +/**
>>   * nla_memdup - duplicate attribute memory (kmemdup)
>>   * @src: netlink attribute to duplicate from
>>   * @gfp: GFP mask
>> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
>> index f86127a..f4fc9c9 100644
>> --- a/include/uapi/linux/netlink.h
>> +++ b/include/uapi/linux/netlink.h
>> @@ -226,5 +226,22 @@ struct nlattr {
>> #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
>> #define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))
>>
>> +/* Generic 32 bitflags attribute content sent to the kernel.
>> + *
>> + * The value is a bitmap that defines the values being set
>> + * The selector is a bitmask that defines which value is legit
>> + *
>> + * Examples:
>> + *  value = 0x0, and selector = 0x1
>> + *  implies we are selecting bit 1 and we want to set its value to 0.
>> + *
>> + *  value = 0x2, and selector = 0x2
>> + *  implies we are selecting bit 2 and we want to set its value to 1.
>> + *
>> + */
>> +struct nla_bitfield32 {
>> +	__u32 value;
>> +	__u32 selector;
>> +};
>>
>> #endif /* _UAPI__LINUX_NETLINK_H */
>> diff --git a/lib/nlattr.c b/lib/nlattr.c
>> index fb52435..ee79b7a 100644
>> --- a/lib/nlattr.c
>> +++ b/lib/nlattr.c
>> @@ -27,6 +27,30 @@
>> 	[NLA_S64]	= sizeof(s64),
>> };
>>
>> +static int validate_nla_bitfield32(const struct nlattr *nla,
>> +				   u32 *valid_flags_allowed)
>> +{
>> +	const struct nla_bitfield32 *bf = nla_data(nla);
>> +	u32 *valid_flags_mask = valid_flags_allowed;
> 
> I pointed this out already. This weird.
> You do *u32 = *u32, just with different name. Just use valid_flags_allowed
> directly.
> 
> 
>> +
>> +	if (!valid_flags_allowed)
>> +		return -EINVAL;
>> +
>> +	/*disallow invalid bit selector */
> 
> Fix all the comments in this function. Should be
> 	/* something */
> with spaces in front and at the end.
> 
> 
>> +	if (bf->selector & ~*valid_flags_mask)
>> +		return -EINVAL;
>> +
>> +	/*disallow invalid bit values */
>> +	if (bf->value & ~*valid_flags_mask)
>> +		return -EINVAL;
>> +
>> +	/*disallow valid bit values that are not selected*/
>> +	if (bf->value & ~bf->selector)
>> +		return -EINVAL;
>> +
>> +	return 0;
>> +}
>> +
>> static int validate_nla(const struct nlattr *nla, int maxtype,
>> 			const struct nla_policy *policy)
>> {
>> @@ -46,6 +70,12 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
>> 			return -ERANGE;
>> 		break;
>>
>> +	case NLA_BITFIELD32:
>> +		if (attrlen != sizeof(struct nla_bitfield32))
>> +			return -ERANGE;
>> +
>> +		return validate_nla_bitfield32(nla, pt->validation_data);
>> +
>> 	case NLA_NUL_STRING:
>> 		if (pt->len)
>> 			minlen = min_t(int, attrlen, pt->len + 1);
>> -- 
>> 1.9.1
>>
