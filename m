From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Wed, 24 Dec 2008 00:38:18 +0300
Message-ID: <20081223213817.GB16883@ioremap.net>
References: <494C1E5E.7070809@goop.org> <20081219223314.GA2736@ioremap.net> <494C50BB.5030809@goop.org> <20081220020250.GA15064@gondor.apana.org.au> <494C8D57.7040808@goop.org> <20081220065105.GA16936@gondor.apana.org.au> <494CA226.9000200@goop.org> <20081220081045.GA17439@gondor.apana.org.au> <20081220103209.GA23632@ioremap.net> <49513909.1050100@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49513909.1050100@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 23, 2008 at 10:16:25PM +0300, Vladislav Bolkhovitin (vst@vlnb.net) wrote:
> Actually, there's another way, which seems to be a lot simpler. Alexey 
> Kuznetsov privately suggested it to me.
> 
> In skb_shared_info new pointer transaction_token would be added, which 
> would point on:
> 
> struct sk_transaction_token
> {
> 	atomic_t			io_count;
> 	struct sk_transaction_token	*next;
> 	unsigned long			token;
> 	unsigned long			private;
> 	void				(*finish_callback)(struct 
> 	sk_transaction_token *);
> };
> 
> When skb is translated, transaction_token inherited. If 2 skb are merged 
> (the same places where I put net_get_page's in my patch), the *older* 
> token is inherited. This is the main point of this idea.
> 
> Before starting new asynchronous send a client would open a new token. 
> Everything sent then would receive that token. Finish_callback() would 
> be called and the corresponding token freed, when io_count == 0 *AND* 
> all previous tokens closed.
> 
> This idea seems to be simpler, than even what Rusty implemented. Correct 
> me, if I wrong. But, unfortunately, in the near future I will have no 
> time to develop it.. :-(

Yes, it is simpler and cleaner, but it requires additional allocation.
This is additional (and quite noticeble) overhead.

-- 
	Evgeniy Polyakov
