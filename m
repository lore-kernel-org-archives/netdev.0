From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC v6 net-next] ravb: Add dma queue interrupt support
Date: Wed, 9 Mar 2016 02:18:07 +0900
Message-ID: <CAH1o70JGx5AWOyke2AU5DwFvi58TzKbAGVJP7XbXZC2VAJHoOA@mail.gmail.com>
References: <1456674078-1316-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456674078-1316-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei-san,

2016-02-29 0:41 GMT+09:00 Yoshihiro Kaneko <ykaneko0929@gmail.com>:

[snip]

> +static bool ravb_timestamp_interrupt(struct net_device *ndev, u32 tis)
> +{

I'd like to read TIS here like ravb_queue_interrupt().


> +       if (tis & TIS_TFUF) {
> +               ravb_write(ndev, ~TIS_TFUF, TIS);
> +               ravb_get_tx_tstamp(ndev);
> +               return true;
> +       }
> +       return false;
> +}

[snip]

> +/* Timestamp/Error/gPTP interrupt handler */
> +static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
> +{
> +       struct net_device *ndev = dev_id;
> +       struct ravb_private *priv = netdev_priv(ndev);
> +       irqreturn_t result = IRQ_NONE;
> +       u32 iss, tis;
> +
> +       spin_lock(&priv->lock);
> +       /* Get interrupt status */
> +       iss = ravb_read(ndev, ISS);
> +
> +       /* Timestamp updated */
> +       if (iss & ISS_TFUS) {
> +               tis  = ravb_read(ndev, TIS);
> +               if (ravb_timestamp_interrupt(ndev, tis))
> +                       result = IRQ_HANDLED;
> +       }
> +
> +       /* Error status summary */
> +       if (iss & ISS_ES) {
> +               ravb_error_interrupt(ndev);
> +               result = IRQ_HANDLED;
> +       }
> +
> +       /* gPTP interrupt status summary */
> +       if (iss & ISS_CGIS)
> +               result = ravb_ptp_interrupt(ndev);

This assignment overwrites the result above.
How about this?
    if ((iss & ISS_CGIS) && ravb_ptp_interrupt(ndev) == IRQ_HANDLED)
            result = IRQ_HANDLED;


> +
> +       mmiowb();
> +       spin_unlock(&priv->lock);
> +       return result;
> +}
[snip]


Thanks,
kaneko
