From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] ath9k : Fix ieee80211 work while going to suspend
Date: Thu, 21 Mar 2013 12:42:20 +0100
Message-ID: <20130321114219.GB1459@redhat.com>
References: <CAOULuOb0_40EX+6A_HM8eJN7kj9J4WhO9UhZbUUqng1Sfy_SQg@mail.gmail.com>
 <20130318191340.GA28919@tuxdriver.com>
 <20130318210308.GD32416@pogo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	senthilb@qca.qualcomm.com
To: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130318210308.GD32416@pogo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 18, 2013 at 02:03:08PM -0700, Luis R. Rodriguez wrote:
> > > --- a/drivers/net/wireless/ath/ath9k/link.c
> > > +++ b/drivers/net/wireless/ath/ath9k/link.c
> > > @@ -158,7 +158,8 @@ void ath_start_rx_poll(struct ath_softc *sc, u8 nbeacon)
> > >  {
> > >   if (!AR_SREV_9300(sc->sc_ah))
> > >   return;
> > > -
> > > + if (sc->suspending)
> > > + return;
> 
> Thanks for the patch! Please note the style issue here, you should
> use a tab, but other than that lets review what happened.
> 
> > >   if (!test_bit(SC_OP_PRIM_STA_VIF, &sc->sc_flags))
> > >   return;
> 
> Note that what this will do is call later mod_timer() for
> rx_poll_timer, the right thing to do then, which would
> be equivalent to your patch is to modify the ath_start_rx_poll()
> to instead use the new API mod_timer_pending() added on v2.6.30
> via commit 74019224. This would not re-arm the timer if it was
> previously removed.
[snip]
> -	mod_timer(&sc->rx_poll_timer, jiffies + msecs_to_jiffies
> -		  (nbeacon * sc->cur_beacon_conf.beacon_interval));
> +	mod_timer_pending(&sc->rx_poll_timer, jiffies + msecs_to_jiffies
> +			  (nbeacon * sc->cur_beacon_conf.beacon_interval));

But isn't this prevent to run timer in case it was not running, but
we want to start it ?

> Looking at this makes me think we should review all usage of
> mod_timer all over our 802.11 drivers, and mac80211, cfg80211 as
> well.

I mac80211 we use local->suspended and local->quiesce booleans to
prevent reschedule of timers when going to suspend for example.
Works use ifmgd->associted to prevent reschedule when we are
disassociating.

I think on ath9k also some boolean variable should be used, not only
for rx_poll_timer but also for other works i.e. tx_complete_work.
Is possible to use SC_OP_INVALID flags, since mac80211 call ath9k_stop
on suspend and ath9k_start on resume.

Stanislaw
