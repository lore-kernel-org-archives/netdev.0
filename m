From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v2 1/2] mac80211: Add rcu read side critical sections
Date: Wed, 20 Sep 2017 12:39:24 +0200
Message-ID: <1505903964.3026.14.camel@sipsolutions.net>
References: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
         <20170920101123.23312-1-ville.syrjala@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ville Syrjala <ville.syrjala-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170920101123.23312-1-ville.syrjala-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-20 at 13:11 +0300, Ville Syrjala wrote:

> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> @@ -1770,15 +1770,21 @@ bool ieee80211_tx_prepare_skb(struct ieee80211_hw *hw,
>  	struct ieee80211_tx_data tx;
>  	struct sk_buff *skb2;
>  
> -	if (ieee80211_tx_prepare(sdata, &tx, NULL, skb) == TX_DROP)
> +	rcu_read_lock();

The documentation says:

/**
 * ieee80211_tx_prepare_skb - prepare an 802.11 skb for transmission
 * @hw: pointer as obtained from ieee80211_alloc_hw()
 * @vif: virtual interface
 * @skb: frame to be sent from within the driver
 * @band: the band to transmit on
 * @sta: optional pointer to get the station to send the frame to
 *
 * Note: must be called under RCU lock
 */

You can't even argue that it should be the function itself doing it,
because the (admittedly optional) sta pointer would otherwise not have
proper protection after you leave the function ... You can't pass out a
sta pointer that's RCU protected.

Side note: Perhaps some annotation should be there? not sure it's
possible - would have to be something like
	struct ieee80211_sta * __rcu *sta;

I guess since the outer pointer isn't protected, only the inner ...


Therefore, this patch is wrong.

I actually think the same is true for ieee80211_tx_dequeue(), but I'm
less sure about it - the sta pointer there clearly is somehow safely
passed in (even if it's w/o RCU, the driver can potentially make that
safe), but the key pointer seems unsafe in this case (as well) if
there's no outer RCU protection.

johannes
