From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: Re: [PATCH 1/2] mac80211: Add rcu read side critical sections
Date: Tue, 19 Sep 2017 15:35:45 +0300
Message-ID: <20170919123545.GM4914@intel.com>
References: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
 <1505765477.13691.20.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56423 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750972AbdISMfu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 08:35:50 -0400
Content-Disposition: inline
In-Reply-To: <1505765477.13691.20.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 10:11:17PM +0200, Johannes Berg wrote:
> > I got the following lockdep warning about the rcu_dereference()s in
> > ieee80211_tx_h_select_key(). After tracing all callers of
> > ieee80211_tx_h_select_key() I discovered that
> > ieee80211_get_buffered_bc()
> > and ieee80211_build_data_template() had the rcu_read_lock/unlock()
> > but
> > three other places did not. So I just blindly added them and made the
> > read side critical section extend as far as the lifetime of 'tx'
> > which
> > is where we seem to be stuffing the rcu protected pointers. No real
> > clue whether this is correct or not.
> 
> Heh.
> 
> I think we should do it in ieee80211_tx_dequeue(),

Oh, I guess I didn't trace the call chains far enough. ieee80211_tx()
does indeed look OK. But unless I made another mistake in my analysis
ieee80211_tx_prepare_skb() is still busted.

> if not even in the
> driver (and document that it's required)
> 
> johannes
> 
> > @@ -3411,6 +3430,8 @@ struct sk_buff *ieee80211_tx_dequeue(struct
> > ieee80211_hw *hw,
> >  	ieee80211_tx_result r;
> >  	struct ieee80211_vif *vif;
> >  
> > +	rcu_read_lock();
> > +
> >  	spin_lock_bh(&fq->lock);
> >  
> >  	if (test_bit(IEEE80211_TXQ_STOP, &txqi->flags))
> > @@ -3513,6 +3534,8 @@ struct sk_buff *ieee80211_tx_dequeue(struct
> > ieee80211_hw *hw,
> >  out:
> >  	spin_unlock_bh(&fq->lock);
> >  
> > +	rcu_read_unlock();
> > 
> 
> i.e. this in itself should be sufficient, though you should probably
> reorder and acquire the spinlock first since that might spin, and you
> want to keep the RCU section minimal (it's trivial here, after all)

Good point. I'll respin with that change.

-- 
Ville Syrjälä
Intel OTC
