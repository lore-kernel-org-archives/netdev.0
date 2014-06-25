From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] rtnetlink: allow to register ops without
 ops->setup set
Date: Wed, 25 Jun 2014 18:31:08 +0200
Message-ID: <20140625163108.GB2972@minipsycho.orion>
References: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
 <87tx79vvah.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:46857 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757687AbaFYQbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 12:31:13 -0400
Received: by mail-wi0-f179.google.com with SMTP id cc10so2880235wib.0
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 09:31:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87tx79vvah.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 25, 2014 at 05:55:02PM CEST, ebiederm@xmission.com wrote:
>Jiri Pirko <jiri@resnulli.us> writes:
>
>> So far, it is assumed that ops->setup is filled up. But there might be
>> case that ops might make sense even without ->setup. In that case,
>> forbid to newlink and dellink.
>
>This patch does not handle all cases of dellink, and so you have created
>a way to oops the kernel.  One case that is not handled is
>default_device_exit_batch.

Thanks. Missed that.

>
>Further using !setup to prevent dellink does not make any kind of
>logical sense.  Which leads to a maintenance hazard.  Aka how can we
>further update this code without running into weird corner cases.

You are right. Changed this in next patch iteration.


>
>Further you have not given a description why anyone would want to have
>something that is almost completely unlike rtnl link operations
>implemented with the rtnl link operations.


Well the main reason is that this is consistent way of telling what kind
of netdevice or slave kind this is to userspace. I do not see any reason
to do it in some other way. We just would not use rtnllinkops to its full
potential in cases like this, which is I believe ok.

I will extend the patch desc.

Thanks for review Eric.

>
>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/core/rtnetlink.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> index 1063996..84affd7 100644
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -1777,7 +1777,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
>>  		return -ENODEV;
>>  
>>  	ops = dev->rtnl_link_ops;
>> -	if (!ops)
>> +	if (!ops || !ops->setup)
>>  		return -EOPNOTSUPP;
>>  
>>  	ops->dellink(dev, &list_kill);
>> @@ -2038,6 +2038,9 @@ replay:
>>  			return -EOPNOTSUPP;
>>  		}
>>  
>> +		if (!ops->setup)
>> +			return -EOPNOTSUPP;
>> +
>>  		if (!ifname[0])
>>  			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
