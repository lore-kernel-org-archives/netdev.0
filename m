From: Andreea Bernat <bernat.ada@gmail.com>
Subject: Re: [PATCH] carl9170: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Thu, 21 Aug 2014 23:10:26 +0300
Message-ID: <20140821201026.GA26428@ada>
References: <20140817104806.GA14533@ada>
 <3029076.uaUkTd8nru@debian64>
 <20140820173210.GA18892@ada>
 <3042528.E5hT1D5bWz@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3042528.E5hT1D5bWz@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 20, 2014 at 01:20:02PM -0700, Christian Lamparter wrote:
> On Wednesday, August 20, 2014 08:32:11 PM Andreea Bernat wrote:
> > On Mon, Aug 18, 2014 at 09:29:36PM +0200, Christian Lamparter wrote:
> > > On Sunday, August 17, 2014 01:48:07 PM Andreea-Cristina Bernat wrote:
> > > > The rcu_dereference() call is used directly in a condition.
> > > > Since its return value is never dereferenced it is recommended to use
> > > > "rcu_access_pointer()" instead of "rcu_dereference()".
> > > > Therefore, this patch makes the replacement.
> > > > [...]
> > > > Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
> > > > ---
> > > >  drivers/net/wireless/ath/carl9170/main.c | 2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > 
> > > > diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
> > > > index f8ded84..12018ff 100644
> > > > --- a/drivers/net/wireless/ath/carl9170/main.c
> > > > +++ b/drivers/net/wireless/ath/carl9170/main.c
> > > > @@ -1431,7 +1431,7 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
> > > >  			return -EOPNOTSUPP;
> > > >  
> > > >  		rcu_read_lock();
> > > > -		if (rcu_dereference(sta_info->agg[tid])) {
> > > > +		if (rcu_access_pointer(sta_info->agg[tid])) {
> > > >  			rcu_read_unlock();
> > > >  			return -EBUSY;
> > > >  		}
> > > 
> > > There's more. The check does not do a whole lot. I think *it* [the check] and the
> > > rcu_read_[un]lock [and the return -EBUSY] can be removed completely from the
> > > IEEE80211_AMPDU_TX_START code-path in carl9170_op_ampdu_action.
> > > 
> > > It would be awesome, if you could you make a patch which removes this 
> > > unneeded cosmic-ray-protection check :-) .
> > 
> > Could you tell me why you think that those lines have to be removed?
> The carl9170_op_ampdu_action callback is used exclusively by the mac80211
> framework to notify the driver about setup and tear down of TX and RX 
> aggregation sessions. Hence, mac80211 takes great care of performing
> sanity checks and properly serializing calls to the driver's ampdu_action
> callback.
> 
> Specifically mac80211 already prevents the START of an TX aggregation session,
> if the aggregation session is already active [0]. Therefore the driver doesn't
> need to perform a similar check as well. This is why:
>  - the expression (rcu_dereference(sta_info->agg[tid])) never evaluates to true
>  -> the -EBUSY exit path is "dead code"
> 
> And without the rcu_dereference(...) the rcu_read protection is not needed
> either. So it can be removed for this case as well.
> 
> > I would like to fully understand this before I remove them.
> Let me know if the explanation above answers sufficient :).
> If not, I need some *pointers* to what needs further 
> explanation.

Your explanation is clear. I will send a version two of the patch with
those lines removed.

Thank you,
Andreea

> 
> Regards
> Christian
> 
> [0] <http://lxr.free-electrons.com/source/net/mac80211/agg-tx.c#L583>
> 
