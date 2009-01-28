From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: mgmt unit interface changes
Date: Tue, 27 Jan 2009 17:27:05 -0800
Message-ID: <20090127172705.d6ad4c56.akpm@linux-foundation.org>
References: <497A3046.7060202@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38857 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750888AbZA1B1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 20:27:11 -0500
In-Reply-To: <497A3046.7060202@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Jan 2009 16:01:58 -0500
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> +static int nv_mgmt_get_version(struct net_device *dev)
> +{
> +	struct fe_priv *np = netdev_priv(dev);
> +	u8 __iomem *base = get_hwbase(dev);
> +	u32 data_ready = readl(base + NvRegTransmitterControl);
> +	u32 data_ready2;
> +	int i;
> +
> +	writel(NVREG_MGMTUNITGETVERSION, base + NvRegMgmtUnitGetVersion);
> +	writel(data_ready ^ NVREG_XMITCTL_DATA_START, base + NvRegTransmitterControl);
> +	for (i = 0; i < 1000000; i++) {
> +		data_ready2 = readl(base + NvRegTransmitterControl);
> +		if ((data_ready & NVREG_XMITCTL_DATA_READY) != (data_ready2 & NVREG_XMITCTL_DATA_READY))
> +			break;
> +		udelay(50);
> +	}
> +
> +	if (i == 1000000 || (data_ready2 & NVREG_XMITCTL_DATA_ERROR))
> +		return 0;
> +
> +	np->mgmt_version = readl(base + NvRegMgmtUnitVersion) & NVREG_MGMTUNITVERSION;
> +
> +	return 1;
> +}

whee, a 50 second busy-wait.

Unnecessarily, afacit.  The sole caller calls this function from
->probe without any locks held?

I'd suggest that we

a) use schedule_timeout_uninterruptible(1) and

b) add a bit of user feedback (printk(".")?) so they don't get bored
and hit the reset button (remember those?)

