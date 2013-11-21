From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] packet: fix use after free race in send path
 when dev is released
Date: Thu, 21 Nov 2013 07:27:04 -0800
Message-ID: <1385047624.10637.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385027235-2217-1-git-send-email-dborkman@redhat.com>
	 <1385044842.10637.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <528E2099.90208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43051 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab3KUP1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 10:27:06 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so6098595pdj.39
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 07:27:05 -0800 (PST)
In-Reply-To: <528E2099.90208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 16:02 +0100, Daniel Borkmann wrote:

> 
> That was also my first thought, but Salam pointed out to me, that in case
> we have a situation such as ...
> 
> in packet_cached_dev_get():
>      rcu_read_lock();
>      dev = rcu_dereference(po->cached_dev);      in packet_notifier():
>                                                  ---> CPU1: dev_put(po->prot_hook.dev);
> ---> CPU0:
>      if (dev)
> 	dev_hold(dev);
>      rcu_read_unlock();
> 
> ... we could reach a refcount of 0, before we increase it back to 1. Not sure
> if this can actually happen, maybe in preemptible RCU where read-side critical
> sections to be preempted? So with this rather paranoid approach we make sure
> to avoid such a situation as we wait a grace period when readers finished.

There is no need, because we respect a rcu grace period at dismantle
time already.

Nothing bad can happen inside the rcu_read_lock()/rcu_read_unlock() pair
in packed_cached_dev_get()

Note that dev_put() does not take any immediate action, it only
decrements the refcount.

So if CPU1 does the dev_put(po->prot_hook.dev) after
setting cached_dev to NULL, we should be safe.
