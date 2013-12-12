From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH] sctp: loading sctp when load sctp_probe
Date: Thu, 12 Dec 2013 22:58:58 +0800
Message-ID: <52A9CF32.3060000@gmail.com>
References: <52A9ACE4.3080506@huawei.com> <20131212135406.GA783@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36552 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab3LLO6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:58:36 -0500
In-Reply-To: <20131212135406.GA783@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>

On 2013/12/12 21:54, Neil Horman wrote:
> On Thu, Dec 12, 2013 at 08:32:36PM +0800, Wang Weidong wrote:
>> when I modprobe sctp_probe, it failed with "FATAL: ". I found that
>> sctp should load before sctp_probe register jprobe. So I add a
>> sctp_setup_jprobe for loading 'sctp' when first failed to register
>> jprobe, just do this similar to dccp_probe.
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/sctp/probe.c | 13 ++++++++++++-
>>   1 file changed, 12 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
>> index 53c452e..cd9565a 100644
>> --- a/net/sctp/probe.c
>> +++ b/net/sctp/probe.c
>> @@ -182,6 +182,17 @@ static struct jprobe sctp_recv_probe = {
>>   	.entry	= jsctp_sf_eat_sack,
>>   };
>>
>> +static __init int sctp_setup_jprobe(void)
>> +{
>> +	int ret = register_jprobe(&sctp_recv_probe);
>> +
>> +	if (ret) {
>> +		request_module("sctp");
>> +		ret = register_jprobe(&sctp_recv_probe);
>> +	}
>> +	return ret;
>> +}
>> +
>>   static __init int sctpprobe_init(void)
>>   {
>>   	int ret = -ENOMEM;
>> @@ -202,7 +213,7 @@ static __init int sctpprobe_init(void)
>>   			 &sctpprobe_fops))
>>   		goto free_kfifo;
>>
>> -	ret = register_jprobe(&sctp_recv_probe);
>> +	ret = sctp_setup_jprobe();
>>   	if (ret)
>>   		goto remove_proc;
>>
>> --
>> 1.7.12
>>
>>
>>
> You need to check the return code of request_module.  if sctp.ko doesn't exist,
> you'll hit exactly the same problem.
>
> You might consider also adding a MODULE_SOFTDEP macro in to the patch, so that
> the dependency is clearly visible in userspace to modprobe.
>
> Neil
>
Thanks for your suggestions. I will fix it.

Regards.
Wang

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
