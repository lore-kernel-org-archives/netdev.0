From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/2] xen-netback: limit xen vif max queues
 number to online cpus
Date: Fri, 23 Oct 2015 16:33:15 +0800
Message-ID: <5629F0CB.5030905@oracle.com>
References: <5629E796.5040203@oracle.com> <5629E8AF.9020108@oracle.com>
 <562A09E802000078000ADDE7@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, wei.liu2@citrix.com,
	"David S. Miller" <davem@davemloft.net>,
	xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39699 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbbJWId2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 04:33:28 -0400
In-Reply-To: <562A09E802000078000ADDE7@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jan,

Thanks for you review, will create new patches with your comments.

Regards,
Joe
On 10/23/2015 04:20 PM, Jan Beulich wrote:
>>>> On 23.10.15 at 09:58, <joe.jin@oracle.com> wrote:
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -68,7 +68,9 @@ unsigned int rx_stall_timeout_msecs = 60000;
>>  module_param(rx_stall_timeout_msecs, uint, 0444);
>>  
>>  unsigned int xenvif_max_queues;
>> -module_param_named(max_queues, xenvif_max_queues, uint, 0644);
>> +static int xennet_set_max_queues(const char *val, struct kernel_param *kp);
>> +module_param_call(max_queues, xennet_set_max_queues, param_get_int,
> 
> param_get_uint
> 
>> +		  &xenvif_max_queues, 0600);
> 
> Why the change from mode 0644 to 0600?
> 
>> @@ -107,6 +109,20 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue
>>  					     u16      size,
>>  					     u16      flags);
>>  
>> +static int xennet_set_max_queues(const char *val, struct kernel_param *kp)
>> +{
>> +	unsigned int cpus = num_online_cpus();
>> +	unsigned int max_queues = simple_strtoul(val, NULL, 10);
>> +
>> +	if (max_queues == 0 || max_queues > cpus) {
>> +		pr_info("max_queues %d is out of range [0 - %d]!\n", 
> 
> %u in both cases.
> 
>> +			max_queues, cpus);
>> +		return -EINVAL;
> 
> Considering the message: -ERANGE?
> 
>> +	}
>> +
>> +	return param_set_int(val, kp);
> 
> param_set_uint()
> 
>> @@ -2110,15 +2126,15 @@ int xenvif_dealloc_kthread(void *data)
>>  static int __init netback_init(void)
>>  {
>>  	int rc = 0;
>> +	unsigned int cpus = num_online_cpus();
>>  
>>  	if (!xen_domain())
>>  		return -ENODEV;
>>  
>> -	/* Allow as many queues as there are CPUs if user has not
>> -	 * specified a value.
>> -	 */
>> -	if (xenvif_max_queues == 0)
>> -		xenvif_max_queues = num_online_cpus();
>> +	/* Allow at most as many queues as CPUs. */
>> +	if (xenvif_max_queues == 0 || xenvif_max_queues > cpus)
>> +		xenvif_max_queues = cpus;
>> +	pr_info("vif max_queues: %d\n", xenvif_max_queues);
> 
> %u again.
> 
> Jan
> 


-- 
Oracle <http://www.oracle.com>
Joe Jin | Software Development Director | +8610.6106.5624
ORACLE | Linux and Virtualization
No. 24 Zhongguancun Software Park, Haidian District | 100193 Beijing 
