From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: ptp: fix the reference clock
Date: Wed, 27 Aug 2014 16:26:52 -0700 (PDT)
Message-ID: <20140827.162652.544817209778584023.davem@davemloft.net>
References: <1409033072-10508-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964948AbaH0X0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:26:53 -0400
In-Reply-To: <1409033072-10508-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 26 Aug 2014 08:04:32 +0200

> @@ -638,6 +638,15 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
>  	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
>  		return -EOPNOTSUPP;
>  
> +	/* Fall-back to main clock in case of no PTP ref is passed */
> +	priv->clk_ptp_ref = devm_clk_get(priv->device, "clk_ptp_ref");
> +	if (IS_ERR(priv->clk_ptp_ref)) {
> +		priv->clk_ptp_rate = clk_get_rate(priv->stmmac_clk);

This code path will leave an IS_ERR() value in clk_ptp_ref.
 ...
>  static void stmmac_release_ptp(struct stmmac_priv *priv)
>  {
> +	if (priv->clk_ptp_ref)
> +		clk_disable_unprepare(priv->clk_ptp_ref);
>  	stmmac_ptp_unregister(priv);
>  }

Which this code will erroneously pass into clk_disable_unprepare().

Please NULL the pointer out properl when devm_clk_get() errors.

Thanks.
