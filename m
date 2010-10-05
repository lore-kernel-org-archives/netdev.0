From: Florian Mickler <florian@mickler.org>
Subject: Re: [PATCH] iwl3945: queue the right work if the scan needs to be
 aborted
Date: Tue, 5 Oct 2010 12:12:42 +0200
Message-ID: <20101005121242.79cdafc2@schatten.dmk.lab>
References: <20101005084305.52a31ed4@schatten.dmk.lab>
	<20101005085717.GA18012@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy@intel.com>,
	"Chatre, Reinette" <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Cahill, Ben M" <ben.m.cahill@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101005085717.GA18012@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Oct 2010 10:57:17 +0200
Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> On Tue, Oct 05, 2010 at 08:43:05AM +0200, Florian Mickler wrote:
> > commit e7ee762cf074b0fd8eec483d0cef8fdbf0d04b81
> > 
> > 
> > Begin forwarded message:
> > On Fri, 2010-09-24 at 09:22 -0700, Florian Mickler wrote:
> > > iwl3945's scan_completed calls into the mac80211 stack which triggers a
> > > warn on if there is no scan outstanding.
> > > 
> > > This can be avoided by not calling scan_completed but abort_scan in
> > > iwl3945_request_scan  in the done: branch of the function which is used
> > > as an error out.
> > > 
> > > The done: branch seems to be an error-out branch, as, for example, if
> > > iwl_is_ready(priv) returns false  the done: branch is executed.
> > > 
> > > NOTE:
> > > I'm not familiar with the driver at all.
> > > I just quickly scanned as a reaction to
> > > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=17722
> > > 
> > > the users of scan_completed in the  iwl3945 driver and noted the odd
> > > discrepancy between the comment above this instance and the comment in
> > > mac80211 scan_completed function.
> > > Signed-off-by: Florian Mickler <florian@mickler.org>
> > Acked-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> > > ---
> > go into wireless-2.6 and stable only, scan fix already in
> > wireless-next-2.6
> 
> > 
> > Thanks
> > Wey
> > 
> > >  drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |    2 +-
> > >  drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
> > >  2 files changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> > > index 9dd9e64..8fd00a6 100644
> > > --- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> > > +++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> > > @@ -1411,7 +1411,7 @@ void iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
> > >  	clear_bit(STATUS_SCAN_HW, &priv->status);
> > >  	clear_bit(STATUS_SCANNING, &priv->status);
> > >  	/* inform mac80211 scan aborted */
> > > -	queue_work(priv->workqueue, &priv->scan_completed);
> > > +	queue_work(priv->workqueue, &priv->abort_scan);
> 
> Unfortunately this patch is not right thing to do. If you look at
> abort_scan work, it do nothing if STATUS_SCAN_ABORTING bit is not set.
> That's wrong because we have to complete scan (with abort == true).
> If STATUS_SCAN_ABORTING will be set, abort_work will send scan cancel
> commands to hardware what is wrong if scan was not started yet.
> 
> What we can eventually do, except apply iwl-scan rewrite from
> wireless-testing, is something like that:
>  
> iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
> 
>   clear_bit(STATUS_SCAN_HW, &priv->status); 
>   clear_bit(STATUS_SCANNING, &priv->status); 
>   /* inform mac80211 scan aborted */ 
>   set_bit(STATUS_SCAN_ABORTING, &priv->status);
>   queue_work(priv->workqueue, &priv->scan_completed);
> 
> ieee80211_scan_completed
>   
>   if (!internal) {
>      bool aborted = test_bit(STATUS_SCAN_ABORTING, &priv->status);
>      ieee80211_scan_completed(priv->hw, aborted);
> 
>   }
> 
> However, I do not think we should go with that to -stable (below
> 2.6.36). IIRC warnings showed up in current 2.6.36-rc, because of
> some other changes in the code.
> 
> Stanislaw

Thx for looking at this. I suspect you know the code better than I do.. what is about the
first jump to :done in iwlagn_request_scan()

         if (!iwl_is_ready(priv)) {
                 IWL_WARN(priv, "request scan called when driver not ready.\n");
                 goto done;
         }

Does abort_scan need to do anything in that case? 
I can't see where we set up the hardware for scanning in that case.
(I've gone through the codepath coming from the mac80211 hw_scan) 

Regards,
Flo
