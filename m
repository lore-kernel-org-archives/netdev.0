From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Thu, 29 Nov 2012 10:59:34 -0500
Message-ID: <20121129105934.3e0c3a04@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
	<1354141115.21562.101.camel@shinybook.infradead.org>
	<20121129150945.GB16478@shrek.podlesie.net>
	<1354204077.21562.172.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Mazur <krzysiek@podlesie.net>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:37284 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab2K2QAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 11:00:50 -0500
In-Reply-To: <1354204077.21562.172.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Nov 2012 15:47:57 +0000
David Woodhouse <dwmw2@infradead.org> wrote:


> @@ -1020,12 +1048,15 @@ static uint32_t fpga_tx(struct solos_card *card)
>  			if (vcc) {
>  				atomic_inc(&vcc->stats->tx);
>  				solos_pop(vcc, oldskb);
> -			} else {
> -				struct pkt_hdr *header = (void *)oldskb->data;
> -				if (le16_to_cpu(header->type) == PKT_PCLOSE)
> -					complete(&SKB_CB(oldskb)->c);
> +
> +				/*
> +				 * If it's a TX skb on a closed VCC, pclose()
> +				 * may be waiting for it...
> +				 */
> +				if (!test_bit(ATM_VF_READY, &vcc->flags))
> +					wake_up(&card->param_wq);
> +			} else
>  				dev_kfree_skb_irq(oldskb);
> -			}

the part that bothers me (and i dont have the programmer's guide for
the solos hardware) is that you are watching for the PKT_PCLOSE to be
sent to the card.  shouldnt you be watching for the PKT_PCLOSE to be
returned from the card (assuming it does such a thing) so that you can
be assured that the tx/rx for this vpi/vci pair has been "stopped"?
