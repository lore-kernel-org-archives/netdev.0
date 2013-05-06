From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH v3 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Mon, 06 May 2013 12:16:04 +0200
Message-ID: <1367835364.4126.24.camel@weser.hi.pengutronix.de>
References: <1367456138-27172-1-git-send-email-Frank.Li@freescale.com>
	 <1367831973.4126.16.camel@weser.hi.pengutronix.de>
	 <CAHrpEqSDU6kkm9eRKLrc76LZJSjDDQsdzUC0=vS6ZE=spE14pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45832 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab3EFKR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 06:17:26 -0400
In-Reply-To: <CAHrpEqSDU6kkm9eRKLrc76LZJSjDDQsdzUC0=vS6ZE=spE14pQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 06.05.2013, 17:56 +0800 schrieb Frank Li:
> 2013/5/6 Lucas Stach <l.stach@pengutronix.de>:
> > Hi Frank,
> >
> > Am Donnerstag, den 02.05.2013, 08:55 +0800 schrieb Frank Li:
[...]
> >> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> >> index eb43729..a367b21 100644
> >> --- a/drivers/net/ethernet/freescale/fec.h
> >> +++ b/drivers/net/ethernet/freescale/fec.h
> >> @@ -260,7 +260,8 @@ struct fec_enet_private {
> >>       int hwts_rx_en;
> >>       int hwts_tx_en;
> >>       struct timer_list time_keep;
> >> -
> >> +     struct delayed_work delay_work;
> >> +     int timeout;
> > I suspect you are going to add more variables like this in the future if
> > you are using the workqueue more extensively. This is a massive
> > pollution of the fec_enet_private struct. Please make this a bitfield
> > with a proper define for the timeout, so we can reuse one variable for
> > different tasks, or even split this out into it's own struct for the
> > delayed tasks.
> 
> Bit | & is not atomic.
> So I prefer use two variable. the real work in delay work is very
> simple for future workaround.

Ah yes, that's right. Could you then please change the type of the
variable to bool to make it clear that nothing other than true/false
should go into this?

I would still prefer to group the delayed work related things together
in one struct to make the driver more readable overall. Like this:
struct fec_delayed_work {
	struct delayed_work delay_work;
	bool timeout;
	bool future_workaround;
	bool more_delayed_things;
};
And just include this struct in fec_enet_private.

-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
