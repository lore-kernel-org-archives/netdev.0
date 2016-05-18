From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 11:21:29 +0200
Message-ID: <20160518112129.0472b5dc@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
	<20160516070012-mutt-send-email-mst@redhat.com>
	<57397C2B.7000603@redhat.com>
	<20160516105434-mutt-send-email-mst@redhat.com>
	<573A761D.8080909@redhat.com>
	<20160518101631.368e3447@redhat.com>
	<20160518112045-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160518112045-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2016 11:21:59 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Wed, May 18, 2016 at 10:16:31AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > On Tue, 17 May 2016 09:38:37 +0800 Jason Wang <jasowang@redhat.com> wrote:
> >   
> > > >> And if tx_queue_length is not power of 2,
> > > >> we probably need modulus to calculate the capacity.    
> > > > Is that really that important for speed?    
> > > 
> > > Not sure, I can test.  
> > 
> > In my experience, yes, adding a modulus does affect performance.  
> 
> How about simple
> 	if (unlikely(++idx > size))
> 		idx = 0;

So, you are exchanging an AND-operation with a mask, for a
branch-operation.  If the branch predictor is good enough in the CPU
and code-"size" use-case, then I could be just as fast.

I've actually played with a lot of different approaches:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/include/linux/alf_queue_helpers.h

I cannot remember the exact results. I do remember micro benchmarking
showed good results with the advanced "unroll" approach, but IPv4
forwarding, where I know I-cache is getting evicted, showed best
results with the more simpler implementations.


> > > 
> > > Right, this sounds a good solution.  
> > 
> > Good idea.  
> 
> I'm not that sure - it's clearly wasting memory.

Rounding up to power of two.  In this case I don't think the memory
wast is too high.  As we are talking about max 16 bytes elements.

I am concerned about memory in another way. We need to keep these
arrays/rings small, due to data cache usage.  A 4096 ring queue is bad
because e.g. 16*4096=65536 bytes, and typical L1 cache is 32K-64K. As
this is a circular buffer, we walk over this memory all the time, thus
evicting the L1 cache.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
