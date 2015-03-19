From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 03/10] amd-xgbe-phy: Provide support for
 auto-negotiation timeout
Date: Thu, 19 Mar 2015 16:16:42 -0400 (EDT)
Message-ID: <20150319.161642.52123219885309637.davem@davemloft.net>
References: <20150319200808.28321.37307.stgit@tlendack-t1.amdoffice.net>
	<20150319200826.28321.19581.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbCSUQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 16:16:45 -0400
In-Reply-To: <20150319200826.28321.19581.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 19 Mar 2015 15:08:26 -0500

> @@ -902,8 +906,23 @@ static enum amd_xgbe_phy_an amd_xgbe_an_page_received(struct phy_device *phydev)
>  {
>  	struct amd_xgbe_phy_priv *priv = phydev->priv;
>  	enum amd_xgbe_phy_rx *state;
> +	struct timespec64 rcv_time, diff_time;
>  	int ret;
>  
> +	getnstimeofday64(&rcv_time);
> +	if (!timespec64_to_ns(&priv->an_start)) {
> +		priv->an_start = rcv_time;
> +	} else {
> +		diff_time = timespec64_sub(rcv_time, priv->an_start);
> +		if (timespec64_to_ns(&diff_time) > XGBE_AN_NS_TIMEOUT) {
> +			/* Auto-negotiation timed out, reset state */
> +			priv->kr_state = AMD_XGBE_RX_BPA;
> +			priv->kx_state = AMD_XGBE_RX_BPA;
> +
> +			priv->an_start = rcv_time;
> +		}
> +	}
> +

timespec is a little bit heavyweight for something like this, you just
want to snapshot a point in time then later check if a certain number
of ms have passed or not.

For that, plain 'jiffies' is sufficient.
