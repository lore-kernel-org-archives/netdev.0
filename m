From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH v2] sctp: loading sctp when load sctp_probe
Date: Fri, 13 Dec 2013 22:41:11 +0800
Message-ID: <52AB1C87.2010808@gmail.com>
References: <52AA783A.7090502@huawei.com> <20131213122605.GA23384@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39391 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab3LMOlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:41:24 -0500
In-Reply-To: <20131213122605.GA23384@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang weidong <wangweidong1@huawei.com>

On 2013/12/13 20:26, Neil Horman wrote:
> On Fri, Dec 13, 2013 at 11:00:10AM +0800, Wang Weidong wrote:
>> when I modprobe sctp_probe, it failed with "FATAL: ". I found that
>> sctp should load before sctp_probe register jprobe. So I add a
>> sctp_setup_jprobe for loading 'sctp' when first failed to register
>> jprobe, just do this similar to dccp_probe.
>>
>> v2: add MODULE_SOFTDEP and check of request_module, as suggested by Neil
>>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/sctp/probe.c | 17 ++++++++++++++++-
>>   1 file changed, 16 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
>> index 53c452e..5e68b94 100644
>> --- a/net/sctp/probe.c
>> +++ b/net/sctp/probe.c
>> @@ -38,6 +38,7 @@
>>   #include <net/sctp/sctp.h>
>>   #include <net/sctp/sm.h>
>>
>> +MODULE_SOFTDEP("pre: sctp");
>>   MODULE_AUTHOR("Wei Yongjun <yjwei@cn.fujitsu.com>");
>>   MODULE_DESCRIPTION("SCTP snooper");
>>   MODULE_LICENSE("GPL");
>> @@ -182,6 +183,20 @@ static struct jprobe sctp_recv_probe = {
>>   	.entry	= jsctp_sf_eat_sack,
>>   };
>>
>> +static __init int sctp_setup_jprobe(void)
>> +{
>> +	int ret = register_jprobe(&sctp_recv_probe);
>> +
>> +	if (ret) {
>> +		if (request_module("sctp"))
>> +			goto out;
>> +		ret = register_jprobe(&sctp_recv_probe);
>> +	}
>> +
>> +out:
>> +	return ret;
>> +}
>> +
>>   static __init int sctpprobe_init(void)
>>   {
>>   	int ret = -ENOMEM;
>> @@ -202,7 +217,7 @@ static __init int sctpprobe_init(void)
>>   			 &sctpprobe_fops))
>>   		goto free_kfifo;
>>
>> -	ret = register_jprobe(&sctp_recv_probe);
>> +	ret = sctp_setup_jprobe();
> You don't need to create your own function for this, you can collapse it down to
> a call to try_then_request_module(regitser_jprobe(...), "sctp");
> Neil
>
It looks good. Thanks. I will try to use it and fix in v3.

Regards.
Wang

>
>>   	if (ret)
>>   		goto remove_proc;
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
