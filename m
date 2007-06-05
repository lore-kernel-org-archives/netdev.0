From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 5 Jun 2007 18:49:37 +0400
Message-ID: <20070605144937.GA12722@2ka.mipt.ru>
References: <20070605080542.GA9909@kernel.dk> <20070605143130.GA31747@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38645 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932117AbXFEOt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 10:49:58 -0400
Content-Disposition: inline
In-Reply-To: <20070605143130.GA31747@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05, 2007 at 06:31:31PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>   [  263.936418] RIP  [<ffffffff8038c60c>] skb_splice_bits+0xac/0x1c9
>   [  263.942516]  RSP <ffff81003c79fc88>
> 
> This a vm_bug_on in get_page().
> 
> > +static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
> > +				unsigned int len, unsigned int offset)
> > +{
> > +	struct page *p;
> > +
> > +	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
> > +		return 1;
> > +
> > +#ifdef NET_COPY_SPLICE
> > +	p = alloc_pages(GFP_KERNEL, 0);
> > +	if (!p)
> > +		return 1;
> > +
> > +	memcpy(page_address(p) + offset, page_address(page) + offset, len);
> > +#else
> > +	p = page;
> > +	get_page(p);
> > +#endif
> 
> Some pages have zero reference counter here.

Very likley bug with mac address is related to this one and you do not
have vm debug enabled in the config? Naive atomic_inc and
atomic_dec_return with bug_on < 0 instead of that get_page and put_page
in spd_fill_page()/sock_pipe_buf_release() resulted in broken file -
initial data contained 6B and 5A instead of zeroes sent. Even more naive 
atomic_add(2, page) ended with:

[   48.273345] page:ffff81003ff22a18 flags:0x0100000000000000
mapping:0000000000000000 mapcount:0 count:2
[   48.273347] Trying to fix it up, but a reboot is needed
[   48.273349] Backtrace:
[   48.295576] 
[   48.295577] Call Trace:
[   48.299624]  [<ffffffff8025f075>] bad_page+0x67/0x95
[   48.304636]  [<ffffffff8025f771>] __free_pages_ok+0x76/0x2c1
[   48.310343]  [<ffffffff8025fbec>] __free_pages+0x29/0x2b
[   48.315703]  [<ffffffff8025fc38>] free_pages+0x4a/0x4f
[   48.320884]  [<ffffffff8027b15f>] kmem_freepages+0xd9/0xe2
[   48.326416]  [<ffffffff8027bd93>] slab_destroy+0xef/0x114
[   48.331865]  [<ffffffff8027bf15>] free_block+0x15d/0x19f
[   48.337227]  [<ffffffff8027c0bb>] cache_flusharray+0x95/0xff
[   48.342933]  [<ffffffff8027c36a>] kfree+0x1cd/0x1ec
[   48.347863]  [<ffffffff8038b233>] skb_release_data+0xab/0xb0
[   48.353567]  [<ffffffff8038aff3>] kfree_skbmem+0x11/0x7e
[   48.358927]  [<ffffffff8038b104>] __kfree_skb+0xa4/0xa9
[   48.364204]  [<ffffffff803afa9e>] tcp_read_sock+0x101/0x1ab
[   48.369823]  [<ffffffff803afb48>] tcp_splice_data_recv+0x0/0x22
[   48.375791]  [<ffffffff803b01d5>] tcp_splice_read+0xae/0x1a3
[   48.381497]  [<ffffffff8038920f>] sock_def_readable+0x0/0x6f
[   48.387209]  [<ffffffff80384a65>] sock_splice_read+0x15/0x17
[   48.392913]  [<ffffffff8029e773>] do_splice_to+0x76/0x88
[   48.398273]  [<ffffffff8029fcc8>] sys_splice+0x1a8/0x232
[   48.403636]  [<ffffffff802097ce>] system_call+0x7e/0x83

-- 
	Evgeniy Polyakov
