From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Fri, 18 Jun 2010 15:59:29 +1000
Message-ID: <20100618055929.GA11333@gondor.apana.org.au>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com> <20100606161348.427822fb@nehalam> <20100608052744.GA21547@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com> <20100611052112.GA25649@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com> <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com> <20100617112119.GB1515@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 18, 2010 at 01:26:49PM +0800, Xin, Xiaohui wrote:
>
> Herbert,
> I have questions about the idea above:
> 1) Since netdev_alloc_skb() is still there, and we only modify alloc_page(), 
> then we don't need napi_gro_frags() any more, the driver's original receiving 
> function is ok. Right?

Well I was actually thinking about converting all drivers that
need this to napi_gro_frags.  But now that you mention it, yes
we could still keep the old interface to minimise the work.

> 2) Is napi_gro_frags() only suitable for TCP protocol packet? 
> I have done a small test for ixgbe driver to let it only allocate paged buffers 
> and found kernel hangs when napi_gro_frags() receives an ARP packet.

It should work with any packet.  In fact, I'm pretty sure the
other drivers (e.g., cxgb3) use that interface for all packets.

> 3) As I have mentioned above, with this idea, netdev_alloc_skb() will allocate 
> as usual, the data pointed by skb->data will be copied into the first guest buffer. 
> That means we should reserve sufficient room in guest buffer. For PS mode 
> supported driver (for example ixgbe), the room will be more than 128. After 128bytes, 
> we will put the first frag data. Look into virtio-net.c the function page_to_skb()  
> and receive_mergeable(), that means we should modify guest virtio-net driver to 
> compute the offset as the parameter for skb_set_frag().
> 
> How do you think about this? Attached is a patch to how to modify the guest driver.
> I reserve 512 bytes as an example, and transfer the header len of the skb in hdr->hdr_len.

Expanding the buffer size to 512 bytes to accomodate PS mode
looks reasonable to me.

However, I don't think we should increase the copy threshold to
512 bytes at the same time.  I don't have any figures myself but
I think if we are to make such a change it should be a separate
one and come with supporting numbers.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
