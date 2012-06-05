From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
 inetpeer
Date: Tue, 05 Jun 2012 14:00:30 +0200
Message-ID: <1338897630.2760.2433.camel@edumazet-glaptop>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1338886626.2760.2109.camel@edumazet-glaptop>
	 <20120605112728.GB27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Gao feng <gaofeng@cn.fujitsu.com>, serge.hallyn@canonical.com,
	ebiederm@xmission.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42968 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857Ab2FEMAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 08:00:35 -0400
Received: by bkcji2 with SMTP id ji2so4510258bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 05:00:34 -0700 (PDT)
In-Reply-To: <20120605112728.GB27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 13:27 +0200, Steffen Klassert wrote:

> > 
> > By the way, I think we have a bug in inetpeer_gc_worker()
> > 
> > Steffen ?
> > 
> > We have no rcu grace period to make sure the following is safe :
> > 
> > if (!atomic_read(&p->refcnt)) {
> > 	list_del(&p->gc_list);
> > 	kmem_cache_free(peer_cachep, p);
> > }
> 
> I think this is ok as it is. inetpeer_invalidate_tree()
> unlinks the whole inetpeer tree from the inetpeer base and
> adds it to a gc_list. These intetpeer entries are stale,
> they can't be looked up again. So noone should increment the
> refcount, they just wait until the refcount get zero.
> 

Its not OK, lookups are done under rcu.

Since there is no RCU grace period, the worker free the entries while
another cpus are doing their lookups.

Alternative would be to wait a RCU grace period before feeding them to
worker.
