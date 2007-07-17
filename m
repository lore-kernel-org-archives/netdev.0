From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/1] 8139cp: implement the missing dev->tx_timeout
Date: Mon, 16 Jul 2007 22:24:44 -0300
Message-ID: <39e6f6c70707161824q6dbee063y15d0a12563fa813c@mail.gmail.com>
References: <4693B6ED.5030102@garzik.org>
	 <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com>
	 <20070713210535.GB18669@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mika.Lansirinne@stonesoft.com, "Jeff Garzik" <jeff@garzik.org>,
	netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:42461 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbXGQBYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:24:46 -0400
Received: by ug-out-1314.google.com with SMTP id j3so51580ugf
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2007 18:24:45 -0700 (PDT)
In-Reply-To: <20070713210535.GB18669@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/13/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
> ---
>  drivers/net/8139cp.c |   27 ++++++++++++++++++++++++---
>  1 files changed, 24 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
> index 807e699..e970e64 100644
> --- a/drivers/net/8139cp.c
> +++ b/drivers/net/8139cp.c
> @@ -26,7 +26,6 @@
>
>         TODO:
>         * Test Tx checksumming thoroughly
> -       * Implement dev->tx_timeout
>
>         Low priority TODO:
>         * Complete reset on PciErr
> @@ -1218,6 +1217,30 @@ static int cp_close (struct net_device *dev)
>         return 0;
>  }
>
> +static void cp_tx_timeout(struct net_device *dev)
> +{
> +       struct cp_private *cp = netdev_priv(dev);
> +       unsigned long flags;
> +       int rc;

What is the point of this variable...

> +
> +       printk(KERN_WARNING "%s: Transmit timeout, status %2x %4x %4x %4x\n",
> +              dev->name, cpr8(Cmd), cpr16(CpCmd),
> +              cpr16(IntrStatus), cpr16(IntrMask));
> +
> +       spin_lock_irqsave(&cp->lock, flags);
> +
> +       cp_stop_hw(cp);
> +       cp_clean_rings(cp);
> +       rc = cp_init_rings(cp);

... if it is set and ...
> +       cp_start_hw(cp);
> +
> +       netif_wake_queue(dev);
> +
> +       spin_unlock_irqrestore(&cp->lock, flags);
> +
> +       return;
> +}

... never used?

- Arnaldo
