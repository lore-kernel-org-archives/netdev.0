From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of
 kmem_cache_free_bulk()
Date: Mon, 7 Sep 2015 22:14:48 +0200
Message-ID: <20150907221448.2b18b174@redhat.com>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
	<CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
	<20150907104101.3e392a6d@redhat.com>
	<CALx6S348WrCr1mCOCMsr7fnSRp1bDRaG+-G1B+gpCJ3a4JeUtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	iamjoonsoo.kim@lge.com, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbbIGUO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 16:14:56 -0400
In-Reply-To: <CALx6S348WrCr1mCOCMsr7fnSRp1bDRaG+-G1B+gpCJ3a4JeUtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 7 Sep 2015 09:25:49 -0700 Tom Herbert <tom@herbertland.com> wrote:

> >> What not pass a list of skbs (e.g. using skb->next)?
> >
> > Because the next layer, the slab API needs an array:
> >   kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> >
> 
> I suppose we could ask the same question of that function. IMO
> encouraging drivers to define arrays of pointers on the stack like
> you're doing in the ixgbe patch is a bad direction.
> 
> In any case I believe this would be simpler in the networking side
> just to maintain a list of skb's to free. Then the dev_free_waitlist
> structure might not be needed then since we could just use a
> skb_buf_head for that.

I guess it is more natural for the network side to work with skb lists.
But I'm keeping it for slab/slub as we cannot assume/enforce objects of a
specific data type.

I worried about how large bulk free we should allow, due to the
interaction with skb->destructor which for sockets affect their memory
accounting. E.g. we have seen issues with hypervisor network drivers
(Xen and HyperV) that are too slow to cleanup their TX completion queue
that their TCP bandwidth get limited by tcp_limit_output_bytes.
I capped it at 32, and the NAPI budget will cap it at 64.


By the following argument, bulk free of 64 objects/skb's is not a problem.
The delay I'm introducing is very small, before the first real
kfree_skb is called, which calls the destructor with free up socket
memory accounting.

Assume measured packet rate of: 2105011 pps
Time between packets (1/2105011*10^9): 475 ns

Perf shows ixgbe_clean_tx_irq() takes: 1.23%
Extrapolating the function call cost: 5.84 ns (475*(1.23/100))

Processing 64 packets in ixgbe_clean_tx_irq() 373 ns.
At 10Gbit/s how many bytes can arrive in this period, only: 466 bytes.
((373/10^9)*(10000*10^6)/8)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
