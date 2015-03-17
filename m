From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] brcmfmac: cfg80211: use msecs_to_jiffies for time
 conversion
Date: Tue, 17 Mar 2015 05:42:39 -0700
Message-ID: <1426596159.23897.61.camel@perches.com>
References: <1426593972-17652-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0092.hostedemail.com ([216.40.44.92]:60014 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932268AbbCQW2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 18:28:17 -0400
In-Reply-To: <1426593972-17652-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-17 at 08:06 -0400, Nicholas Mc Guire wrote:
> Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> OK but msecs_to_jiffies(val) is the cleaner solution and handles all
> corner cases correctly. This is a minor API consolidation only and
> should make things more readable.

Hi Nicholas

These API consolidation changes now always have a function
call when the compiler may have previously been able to
optimize out the "constant * HZ / 1000" calculation.

Perhaps the [um]secs_to_jiffies calls should be indirected
with yet another static inline with a __builtin_constant_p()
test so that the function calls can again be avoided when
possible.

(and a trivial style note)

> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c
[]
> @@ -1110,7 +1110,7 @@ brcmf_cfg80211_escan(struct wiphy *wiphy, struct brcmf_cfg80211_vif *vif,
>  
>  	/* Arm scan timeout timer */
>  	mod_timer(&cfg->escan_timeout, jiffies +
> -			WL_ESCAN_TIMER_INTERVAL_MS * HZ / 1000);
> +		  msecs_to_jiffies(WL_ESCAN_TIMER_INTERVAL_MS));

It may be nicer to keep the arithmetic on one line

 	mod_timer(&cfg->escan_timeout,
		  jiffies + msecs_to_jiffies(WL_ESCAN_TIMER_INTERVAL_MS));
