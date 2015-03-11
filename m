From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH 1/2 RFC] ath10k: move code out of the parameter list
Date: Wed, 11 Mar 2015 19:26:47 +0100
Message-ID: <20150311182647.GA24450@opentech.at>
References: <1426094369-10213-1-git-send-email-hofrat@osadl.org> <87h9tr4d98.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Kalle Valo <kvalo@qca.qualcomm.com>, Valdis.Kletnieks@vt.edu,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bj??rn Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:58835 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbbCKS0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 14:26:49 -0400
Content-Disposition: inline
In-Reply-To: <87h9tr4d98.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Mar 2015, Bj??rn Mork wrote:

> Nicholas Mc Guire <hofrat@osadl.org> writes:
> 
> > Putting code into the parameter list of wait_event_timeout() might be 
> > legal C-code but not really readable - the "inline" code is simply
> > moved into a function and that passed to wait_event_timeout() as the
> > condition.
> >
> > Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> > ---
> >
> > Thanks to Bjorn Mork <bjorn@mork.no> for clarifying my initial confusion !
> >
> > Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
> > CONFIG_ATH10K=m
> >
> > Patch is against 4.0-rc3 (localversion-next is -next-20150311)
> >
> >  drivers/net/wireless/ath/ath10k/mac.c |   32 ++++++++++++++++++--------------
> >  1 file changed, 18 insertions(+), 14 deletions(-)
> >
> > diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
> > index e8cc19f..7b27d99 100644
> > --- a/drivers/net/wireless/ath/ath10k/mac.c
> > +++ b/drivers/net/wireless/ath/ath10k/mac.c
> > @@ -4463,11 +4463,25 @@ static int ath10k_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
> >  	return ret;
> >  }
> >  
> > +static bool check_htt_state(struct ath10k *ar, bool skip)
> > +{
> > +	bool empty;
> > +
> > +	spin_lock_bh(&ar->htt.tx_lock);
> > +	empty = (ar->htt.num_pending_tx == 0);
> > +	spin_unlock_bh(&ar->htt.tx_lock);
> > +
> > +	skip = (ar->state == ATH10K_STATE_WEDGED) ||
> > +		test_bit(ATH10K_FLAG_CRASH_FLUSH,
> > +			 &ar->dev_flags);
> > +	return (empty || skip);
> > +}
> 
> 
> There is no value in the "skip" input argument here.  It could just as
> well be a local variable.
> 
> 
> >  static void ath10k_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
> >  			 u32 queues, bool drop)
> >  {
> >  	struct ath10k *ar = hw->priv;
> > -	bool skip;
> > +	bool skip = false;
> >  	int ret;
> >  
> >  	/* mac80211 doesn't care if we really xmit queued frames or not
> > @@ -4480,19 +4494,9 @@ static void ath10k_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
> >  	if (ar->state == ATH10K_STATE_WEDGED)
> >  		goto skip;
> >  
> > -	ret = wait_event_timeout(ar->htt.empty_tx_wq, ({
> > -			bool empty;
> > -
> > -			spin_lock_bh(&ar->htt.tx_lock);
> > -			empty = (ar->htt.num_pending_tx == 0);
> > -			spin_unlock_bh(&ar->htt.tx_lock);
> > -
> > -			skip = (ar->state == ATH10K_STATE_WEDGED) ||
> > -			       test_bit(ATH10K_FLAG_CRASH_FLUSH,
> > -					&ar->dev_flags);
> > -
> > -			(empty || skip);
> > -		}), ATH10K_FLUSH_TIMEOUT_HZ);
> > +	ret = wait_event_timeout(ar->htt.empty_tx_wq,
> > +				 check_htt_state(ar, skip),
> > +				 ATH10K_FLUSH_TIMEOUT_HZ);
> >  
> >  	if (ret <= 0 || skip)
> >  		ath10k_warn(ar, "failed to flush transmit queue (skip %i ar-state %i): %i\n",
> 
> 
> Which is why this won't work.  The check_htt_state() function won't
> update the "skip" variable, so it is always false here. The test now
> fails to detect any of the two "skip conditions".  Not really a big
> problem of course, as it only masks a warning.  But still: Your attempt
> to clean up has changed the behaviour in an unintentional way.
> 
> I'd suggest to leave this alone as it is.  The existing code is really
> fine. And testing these odd corner cases is probably difficult, even for
> someone with the actual hardware.  I have no idea what will trigger the
> ATH10K_FLAG_CRASH_FLUSH flag for example..
>

Well testing of this sort of stuff is of course goig to be limited
I do think that cleanups of this form are worth doing as the code
readability is not very good in its current form - of course the
passing skip by value was a bit braindead - fixing it up is though simple
and I guess one then can assess that the behavior is the same as before.
 
> It's better to look into some real bug, where you are able to verify a
> fix.
>
to some extent the two are connected - if the code is hard to read and
also hard to formally describe then using tools like static code checkers
to verify correct API usage (atleast partially) is limited.

This was actually found while writing up a cocci scripts checking for
incorrect handling of the return value of wait_event_timeout (in this
case checking for <= 0 when the return is always >= 0.

So I think it would make sense to fix this type of code in general - even
if my ffirst attempt was broken.

thx!
hofrat
