From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Fixes kernel crashes when speed of cable
	connected changes
Date: Fri, 27 Jun 2008 18:54:22 +1000
Message-ID: <1214556862.8011.534.camel@pasglop>
References: <1214225694-25815-1-git-send-email-sr@denx.de>
	 <1214263216.8011.276.camel@pasglop>
	 <1946a170806262354k582ad86asc9a1a8383aad45a4@mail.gmail.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: SathyaNarayanan <sathyan@teamf1.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52001 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755308AbYF0Iyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 04:54:37 -0400
In-Reply-To: <1946a170806262354k582ad86asc9a1a8383aad45a4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>         
>         >       for (i = 0; i < NUM_TX_BUFF; ++i) {
>         > -             if (dev->tx_skb[i]) {
>         > +             if (dev->tx_skb[i] &&
>         dev->tx_desc[i].data_ptr) {
>         
>         
>         Why changing the test above ?
> 
>    The reason for changing this condition is ,  In any of the case if
> the dev->tx_skb is not containing valid address, Then while clearing
> it you may be resulted in "address voilations". This additional
> condition ensures that we are clearing the valid skbs.
> Further this condition is not in general data flow, So this additional
> condition should not have any impact on performance.

Do you see -any- case where tx_skb[i] and dev->tx_desc[i].data_ptr would
be out of sync ? If that's the case, shouldn't we cleanup instead of
leaving some kind of stale entry in the ring ?

In addition, in pure theory, data_ptr == 0 is a valid DMA address :-) So
I think that part of the patch shouldn't be there.

>         
>         >                       dev_kfree_skb(dev->tx_skb[i]);
>         >                       dev->tx_skb[i] = NULL;
>         >                       if (dev->tx_desc[i].ctrl &
>         MAL_TX_CTRL_READY)
>         > @@ -2719,6 +2719,10 @@ static int __devinit
>         emac_probe(struct of_device *ofdev,
>         >       /* Clean rings */
>         >       memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct
>         mal_descriptor));
>         >       memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct
>         mal_descriptor));
>         > +     for (i = 0; i <= NUM_TX_BUFF; i++)
>         > +             dev->tx_skb[i] = NULL;
>         > +     for (i = 0; i <= NUM_RX_BUFF; i++)
>         > +             dev->rx_skb[i] = NULL;
>         
>         
>         Why not use memset here too ?
>     Yes, It was valid to use memset here. I can send the modified
> patch for it. 

Please do, thanks.

Cheers,
Ben.



