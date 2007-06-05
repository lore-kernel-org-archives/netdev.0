From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 5 Jun 2007 18:31:31 +0400
Message-ID: <20070605143130.GA31747@2ka.mipt.ru>
References: <20070605080542.GA9909@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34591 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762847AbXFEObs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 10:31:48 -0400
Content-Disposition: inline
In-Reply-To: <20070605080542.GA9909@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05, 2007 at 10:05:43AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> Here's an implementation of tcp network splice receive support. It's
> originally based on the patch set that Intel posted some time ago, but
> has been (close to) 100% reworked.
> 
> Now, I'm not a networking guru by any stretch of the imagination, so I'd
> like some input on the direction of the main patch. Is the approach
> feasible? Glaring errors? Missing bits?

  263.709262] ------------[ cut here ]------------
  [  263.713932] kernel BUG at include/linux/mm.h:285!
  [  263.718678] invalid opcode: 0000 [1] PREEMPT SMP 
  [  263.723561] CPU 0 
  [  263.725665] Modules linked in: button loop snd_intel8x0
  snd_ac97_codec ac97_bus snd_pcm snd_timer snd soundcore psmouse
  snd_page_alloc k8temp i2c_nforcen
  [  263.755666] Pid: 2709, comm: splice-fromnet Not tainted
  2.6.22-rc4-splice #2
  [  263.762759] RIP: 0010:[<ffffffff8038c60c>]  [<ffffffff8038c60c>]
  skb_splice_bits+0xac/0x1c9
  [  263.771212] RSP: 0018:ffff81003c79fc88  EFLAGS: 00010246
  [  263.776564] RAX: 0000000000000000 RBX: 00000000000005a8 RCX:
  ffff81003ff04778
  [  263.783743] RDX: ffff81003ff04778 RSI: 0000000000000ab2 RDI:
  000000000003d52d
  [  263.790925] RBP: ffff81003c79fdd8 R08: 0000000000000000 R09:
  ffff81003d927b78
  [  263.798104] R10: ffffffff803b0181 R11: ffff81003c79fde8 R12:
  ffff81003d52d000
  [  263.805284] R13: 000000000000054e R14: ffff81003d927b78 R15:
  ffff81003bbc6ea0
  [  263.812463] FS:  00002ac4089a86d0(0000) GS:ffffffff804fb000(0000)
  knlGS:0000000000000000
  [  263.820611] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
  [  263.826396] CR2: 00002ac4088320e0 CR3: 000000003c987000 CR4:
  00000000000006e0
  [  263.833578] Process splice-fromnet (pid: 2709, threadinfo
  ffff81003c79e000, task ffff81003755c380)
  [  263.842591] Stack:  ffff81003ff04720 0000000000000000
  ffff81003755c380 0000000000000046
  [  263.850897]  00000000000000c6 0000000000000046 ffff81003b0428b8
  ffff81003d0b5b10
  [  263.858543]  00000000000000c6 ffff81003d0b5b10 ffff81003b0428b8
  ffff81003d0b5b10
  [  263.865957] Call Trace:
  [  263.868683]  [<ffffffff803dc630>] _read_unlock_irq+0x31/0x4e
  [  263.874393]  [<ffffffff803afb54>] tcp_splice_data_recv+0x20/0x22
  [  263.880447]  [<ffffffff803afa2b>] tcp_read_sock+0xa2/0x1ab
  [  263.885983]  [<ffffffff803afb34>] tcp_splice_data_recv+0x0/0x22
  [  263.891951]  [<ffffffff803b01c1>] tcp_splice_read+0xae/0x1a3
  [  263.897655]  [<ffffffff8038920f>] sock_def_readable+0x0/0x6f
  [  263.903366]  [<ffffffff80384a65>] sock_splice_read+0x15/0x17
  [  263.909072]  [<ffffffff8029e773>] do_splice_to+0x76/0x88
  [  263.914432]  [<ffffffff8029fcc8>] sys_splice+0x1a8/0x232
  [  263.919795]  [<ffffffff802097ce>] system_call+0x7e/0x83
  [  263.925067] 
  [  263.926606] 
  [  263.926607] Code: 0f 0b eb fe 44 89 e6 81 e6 ff 0f 00 00 90 ff 42
  08 48 63 55 
  [  263.936418] RIP  [<ffffffff8038c60c>] skb_splice_bits+0xac/0x1c9
  [  263.942516]  RSP <ffff81003c79fc88>

This a vm_bug_on in get_page().

> +static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
> +				unsigned int len, unsigned int offset)
> +{
> +	struct page *p;
> +
> +	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
> +		return 1;
> +
> +#ifdef NET_COPY_SPLICE
> +	p = alloc_pages(GFP_KERNEL, 0);
> +	if (!p)
> +		return 1;
> +
> +	memcpy(page_address(p) + offset, page_address(page) + offset, len);
> +#else
> +	p = page;
> +	get_page(p);
> +#endif

Some pages have zero reference counter here.

Is commented NET_COPY_SPLICE part from old implementation?
It will be always slower than existing approach due to allocation
overhead.

-- 
	Evgeniy Polyakov
