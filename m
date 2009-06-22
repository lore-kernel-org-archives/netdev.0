From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Mon, 22 Jun 2009 11:00:23 +0000
Message-ID: <20090622110023.GA6994@ff.dom.local>
References: <20090621171141.GA2893@localhost.localdomain> <20090622054315.GA4928@ff.dom.local> <20090622085950.GA26598@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mbizon@freebox.fr, dada1@cosmosbay.com, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:17156 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbZFVLA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 07:00:27 -0400
Received: by fg-out-1718.google.com with SMTP id 16so1008334fgg.17
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 04:00:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090622085950.GA26598@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 12:59:50PM +0400, Alexey Kuznetsov wrote:
> On Mon, Jun 22, 2009 at 05:43:15AM +0000, Jarek Poplawski wrote:
> > Maybe it can work, but it needs a thorough checking now and adds a new
> > code path to track later while looking for bugs. So, I wonder if it's
> > not better to link such dsts in rt_intern_hash anyway, probably as a
> > separate list, scanned only for expired entries.
> 
> Such a list already exists, it is gc list in core/dst.c.
> 
> The fix to the problem could be replacing rt_drop() with rt_free()
> (adding rt_free() after the patch, which deleted rt_drop()), something like:
> 
> 	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> 		/* ..... */
> +		rt_free(rt);
> 		goto report_and_exit;
> 	}
> 
> rt_free() will put the route on that gc list and it will be releases
> as soon as refcnt becomes 0.

One little doubt would be RCU: if it's currently used in rt_free, and
some code depends on it, there would be a change: rt could be freed
just after atomic dec, without waiting for RCU yet. The second one is
about timing: freeing this always from a workqueue could probably
make a problem if softirqs are often disabled.

Jarek P.
