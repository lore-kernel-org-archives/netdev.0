From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Mon, 19 May 2014 07:09:47 -0700
Message-ID: <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>
	 <5379CE8D.2030405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:33717 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaESOJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 10:09:49 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp16so5878852pbb.6
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 07:09:49 -0700 (PDT)
In-Reply-To: <5379CE8D.2030405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-19 at 17:27 +0800, Jason Wang wrote:

> Still a little bit difference. We check the reg_state after we're sure
> there's nothing left in sk_receive_queue. But this patch returns -EIO
> before trying to dequeue skb.

Do you think its a problem, other than a simple difference of behavior ?

Is this -EIO thing a hard requirement, or a side effect ?

Either we try to converge things, or we keep this driver a pile of
copy/pasted stuff from other locations, missing improvements we did
in core networking stack, because of some supposed differences.

About the sk_data_ready() and wake_up_all(), you missed the whole part
of the patch I think.

Check how sock_def_readable() does everything properly and efficiently,
including the async part.

static void sock_def_readable(struct sock *sk)
{
        struct socket_wq *wq;

        rcu_read_lock();
        wq = rcu_dereference(sk->sk_wq);
        if (wq_has_sleeper(wq))
                wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
                                                POLLRDNORM | POLLRDBAND);
        sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
        rcu_read_unlock();
}

Using sk_data_ready() is the way to reach sock_def_readable()
as its not an EXPORT_SYMBOL.

If this driver was using the common interface, we would not have
these false sharing problems, that were solved a long time ago.
