From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 09/18] net: mvpp2: use named interrupts
Date: Mon, 24 Jul 2017 19:49:03 +0300
Message-ID: <80d4b082-a5ed-73da-0634-8295996dc29d@cogentembedded.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-10-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33780 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753780AbdGXQtH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:49:07 -0400
Received: by mail-lf0-f47.google.com with SMTP id p2so30988125lfg.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:49:06 -0700 (PDT)
In-Reply-To: <20170724134848.19330-10-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 04:48 PM, Antoine Tenart wrote:

> This patch update the Marvell PPv2 driver to use named interrupts. A
> compatibility path is kept to allow using device trees using the old dt
> bindings. This change is needed as other interrupts will be used by the
> PPv2 driver at some point.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index f6eb98d38ced..77eef2cc40a1 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -6789,10 +6789,20 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>
>  	port = netdev_priv(dev);
>
> -	port->irq = irq_of_parse_and_map(port_node, 0);
> -	if (port->irq <= 0) {
> -		err = -EINVAL;
> -		goto err_free_netdev;
> +	if (of_get_property(port_node, "interrupt-names", NULL)) {
> +		port->irq = of_irq_get_byname(port_node, "rx-shared");
> +		if (port->irq <= 0) {
> +			err = (port->irq == -EPROBE_DEFER) ?
> +			      -EPROBE_DEFER : -EINVAL;

    Perhaps better:

		err = port->irq ?: -EINVAL;

> +			goto err_free_netdev;
> +		}
> +	} else {
> +		/* kept for dt compatibility */
> +		port->irq = irq_of_parse_and_map(port_node, 0);
> +		if (port->irq <= 0) {

    Note that irq_of_parse_and_map() returns *unsigned int*, so negative error 
codes are not possible, 0 indicates bad IRQ.

> +			err = -EINVAL;
> +			goto err_free_netdev;
> +		}
>  	}
>
>  	if (of_property_read_bool(port_node, "marvell,loopback"))

MBR, Sergei
