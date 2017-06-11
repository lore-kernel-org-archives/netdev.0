From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Sun, 11 Jun 2017 13:38:58 -0400
Message-ID: <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
 <20170611134924.GA1896@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34607 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbdFKRjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 13:39:10 -0400
Received: by mail-io0-f193.google.com with SMTP id a96so8767580ioj.1
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 10:39:10 -0700 (PDT)
In-Reply-To: <20170611134924.GA1896@nanopsycho.orion>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-11 09:49 AM, Jiri Pirko wrote:
> Sun, Jun 11, 2017 at 01:53:43PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>


>> This patch also provides an extra feature: a validation callback
>> that could be speaciliazed for other types.
> 
> s/speaciliazed/speciliazed/
> 

Will fix.


>>
>> [ATTR_GOO] = { .type = MYTYPE,
>> 	       .validation_data = &myvalidation_data,
>>                .validate_content = mycontent_validator },
> 
> Indent is wrong. (Does not matter really in desc, but anyway)
>

I cant find out how it got indented that way; my source
or email dont show it as such (but really doesnt matter).


> Suggested-by: Jiri Pirko <jiri@mellanox.com>
> 

Will add.

> 
>> ---
>> include/net/netlink.h          | 11 +++++++++++
>> include/uapi/linux/rtnetlink.h | 17 +++++++++++++++++
>> lib/nlattr.c                   | 25 +++++++++++++++++++++++++
>> 3 files changed, 53 insertions(+)
>>
>> diff --git a/include/net/netlink.h b/include/net/netlink.h
>> index 0170917..8ab9784 100644
>> --- a/include/net/netlink.h
>> +++ b/include/net/netlink.h
>> @@ -6,6 +6,11 @@
>> #include <linux/jiffies.h>
>> #include <linux/in6.h>
>>
>> +struct nla_bit_flags {
>> +	u32 nla_flag_values;
>> +	u32 nla_flag_selector;
>> +};
> 
> I don't understand why you redefine the struct here. You already have it
> defined in the uapi: struct __nla_bit_flags
> 
> Just move this (struct nla_bit_flags) to the uapi and remove
> __nla_bit_flags ?
>

I am not sure that will compile since the type is defined in netlink.h
Also, note: uapi uses _u32 and kernel uses u32 as types i.e it is pretty
common approach; i will try to move it to uapi and keep that uapi
format. If it doesnt compile without acrobatics I will keep it as is.

> 
> 
>> +



>> diff --git a/lib/nlattr.c b/lib/nlattr.c
>> index a7e0b16..78fed43 100644
>> --- a/lib/nlattr.c
>> +++ b/lib/nlattr.c
>> @@ -27,6 +27,21 @@
>> 	[NLA_S64]	= sizeof(s64),
>> };
>>
>> +static int validate_nla_bit_flags(const struct nlattr *nla, void *valid_data)
>> +{
>> +	const struct nla_bit_flags *nbf = nla_data(nla);
>> +	u32 *valid_flags_mask = valid_data;
>> +
>> +	if (!valid_data)
>> +		return -EINVAL;
>> +
>> +
> 
> Avoid one empty line here (you have 2)
> 

Will fix.

> 
>> +	if (nbf->nla_flag_values & ~*valid_flags_mask)
>> +		return -EINVAL;
>> +
>> +	return 0;
>> +}
>> +
>> static int validate_nla(const struct nlattr *nla, int maxtype,
>> 			const struct nla_policy *policy)
>> {
>> @@ -46,6 +61,13 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
>> 			return -ERANGE;
>> 		break;
>>
>> +	case NLA_FLAG_BITS:
>> +		if (attrlen != 8) /* 2 x 32 bits */
> 
> sizeof(struct nla_bit_flags) instead of 8 please, you can skip the
> comment then.
> 

Good point.

> 
>> +			return -ERANGE;
>> +
>> +		return validate_nla_bit_flags(nla, pt->validation_data);
>> +		break;
>> +
>> 	case NLA_NUL_STRING:
>> 		if (pt->len)
>> 			minlen = min_t(int, attrlen, pt->len + 1);
>> @@ -103,6 +125,9 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
>> 			return -ERANGE;
>> 	}
>>
>> +	if (pt->validate_content)
>> +		return pt->validate_content(nla, pt->validation_data);
> 
> This validation mechanism is completely independent from the added NLA_FLAG_BITS
> attr as it could be used with other attribute types. Please have it as a
> separate patch.
>


Ok - so one more patch then ;->

cheers,
jamal
