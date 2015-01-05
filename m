From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v10 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 05 Jan 2015 09:56:56 +0100
Message-ID: <5940412.J23835FKcW@wuerfel>
References: <1420440691-20928-1-git-send-email-dingtianhong@huawei.com> <1420440691-20928-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, zhangfei.gao@linaro.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:51803 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbbAEI5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 03:57:25 -0500
In-Reply-To: <1420440691-20928-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 05 January 2015 14:51:31 Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
> 
> According David Miller and Arnd Bergmann's suggestion, add some modification
> for v9 version:
> - drop the workqueue
> - batch cleanup based on tx_coalesce_frames/usecs for better throughput
> - use a reasonable default tx timeout (200us, could be shorted
>   based on measurements) with a range timer
> - fix napi poll function return value
> - use a lockless queue for cleanup

The driver looks ok to me now, but it would be good if you could list
any test results you got. Did the performance improve over the previous
versions? What is the maximum latency you get now?

> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Adding my "Signed-off-by:" below yours is not the correct attribution here,
I only contributed a small part, and the last line should always list
the name of the person sending the patch. It would be ok if you change the
order of the lines to have yours last, or you could leave me out here entirely
and just mention me in the description.

> +
> +	/* FIXME: make these adjustable through ethtool */
> +	int tx_coalesce_frames;
> +	int tx_coalesce_usecs;
> +	struct hrtimer tx_coalesce_timer;

The FIXME comment that I added was meant as a suggestion for you to look
into implementing that after you got the driver working. Did you try it
out, or do you have plans to do that as a follow-up patch?

I would assume that doing so would help in the performance evaluation and
to find good default values. The numbers I used were really just guessing
as I have no insight into how the hardware behaves in real-world systems.

> +
> +	/* FIXME: eliminate this mmio access if xmit_more is set */
> +	hip04_set_xmit_desc(priv, phys);
> +	priv->tx_head = TX_NEXT(tx_head);
> +	count++;
> +	netdev_sent_queue(ndev, skb->len);

Same thing here. I would assume that implementing xmit_more support can
boost tx performance significantly, but I don't have access to the hardware
data sheet, so I don't know what kind of interaction with the hardware
is required when you want to submit multiple tx frames at once.

	Arnd
