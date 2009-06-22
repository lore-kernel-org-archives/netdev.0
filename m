From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Mon, 22 Jun 2009 12:04:26 +0000
Message-ID: <20090622120426.GB6994@ff.dom.local>
References: <20090621171141.GA2893@localhost.localdomain> <20090622054315.GA4928@ff.dom.local> <20090622085950.GA26598@ms2.inr.ac.ru> <20090622110023.GA6994@ff.dom.local> <20090622112956.GA22313@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mbizon@freebox.fr, dada1@cosmosbay.com, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:48002 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbZFVME3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 08:04:29 -0400
Received: by fg-out-1718.google.com with SMTP id d23so530524fga.17
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 05:04:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090622112956.GA22313@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 03:29:56PM +0400, Alexey Kuznetsov wrote:
> On Mon, Jun 22, 2009 at 11:00:23AM +0000, Jarek Poplawski wrote:
> > One little doubt would be RCU: if it's currently used in rt_free, and
> > some code depends on it, there would be a change: rt could be freed
> > just after atomic dec, without waiting for RCU yet.
> 
> Is this bad 'could', or "would be good 'could'"? :-)

Hmm... 'would' could be 'could', I guess... ;-) 

> 
> Such route always goes through RCU: nobody can destroy it,
> destruction happens only if route is on gc list or when RCU callback
> is called and refcnt is already 0.

Righ, but now there is some RCU period after refcount goes 0, not
before.

> 
> BTW RCU on such routes is redundant, they never were in hash table.
> This means that rt_free() could be safely replaced with straight dst_free()
> in this place.

If it's like this then of course there is no problem.

> 
> >					 The second one is
> > about timing: freeing this always from a workqueue could probably
> > make a problem if softirqs are often disabled.
> 
> Do you mean dst_gc_task?
> 
> Yes, it could be optimized out, route can be destroyed when
> refcnt hits zero, but this will require checking refcnt in dst_release().
> Old days it was well visible both on code size and performance.
> Probably, nowadays it is not a problem anymore.

I mean checking refcnts on some list in rt_intern_hash while adding
a new uncached dst.

Jarek P.
