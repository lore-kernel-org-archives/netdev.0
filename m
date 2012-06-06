From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/3] qlcnic: fix unsupported CDRP command error
 message.
Date: Wed, 06 Jun 2012 11:14:07 -0700
Message-ID: <1339006447.13710.6.camel@joe2Laptop>
References: <1339004108-7356-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1339004108-7356-3-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41518 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752857Ab2FFSOI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 14:14:08 -0400
In-Reply-To: <1339004108-7356-3-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 13:35 -0400, Anirban Chakraborty wrote:
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Add debug messages for FW CDRP command failure.

trivia:

Please be consistent with the use of (preferably _no_) periods
at the end of logging messages.

$ git grep -E "[^\.]\\\\n\"" drivers/net/ethernet/qlogic/qlcnic/ | wc -l
187
$ git grep -E "\.\\\\n\"" drivers/net/ethernet/qlogic/qlcnic/ | wc -l
22

[]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
[]
> @@ -53,12 +53,39 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
>  	rsp = qlcnic_poll_rsp(adapter);
>  
>  	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
> -		dev_err(&pdev->dev, "card response timeout.\n");
> +		dev_err(&pdev->dev, "CDRP response timeout.\n");

ie: no period necessary.

CDRP is kind of an odd acronym.
Is it for CarD ResPonse?

If it is, then I think a lot of the below messages are
not particularly sensible and the CDRP should be dropped.

>  		cmd->rsp.cmd = QLCNIC_RCODE_TIMEOUT;
>  	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
>  		cmd->rsp.cmd = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
> -		dev_err(&pdev->dev, "failed card response code:0x%x\n",
> +		switch (cmd->rsp.cmd) {
> +		case QLCNIC_RCODE_INVALID_ARGS:
> +			dev_err(&pdev->dev, "CDRP invalid args: 0x%x.\n",
>  				cmd->rsp.cmd);
> +			break;
> +		case QLCNIC_RCODE_NOT_SUPPORTED:
> +		case QLCNIC_RCODE_NOT_IMPL:
> +			dev_err(&pdev->dev,
> +				"CDRP command not supported: 0x%x.\n",
> +				cmd->rsp.cmd);
> +			break;
> +		case QLCNIC_RCODE_NOT_PERMITTED:
> +			dev_err(&pdev->dev,
> +				"CDRP requested action not permitted: 0x%x.\n",
> +				cmd->rsp.cmd);
> +			break;
> +		case QLCNIC_RCODE_INVALID:
> +			dev_err(&pdev->dev,
> +				"CDRP invalid or unknown cmd received: 0x%x.\n",
> +				cmd->rsp.cmd);
> +			break;
> +		case QLCNIC_RCODE_TIMEOUT:
> +			dev_err(&pdev->dev, "CDRP command timeout: 0x%x.\n",
> +				cmd->rsp.cmd);
> +			break;
> +		default:
> +			dev_err(&pdev->dev, "CDRP command failed: 0x%x.\n",
> +				cmd->rsp.cmd);
> +		}
>  	} else if (rsp == QLCNIC_CDRP_RSP_OK) {
>  		cmd->rsp.cmd = QLCNIC_RCODE_SUCCESS;
>  		if (cmd->rsp.arg2)
> @@ -957,9 +984,6 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
>  		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
>  		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
>  		mac_stats->mac_rx_crc_error = le64_to_cpu(stats->mac_rx_crc_error);
> -	} else {
> -		dev_info(&adapter->pdev->dev,
> -			"%s: Get mac stats failed =%d.\n", __func__, err);
>  	}
>  
>  	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
