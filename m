From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] net: adding memory barrier to the poll and receive
	callbacks
Date: Mon, 29 Jun 2009 19:47:20 +0200
Message-ID: <20090629174720.GD2742@ami.dom.local>
References: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com> <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, davidel@xmailserver.org,
	eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:42480 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbZF2Rr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 13:47:27 -0400
Content-Disposition: inline
In-Reply-To: <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 04:14:45PM +0200, Jiri Olsa wrote:
...
> +/**
> + * sk_has_sleeper - check if there are any waiting processes
> + * @sk: socket
> + *
> + * Returns true if socket has waiting processes
> + */
> +static inline int sk_has_sleeper(struct sock *sk)
> +{
> +	/*
> +	 * We need to be sure we are in sync with the
> +	 * add_wait_queue modifications to the wait queue.
> +	 *
> +	 * This memory barrier is paired in the sock_poll_wait.
> +	 */
> +	smp_mb();
> +	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
> +}
> +

Btw. I hope Jiri won't "listen" to me, but I can't stop to mention
sock_waitqueue_active() looks to me quite naturally better paired
with sock_poll_wait() than sk_has_sleeper(which otherwise is more
conspicuous, sorry Eric.)

Jarek P.

> +/**
> + * sock_poll_wait - place memory barrier behind the __poll_wait call.
> + * @filp: file
> + * @sk:   socket
> + * @p:    poll_table
> + */
> +static inline void sock_poll_wait(struct file *filp, struct sock *sk,
> +		poll_table *p)
> +{
> +	if (p && sk->sk_sleep) {
> +		__poll_wait(filp, sk->sk_sleep, p);
> +		/*
> +		 * We need to be sure we are in sync with the
> +		 * socket flags modification.
> +		 *
> +		 * This memory barrier is paired in the sk_has_sleeper.
> +		*/
> +		smp_mb();
> +	}
> +}
