From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 2/2] net: qualcomm: new Ethernet over SPI driver for QCA7000
Date: Mon, 28 Apr 2014 22:09:28 +0200
Message-ID: <5020765.3GuR21cUpi@wuerfel>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <1398707697-43785-3-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.org,
	mark.rutland@arm.org, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:50193 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbaD1UJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 16:09:42 -0400
In-Reply-To: <1398707697-43785-3-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 28 April 2014 19:54:57 Stefan Wahren wrote:
> +/*   Dumps the contents of all SPI slave registers.        */
> +static int
> +qcaspi_regs_dump(struct seq_file *s, void *what)
> +{
> +	struct reg {
> +		char *name;
> +		u32 address;
> +	};
> +
> +	static struct reg regs[] = {
> +		{ "SPI_REG_BFR_SIZE", SPI_REG_BFR_SIZE },
> +		{ "SPI_REG_WRBUF_SPC_AVA", SPI_REG_WRBUF_SPC_AVA },
> +		{ "SPI_REG_RDBUF_BYTE_AVA", SPI_REG_RDBUF_BYTE_AVA },
> +		{ "SPI_REG_SPI_CONFIG", SPI_REG_SPI_CONFIG },
> +		{ "SPI_REG_SPI_STATUS", SPI_REG_SPI_STATUS },
> +		{ "SPI_REG_INTR_CAUSE", SPI_REG_INTR_CAUSE },
> +		{ "SPI_REG_INTR_ENABLE", SPI_REG_INTR_ENABLE },
> +		{ "SPI_REG_RDBUF_WATERMARK", SPI_REG_RDBUF_WATERMARK },
> +		{ "SPI_REG_WRBUF_WATERMARK", SPI_REG_WRBUF_WATERMARK },
> +		{ "SPI_REG_SIGNATURE", SPI_REG_SIGNATURE },
> +		{ "SPI_REG_ACTION_CTRL", SPI_REG_ACTION_CTRL }
> +	};
> +
> +	struct qcaspi *qca = s->private;
> +	int i;
> +
> +	for (i = 0; i < (sizeof(regs) / sizeof(struct reg)); i++) {
> +		u16 value;
> +
> +		qcaspi_read_register(qca, regs[i].address, &value);
> +		seq_printf(s, "%-25s(0x%04x): 0x%04x\n",
> +			regs[i].name, regs[i].address, value);
> +	}
> +
> +	return 0;
> +}

Shouldn't these just come through ethtool --register-dump ?

> +
> +static int
> +qcaspi_stats_show(struct seq_file *s, void *what)
> +{
> +	struct qcaspi *qca = s->private;
> +
> +	seq_printf(s, "Triggered resets    : %lu\n", qca->stats.trig_reset);
> +	seq_printf(s, "Device resets       : %lu\n", qca->stats.device_reset);
> +	seq_printf(s, "Reset timeouts      : %lu\n", qca->stats.reset_timeout);
> +	seq_printf(s, "Read errors         : %lu\n", qca->stats.read_err);
> +	seq_printf(s, "Write errors        : %lu\n", qca->stats.write_err);
> +	seq_printf(s, "Read buffer errors  : %lu\n", qca->stats.read_buf_err);
> +	seq_printf(s, "Write buffer errors : %lu\n", qca->stats.write_buf_err);
> +	seq_printf(s, "Out of memory       : %lu\n", qca->stats.out_of_mem);
> +	seq_printf(s, "Write buffer misses : %lu\n", qca->stats.write_buf_miss);
> +	seq_printf(s, "Transmit queue full : %lu\n", qca->stats.queue_full);
> +	seq_printf(s, "SPI errors          : %lu\n", qca->stats.spi_err);
> +
> +	return 0;
> +}

and ethtool --statistics

> +static int
> +qcaspi_info_show(struct seq_file *s, void *what)
> +{

There might also be an interface for these.

> +static irqreturn_t
> +qcaspi_intr_handler(int irq, void *data)
> +{
> +	struct qcaspi *qca = (struct qcaspi *) data;
> +	qca->intr_req++;
> +	if (qca->spi_thread &&
> +		qca->spi_thread->state != TASK_RUNNING)
> +		wake_up_process(qca->spi_thread);
> +
> +	return IRQ_HANDLED;
> +}

What is the advantage of using your own thread mechanism for receiving
data instead of the normal NAPI method?

	Arnd
