From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2 1/2] mac80211: Add rcu read side critical sections
Date: Wed, 20 Sep 2017 15:11:37 +0300
Message-ID: <20170920121137.GZ4914@intel.com>
References: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
 <20170920101123.23312-1-ville.syrjala@linux.intel.com>
 <1505903964.3026.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1505903964.3026.14.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 20, 2017 at 12:39:24PM +0200, Johannes Berg wrote:
> On Wed, 2017-09-20 at 13:11 +0300, Ville Syrjala wrote:
> 
> > --- a/net/mac80211/tx.c
> > +++ b/net/mac80211/tx.c
> > @@ -1770,15 +1770,21 @@ bool ieee80211_tx_prepare_skb(struct ieee80211_hw *hw,
> >  	struct ieee80211_tx_data tx;
> >  	struct sk_buff *skb2;
> >  
> > -	if (ieee80211_tx_prepare(sdata, &tx, NULL, skb) == TX_DROP)
> > +	rcu_read_lock();
> 
> The documentation says:
> 
> /**
>  * ieee80211_tx_prepare_skb - prepare an 802.11 skb for transmission
>  * @hw: pointer as obtained from ieee80211_alloc_hw()
>  * @vif: virtual interface
>  * @skb: frame to be sent from within the driver
>  * @band: the band to transmit on
>  * @sta: optional pointer to get the station to send the frame to
>  *
>  * Note: must be called under RCU lock
>  */
> 
> You can't even argue that it should be the function itself doing it,
> because the (admittedly optional) sta pointer would otherwise not have
> proper protection after you leave the function ... You can't pass out a
> sta pointer that's RCU protected.

Yeah, I suppose that would need rcu_handoff+some other mechanism to
make sure it stays around after that.

> 
> Side note: Perhaps some annotation should be there? not sure it's
> possible - would have to be something like
> 	struct ieee80211_sta * __rcu *sta;
> 
> I guess since the outer pointer isn't protected, only the inner ...

I think just the fact that even the pointers in ieee80211_tx_data don't
have the __rcu annotation makes it rather hard to see what is really rcu
protected and what isn't. If every user of those pointers would have to
do the rcu_dereference() things would be rather more explicit.

> Therefore, this patch is wrong.

OK, so the problem is in ath9k then.

> I actually think the same is true for ieee80211_tx_dequeue(), but I'm
> less sure about it - the sta pointer there clearly is somehow safely
> passed in (even if it's w/o RCU, the driver can potentially make that
> safe), but the key pointer seems unsafe in this case (as well) if
> there's no outer RCU protection.

Well, I think this is as far as I want to dig into the matter. I can
respin the patch once more with just tx_dequeue() fix in there, if you
want (not sure you do if you think it's wrong as well). After that I'll
leave it to someone who actually knows what they're doing with mac80211 ;)

-- 
Ville Syrjälä
Intel OTC
