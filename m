From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 02/27] HFI: Add HFI adapter control structure
Date: Thu, 21 Apr 2011 17:38:39 -0400
Message-ID: <4DB0A3DF.50900@linux.vnet.ibm.com>
References: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com> <1303096919-7367-3-git-send-email-dykmanj@linux.vnet.ibm.com> <1303129145.5282.1030.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37135 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753824Ab1DUWVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 18:21:03 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LM1g3m022760
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 18:01:42 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LMJo9B2339068
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 18:20:35 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LLhslk009959
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 15:43:55 -0600
In-Reply-To: <1303129145.5282.1030.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2011 8:19 AM, Ben Hutchings wrote:
> On Sun, 2011-04-17 at 23:21 -0400, dykmanj@linux.vnet.ibm.com wrote:
>> From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
>>
>> Alloc/free of hfidd_acs to track the state of each HFI
> [...]
>> --- /dev/null
>> +++ b/drivers/net/hfi/core/hfidd_adpt.c
> [...]
>> +int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
>> +{
>> +
>> +	struct hfidd_acs	*p_acs = NULL;
>> +
>> +	p_acs = kzalloc(sizeof(*p_acs), GFP_KERNEL);
>> +	if (p_acs == NULL)
>> +		return -ENOMEM;
>> +
>> +	p_acs->dev_num = devno;
>> +	p_acs->index  = MINOR(devno);
>> +	p_acs->state  = HFI_INVALID;
>> +	snprintf(p_acs->name, HFI_DEVICE_NAME_MAX - 1,
>> +			"%s%d", HFIDD_DEV_NAME, p_acs->index);
> 
> snprintf() always null-terminates so the buffer length should be
> specified as HFI_DEVICE_NAME_MAX or sizeof(p_acs->name).
> 

Ok.

> [...]
>> --- a/drivers/net/hfi/core/hfidd_init.c
>> +++ b/drivers/net/hfi/core/hfidd_init.c
> [...]
>>  static int __init hfidd_mod_init(void)
>>  {
>>  	int			rc = 0;
>>  
>> +	hfidd_global.acs_cnt = 0;
>> +
>>  	rc = hfidd_create_class();
>>  	if (rc < 0) {
>>  		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_class failed"
>> @@ -129,12 +172,26 @@ static int __init hfidd_mod_init(void)
>>  		return -1;
>>  	}
>>  
>> +	rc = hfidd_create_devices();
>> +	if (rc < 0) {
>> +		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_devices"
>> +			" failed rc = %d\n", HFIDD_DEV_NAME, rc);
>> +		goto error1;
>> +	}
>> +
>>  	printk(KERN_INFO "IBM hfi device driver loaded sucessfully\n");
>>  	return 0;
>> +
>> +error1:
>> +	hfidd_destroy_class();
>> +
>> +	/* Returning -1 so insmod will fail */
>> +	return -1;
>>  }
> [...]
> 
> Should be 'return rc'.  Never return -1 as a generic failure; it means
> -EPERM.
> 

Ok

> Ben.
> 

Jim

