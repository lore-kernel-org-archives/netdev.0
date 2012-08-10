From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] NETDEV_UNREGISTER_BATCH seems unused nowaday ?
Date: Fri, 10 Aug 2012 13:06:49 +0200
Message-ID: <1344596809.31104.2358.camel@edumazet-glaptop>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
	 <20120810.034211.994338127277150687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38267 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760206Ab2HJLGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 07:06:54 -0400
Received: by bkwj10 with SMTP id j10so542680bkw.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 04:06:53 -0700 (PDT)
In-Reply-To: <20120810.034211.994338127277150687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 03:42 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 10 Aug 2012 11:27:04 +0200
> 
> > NETDEV_UNREGISTER_BATCH seems unused we can probably remove it.
> 
> Indeed, the routing cache was the final real user.
> 
> > I am tracking a device refcount issue, delaying net device dismantle by
> > 1 second in netdev_wait_allrefs()
> > 
> > I guess we need to add a notifier called _after_ the final
> > synchronize_net() in rollback_registered_many()
> 
> It's essentially caused by DST_GC_INC, right?

No, we in fact need a rcu_barrier(), then another call to
dst_dev_event().

rcu_barrier() is needed so that in-flight call_rcu() of routes (from
rt_free()) are completed. Or else we miss these dst in the
dst_dev_event().

I have a working patch, adding the rcu_barrier() and one additional
NETDEV_UNREGISTER_FINAL event.
