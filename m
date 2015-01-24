From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Sat, 24 Jan 2015 13:37:12 -0800
Message-ID: <1422135432.18650.2.camel@perches.com>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Stathis Voukelatos <stathis.voukelatos@linn.co.uk>,
	abrestic@chromium.org
To: Stathis Voukelatos <stathisv70@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0116.hostedemail.com ([216.40.44.116]:49778 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753634AbbAYVCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 16:02:12 -0500
In-Reply-To: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-23 at 10:07 +0000, Stathis Voukelatos wrote:
> This patch adds support the Ethernet Packet Sniffer H/W module
> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
> The module allows Ethernet packets to be parsed, matched against
> a user-defined pattern and timestamped. It sits between a 100M
> Ethernet MAC and PHY and is completely passive with respect to
> Ethernet frames.
[]
>  include/linux/pkt_sniffer.h                        |  89 +++++

Why should this file be here?
Why not in the drivers/net/pkt-sniffer directory?

> diff --git a/drivers/net/pkt-sniffer/backends/ether/channel.c b/drivers/net/pkt-sniffer/backends/ether/channel.c
[]
> +static int esnf_start(struct snf_chan *dev);

Be nice to rearrange the code to avoid the forward declarations.

> +static int esnf_stop(struct snf_chan *dev);
> +static int esnf_set_pattern(struct snf_chan *dev, const u8 *pattern, int count);
> +static int esnf_num_recs_avail(struct snf_chan *dev);
> +static int esnf_max_ptn_entries(struct snf_chan *dev);
> +static int esnf_max_match_bytes(struct snf_chan *dev);
> +static int validate_pattern(
> +			struct ether_snf_chan *ch,
> +			const u8 *buf,
> +			int count);

[]

> +static int validate_pattern(struct ether_snf_chan *ch, const u8 *buf, int count)
> +{

Maybe better as bool

> +	int i, complete, max_copy_bytes;
[]
> +	/* Check if the string was properly terminated
> +	 * and contained valid number of commands
> +	 */
> +	if (complete) {
> +		max_copy_bytes = ch->fifo_blk_words * 4;
> +		if (ts)
> +			max_copy_bytes -= 4;
> +		if ((copy_before + copy_after) > max_copy_bytes)
> +			return 0;
> +		ch->ts_present = ts;
> +		ch->nfb_before = copy_before;
> +		ch->nfb_after = copy_after;
> +		return 1;
> +	} else {
> +		return 0;
> +	}

	return complete;

[]

> +/* Interrupt thread function */
> +static irqreturn_t esnf_irq_thread(int irq, void *dev_id)
> +{
> +	struct platform_device *pdev = (struct platform_device *)dev_id;
> +	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
> +	u32 irq_status;
> +
> +	if (unlikely(esnf->irq != irq))
> +		return IRQ_NONE;
> +
> +	irq_status = ioread32(esnf->regs + INTERRUPT_STATUS) &
> +				 ioread32(esnf->regs + INTERRUPT_ENABLE);
> +
> +	dev_dbg(&pdev->dev, "irq: 0x%08x\n", irq_status);
> +
> +	/* TX FIFO full */
> +	if (unlikely(irq_status & TX_FULL_IRQ_BIT))
> +		dev_notice(&pdev->dev, "TX FIFO full");

Missing terminating newlines
> +
> +	/* RX FIFO full */
> +	if (unlikely(irq_status & RX_FULL_IRQ_BIT))
> +		dev_notice(&pdev->dev, "RX FIFO full");
> +
> +	/* TX match data available */
> +	if (irq_status & TX_DATA_IRQ_BIT) {
> +		dev_dbg(&pdev->dev, "TX data");
> +		channel_data_available(&esnf->txc);
> +	}
> +
> +	/* RX match data available */
> +	if (irq_status & RX_DATA_IRQ_BIT) {
> +		dev_dbg(&pdev->dev, "RX data");
> +		channel_data_available(&esnf->rxc);
> +	}

> diff --git a/drivers/net/pkt-sniffer/core/nl.c b/drivers/net/pkt-sniffer/core/nl.c
[]
> +int snf_netlink_init(int id, struct snf_chan *dev, const char *name)
> +{
[]
> +	/* Allocate ops array and copy template data */
> +	nl->ops = kmalloc(sizeof(snf_ops_tmpl), GFP_KERNEL);
> +	if (!nl->ops) {
> +		ret = -ENOMEM;
> +		goto fail2;
> +	}
> +	memcpy(nl->ops, snf_ops_tmpl, sizeof(snf_ops_tmpl));

kmemdup
