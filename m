From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] ath9k : Fix ieee80211 work while going to suspend
Date: Thu, 21 Mar 2013 12:33:31 -0700
Message-ID: <20130321193331.GB32416@pogo>
References: <CAOULuOb0_40EX+6A_HM8eJN7kj9J4WhO9UhZbUUqng1Sfy_SQg@mail.gmail.com>
 <20130318191340.GA28919@tuxdriver.com>
 <20130318210308.GD32416@pogo>
 <20130321114219.GB1459@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@venema.h4ckr.net>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	<senthilb@qca.qualcomm.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130321114219.GB1459@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 21, 2013 at 12:42:20PM +0100, Stanislaw Gruszka wrote:
> On Mon, Mar 18, 2013 at 02:03:08PM -0700, Luis R. Rodriguez wrote:
> > > > --- a/drivers/net/wireless/ath/ath9k/link.c
> > > > +++ b/drivers/net/wireless/ath/ath9k/link.c
> > > > @@ -158,7 +158,8 @@ void ath_start_rx_poll(struct ath_softc *sc, u8 nbeacon)
> > > >  {
> > > >   if (!AR_SREV_9300(sc->sc_ah))
> > > >   return;
> > > > -
> > > > + if (sc->suspending)
> > > > + return;
> > 
> > Thanks for the patch! Please note the style issue here, you should
> > use a tab, but other than that lets review what happened.
> > 
> > > >   if (!test_bit(SC_OP_PRIM_STA_VIF, &sc->sc_flags))
> > > >   return;
> > 
> > Note that what this will do is call later mod_timer() for
> > rx_poll_timer, the right thing to do then, which would
> > be equivalent to your patch is to modify the ath_start_rx_poll()
> > to instead use the new API mod_timer_pending() added on v2.6.30
> > via commit 74019224. This would not re-arm the timer if it was
> > previously removed.
> [snip]
> > -	mod_timer(&sc->rx_poll_timer, jiffies + msecs_to_jiffies
> > -		  (nbeacon * sc->cur_beacon_conf.beacon_interval));
> > +	mod_timer_pending(&sc->rx_poll_timer, jiffies + msecs_to_jiffies
> > +			  (nbeacon * sc->cur_beacon_conf.beacon_interval));
> 
> But isn't this prevent to run timer in case it was not running, but
> we want to start it ?

No you're right, this would never have it run, sorry about that.
But lets look at this a little closer. The issue is at suspend
time, and the issue is ath9k is trying to schedule work while
going to suspend.

So when does this work get called?

Given the trace this is hit when the timer rx_poll_timer runs,
which in turn calls ath_rx_poll() to schedule hw_check_work work.
The rx_poll_timer however was originally only set at the end of
the routine that hw_check_work sets off but also at other entry
points (ath_start_rx_poll() callers). Once ath_start_rx_poll()
gets called though we can go on looping as follows:

work			timer			work
hw_check_work	-->	rx_poll_timer	-->	hw_check_work

At suspend time we do this though:

ath_cancel_work(sc);                                                    
del_timer_sync(&sc->rx_poll_timer);  

So perhaps what we need is:

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 6e66f9c..42bb9ea 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2151,9 +2152,9 @@ static int ath9k_suspend(struct ieee80211_hw *hw,
 
 	mutex_lock(&sc->mutex);
 
+	del_timer_sync(&sc->rx_poll_timer);
 	ath_cancel_work(sc);
 	ath_stop_ani(sc);
-	del_timer_sync(&sc->rx_poll_timer);
 
 	if (test_bit(SC_OP_INVALID, &sc->sc_flags)) {
 		ath_dbg(common, ANY, "Device not present\n");


The less changes needed to fix the issue for stable the easier
to backport.

Technically though then we'd need all of these changes as well then:

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 6e66f9c..42bb9ea 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -752,8 +752,8 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	mutex_lock(&sc->mutex);
 
-	ath_cancel_work(sc);
 	del_timer_sync(&sc->rx_poll_timer);
+	ath_cancel_work(sc);
 
 	if (test_bit(SC_OP_INVALID, &sc->sc_flags)) {
 		ath_dbg(common, ANY, "Device not present\n");
@@ -1145,6 +1145,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 	if (changed & IEEE80211_CONF_CHANGE_IDLE) {
 		sc->ps_idle = !!(conf->flags & IEEE80211_CONF_IDLE);
 		if (sc->ps_idle) {
+			del_timer_sync(&sc->rx_poll_timer);
 			ath_cancel_work(sc);
 			ath9k_stop_btcoex(sc);
 		} else {
@@ -2151,9 +2152,9 @@ static int ath9k_suspend(struct ieee80211_hw *hw,
 
 	mutex_lock(&sc->mutex);
 
+	del_timer_sync(&sc->rx_poll_timer);
 	ath_cancel_work(sc);
 	ath_stop_ani(sc);
-	del_timer_sync(&sc->rx_poll_timer);
 
 	if (test_bit(SC_OP_INVALID, &sc->sc_flags)) {
 		ath_dbg(common, ANY, "Device not present\n");

But then we have the chicken and the egg problem, as the work item
could fire off the timer so it would seem to be good to prevent
adding new work when suspending.

> > Looking at this makes me think we should review all usage of
> > mod_timer all over our 802.11 drivers, and mac80211, cfg80211 as
> > well.
> 
> In mac80211 we use local->suspended and local->quiesce booleans to
> prevent reschedule of timers when going to suspend for example.
> Works use ifmgd->associted to prevent reschedule when we are
> disassociating.
> 
> I think on ath9k also some boolean variable should be used, not only
> for rx_poll_timer but also for other works i.e. tx_complete_work.
> Is possible to use SC_OP_INVALID flags, since mac80211 call ath9k_stop
> on suspend and ath9k_start on resume.

Indeed however ieee80211_queue_work() already does a suspend check for
us, it just complains as many drivers including mac80211 were setting
up work incorrectly. The warning was put in place to help us find the
issues. Using SC_OP_INVALID seems fair but we could also add a routine
ieee80211_queue_work_safe() that silently fails if we are quiescing or
suspended and not resuming but I can see that creating very sloppy
driver writing and everyone abusing it.

OK how about this for stable for now:

diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/ath/ath9k/link.c
index 39c84ec..7fdac6c 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -170,7 +170,8 @@ void ath_rx_poll(unsigned long data)
 {
 	struct ath_softc *sc = (struct ath_softc *)data;
 
-	ieee80211_queue_work(sc->hw, &sc->hw_check_work);
+	if (!test_bit(SC_OP_INVALID, &sc->sc_flags))
+		ieee80211_queue_work(sc->hw, &sc->hw_check_work);
 }
 
 /*

  Luis
