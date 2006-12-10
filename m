From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] ieee80211softmac: Fix errors related to the work_struct changes
Date: Sun, 10 Dec 2006 18:49:46 +0100
Message-ID: <200612101849.47179.mb@bu3sch.de>
References: <20061210173908.GB29871@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54147
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762286AbWLJRuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 12:50:15 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061210173908.GB29871@p15091797.pureserver.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 December 2006 18:39, Ulrich Kunitz wrote:
> The signature of work functions changed recently from a context
> pointer to the work structure pointer. This caused a problem in
> the ieee80211softmac code, because the ieee80211softmac_assox_work
> function has  been called directly with a parameter explicitly
> casted to (void*). This compiled correctly but resulted in a
> softlock, because mutex_lock was called with the wrong memory
> address. The patch fixes the problem. Another issue was a wrong
> call of the schedule_work function. Softmac works again and this
> fixes the problem I mentioned earlier in the zd1211rw rx tasklet
> patch. The patch is against Linus' tree (commit af1713e0).
> 
> Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> ---
>  net/ieee80211/softmac/ieee80211softmac_assoc.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
> index eec1a1d..a824852 100644
> --- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
> +++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
> @@ -167,7 +167,7 @@ static void
>  ieee80211softmac_assoc_notify_scan(struct net_device *dev, int event_type, void *context)
>  {
>  	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
> -	ieee80211softmac_assoc_work((void*)mac);
> +	ieee80211softmac_assoc_work(&mac->associnfo.work.work);
>  }
>  
>  static void
> @@ -177,7 +177,7 @@ ieee80211softmac_assoc_notify_auth(struc
>  
>  	switch (event_type) {
>  	case IEEE80211SOFTMAC_EVENT_AUTHENTICATED:
> -		ieee80211softmac_assoc_work((void*)mac);
> +		ieee80211softmac_assoc_work(&mac->associnfo.work.work);
>  		break;
>  	case IEEE80211SOFTMAC_EVENT_AUTH_FAILED:
>  	case IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT:
> @@ -438,7 +438,7 @@ ieee80211softmac_try_reassoc(struct ieee
>  
>  	spin_lock_irqsave(&mac->lock, flags);
>  	mac->associnfo.associating = 1;
> -	schedule_work(&mac->associnfo.work);
> +	schedule_delayed_work(&mac->associnfo.work, 0);

Why do you use a zero delay here? What does that fix?

>  	spin_unlock_irqrestore(&mac->lock, flags);
>  }

-- 
Greetings Michael.
