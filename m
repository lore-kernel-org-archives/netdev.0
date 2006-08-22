From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 07/18] d80211:  get rid of sta_aid in favour of keeping
 track of TIM
Date: Tue, 22 Aug 2006 20:36:47 +0200
Message-ID: <20060822203647.5a160a34@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075200.055344487@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10429 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750770AbWHVSgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 14:36:49 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075200.055344487@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:14 +0200, Johannes Berg wrote:
> I think this is not correct if a STA is removed for which packets
> are buffered, but if it is still wrong then that case was never
> correct to start with if the hw has a set_tim callback.

You're right, good catch.

Just minor things:

> [...]
> -	if (num_bits) {
> +	if (have_bits) {
>  		/* Find largest even number N1 so that bits numbered 1 through
>  		 * (N1 x 8) - 1 in the bitmap are 0 and number N2 so that bits
>  		 * (N2 + 1) x 8 through 2007 are 0. */
>  		n1 = 0;
> -		for (i = 0; i < sizeof(bitmap); i++) {
> -			if (bitmap[i]) {
> +		/* 251 = max size of tim bitmap in beacon */
> +		for (i = 0; i < 251; i++) {

Please, use a constant here.

> [...]
> @@ -211,13 +213,10 @@ struct ieee80211_if_ap {
>  	u8 *generic_elem;
>  	size_t generic_elem_len;
>  
> -	/* TODO: sta_aid could be replaced by 2008-bit large bitfield of
> -	 * that could be used in TIM element generation. This would also
> -	 * make TIM element generation a bit faster. */
> -	/* AID mapping to station data. NULL, if AID is free. AID is in the
> -	 * range 1..2007 and sta_aid[i] corresponds to AID i+1. */
> -	struct sta_info *sta_aid[MAX_AID_TABLE_SIZE];
> -	int max_aid; /* largest aid currently in use */
> +	/* yes, this looks ugly, but guarantees that we can later use
> +	 * bitmap_empty :)
> +	 * NB: don't ever use set_bit, use bss_tim_set/bss_tim_clear! */
> +	u8 tim[sizeof(unsigned long)*BITS_TO_LONGS(MAX_AID_TABLE_SIZE+1)];

Hm, adding spaces here would extend the line above 80 characters... But
this way it doesn't look good. What to do here? I'd prefer leaving the
line a little over 80 chars in this case. What do you think?

> [...]
> --- wireless-dev.orig/net/d80211/sta_info.c	2006-08-20 14:56:17.418192788 +0200
> +++ wireless-dev/net/d80211/sta_info.c	2006-08-20 14:56:20.588192788 +0200
> @@ -424,13 +424,6 @@ void sta_info_remove_aid_ptr(struct sta_
>  	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
>  	if (sta->aid <= 0 || !sdata->bss)
>  		return;
> -
> -	sdata->bss->sta_aid[sta->aid - 1] = NULL;
> -	if (sta->aid == sdata->bss->max_aid) {
> -		while (sdata->bss->max_aid > 0 &&
> -		       !sdata->bss->sta_aid[sdata->bss->max_aid - 1])
> -			sdata->bss->max_aid--;
> -	}
>  }

Why are you not calling bss_tim_clear here? Am I missing something?

Also, adding hw->set_tim call here should fix the problem you described
at the beginning of the mail.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
