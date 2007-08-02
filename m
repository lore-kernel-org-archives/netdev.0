From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Thu, 02 Aug 2007 14:48:21 -0700
Message-ID: <1186091301.18322.46.camel@dell>
References: <1185957077.5552.22.camel@dell>
 <200708020006.13457.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, jeff@garzik.org,
	"netdev" <netdev@vger.kernel.org>, eliezert@broadcom.com,
	lusinsky@broadcom.com, eilong@broadcom.com
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4372 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbXHBUyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 16:54:15 -0400
In-Reply-To: <200708020006.13457.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-02 at 00:06 +0200, Michael Buesch wrote:
> +static inline u32 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
> 
> Too big for inlining.
> 
> > +{
> > +     u16 used;
> > +     u32 prod = fp->tx_bd_prod;
> > +     u32 cons = fp->tx_bd_cons;
> > +
> > +     smp_mb();
> 
> This barrier needs a comment. Why is it there? And why SMP only?

bnx2 and tg3 have similar logic to tell the compiler that prod and cons
can change.  Strictly speaking, we can just use barrier().  The barrier
is also not placed correctly and should be:

	/* Tell compiler that prod and cons can change. */
	barrier();
	prod = fp->tx_bd_prod;
	cons = fp->tx_bd_cons;
 
...
> 
> > +     fp->tx_pkt_cons = sw_cons;
> > +     fp->tx_bd_cons = bd_cons;
> > +
> > +     smp_mb();
>
> Please add a comment why we need a SMP MB here.

This is again similar to logic in tg3 and bnx2 and the comments in tg3
are:

	/* Need to make the tx_cons update visible to tg3_start_xmit()
	 * before checking for netif_queue_stopped().  Without the
	 * memory barrier, there is a small possibility that tg3_start_xmit()
	 * will miss it and cause the queue to be stopped forever.
	 */



