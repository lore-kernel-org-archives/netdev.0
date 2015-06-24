From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: use atomic_t instead of spin_lock in
 busy poll
Date: Wed, 24 Jun 2015 01:25:01 -0700 (PDT)
Message-ID: <20150624.012501.1398638370458478294.davem@davemloft.net>
References: <1435076270-14166-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbbFXINK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 04:13:10 -0400
In-Reply-To: <1435076270-14166-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue, 23 Jun 2015 21:47:50 +0530

> -static inline bool enic_poll_unlock_napi(struct vnic_rq *rq)
> +static inline void enic_poll_unlock_napi(struct vnic_rq *rq,
> +					 struct napi_struct *napi)
>  {
> -	bool rc = false;
> -
> -	spin_lock(&rq->bpoll_lock);
> -	WARN_ON(rq->bpoll_state &
> -		(ENIC_POLL_STATE_POLL | ENIC_POLL_STATE_NAPI_YIELD));
> -	if (rq->bpoll_state & ENIC_POLL_STATE_POLL_YIELD)
> -		rc = true;
> -	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
> -	spin_unlock(&rq->bpoll_lock);
> -
> -	return rc;
> +	WARN_ON(atomic_read(&rq->bpoll_state) != ENIC_POLL_STATE_NAPI);
> +	napi_gro_flush(napi, false);
> +	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
>  }

I don't understand why you needed to add this napi_gro_flush() call here,
and regardless of the reason you must explain this, in detail, in your
commit message,
