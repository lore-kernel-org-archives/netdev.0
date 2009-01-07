From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 13:35:04 +0100
Message-ID: <20090107123504.GN32491@kernel.dk>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:17417 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752283AbZAGMgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 07:36:11 -0500
Content-Disposition: inline
In-Reply-To: <20090107123153.GA9597@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07 2009, Jarek Poplawski wrote:
> On Wed, Jan 07, 2009 at 01:22:05PM +0100, Willy Tarreau wrote:
> > [ CCing Evgeniy and Herbert who also participate to the thread ]
> ...
> > Well, I've just tested it. It did not fix the problem but made it worse.
> ...
> 
> Terrible mistake! Here is take 2.

Not sure what this:

> +static inline struct page *linear_to_page(struct page *page, unsigned int len,
> +					  unsigned int offset)
> +{
> +	struct page *p = alloc_pages(GFP_KERNEL, 0);
> +
> +	if (!p)
> +		return NULL;
> +	memcpy((void *)p + offset, (void *)page + offset, len);

is trying to do. I'm assuming you want to copy the page contents? If so,
you'd want something like

        memcpy(page_address(p) + offset, page_address(page) + offset, len);

with possible kmaps for 'page'.

Irregardless of that particular oddity, I don't think this is the right
path to take at all. We need to delay the pipe buffer consumption until
the appropriate time.

-- 
Jens Axboe

