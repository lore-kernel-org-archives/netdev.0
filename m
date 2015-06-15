From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC,v3 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 15 Jun 2015 08:08:15 -0700
Message-ID: <1434380895.27504.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430319405-31280-1-git-send-email-madalin.bucur@freescale.com>
	 <1433958961.27504.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BL2PR03MB54503B16A47056DBA9653C0E6B80@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:35515 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbbFOPIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:08:18 -0400
In-Reply-To: <BL2PR03MB54503B16A47056DBA9653C0E6B80@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-15 at 13:40 +0000, Madalin-Cristian Bucur wrote:
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > 
> > On Wed, 2015-04-29 at 17:56 +0300, Madalin Bucur wrote:
> > > This introduces the Freescale Data Path Acceleration Architecture
> > > (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> > > BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> > > the Freescale DPAA QorIQ platforms.
> > ...
> > 
> > > +	/* We're going to store the skb backpointer at the beginning
> > > +	 * of the data buffer, so we need a privately owned skb
> > > +	 */
> > > +
> > > +	/* Code borrowed from skb_unshare(). */
> > > +	if (skb_cloned(skb)) {
> > > +		struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
> > > +
> > > +		/* Finally, create a contig FD from this skb */
> > > +		skb_to_contig_fd(priv, skb, &fd, countptr, &offset);
> > > +
> > > +		kfree_skb(skb);
> > > +		skb = nskb;
> > > +		/* skb_copy() has now linearized the skbuff. */
> > > +	}
> > > +
> > 
> > You know that TCP packets are clones, right ?
> > This code is killing performance.
> > 
> > TCP allows the headers part being modified by a driver if needed.
> > 
> > You should use skb_header_cloned() instead.
> 
> Thank you, I'll address this. I plan to do something like this:
> 
> +       if (!nonlinear) {
> +               /* We're going to store the skb backpointer at the beginning
> +                * of the data buffer, so we need a privately owned skb
> +                */
> +
> +               /* make sure skb is not shared, skb_cow_head() assumes it's not */
> +               skb = skb_share_check(skb, GFP_ATOMIC);
> +               if (!skb)
> +                       goto enomem;
> +
> +               /* verify the skb head is not cloned */
> +               if (skb_cow_head(skb, priv->tx_headroom))
> +                       goto enomem;
> +
> +               nonlinear = skb_is_nonlinear(skb);
> +       }
> 
> but I'm not sure the skb_share_check() is required on tx.
> I'm also a bit puzzled by the aliasing between shared and cloned terms
> (i.e. skb_unshare() could be named something like skb_unclone();
>  the skb_share_check() not only checks but also unshares an skb so
>  the already taken skb_unshare() name would probably fit too).

A driver can ask tx skbs to be not shared, even if pktgen is used with
"clone=X" on it.

dev->priv_flags         &= ~IFF_TX_SKB_SHARING;

This way, you can avoid skb_share_check() completely. Only pktgen will
care.

Most skb_share_check() calls in drivers/net are related to input paths
on virtual drivers.
