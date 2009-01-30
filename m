From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] forcedeth: mgmt unit interface
Date: Fri, 30 Jan 2009 14:35:41 -0800
Message-ID: <20090130143541.4b85f22a.akpm@linux-foundation.org>
References: <49834D5A.9000005@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35450 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752645AbZA3WgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:36:24 -0500
In-Reply-To: <49834D5A.9000005@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jan 2009 13:56:26 -0500
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
> +	for (i = 0; i < 100000; i++) {
> +		data_ready2 = readl(base + NvRegTransmitterControl);
> +		if ((data_ready & NVREG_XMITCTL_DATA_READY) != (data_ready2 & NVREG_XMITCTL_DATA_READY))
> +			break;
> +		udelay(50);
> +	}
> +
> +	if (i == 100000 || (data_ready2 & NVREG_XMITCTL_DATA_ERROR))
> +		return 0;
> +
> +	np->mgmt_version = readl(base + NvRegMgmtUnitVersion) & NVREG_MGMTUNITVERSION;
> +
> +	return 1;
> +}

A five second busy-wait still sucks :(

Why not do

	start = jiffies;
	while (time_before(jiffies, start + 5*HZ)) {
		...
		schedule_timeout_uninterruptible(1);
	}

?
