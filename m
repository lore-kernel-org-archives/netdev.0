From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/9] qlcnic: Implement GET_LED_STATUS command
 for 82xx adapter.
Date: Sun, 14 Apr 2013 12:55:14 +0200
Message-ID: <20130414105514.GA30385@electric-eye.fr.zoreil.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
 <1365874114-6759-2-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44066 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab3DNKzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 06:55:23 -0400
Content-Disposition: inline
In-Reply-To: <1365874114-6759-2-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahed Shaikh <shahed.shaikh@qlogic.com> :
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
> index 253b3ac..3784bef 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
> @@ -1462,6 +1462,29 @@ int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
>  	return rv;
>  }
>  
> +int qlcnic_get_beacon_state(struct qlcnic_adapter *adapter, u8 *h_state)
> +{
> +	int err = 0;
> +	struct qlcnic_cmd_args cmd;

The scope of this variable could have been narrowed.

> +
> +	if (adapter->ahw->capabilities2 & QLCNIC_FW_CAPABILITY_2_BEACON) {
> +		err = qlcnic_alloc_mbx_args(&cmd, adapter,
> +					    QLCNIC_CMD_GET_LED_STATUS);
> +		if (err)
> +			goto error;
> +
> +		err = qlcnic_issue_cmd(adapter, &cmd);
> +		if (err)
> +			err = -EIO;

qlcnic_issue_cmd should return a proper error code so that there is no
reason to smash it.

> +		else
> +			*h_state = cmd.rsp.arg[1];
> +
> +		qlcnic_free_mbx_args(&cmd);
> +	}
> +error:
> +	return err;
> +}

Normal path going through an "error" label... :o/

Please compare with:

int qlcnic_get_beacon_state(struct qlcnic_adapter *adapter, u8 *h_state)
{
	struct qlcnic_cmd_args cmd;
	int rc;

	if (!(adapter->ahw->capabilities2 & QLCNIC_FW_CAPABILITY_2_BEACON))
		return 0;

	rc = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_LED_STATUS);
	if (!rc) {
		rc = qlcnic_issue_cmd(adapter, &cmd);
		if (!rc)
			*h_state = cmd.rsp.arg[1];

		qlcnic_free_mbx_args(&cmd);
	}

	return rc;
}
	
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> index c77675d..a17671d 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
[...]
> @@ -174,6 +175,14 @@ beacon_err:
>  	if (err)
>  		return err;
>  
> +	err = qlcnic_get_beacon_state(adapter, &h_beacon_state);
> +	if (err != -EIO) {
> +		if (h_beacon_state == QLCNIC_BEACON_DISABLE)
> +			adapter->ahw->beacon_state = 0;
> +		else
> +			adapter->ahw->beacon_state = 2;

Nit: what about a ternary ?

		adapter->ahw->beacon_state =
			(h_beacon_state == QLCNIC_BEACON_DISABLE) ? 0 : 2;

You should consider reworking qlcnic_store_beacon. It's in a sad state
(multiple return points and locks as well as a big inline reset path).

-- 
Ueimor
