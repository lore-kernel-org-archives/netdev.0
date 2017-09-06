From: Matteo Croce <mcroce@redhat.com>
Subject: Re: hung task in mac80211
Date: Wed, 6 Sep 2017 17:04:26 +0200
Message-ID: <CAGnkfhyBMKT-Tf10NxjN40Znuj7OK2pSM3qLUidPSkQqh8gjwQ@mail.gmail.com>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
 <1504702728.13457.17.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504702728.13457.17.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 6, 2017 at 2:58 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Wed, 2017-09-06 at 13:57 +0200, Matteo Croce wrote:
>
>> I have an hung task on vanilla 4.13 kernel which I haven't on 4.12.
>> The problem is present both on my AP and on my notebook,
>> so it seems it affects AP and STA mode as well.
>> The generated messages are:
>>
>> INFO: task kworker/u16:6:120 blocked for more than 120 seconds.
>>       Not tainted 4.13.0 #57
>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>> kworker/u16:6   D    0   120      2 0x00000000
>> Workqueue: phy0 ieee80211_ba_session_work [mac80211]
>> Call Trace:
>>  ? __schedule+0x174/0x5b0
>>  ? schedule+0x31/0x80
>>  ? schedule_preempt_disabled+0x9/0x10
>>  ? __mutex_lock.isra.2+0x163/0x480
>>  ? select_task_rq_fair+0xb9f/0xc60
>>  ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
>>  ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
>
> Yeah - obviously as Stefano found, both take &sta->ampdu_mlme.mtx.
>
> Can you try this?
>
> diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
> index 2b36eff5d97e..d8d32776031e 100644
> --- a/net/mac80211/agg-rx.c
> +++ b/net/mac80211/agg-rx.c
> @@ -245,10 +245,10 @@ static void ieee80211_send_addba_resp(struct ieee80211_sub_if_data *sdata, u8 *d
>         ieee80211_tx_skb(sdata, skb);
>  }
>
> -void __ieee80211_start_rx_ba_session(struct sta_info *sta,
> -                                    u8 dialog_token, u16 timeout,
> -                                    u16 start_seq_num, u16 ba_policy, u16 tid,
> -                                    u16 buf_size, bool tx, bool auto_seq)
> +void ___ieee80211_start_rx_ba_session(struct sta_info *sta,
> +                                     u8 dialog_token, u16 timeout,
> +                                     u16 start_seq_num, u16 ba_policy, u16 tid,
> +                                     u16 buf_size, bool tx, bool auto_seq)
>  {
>         struct ieee80211_local *local = sta->sdata->local;
>         struct tid_ampdu_rx *tid_agg_rx;
> @@ -267,7 +267,7 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
>                 ht_dbg(sta->sdata,
>                        "STA %pM requests BA session on unsupported tid %d\n",
>                        sta->sta.addr, tid);
> -               goto end_no_lock;
> +               goto end;
>         }
>
>         if (!sta->sta.ht_cap.ht_supported) {
> @@ -275,14 +275,14 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
>                        "STA %pM erroneously requests BA session on tid %d w/o QoS\n",
>                        sta->sta.addr, tid);
>                 /* send a response anyway, it's an error case if we get here */
> -               goto end_no_lock;
> +               goto end;
>         }
>
>         if (test_sta_flag(sta, WLAN_STA_BLOCK_BA)) {
>                 ht_dbg(sta->sdata,
>                        "Suspend in progress - Denying ADDBA request (%pM tid %d)\n",
>                        sta->sta.addr, tid);
> -               goto end_no_lock;
> +               goto end;
>         }
>
>         /* sanity check for incoming parameters:
> @@ -296,7 +296,7 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
>                 ht_dbg_ratelimited(sta->sdata,
>                                    "AddBA Req with bad params from %pM on tid %u. policy %d, buffer size %d\n",
>                                    sta->sta.addr, tid, ba_policy, buf_size);
> -               goto end_no_lock;
> +               goto end;
>         }
>         /* determine default buffer size */
>         if (buf_size == 0)
> @@ -311,7 +311,6 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
>                buf_size, sta->sta.addr);
>
>         /* examine state machine */
> -       mutex_lock(&sta->ampdu_mlme.mtx);
>
>         if (test_bit(tid, sta->ampdu_mlme.agg_session_valid)) {
>                 if (sta->ampdu_mlme.tid_rx_token[tid] == dialog_token) {
> @@ -415,15 +414,25 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
>                 __clear_bit(tid, sta->ampdu_mlme.unexpected_agg);
>                 sta->ampdu_mlme.tid_rx_token[tid] = dialog_token;
>         }
> -       mutex_unlock(&sta->ampdu_mlme.mtx);
>
> -end_no_lock:
>         if (tx)
>                 ieee80211_send_addba_resp(sta->sdata, sta->sta.addr, tid,
>                                           dialog_token, status, 1, buf_size,
>                                           timeout);
>  }
>
> +void __ieee80211_start_rx_ba_session(struct sta_info *sta,
> +                                    u8 dialog_token, u16 timeout,
> +                                    u16 start_seq_num, u16 ba_policy, u16 tid,
> +                                    u16 buf_size, bool tx, bool auto_seq)
> +{
> +       mutex_lock(&sta->ampdu_mlme.mtx);
> +       ___ieee80211_start_rx_ba_session(sta, dialog_token, timeout,
> +                                        start_seq_num, ba_policy, tid,
> +                                        buf_size, tx, auto_seq);
> +       mutex_unlock(&sta->ampdu_mlme.mtx);
> +}
> +
>  void ieee80211_process_addba_request(struct ieee80211_local *local,
>                                      struct sta_info *sta,
>                                      struct ieee80211_mgmt *mgmt,
> diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
> index c92df492e898..198b2d3e56fd 100644
> --- a/net/mac80211/ht.c
> +++ b/net/mac80211/ht.c
> @@ -333,9 +333,9 @@ void ieee80211_ba_session_work(struct work_struct *work)
>
>                 if (test_and_clear_bit(tid,
>                                        sta->ampdu_mlme.tid_rx_manage_offl))
> -                       __ieee80211_start_rx_ba_session(sta, 0, 0, 0, 1, tid,
> -                                                       IEEE80211_MAX_AMPDU_BUF,
> -                                                       false, true);
> +                       ___ieee80211_start_rx_ba_session(sta, 0, 0, 0, 1, tid,
> +                                                        IEEE80211_MAX_AMPDU_BUF,
> +                                                        false, true);
>
>                 if (test_and_clear_bit(tid + IEEE80211_NUM_TIDS,
>                                        sta->ampdu_mlme.tid_rx_manage_offl))
> diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
> index 2197c62a0a6e..9675814f64db 100644
> --- a/net/mac80211/ieee80211_i.h
> +++ b/net/mac80211/ieee80211_i.h
> @@ -1760,6 +1760,10 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
>                                      u8 dialog_token, u16 timeout,
>                                      u16 start_seq_num, u16 ba_policy, u16 tid,
>                                      u16 buf_size, bool tx, bool auto_seq);
> +void ___ieee80211_start_rx_ba_session(struct sta_info *sta,
> +                                     u8 dialog_token, u16 timeout,
> +                                     u16 start_seq_num, u16 ba_policy, u16 tid,
> +                                     u16 buf_size, bool tx, bool auto_seq);
>  void ieee80211_sta_tear_down_BA_sessions(struct sta_info *sta,
>                                          enum ieee80211_agg_stop_reason reason);
>  void ieee80211_process_delba(struct ieee80211_sub_if_data *sdata,
>
> johannes

I confirm that this patch fixes the hang too.
I'm curious to see if there are noticeable performance differences
between the two solutions.

Cheers,
-- 
Matteo Croce
per aspera ad upstream
