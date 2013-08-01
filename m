From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/5] qlcnic: Return appropriate error code.
Date: Wed, 31 Jul 2013 17:22:14 -0700 (PDT)
Message-ID: <20130731.172214.697799957184718554.davem@davemloft.net>
References: <cover.1375314056.git.himanshu.madhani@qlogic.com>
	<0c731a62dfe618090e3f9fcd7b7dd1de0a243a33.1375314056.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	jitendra.kalsaria@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab3HAAWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:22:15 -0400
In-Reply-To: <0c731a62dfe618090e3f9fcd7b7dd1de0a243a33.1375314056.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Wed, 31 Jul 2013 17:10:58 -0400

> @@ -952,10 +952,11 @@ struct qlcnic_ipaddr {
>  #define QLCNIC_LB_BUCKET_SIZE	32
>  
>  /* QLCNIC Driver Error Code */
> -#define QLCNIC_FW_NOT_RESPOND		51
> +#define QLCNIC_FW_RESPONSE_TIMEOUT	51
>  #define QLCNIC_TEST_IN_PROGRESS		52
>  #define QLCNIC_UNDEFINED_ERROR		53
>  #define QLCNIC_LB_CABLE_NOT_CONN	54
> +#define QLCNIC_LB_IN_PROGRESS		55
>  #define QLCNIC_ILB_MAX_RCV_LOOP	10
>  
>  struct qlcnic_filter {
 ...
> @@ -1686,13 +1686,13 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
>  		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
>  			netdev_info(netdev,
>  				    "Device is resetting, free LB test resources\n");
> -			ret = -EIO;
> +			ret = -EBUSY;
>  			goto free_diag_res;
>  		}
>  		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
>  			netdev_info(netdev,
>  				    "Firmware didn't sent link up event to loopback request\n");
> -			ret = -QLCNIC_FW_NOT_RESPOND;
> +			ret = -QLCNIC_FW_RESPONSE_TIMEOUT;
>  			qlcnic_83xx_clear_lb_mode(adapter, mode);
>  			goto free_diag_res;
>  		}

You absolutely cannot do error codes this way.

It is not valid to arbitrarily mix standard E*** error codes with
custom ones you've defined in this driver such as
QLCNIC_FW_RESPONSE_TIMEOUT.

You have no idea what values EIO, EBUSY, etc. take on. They are in fact
different on every single architecture.  So they might overlap the
values you've choosen for your custom errors.

Either you use standard error codes for everything, or your own.

I'm not applying these patches, sorry.
