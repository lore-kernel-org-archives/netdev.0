From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Thu, 3 Feb 2005 17:23:57 -0800
Message-ID: <20050203172357.670c3402.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
	<20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
	<20050203203010.GA7081@gondor.apana.org.au>
	<20050203141901.5ce04c92.davem@davemloft.net>
	<20050203235044.GA8422@gondor.apana.org.au>
	<20050203164922.2627a112.davem@davemloft.net>
	<20050204012053.GA8949@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, okir@suse.de, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050204012053.GA8949@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005 12:20:53 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is true if CPU 0 reads the count before reading skb->list.
> Without a memory barrier, atomic_read and reading skb->list can
> be reordered.  Put it another way, reading skb->list could return
> a cached value that was read from the main memory prior to the
> atomic_read.
> 
> So in order for CPU 0 to always see an up-to-date value of skb->list,
> it needs to do an smp_rmb() between the atomic_read and reading
> skb->list.

You're absolutely right.  Ok, so we do need to change kfree_skb().
I believe even with the memory barrier, the atomic_read() optimization
is still worth it.  atomic ops on sparc64 take a minimum of 40 some odd
cycles on UltraSPARC-III and later, whereas the memory barrier will
take up a single cycle most of the time.

So it'll look something like:

	if (atomic_read(&skb->users) == 1)
		smb_rmb();
	else if (!atomic_dec_and_test(&skb->users))
		return;
	__kfree_skb(skb);
