From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] mac80211: Add rcu read side critical sections
Date: Mon, 18 Sep 2017 22:11:17 +0200
Message-ID: <1505765477.13691.20.camel@sipsolutions.net>
References: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ville Syrjala <ville.syrjala@linux.intel.com>,
        linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43940 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750769AbdIRULX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 18 Sep 2017 16:11:23 -0400
In-Reply-To: <20170918195919.15860-1-ville.syrjala@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I got the following lockdep warning about the rcu_dereference()s in
> ieee80211_tx_h_select_key(). After tracing all callers of
> ieee80211_tx_h_select_key() I discovered that
> ieee80211_get_buffered_bc()
> and ieee80211_build_data_template() had the rcu_read_lock/unlock()
> but
> three other places did not. So I just blindly added them and made the
> read side critical section extend as far as the lifetime of 'tx'
> which
> is where we seem to be stuffing the rcu protected pointers. No real
> clue whether this is correct or not.

Heh.

I think we should do it in ieee80211_tx_dequeue(), if not even in the
driver (and document that it's required)

johannes

> @@ -3411,6 +3430,8 @@ struct sk_buff *ieee80211_tx_dequeue(struct
> ieee80211_hw *hw,
>  	ieee80211_tx_result r;
>  	struct ieee80211_vif *vif;
>  
> +	rcu_read_lock();
> +
>  	spin_lock_bh(&fq->lock);
>  
>  	if (test_bit(IEEE80211_TXQ_STOP, &txqi->flags))
> @@ -3513,6 +3534,8 @@ struct sk_buff *ieee80211_tx_dequeue(struct
> ieee80211_hw *hw,
>  out:
>  	spin_unlock_bh(&fq->lock);
>  
> +	rcu_read_unlock();
> 

i.e. this in itself should be sufficient, though you should probably
reorder and acquire the spinlock first since that might spin, and you
want to keep the RCU section minimal (it's trivial here, after all)

johannes
