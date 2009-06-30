From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCHv3 1/2] net: adding memory barrier to the poll and receive
 callbacks
Date: Tue, 30 Jun 2009 12:13:40 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906301210210.3968@makko.or.mcafeemobile.com>
References: <20090630125240.GB4406@jolsa.lab.eng.brq.redhat.com> <20090630125425.GC4406@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:44740 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbZF3TOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 15:14:46 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2F4C12> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Tue, 30 Jun 2009 15:14:11 -0400
In-Reply-To: <20090630125425.GC4406@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jun 2009, Jiri Olsa wrote:

> Adding memory barrier after the poll_wait function, paired with
> receive callbacks. Adding fuctions sock_poll_wait and sock_has_sleeper
> to wrap the memory barrier.
> 
> Without the memory barrier, following race can happen.
> The race fires, when following code paths meet, and the tp->rcv_nxt 
> and __add_wait_queue updates stay in CPU caches.
> 
> 
> CPU1                         CPU2
> 
> sys_select                   receive packet
>   ...                        ...
>   __add_wait_queue           update tp->rcv_nxt
>   ...                        ...
>   tp->rcv_nxt check          sock_def_readable
>   ...                        {
>   schedule                      ...
>                                 if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
>                                         wake_up_interruptible(sk->sk_sleep)
>                                 ...
>                              }
> 
> If there was no cache the code would work ok, since the wait_queue and
> rcv_nxt are opposit to each other.
> 
> Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either already
> passed the tp->rcv_nxt check and sleeps, or will get the new value for
> tp->rcv_nxt and will return with new data mask.
> In both cases the process (CPU1) is being added to the wait queue, so the
> waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> 
> The bad case is when the __add_wait_queue changes done by CPU1 stay in its
> cache, and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 will then
> endup calling schedule and sleep forever if there are no more data on the
> socket.

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

Jiri, since this is a pretty tricky condition, would you mind to have a 
reduced version of the patch comment added to the source code?
Patch comments are not really useful when you're trying to make sense of 
some code ;)


- Davide


