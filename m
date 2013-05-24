From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 06/12] qlcnic: Convert nested if-else to switch-case
Date: Fri, 24 May 2013 09:36:49 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B724B@saturn3.aculab.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com> <1369379076-4718-7-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>
To: "Shahed Shaikh" <shahed.shaikh@qlogic.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42373 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750720Ab3EXImn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 04:42:43 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14765-07 for <netdev@vger.kernel.org>;
 Fri, 24 May 2013 09:42:39 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1369379076-4718-7-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -
> -	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
> +	switch (priv_level) {
> +	case QLCNIC_NON_PRIV_FUNC:
>  		ahw->op_mode = QLCNIC_NON_PRIV_FUNC;
>  		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
>  		nic_ops->init_driver = qlcnic_83xx_init_non_privileged_vnic;
> -	} else if (priv_level == QLCNIC_PRIV_FUNC) {
> +		break;
> +	case QLCNIC_PRIV_FUNC:
>  		ahw->op_mode = QLCNIC_PRIV_FUNC;
>  		ahw->idc.state_entry = qlcnic_83xx_idc_vnic_pf_entry;
>  		nic_ops->init_driver = qlcnic_83xx_init_privileged_vnic;
> -	} else if (priv_level == QLCNIC_MGMT_FUNC) {
> +		break;
> +	case QLCNIC_MGMT_FUNC:
>  		ahw->op_mode = QLCNIC_MGMT_FUNC;
>  		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
>  		nic_ops->init_driver = qlcnic_83xx_init_mgmt_vnic;
> -	} else {
> +		break;
> +	default:
> +		dev_err(&adapter->pdev->dev, "Invalid Virtual NIC opmode\n");
>  		return -EIO;
>  	}

If the NON_PRIV case happens most of the time, then the old code would
have a single conditional branch that could easily be predicted correctly.
The switch statement version will either be a compare and an indirect jump
(a pipeline stall on a lot of cpus) or a compare-branch chain.

So this is necessarily an improvent!

	David
