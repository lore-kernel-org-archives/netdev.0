From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] iwl3945: queue the right work if the scan needs to be
 aborted
Date: Tue, 5 Oct 2010 12:43:58 +0200
Message-ID: <20101005104357.GB18833@redhat.com>
References: <20101005084305.52a31ed4@schatten.dmk.lab>
 <20101005085717.GA18012@redhat.com>
 <20101005121242.79cdafc2@schatten.dmk.lab>
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
In-Reply-To: <20101005121242.79cdafc2-mGsOIKOveelVRbCss4o9kg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2010 at 12:12:42PM +0200, Florian Mickler wrote:
> > Unfortunately this patch is not right thing to do. If you look at
> > abort_scan work, it do nothing if STATUS_SCAN_ABORTING bit is not set.
> > That's wrong because we have to complete scan (with abort == true).
> > If STATUS_SCAN_ABORTING will be set, abort_work will send scan cancel
> > commands to hardware what is wrong if scan was not started yet.
> > 
> > What we can eventually do, except apply iwl-scan rewrite from
> > wireless-testing, is something like that:
> >  
> > iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
> > 
> >   clear_bit(STATUS_SCAN_HW, &priv->status); 
> >   clear_bit(STATUS_SCANNING, &priv->status); 
> >   /* inform mac80211 scan aborted */ 
> >   set_bit(STATUS_SCAN_ABORTING, &priv->status);
> >   queue_work(priv->workqueue, &priv->scan_completed);
> > 
> > ieee80211_scan_completed
> >   
> >   if (!internal) {
> >      bool aborted = test_bit(STATUS_SCAN_ABORTING, &priv->status);
> >      ieee80211_scan_completed(priv->hw, aborted);
> > 
> >   }
> > 
> > However, I do not think we should go with that to -stable (below
> > 2.6.36). IIRC warnings showed up in current 2.6.36-rc, because of
> > some other changes in the code.
> > 
> > Stanislaw
> 
> Thx for looking at this. I suspect you know the code better than I do.. what is about the
> first jump to :done in iwlagn_request_scan()
> 
>          if (!iwl_is_ready(priv)) {
>                  IWL_WARN(priv, "request scan called when driver not ready.\n");
>                  goto done;
>          }
> 
> Does abort_scan need to do anything in that case? 

Yes, because we do not return value to mac80211 about .hw_scan failure,
we always return 0, what is completely wrong. And yes, return error can
be done instead of queueing scan_completed to improve situation - this is
one of the thing, we do in wireless-testing.

> I can't see where we set up the hardware for scanning in that case.
> (I've gone through the codepath coming from the mac80211 hw_scan) 

.hw_scan = iwl_mac_hw_scan -> iwl_scan_initiate ->
 "priv->cfg->ops->utils->request_scan" = {iwl3945,iwlang}_request_scan

Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
