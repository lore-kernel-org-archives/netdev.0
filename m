From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aggregation: Convert timers to use
 timer_setup()
Date: Wed, 18 Oct 2017 12:29:26 +0200
Message-ID: <1508322566.2674.17.camel@sipsolutions.net>
References: <20171017202545.GA115810@beast>
         (sfid-20171017_222550_315925_34B26DDB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171017202545.GA115810@beast> (sfid-20171017_222550_315925_34B26DDB)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[quoting your other email:]

> This has been the least trivial timer conversion yet. Given the use of
> RCU and other things I may not even know about, I'd love to get a close
> look at this. I *think* this is correct, as it will re-lookup the tid
> entries when firing the timer.

I'm not really sure why you're doing the lookup again? That seems
pointless, since you already have the right structure, and already rely
on it being valid. You can't really get a new struct assigned to the
same TID without the old one being destroyed.

> -static void sta_rx_agg_session_timer_expired(unsigned long data)
> +static void sta_rx_agg_session_timer_expired(struct timer_list *t)
>  {
> -	/* not an elegant detour, but there is no choice as the timer passes
> -	 * only one argument, and various sta_info are needed here, so init
> -	 * flow in sta_info_create gives the TID as data, while the timer_to_id
> -	 * array gives the sta through container_of */
> -	u8 *ptid = (u8 *)data;
> -	u8 *timer_to_id = ptid - *ptid;
> -	struct sta_info *sta = container_of(timer_to_id, struct sta_info,
> -					 timer_to_tid[0]);
> +	struct tid_ampdu_rx *tid_rx_timer =
> +		from_timer(tid_rx_timer, t, session_timer);
> +	struct sta_info *sta = tid_rx_timer->sta;
> +	u16 tid = tid_rx_timer->tid;
>  	struct tid_ampdu_rx *tid_rx;
>  	unsigned long timeout;
>  
>  	rcu_read_lock();
> -	tid_rx = rcu_dereference(sta->ampdu_mlme.tid_rx[*ptid]);
> +	tid_rx = rcu_dereference(sta->ampdu_mlme.tid_rx[tid]);
>  	if (!tid_rx) {
>  		rcu_read_unlock();

So through all of this, I'm pretty sure we can just use tid_rx_timer
instead of tid_rx.

(Same for TX)

Anyway, the change here looks correct to me, so I'll apply it and then
perhaps clean up more. I've only changed "u16 tid" to "u8 tid" since
the valid range is 0-15 (in theory, in practice 0-7).

johannes
