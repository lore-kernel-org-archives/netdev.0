From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V4 3/3] can: m_can: add missing message RAM initialization
Date: Fri, 07 Nov 2014 12:53:10 +0100
Message-ID: <545CB2A6.1010703@hartkopp.net>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com> <1415349914-9145-3-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, wg@grandegger.com, varkabhadram@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415349914-9145-3-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks!

Hopefully we can manage to push the patch series via can/master ;-)

Regards,
Oliver

On 07.11.2014 09:45, Dong Aisheng wrote:
> The M_CAN message RAM is usually equipped with a parity or ECC functionality.
> But RAM cells suffer a hardware reset and can therefore hold arbitrary
> content at startup - including parity and/or ECC bits.
>
> To prevent the M_CAN controller detecting checksum errors when reading
> potentially uninitialized TX message RAM content to transmit CAN
> frames the TX message RAM has to be written with (any kind of) initial
> data.
>
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
> ChangeLog:
> v3-v4:
>   * initialize the entire Message RAM in use instead of only 8 bytes
>     since this is a valid and needed initialization process.
>     Patch title also changed.
> ---
>   drivers/net/can/m_can/m_can.c | 11 ++++++++++-
>   1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> index eee1533..de742d0 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1114,7 +1114,7 @@ static int m_can_of_parse_mram(struct platform_device *pdev,
>   	struct resource *res;
>   	void __iomem *addr;
>   	u32 out_val[MRAM_CFG_LEN];
> -	int ret;
> +	int i, start, end, ret;
>
>   	/* message ram could be shared */
>   	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "message_ram");
> @@ -1165,6 +1165,15 @@ static int m_can_of_parse_mram(struct platform_device *pdev,
>   		priv->mcfg[MRAM_TXE].off, priv->mcfg[MRAM_TXE].num,
>   		priv->mcfg[MRAM_TXB].off, priv->mcfg[MRAM_TXB].num);
>
> +	/* initialize the entire Message RAM in use to avoid possible
> +	 * ECC/parity checksum errors when reading an uninitialized buffer
> +	 */
> +	start = priv->mcfg[MRAM_SIDF].off;
> +	end = priv->mcfg[MRAM_TXB].off +
> +		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
> +	for (i = start; i < end; i += 4)
> +		writel(0x0, priv->mram_base + i);
> +
>   	return 0;
>   }
>
>
