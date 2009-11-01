From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Sun, 1 Nov 2009 11:23:39 -0800
Message-ID: <20091101112339.5e4e5032@nehalam>
References: <200911010503.nA153ESA019066@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34155 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbZKATYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2009 14:24:05 -0500
In-Reply-To: <200911010503.nA153ESA019066@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Oct 2009 22:03:14 -0700
Rasesh Mody <rmody@brocade.com> wrote:

> +
> +void
> +bfa_timer_init(struct bfa_timer_mod_s *mod)
> +{
> +	INIT_LIST_HEAD(&mod->timer_q);
> +}
Why wrap this, you are only calling it once?

> +void
> +bfa_timer_beat(struct bfa_timer_mod_s *mod)
> +{
> +	struct list_head        *qh = &mod->timer_q;
> +	struct list_head        *qe, *qe_next;
> +	struct bfa_timer_s *elem;
> +	struct list_head         timedout_q;
> +
> +	INIT_LIST_HEAD(&timedout_q);
> +
> +	qe = bfa_q_next(qh);
> +
> +	while (qe != qh) {
> +		qe_next = bfa_q_next(qe);
> +
> +		elem = (struct bfa_timer_s *) qe;
> +		if (elem->timeout <= BFA_TIMER_FREQ) {
> +			elem->timeout = 0;
> +			list_del(&elem->qe);
> +			list_add_tail(&elem->qe, &timedout_q);
> +		} else {
> +			elem->timeout -= BFA_TIMER_FREQ;
> +		}
> +
> +		qe = qe_next;	/* go to next elem */
> +	}

Why not make list_for_each_entry()?

> +	/*
> +	 * Pop all the timeout entries
> +	 */
> +	while (!list_empty(&timedout_q)) {
> +		bfa_q_deq(&timedout_q, &elem);
> +		elem->timercb(elem->arg);
> +	}
> +}
> +
> +/**
> + * Should be called with lock protection
> + */
> +void
> +bfa_timer_begin(struct bfa_timer_mod_s *mod, struct bfa_timer_s *timer,
> +		    void (*timercb) (void *), void *arg, unsigned int timeout)
> +{
> +
> +	bfa_assert(timercb != NULL);
> +	bfa_assert(!bfa_q_is_on_q(&mod->timer_q, timer));
> +
> +	timer->timeout = timeout;
> +	timer->timercb = timercb;
> +	timer->arg = arg;
> +
> +	list_add_tail(&timer->qe, &mod->timer_q);
> +}
Isn't this the same as timer_setup()?

> +/**
> + * Should be called with lock protection
> + */
> +void
> +bfa_timer_stop(struct bfa_timer_s *timer)
> +{
> +	bfa_assert(!list_empty(&timer->qe));
> +
> +	list_del(&timer->qe);
> +}
Gratuitous wrapping?

-- 
