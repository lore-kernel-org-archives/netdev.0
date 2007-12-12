From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [4/4] DST: Algorithms used in distributed storage.
Date: Wed, 12 Dec 2007 13:20:11 +0300
Message-ID: <20071212102011.GC13713@2ka.mipt.ru>
References: <11972872511269@2ka.mipt.ru> <11972872511718@2ka.mipt.ru> <20071212091246.GA12871@dmon-lap.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35699 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294AbXLLKUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 05:20:21 -0500
Content-Disposition: inline
In-Reply-To: <20071212091246.GA12871@dmon-lap.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 12:12:47PM +0300, Dmitry Monakhov (dmonakhov@sw.ru) wrote:
> On 14:47 Mon 10 Dec     , Evgeniy Polyakov wrote:
> > 
> > Algorithms used in distributed storage.
> > Mirror and linear mapping code.
> Hi, i've finally take a look on your DST solution.
> It seems what your current implementation will not work on nonstandard
> devices for example software raid0.
> other comments are follows:

> > +static int dst_mirror_process_node_data(struct dst_node *n,
> > +		struct dst_mirror_node_data *ndata, int op)

> > +
> > +	kunmap(cmp->page);
> << MINOR_BUG:
>    You has forgot to unmap page on error path, so IMHO it is better to move
>    kunmap to "err_out_free_cmp" label.

Yep, I will fix this.

> > +	priv = kzalloc(sizeof(struct dst_mirror_priv), GFP_KERNEL);
> > +	if (!priv)
> > +		return -ENOMEM;
> > +
> > +	priv->chunk_num = st->disk_size;
> > +
> > +	priv->chunk = vmalloc(DIV_ROUND_UP(priv->chunk_num, BITS_PER_LONG) * sizeof(long));
> << Ohhh. My. I want to add my 500G hdd. Do you really wanna
>    say what i have to store 128Mb in memory object for this.

Right now yes. There was a code which used single bit for bigger
data units, but I dropped it because of resync troubles (i.e. when
one single sector has been updated, it requires to resync the whole
block). I can not say which case is better though.

> > +		dprintk("%s: start: %llu, size: %llu/%u, bio: %p, req: %p, "
> > +				"node: %p.\n",
> > +				__func__, req->start, req->size, nr_pages, bio,
> > +				req, req->node);
> > +
> > +		err = n->st->queue->make_request_fn(n->st->queue, bio);
> << Why direct make_request_fn instead of generic_make_request?

generic_make_request() will queue the bio in this case,
so I call request_fn directly.

> > +	for (i = 0; i < DIV_ROUND_UP(priv->chunk_num, BITS_PER_LONG); ++i) {
> > +		int bit, num, start;
> > +		unsigned long word = priv->chunk[i];
> > +
> > +		if (!word)
> > +			continue;
> > +
> > +		num = 0;
> > +		start = -1;
> > +		while (word && num < BITS_PER_LONG) {
> > +			bit = __ffs(word);
> > +			if (start == -1)
> > +				start = bit;
> > +			num++;
> << MINOR_BUG: Seems you have misstyped here. AFAIU @num represent position
>    of last non zero bit (start + num == last_non_zero_bit_pos)
> 			if (start == -1) {
>                 		start = bit;
>                      		num = 1;
> 			} else
>                                 num += bit;

Yes, you are right of course.
Since I shift word to more than a single bit, @num has to be update
accordingly.

> > +			word >>= (bit+1);

Dmitry, thanks a lot for comments, I will fix issues you pointed in the
next release, although will stay bitmap case opened for a while.

-- 
	Evgeniy Polyakov
