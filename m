From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Wed, 30 Aug 2006 04:06:20 +0400
Message-ID: <20060830000620.GA24183@ms2.inr.ac.ru>
References: <20060828230748.827712918@localhost.localdomain> <20060828230915.587544687@localhost.localdomain> <20060829152816.GA24283@ms2.inr.ac.ru> <20060829112204.0cf5e866@localhost.localdomain> <20060829211722.GA27855@ms2.inr.ac.ru> <20060829144608.012f0d60@dxpl.pdx.osdl.net> <20060829221606.GA10285@ms2.inr.ac.ru> <20060829160022.552d46e0@dxpl.pdx.osdl.net> <20060829232126.GA18636@ms2.inr.ac.ru> <20060829164940.13d03500@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:30665 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964844AbWH3AGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 20:06:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060829164940.13d03500@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Race 1: w/o RCU
> 					Cpu 0: is in neigh_lookup
> 						gets read_lock()
> 						finds entry
> 						++refcount to 2
> 						updates it
> 	Cpu 1: is in forced_gc()
> 		waits at write_lock()
> 						releases read_lock()
> 						drops ref count to 1.
> 		sees ref count is 1
> 		deletes it

Do you mean it is purged, though it is actually fresh?
It is harmless race condition.


> Why must it be hashed, it could always get zapped just after the update.

Because otherwise we have to check its validity on level of dst_cache
and to rebind. We do not want this. Actually dst->neighbour is supposed
to be immutable.

It means that if some valid dst refers to a neighbour, it must remain
hashed.


> Hmm.. Since this is a slow path,

All the neighbour lookups are in slow path. Actually, lookup
of neighbour entry for use in dst cache is the most loaded path,
the rest of them are pure maintanance paths.

Yes, this would work. RCU is a little spoiled, but at least global
tbl->lock is replaced with per neighbour lock.

Alexey
