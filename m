From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Mon, 22 Jun 2009 12:59:50 +0400
Message-ID: <20090622085950.GA26598@ms2.inr.ac.ru>
References: <20090621171141.GA2893@localhost.localdomain> <20090622054315.GA4928@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mbizon@freebox.fr, dada1@cosmosbay.com, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:35024 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750872AbZFVJR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 05:17:56 -0400
Content-Disposition: inline
In-Reply-To: <20090622054315.GA4928@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 05:43:15AM +0000, Jarek Poplawski wrote:
> Maybe it can work, but it needs a thorough checking now and adds a new
> code path to track later while looking for bugs. So, I wonder if it's
> not better to link such dsts in rt_intern_hash anyway, probably as a
> separate list, scanned only for expired entries.

Such a list already exists, it is gc list in core/dst.c.

The fix to the problem could be replacing rt_drop() with rt_free()
(adding rt_free() after the patch, which deleted rt_drop()), something like:

	if (!rt_caching(dev_net(rt->u.dst.dev))) {
		/* ..... */
+		rt_free(rt);
		goto report_and_exit;
	}

rt_free() will put the route on that gc list and it will be releases
as soon as refcnt becomes 0.

Alexey

