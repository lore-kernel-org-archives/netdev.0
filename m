From: John Rose <johnrose@austin.ibm.com>
Subject: Re: [PATCH 3/5] ehea: queue management
Date: Fri, 09 Jun 2006 13:41:10 -0500
Message-ID: <1149878470.28483.6.camel@sinatra.austin.ibm.com>
References: <4487F421.2050001@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Marcus Eder <MEDER@de.ibm.com>,
	Christoph Raisch <RAISCH@de.ibm.com>, themann@de.ibm.com,
	tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:27099 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030300AbWFISl6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 14:41:58 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k59IfubZ018139
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 9 Jun 2006 14:41:56 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k59IfnRD117848
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Jun 2006 12:41:49 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k59Iftd3003344
	for <netdev@vger.kernel.org>; Fri, 9 Jun 2006 12:41:55 -0600
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <4487F421.2050001@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi-

> +#define EHEA_MEM_START 0xc000000000000000

You probably don't want to hardcode this.  Maybe KERNELBASE from page.h?

> +
> +int ehea_reg_mr_adapter(struct ehea_adapter *adapter)
> +{
> +	int i;
> +	u64 hret;
> +	u64 start = EHEA_MEM_START;
> +	u64 end = (u64) high_memory;
> +	u64 nr_pages = (end - start) / PAGE_SIZE;
> +	u32 acc_ctrl = EHEA_MEM_ACC_CTRL;
> +
> +	EDEB_EN(7, "adapter=%p", adapter);
> +
> +	hret = ehea_h_alloc_resource_mr(adapter->handle,
> +					start,
> +					end - start,
> +					acc_ctrl,
> +					adapter->pd,
> +					&adapter->mr_handle,
> +					&adapter->lkey);
> +	if (hret != H_SUCCESS) {
> +		EDEB_EX(4, "Error: hret=%lX\n", hret);
> +		return -EINVAL;
> +	}
> +
> +	for (i = 0; i < nr_pages; i++) {
> +		hret = ehea_h_register_rpage_mr(adapter->handle,
> +						adapter->mr_handle,
> +						0,
> +						0,
> +						virt_to_abs(
> +							(void *)(((u64) start)
> +							+ (i * PAGE_SIZE))),
> +						1);
> +
> +		if (((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))) {
> +			ehea_h_free_resource_mr(adapter->handle, adapter->mr_handle);
> +			EDEB_EX(4, " register rpage_mr: hret=%lX\n", hret);
> +			return -EINVAL;
> +		}
> +	}

This creates DMA mappings for the entirety of kernel memory, right?  Has
this been run by the ppc64 folks for possible impacts?

Thanks-
John

