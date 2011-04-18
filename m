From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 02/27] HFI: Add HFI adapter control structure
Date: Mon, 18 Apr 2011 13:19:05 +0100
Message-ID: <1303129145.5282.1030.camel@localhost>
References: <1303096919-7367-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	 <1303096919-7367-3-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13830 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab1DRMTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 08:19:13 -0400
In-Reply-To: <1303096919-7367-3-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-17 at 23:21 -0400, dykmanj@linux.vnet.ibm.com wrote:
> From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
> 
> Alloc/free of hfidd_acs to track the state of each HFI
[...]
> --- /dev/null
> +++ b/drivers/net/hfi/core/hfidd_adpt.c
[...]
> +int hfidd_alloc_adapter(struct hfidd_acs **adpt, dev_t devno, void *uiop)
> +{
> +
> +	struct hfidd_acs	*p_acs = NULL;
> +
> +	p_acs = kzalloc(sizeof(*p_acs), GFP_KERNEL);
> +	if (p_acs == NULL)
> +		return -ENOMEM;
> +
> +	p_acs->dev_num = devno;
> +	p_acs->index  = MINOR(devno);
> +	p_acs->state  = HFI_INVALID;
> +	snprintf(p_acs->name, HFI_DEVICE_NAME_MAX - 1,
> +			"%s%d", HFIDD_DEV_NAME, p_acs->index);

snprintf() always null-terminates so the buffer length should be
specified as HFI_DEVICE_NAME_MAX or sizeof(p_acs->name).

[...]
> --- a/drivers/net/hfi/core/hfidd_init.c
> +++ b/drivers/net/hfi/core/hfidd_init.c
[...]
>  static int __init hfidd_mod_init(void)
>  {
>  	int			rc = 0;
>  
> +	hfidd_global.acs_cnt = 0;
> +
>  	rc = hfidd_create_class();
>  	if (rc < 0) {
>  		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_class failed"
> @@ -129,12 +172,26 @@ static int __init hfidd_mod_init(void)
>  		return -1;
>  	}
>  
> +	rc = hfidd_create_devices();
> +	if (rc < 0) {
> +		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_devices"
> +			" failed rc = %d\n", HFIDD_DEV_NAME, rc);
> +		goto error1;
> +	}
> +
>  	printk(KERN_INFO "IBM hfi device driver loaded sucessfully\n");
>  	return 0;
> +
> +error1:
> +	hfidd_destroy_class();
> +
> +	/* Returning -1 so insmod will fail */
> +	return -1;
>  }
[...]

Should be 'return rc'.  Never return -1 as a generic failure; it means
-EPERM.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

