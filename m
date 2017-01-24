From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net v2 2/2] lwtunnel: Fix oops on state free after encap
 module unload
Date: Tue, 24 Jan 2017 16:26:21 +0000
Message-ID: <537e4ef5-6daa-a95d-e004-5700a8533f04@brocade.com>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
 <1484958086-6151-1-git-send-email-rshearma@brocade.com>
 <1484958086-6151-3-git-send-email-rshearma@brocade.com>
 <20170123.154248.261820530578170635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tom@herbertland.com>,
        <roopa@cumulusnetworks.com>, <david.lebrun@uclouvain.be>,
        <tgraf@suug.ch>, <dsa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46834 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750713AbdAXQ0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:26:52 -0500
In-Reply-To: <20170123.154248.261820530578170635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/01/17 20:42, David Miller wrote:
> From: Robert Shearman <rshearma@brocade.com>
> Date: Sat, 21 Jan 2017 00:21:26 +0000
>
>> @@ -115,8 +115,12 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
>>  	ret = -EOPNOTSUPP;
>>  	rcu_read_lock();
>
> Here 'ret' equals -EOPNOTSUPP
>
>>  	ops = rcu_dereference(lwtun_encaps[encap_type]);
>> -	if (likely(ops && ops->build_state))
>> -		ret = ops->build_state(dev, encap, family, cfg, lws);
>> +	if (likely(ops)) {
>> +		if (likely(try_module_get(ops->owner) && ops->build_state))
>> +			ret = ops->build_state(dev, encap, family, cfg, lws);
>> +		if (ret)
>> +			module_put(ops->owner);
>
> If try_module_get() fails, 'ret' will still be -EOPNOTSUPP and we will
> module_put() on a module we did not grab a reference to.
>
> I think you need to adjust the logic here.  You only want to 'put' if
> try_module_get() succeeds and ->build_state() returns an error.

Indeed, good point. Will address in a v3 shortly.

Thanks,
Rob
