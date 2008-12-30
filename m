From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Wed, 31 Dec 2008 00:35:59 +0300
Message-ID: <20081230213559.GD20238@ioremap.net>
References: <494CA226.9000200@goop.org> <20081220081045.GA17439@gondor.apana.org.au> <20081220103209.GA23632@ioremap.net> <49513909.1050100@vlnb.net> <20081223213817.GB16883@ioremap.net> <4952493F.10508@vlnb.net> <20081224144422.GA25089@ioremap.net> <49527590.7090909@vlnb.net> <20081224180841.GA615@ioremap.net> <495A5C3C.8090006@vlnb.net>
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
In-Reply-To: <495A5C3C.8090006@vlnb.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vlad.

On Tue, Dec 30, 2008 at 08:37:00PM +0300, Vladislav Bolkhovitin (vst@vlnb.net) wrote:
> Although I agree that any additional allocation is something, which 
> should be avoided, *if possible*. But you shouldn't overestimate the 
> overhead of the sk_transaction_token allocation in cases, when it would 
> be needed. At first, sk_transaction_token is quite small, so a single 
> page in the kmem cache would keep about 100 of them, hence the slow 
> allocation path would be called only once per 100 objects. Second, in 
> many cases ->sendpages() needs to allocate a new skb, so already there 
> is at least one such allocations on the fast path.

Once per 100 objects? With millions of packets per second at extreme
cases this does not scale. Even more common thousand of usual packets
per second with 1.5k mtu will show up (especially freeing actually).

Any additional overhead has to be avoided if possible, even if it looks
innocent.

BSD guys already learned this lesson with packet processing tags at
every layer.

> Actually, it doesn't look like the skb shared info destructor alone 
> can't solve the task we are solving, because we need to know not when an 
> skb transmittion finished, but when transmittion of our *set of pages* 
> finished. Hence, with skb shared info destructor we would need also to 
> invent some way to track set of pages <-> set of skbs translation (you 
> refer it as combining tag and separate destructor), which would bring 
> this solution on the entire new complexity level for no gain over the 
> sk_transaction_token solution.

You really do not need to know when transmission is over, but when remote
side acks it (or connection is reset by the timeout). There is no way to
know when transmission is over without creating own skbs and submitting
them avoiding usual tcp/ip stack machinery.

You do not need to know which skbs contain which pages, system only should
track page pointers freed at skb destruction (shared info destruction
actually) time, no matter who owns those pages (since new pages can be
added into the page and some of the old ones can be freed early).

This will be effectively the same token, but it does not mean that
everyone who needs notification will have to perform additional
allocation. Put two pointers: destructor and token and do whatever you
like if one of them is non-empty, but try to avoid unneded overhead when
it is possible.

-- 
	Evgeniy Polyakov
