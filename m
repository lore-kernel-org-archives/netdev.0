From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable
 and friendly ?
Date: Thu, 16 Aug 2007 15:36:19 +0200
Message-ID: <20070816153619.2c699e21.dada1@cosmosbay.com>
References: <20070816140914.de24335c.dada1@cosmosbay.com>
	<E1ILefm-00010m-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:37543 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758118AbXHPNgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 09:36:20 -0400
In-Reply-To: <E1ILefm-00010m-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007 20:41:58 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Eric Dumazet <dada1@cosmosbay.com> wrote:
> >
> > I am wondering how to really solve the problem. Could a workqueue be used here instead of a timer ?
> 
> I think so.
> 
> A mutex would separate the GC and dst_ifdown.  You'd take the
> spin lock in the GC only to replace the garbage list with NULL.
> You then drop the lock to process it.  Once it's done you take
> the lock again and join it with whatever that's been added in
> the mean time.  This is easy because you should already have
> the tail after the GC process.

Thanks Herbert

Yes, I already did this (with the current softirq based timer model),
 but how can dst_dev_event() do its work, since the GC is using 
a private list. (In my patch, time to GC process XXX.000 entries is about XX seconds.)

We would have to change dst_dev_event() to :
- Signal to GC it has to stop as soon as possible.
- Wait for GC be stoped (busy wait I suspect we cannot sleep in dst_dev_event() ? )
, giving us a full garbage_list.
- Process the whole list.
- Restart GC

