From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless-current
 tree
Date: Mon, 15 Feb 2010 15:20:23 +1100
Message-ID: <20100215152023.0696878f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jouni Malinen <jouni.malinen@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/mac80211/rate.c between commit
5affcd6ba2036b59a4dee3f0576ae3584e92e4f1 ("mac80211: fix handling of
null-rate control in rate_control_get_rate") from the wireless-current
tree and commit 37eb0b164cf9fa9f70c8500926f5cde7c652f48e
("cfg80211/mac80211: Use more generic bitrate mask for rate control")
from the net tree.

John, I know you mentioned this, so I assume it will go away soon.

I fixed it up (I think - see below).
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/rate.c
index 12a2bff,c74b7c8..0000000
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@@ -245,26 -303,31 +303,34 @@@ void rate_control_get_rate(struct ieee8
  		info->control.rates[i].count = 1;
  	}
  
 +	if (sdata->local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL)
 +		return;
 +
- 	if (sta && sdata->force_unicast_rateidx > -1) {
- 		info->control.rates[0].idx = sdata->force_unicast_rateidx;
- 	} else {
- 		ref->ops->get_rate(ref->priv, ista, priv_sta, txrc);
- 		info->flags |= IEEE80211_TX_INTFL_RCALGO;
- 	}
+ 	ref->ops->get_rate(ref->priv, ista, priv_sta, txrc);
  
  	/*
- 	 * try to enforce the maximum rate the user wanted
+ 	 * Try to enforce the rateidx mask the user wanted. skip this if the
+ 	 * default mask (allow all rates) is used to save some processing for
+ 	 * the common case.
  	 */
- 	if (sdata->max_ratectrl_rateidx > -1)
+ 	mask = sdata->rc_rateidx_mask[info->band];
+ 	if (mask != (1 << txrc->sband->n_bitrates) - 1) {
+ 		if (sta) {
+ 			/* Filter out rates that the STA does not support */
+ 			mask &= sta->sta.supp_rates[info->band];
+ 		}
+ 		/*
+ 		 * Make sure the rate index selected for each TX rate is
+ 		 * included in the configured mask and change the rate indexes
+ 		 * if needed.
+ 		 */
  		for (i = 0; i < IEEE80211_TX_MAX_RATES; i++) {
+ 			/* Rate masking supports only legacy rates for now */
  			if (info->control.rates[i].flags & IEEE80211_TX_RC_MCS)
  				continue;
- 			info->control.rates[i].idx =
- 				min_t(s8, info->control.rates[i].idx,
- 				      sdata->max_ratectrl_rateidx);
+ 			rate_idx_match_mask(&info->control.rates[i],
+ 					    txrc->sband->n_bitrates, mask);
+ 		}
  	}
  
  	BUG_ON(info->control.rates[0].idx < 0);
