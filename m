From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Tue, 23 Dec 2008 22:16:25 +0300
Message-ID: <49513909.1050100@vlnb.net>
References: <494C0255.8010208@goop.org> <20081219220452.GB704@ioremap.net> <494C1E5E.7070809@goop.org> <20081219223314.GA2736@ioremap.net> <494C50BB.5030809@goop.org> <20081220020250.GA15064@gondor.apana.org.au> <494C8D57.7040808@goop.org> <20081220065105.GA16936@gondor.apana.org.au> <494CA226.9000200@goop.org> <20081220081045.GA17439@gondor.apana.org.au> <20081220103209.GA23632@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20081220103209.GA23632@ioremap.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov, on 12/20/2008 01:32 PM wrote:
> On Sat, Dec 20, 2008 at 07:10:45PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
>>> Hm.  So if I get a destructor call from the shared_info, can I go an  
>>> inspect the page refcounts to see if its really the last use?
>> The pages that were originally in the shared_info at creation
>> time may no longer be there by the time it's freed because of
>> pskb_pull_tail.
> 
> Things should work fine, since pskb_expand_head() copies whole shared
> info structure (and thus will copy destructor), get all pages and then
> copy all pointers into the new skb, and then release old skb's data.
> 
> So destructor for the pages should not rely on which skb it is called on
> and check if pages are about to be really freed (i.e. check theirs
> reference counter).
> 
> __pskb_pull_tail() is tricky, it just puts some pages it does not want
> to be present in the skb, but it could be possible to add there
> destructor callback from the original skb with partial flag (or just
> having destructor with two parameters: skb and page, and if page is not
> NULL, then actually only given page is freed, otherwise the whole skb).

Actually, there's another way, which seems to be a lot simpler. Alexey 
Kuznetsov privately suggested it to me.

In skb_shared_info new pointer transaction_token would be added, which 
would point on:

struct sk_transaction_token
{
	atomic_t			io_count;
	struct sk_transaction_token	*next;
	unsigned long			token;
	unsigned long			private;
	void				(*finish_callback)(struct sk_transaction_token *);
};

When skb is translated, transaction_token inherited. If 2 skb are merged 
(the same places where I put net_get_page's in my patch), the *older* 
token is inherited. This is the main point of this idea.

Before starting new asynchronous send a client would open a new token. 
Everything sent then would receive that token. Finish_callback() would 
be called and the corresponding token freed, when io_count == 0 *AND* 
all previous tokens closed.

This idea seems to be simpler, than even what Rusty implemented. Correct 
me, if I wrong. But, unfortunately, in the near future I will have no 
time to develop it.. :-(

Vlad

