From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Wed, 5 Sep 2012 06:47:12 +0200
Message-ID: <20120905044712.GA2284@netboy.at.omicron.at>
References: <1346768514-19823-1-git-send-email-oliver@neukum.org>
 <20120904155343.GA2170@netboy.at.omicron.at>
 <20747715.9FmHp7X6VE@linux-lqwf.site>
 <20120904.123740.1915830868205918256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@neukum.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:62259 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841Ab2IEErY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 00:47:24 -0400
Received: by wgbfm10 with SMTP id fm10so3729249wgb.1
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 21:47:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120904.123740.1915830868205918256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 04, 2012 at 12:37:40PM -0400, David Miller wrote:
> From: Oliver Neukum <oliver@neukum.org>
> Date: Tue, 04 Sep 2012 18:13:18 +0200
> 
> > If that check is ever needed and tx_fixup not needed, the driver will oops here.
> > The check is wrong in any case.
> 
> Right, we are dealing with two different things here.
> 
> Tree-wide there was a blind set of changes to protect skb_tx_timestamp()
> calls with a NULL skb check.
> 
> But in this specific case, it's completely unnecessary.
> 
> So Oliver's change is definitely correct and I will add it to net-next

Looking at git blame on usbnet.c we see ...

    23ba0799	if (skb)
    23ba0799		skb_tx_timestamp(skb);

and reading on ...

    commit 23ba07991dad5a96a024c1b45cb602eef5f83df8
    Author: Konstantin Khlebnikov <khlebnikov@openvz.org>
    Date:   Mon Nov 7 05:54:58 2011 +0000

    usbnet: fix oops in usbnet_start_xmit
    
    This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
    SKB can be NULL at this point, at least for cdc-ncm.
    
    Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
    Acked-by: Richard Cochran <richardcochran@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

and finally cdc-ncm.c reveals

static void cdc_ncm_txpath_bh(unsigned long param)
{
	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)param;

	spin_lock_bh(&ctx->mtx);
	if (ctx->tx_timer_pending != 0) {
		ctx->tx_timer_pending--;
		cdc_ncm_tx_timeout_start(ctx);
		spin_unlock_bh(&ctx->mtx);
	} else if (ctx->netdev != NULL) {
		spin_unlock_bh(&ctx->mtx);
		netif_tx_lock_bh(ctx->netdev);
		usbnet_start_xmit(NULL, ctx->netdev);
----------------------------------^^^^
		netif_tx_unlock_bh(ctx->netdev);
	}
}

and so I think the problem that the test addresses is still present,
or am I missing something?

Thanks,
Richard
