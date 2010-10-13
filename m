From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: fix resume, request_irq after hw reset
Date: Wed, 13 Oct 2010 09:46:59 -0700 (PDT)
Message-ID: <20101013.094659.226765041.davem@davemloft.net>
References: <201010120022.13171.james@albanarts.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, jpirko@redhat.com,
	fujita.tomonori@lab.ntt.co.jp, hauke@hauke-m.de,
	Larry.Finger@lwfinger.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: james@albanarts.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201010120022.13171.james@albanarts.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Hogan <james@albanarts.com>
Date: Tue, 12 Oct 2010 00:22:12 +0100

> @@ -2309,6 +2303,12 @@ static int b44_resume(struct ssb_device *sdev)
>  	netif_device_attach(bp->dev);
>  	spin_unlock_irq(&bp->lock);
>  
> +	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
> +	if (rc) {
> +		netdev_err(dev, "request_irq failed\n");
> +		return rc;
> +	}
> +
>  	b44_enable_ints(bp);
>  	netif_wake_queue(dev);

Since you've moved the request_irq() down, you'll need to adjust
the error handling so that it undoes side effects made by this
function up until this point.

F.e. netif_device_attach() has to be undone for one thing.

Next, b44_init_rings() allocates memory that you must now free.

Etc. etc. etc.

This change is not so simple. :-)
