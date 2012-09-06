From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 06/12] qlcnic: 83xx data path and HW interfaces routines
Date: Thu, 6 Sep 2012 18:33:20 +0100
Message-ID: <1346952800.2714.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
	 <1346912529-17406-7-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42148 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932654Ab2IFRdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:33:24 -0400
In-Reply-To: <1346912529-17406-7-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 02:22 -0400, Sony Chacko wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Modify 82xx driver to support new adapter - Qlogic 83XX CNA
> Create 83xx adapter data path and hardware interface routines
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
[...]
> +int qlcnic_83xx_set_settings(struct qlcnic_adapter *adapter,
> +			     struct ethtool_cmd *ecmd)
> +{
> +	int status = 0;
> +	u32 config = adapter->ahw->port_config;
> +
> +	if (ecmd->autoneg)
> +		adapter->ahw->port_config |= BIT_15;
> +
> +	switch (ethtool_cmd_speed(ecmd)) {
> +	case SPEED_10:
> +		adapter->ahw->port_config |= BIT_8;
> +		break;
> +	case SPEED_100:
> +		adapter->ahw->port_config |= BIT_9;
> +		break;
> +	case SPEED_1000:
> +		adapter->ahw->port_config |= BIT_10;
> +		break;
> +	case SPEED_10000:
> +		adapter->ahw->port_config |= BIT_11;
> +		break;
> +	default:
> +		return -EIO;

Should be -EINVAL.

> +	}
> +
> +	status = qlcnic_83xx_set_port_config(adapter);
> +	if (status) {
> +		dev_info(&adapter->pdev->dev,
> +			 "Faild to Set Link Speed and autoneg.\n");
> +		adapter->ahw->port_config = config;
> +	}
> +	return status;
> +}
[...]
> +static u64*
> +qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
> +		       struct qlcnic_cmd_args *cmd, u64 *data, int type,
> +		       int *ret)
> +{
> +	int err, k, total_regs;
> +
> +	*ret = 0;
> +	err = qlcnic_issue_cmd(adapter, cmd);
> +	if (err != QLCNIC_RCODE_SUCCESS) {
> +		dev_info(&adapter->pdev->dev,
> +			 "Error in get statistics mailbox command\n");
> +		*ret = -EIO;
> +		return data;
> +	}
> +	total_regs = cmd->rsp.num;
> +	switch (type) {
[...]
> +	default:
> +		dev_info(&adapter->pdev->dev, "Unknown get statistics mode\n");

It seems like this default case can only be reached in case of a driver
bug, so WARN would be more appropriate.

> +		*ret = -EIO;
> +	}
> +	return data;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
