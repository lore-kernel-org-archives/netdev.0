From: John Allen <jallen@linux.vnet.ibm.com>
Subject: Re: [PATCH net 3/4] ibmvnic: simplify and improve driver probe
 function
Date: Thu, 7 Jul 2016 14:31:00 -0500
Message-ID: <b9d427e9-841f-1959-1f58-82166c9b510a@linux.vnet.ibm.com>
References: <1467837318-31710-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <1467837318-31710-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: nfont@linux.vnet.ibm.com
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:20950 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751400AbcGGTaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 15:30:46 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u67JSoqO132037
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2016 15:30:45 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xn0dwu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 15:30:45 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
	Thu, 7 Jul 2016 13:30:44 -0600
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 27D921FF0049
	for <netdev@vger.kernel.org>; Thu,  7 Jul 2016 13:30:11 -0600 (MDT)
In-Reply-To: <1467837318-31710-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/2016 03:35 PM, Thomas Falcon wrote:
> @@ -3560,6 +3608,7 @@ static const struct file_operations ibmvnic_dump_ops = {
> 
>  static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
>  {
> +	unsigned long timeout = msecs_to_jiffies(30000);
>  	struct ibmvnic_adapter *adapter;
>  	struct net_device *netdev;
>  	unsigned char *mac_addr_p;
> @@ -3638,30 +3687,26 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
>  	ibmvnic_send_crq_init(adapter);
> 
>  	init_completion(&adapter->init_done);
> -	wait_for_completion(&adapter->init_done);
> +	if (!wait_for_completion_timeout(&adapter->init_done, timeout))
> +		return 0;
> 
>  	do {
> -		adapter->renegotiate = false;
> -
> -		init_sub_crqs(adapter, 0);
> -		reinit_completion(&adapter->init_done);
> -		wait_for_completion(&adapter->init_done);
> -
>  		if (adapter->renegotiate) {
> -			release_sub_crqs(adapter);
> +			adapter->renegotiate = false;
> +			release_sub_crqs_no_irqs(adapter);
>  			send_cap_queries(adapter);
> 
>  			reinit_completion(&adapter->init_done);
> -			wait_for_completion(&adapter->init_done);
> +			if (!wait_for_completion_timeout(&adapter->init_done,
> +							 timeout))
> +				return 0;
>  		}
>  	} while (adapter->renegotiate);

Instead of a do-while here, this should just be simplified to a while loop.

while (adapter->renegotiate) {
	...
}

will serve the same purpose as

do {
	if (adapter->renegotiate) {
		...
	}
} while (adapter->renegotiate);

Same goes for the similar loop in patch 4/4.
