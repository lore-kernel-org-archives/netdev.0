From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Fw: [PATCH] iwl3945: queue the right work if the scan needs to
 be aborted
Date: Tue, 5 Oct 2010 10:57:17 +0200
Message-ID: <20101005085717.GA18012@redhat.com>
References: <20101005084305.52a31ed4@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Cahill, Ben M" <ben.m.cahill-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101005084305.52a31ed4-mGsOIKOveelVRbCss4o9kg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2010 at 08:43:05AM +0200, Florian Mickler wrote:
> commit e7ee762cf074b0fd8eec483d0cef8fdbf0d04b81
> 
> 
> Begin forwarded message:
> On Fri, 2010-09-24 at 09:22 -0700, Florian Mickler wrote:
> > iwl3945's scan_completed calls into the mac80211 stack which triggers a
> > warn on if there is no scan outstanding.
> > 
> > This can be avoided by not calling scan_completed but abort_scan in
> > iwl3945_request_scan  in the done: branch of the function which is used
> > as an error out.
> > 
> > The done: branch seems to be an error-out branch, as, for example, if
> > iwl_is_ready(priv) returns false  the done: branch is executed.
> > 
> > NOTE:
> > I'm not familiar with the driver at all.
> > I just quickly scanned as a reaction to
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=17722
> > 
> > the users of scan_completed in the  iwl3945 driver and noted the odd
> > discrepancy between the comment above this instance and the comment in
> > mac80211 scan_completed function.
> > Signed-off-by: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
> Acked-by: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > ---
> go into wireless-2.6 and stable only, scan fix already in
> wireless-next-2.6

> 
> Thanks
> Wey
> 
> >  drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |    2 +-
> >  drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> > index 9dd9e64..8fd00a6 100644
> > --- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> > +++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
> > @@ -1411,7 +1411,7 @@ void iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
> >  	clear_bit(STATUS_SCAN_HW, &priv->status);
> >  	clear_bit(STATUS_SCANNING, &priv->status);
> >  	/* inform mac80211 scan aborted */
> > -	queue_work(priv->workqueue, &priv->scan_completed);
> > +	queue_work(priv->workqueue, &priv->abort_scan);

Unfortunately this patch is not right thing to do. If you look at
abort_scan work, it do nothing if STATUS_SCAN_ABORTING bit is not set.
That's wrong because we have to complete scan (with abort == true).
If STATUS_SCAN_ABORTING will be set, abort_work will send scan cancel
commands to hardware what is wrong if scan was not started yet.

What we can eventually do, except apply iwl-scan rewrite from
wireless-testing, is something like that:
 
iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)

  clear_bit(STATUS_SCAN_HW, &priv->status); 
  clear_bit(STATUS_SCANNING, &priv->status); 
  /* inform mac80211 scan aborted */ 
  set_bit(STATUS_SCAN_ABORTING, &priv->status);
  queue_work(priv->workqueue, &priv->scan_completed);

ieee80211_scan_completed
  
  if (!internal) {
     bool aborted = test_bit(STATUS_SCAN_ABORTING, &priv->status);
     ieee80211_scan_completed(priv->hw, aborted);

  }

However, I do not think we should go with that to -stable (below
2.6.36). IIRC warnings showed up in current 2.6.36-rc, because of
some other changes in the code.

Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
