From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH v3 2/5] napi: convert trace_napi_poll to TRACE_EVENT
Date: Wed, 21 Jul 2010 16:00:15 +0900
Message-ID: <4C469AFF.1090204@jp.fujitsu.com>
References: <4C44F12F.5090908@jp.fujitsu.com> <4C44F1FB.8080309@jp.fujitsu.com> <20100720110952.GB1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:59620 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762617Ab0GUHA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 03:00:26 -0400
In-Reply-To: <20100720110952.GB1995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/07/20 20:09), Neil Horman wrote:
> On Tue, Jul 20, 2010 at 09:46:51AM +0900, Koki Sanagi wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>>
>> This patch converts trace_napi_poll from DECLARE_EVENT to TRACE_EVENT to improve
>> the usability of napi_poll tracepoint.
>>
>>           <idle>-0     [001] 241302.750777: napi_poll: napi poll on napi struct f6acc480 for device eth3
>>           <idle>-0     [000] 241302.852389: napi_poll: napi poll on napi struct f5d0d70c for device eth1
>>
>> An original patch is below.
>> http://marc.info/?l=linux-kernel&m=126021713809450&w=2
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>
>> And add a fix by Steven Rostedt.
>> http://marc.info/?l=linux-kernel&m=126150506519173&w=2
>>
>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> ---
>>  include/trace/events/napi.h |   25 +++++++++++++++++++++++--
>>  1 files changed, 23 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
>> index 188deca..8fe1e93 100644
>> --- a/include/trace/events/napi.h
>> +++ b/include/trace/events/napi.h
>> @@ -6,10 +6,31 @@
>>  
>>  #include <linux/netdevice.h>
>>  #include <linux/tracepoint.h>
>> +#include <linux/ftrace.h>
>> +
>> +#define NO_DEV "(no_device)"
>> +
>> +TRACE_EVENT(napi_poll,
>>  
>> -DECLARE_TRACE(napi_poll,
>>  	TP_PROTO(struct napi_struct *napi),
>> -	TP_ARGS(napi));
>> +
>> +	TP_ARGS(napi),
>> +
>> +	TP_STRUCT__entry(
>> +		__field(	struct napi_struct *,	napi)
>> +		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
>> +	),
>> +
>> +	TP_fast_assign(
>> +		__entry->napi = napi;
>> +		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
>> +	),
>> +
>> +	TP_printk("napi poll on napi struct %p for device %s",
>> +		__entry->napi, __get_str(dev_name))
>> +);
>> +
>> +#undef NO_DEV
>>  
>>  #endif /* _TRACE_NAPI_H_ */
>>  
>>
> NAK, This change will create a build break in the drop monitor code.  You'll
> need to fix that up if you want to make this change.
> Neil
> 
I built a kernel with CONFIG_NET_DROP_MONITOR=y.
But build break did not occur.

Thanks,
Koki Sanagi.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


