From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] rtnetlink: Mask the rta_type when range checking
Date: Wed, 13 Mar 2013 11:41:46 -0400
Message-ID: <51409E3A.2070801@redhat.com>
References: <1363184338-15781-1-git-send-email-vyasevic@redhat.com> <20130313083654.01d9c924@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932391Ab3CMPlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 11:41:55 -0400
In-Reply-To: <20130313083654.01d9c924@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2013 11:36 AM, Stephen Hemminger wrote:
> On Wed, 13 Mar 2013 10:18:58 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> Range/validity checks on rta_type in rtnetlink_rcv_msg() do
>> not account for flags that may be set.  This causes the function
>> to return -EINVAL when flags are set on the type (for example
>> NLA_F_NESTED).
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   net/core/rtnetlink.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 1868625..dc5edf1 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2538,7 +2538,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>>   		struct rtattr *attr = (void *)nlh + NLMSG_ALIGN(min_len);
>>
>>   		while (RTA_OK(attr, attrlen)) {
>> -			unsigned int flavor = attr->rta_type;
>> +			unsigned int flavor = attr->rta_type & NLA_TYPE_MASK;
>>   			if (flavor) {
>>   				if (flavor > rta_max[sz_idx])
>>   					return -EINVAL;
>
> No. This is effectively an ABI change. It adds nothing.
>

It makes nested IFLA_PROTINFO work that the bridge code expects. 
Without this change, sending a nested IFLA_PROTINFO causes a EIVNAL
return.

-vlad

> The NLA_F_NESTED attribute wasn't in the first generation version of netlink
> (before my time with Linux). It doesn't make sense to all of sudden start
> accepting it on requests. Also, then you would expect the query to set
> the NESTED flag as well, and that would be another ABI change.
>
