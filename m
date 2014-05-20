From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better sleep/wakeup
 efficiency
Date: Tue, 20 May 2014 12:44:01 +0800
Message-ID: <537ADD91.4000609@redhat.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>	 <5379CE8D.2030405@redhat.com> <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaETEoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 00:44:14 -0400
In-Reply-To: <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2014 10:09 PM, Eric Dumazet wrote:
> On Mon, 2014-05-19 at 17:27 +0800, Jason Wang wrote:
>
>> Still a little bit difference. We check the reg_state after we're sure
>> there's nothing left in sk_receive_queue. But this patch returns -EIO
>> before trying to dequeue skb.
> Do you think its a problem, other than a simple difference of behavior ?

 I just point out the possible issues.
>
> Is this -EIO thing a hard requirement, or a side effect ?

Probably not, but it's really not hard to keep this.
>
> Either we try to converge things, or we keep this driver a pile of
> copy/pasted stuff from other locations, missing improvements we did
> in core networking stack, because of some supposed differences.

Agree, but we'd better separate the unrelated changes into other patches
to simplify review and speed up convergence.
>
> About the sk_data_ready() and wake_up_all(), you missed the whole part
> of the patch I think.
>
> Check how sock_def_readable() does everything properly and efficiently,
> including the async part.

But this changes (sk_data_ready()) has nothing related to switching to
use __skb_recv_datagram()

The async part may not work since tun has its own implementation of fasync.
>
> static void sock_def_readable(struct sock *sk)
> {
>         struct socket_wq *wq;
>
>         rcu_read_lock();
>         wq = rcu_dereference(sk->sk_wq);
>         if (wq_has_sleeper(wq))
>                 wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
>                                                 POLLRDNORM | POLLRDBAND);
>         sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
>         rcu_read_unlock();
> }
>
> Using sk_data_ready() is the way to reach sock_def_readable()
> as its not an EXPORT_SYMBOL.
>
> If this driver was using the common interface, we would not have
> these false sharing problems, that were solved a long time ago.

Yes, but better with a separate patch.

We can probably rework the tun_fasync() to use sock_fasync(), but using
sk_data_ready() in tun_detach_all() is still questionable. We may not
want to send EIO to userspace when tun device is destroying.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
