From: Martin Kelly <martin@martingkelly.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 17 Sep 2014 10:04:04 -0700
Message-ID: <CAN8CM3wpZ236h3Okfi0AS+9+0P05fd1JVwfUOXfbp_LV2PqLLQ@mail.gmail.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
	<20140909.150000.1647602729214485795.davem@davemloft.net>
	<CAN8CM3xEnQXVgrLpV0rfAJoZ75v6Xv64pAGJ-9SAPACAT8WJ_w@mail.gmail.com>
	<54199AC7.1040502@martingkelly.com>
	<1410965690.7106.233.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:52210 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370AbaIQREH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 13:04:07 -0400
Received: by mail-wg0-f45.google.com with SMTP id z12so1708337wgg.4
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 10:04:05 -0700 (PDT)
In-Reply-To: <1410965690.7106.233.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 7:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Can you describe the ... ?
>

Sure. The patch I've been looking at is functionally identical to the
one referenced in http://patchwork.ozlabs.org/patch/181605/ with the
exception that sock_orphan() and sock->sk = NULL is moved before the
synchronize_net(). This further improves the performance relative to
http://patchwork.ozlabs.org/patch/181605/ because it never calls
synchronize_net(), whereas http://patchwork.ozlabs.org/patch/181605/
calls synchronize_net() in the po->running case. However, it looks
like making that optimization is not safe, for the reasons you
mentioned below.

>
> What problem do you want to solve exactly ?
>
> I believe its not safe, you missed sk_data_ready() call
> (sock_def_readable())
>

The problem I I'm trying to solve is the same one mentioned in
http://patchwork.ozlabs.org/patch/181605/: On systems with a lot of
RCU contention, raw socket close() can take up to 300 ms or so, which
really adds up for processes that open lots of raw sockets. What you
see is a many-second hang when the process exits as it waits for many
synchronize_rcu calls (all in serial) to finish. Although it would be
better for close() not to be in a critical path, it's sometimes hard
to get around for some userspace processes, so this kind of change
could yield a significant performance improvement for such processes.

You're right, I missed sk_def_readable(), which looks like it would
cause a crash if it occurred before the call_rcu() was called. I see
that sk_def_readable() acceses sk->sk_wq through rcu_read_lock(),
rcu_dereference(), rcu_read_unlock(), while sock_orphan() sets
sk->sk_wq = NULL without an RCU function. You could modify
sock_orphan() and sock->sk to use RCU too, but you would need to patch
all access sites, and the patch would quickly become complex and
error-prone, which is not worth it.

Does my analysis sound correct to you? If so, can you think of a more
natural way to improve raw socket close() performance? I agree that
optimally, userspace should not put close() in a critical path, but it
still seems like a bug for close() to take 300 ms to complete.

Thanks,
Martin
