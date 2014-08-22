From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v2] carl9170: Remove redundant protection check
Date: Fri, 22 Aug 2014 22:38:08 +0200
Message-ID: <1679858.MgakDZE2Vr@debian64>
References: <20140822191431.GA5827@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140822191431.GA5827@ada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, August 22, 2014 10:14:31 PM Andreea-Cristina Bernat wrote:
> The carl9170_op_ampdu_action() function is used only by the mac80211
> framework. Since the mac80211 already takes care of checks and 
> properly serializing calls to the driver's function there is no
> need for the driver to do the same thing.
> 
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
> ---
> Changes in v2:
>  - Change subject line from
>    "carl9170: Replace rcu_dereference() with rcu_access_pointer()"
>    to
>    "carl9170: Remove redundant protection check"
>  - Update the commit message according to the modifications
>  - Delete the lines of interest at the suggestion and explanations of
>    Christian Lamparter <chunkeey@googlemail.com>
> 
>  drivers/net/wireless/ath/carl9170/main.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
> index 12018ff..6758b9a 100644
> --- a/drivers/net/wireless/ath/carl9170/main.c
> +++ b/drivers/net/wireless/ath/carl9170/main.c
> @@ -1430,12 +1430,6 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
>  		if (!sta_info->ht_sta)
>  			return -EOPNOTSUPP;
>  
> -		rcu_read_lock();
> -		if (rcu_access_pointer(sta_info->agg[tid])) {
> -			rcu_read_unlock();
> -			return -EBUSY;
> -		}
> -
>  		tid_info = kzalloc(sizeof(struct carl9170_sta_tid),
>  				   GFP_ATOMIC);
>  		if (!tid_info) {
> 

sparse [0] hit a bug when testing the patch:

drivers/net/wireless/ath/carl9170/main.c:1440:17: 
  warning: context imbalance in 'carl9170_op_ampdu_action' - unexpected unlock

This warning is caused by the remaining, stray rcu_read protection
in the code below (Sorry! Guess RCU needed a bit more explanation
in the previous post. If you are looking for *pointers*, there are
excellent resources available in Documentation/RCU/ [1]).

I've attached a full patch (see below) with all changes so far and
tested if the device/driver still behaves ;-). This patch applies 
cleanly on top of wireless-testing.

@John,
can you please take it?

---
From: Andreea-Cristina Bernat <bernat.ada@gmail.com>

The carl9170_op_ampdu_action() function is used only by the mac80211
framework. Since the mac80211 already takes care of checks and 
properly serializing calls to the driver's function there is no
need for the driver to do the same thing.
 
Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
[chunkeey@googlemail.com: remove two stray rcu_read_unlock()]
Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
---
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index f8ded84..ef5b6dc 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1430,18 +1430,10 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
 		if (!sta_info->ht_sta)
 			return -EOPNOTSUPP;
 
-		rcu_read_lock();
-		if (rcu_dereference(sta_info->agg[tid])) {
-			rcu_read_unlock();
-			return -EBUSY;
-		}
-
 		tid_info = kzalloc(sizeof(struct carl9170_sta_tid),
 				   GFP_ATOMIC);
-		if (!tid_info) {
-			rcu_read_unlock();
+		if (!tid_info)
 			return -ENOMEM;
-		}
 
 		tid_info->hsn = tid_info->bsn = tid_info->snx = (*ssn);
 		tid_info->state = CARL9170_TID_STATE_PROGRESS;
@@ -1460,7 +1452,6 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
 		list_add_tail_rcu(&tid_info->list, &ar->tx_ampdu_list);
 		rcu_assign_pointer(sta_info->agg[tid], tid_info);
 		spin_unlock_bh(&ar->tx_ampdu_list_lock);
-		rcu_read_unlock();
 
 		ieee80211_start_tx_ba_cb_irqsafe(vif, sta->addr, tid);
 		break;
---

Regards
Christian

[0] <http://kernelnewbies.org/Sparse>
[1] <https://www.kernel.org/doc/Documentation/RCU/whatisRCU.txt>
