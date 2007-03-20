From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] Netpoll support for Sibyte MAC
Date: Tue, 20 Mar 2007 17:34:01 +0300
Message-ID: <45FFF0D9.4020905@ru.mvista.com>
References: <20070319224311.GA10176@plexity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, jeff@garzik.org,
	linux-mips@linux-mips.org, Manish Lachwani <mlachwani@mvista.com>
To: dsaxena@plexity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:58369 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933534AbXCTOd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 10:33:27 -0400
In-Reply-To: <20070319224311.GA10176@plexity.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Deepak Saxena wrote:

> NETPOLL support for Sibyte MAC

> Index: linux-2.6.18/drivers/net/sb1250-mac.c
> ===================================================================
> --- linux-2.6.18.orig/drivers/net/sb1250-mac.c
> +++ linux-2.6.18/drivers/net/sb1250-mac.c
> @@ -1128,6 +1128,26 @@ static void sbdma_fillring(sbmacdma_t *d
>  	}
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void sbmac_netpoll(struct net_device *netdev)
> +{
> +	struct sbmac_softc *sc = netdev_priv(netdev);
> +	int irq = sc->sbm_dev->irq;
> +
> +	__raw_writeq(0, sc->sbm_imr);
> +

    Thinking about it again, I'm not sure that blindly writing to the chip 
reg. to mask interrupts is SMP-safe enough (versus disable_irq()).  I know why 
it was done this way -- to quell the BUG emitted in the realtime mode on SMP 
-- because of scheduling with disabled interrupts in synchoronize_irq(), but 
after having spent much time on netpoll, I'm no longer sure that anything but 
disable_irq() is safe enough for SMP since -- otherwise there's no warranty 
that sbmac_intr() is not running on another CPU...

> +	sbmac_intr(irq, netdev, NULL);
> +
> +#ifdef CONFIG_SBMAC_COALESCE
> +	__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
> +	((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_RX_CH0),
> +	sc->sbm_imr);
> +#else
> +	__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) | 
> +	(M_MAC_INT_CHANNEL << S_MAC_RX_CH0), sc->sbm_imr);
> +#endif
> +}
> +#endif

WBR, Sergei
