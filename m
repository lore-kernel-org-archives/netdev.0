From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 29 Sep 2010 10:28:20 +0200
Message-ID: <20100929082820.GC21195@redhat.com>
References: <20100914182707.GB15549@redhat.com>
 <1284490143.13351.82.camel@localhost.localdomain>
 <20100914190156.GA16037@redhat.com>
 <1284492983.13351.95.camel@localhost.localdomain>
 <20100915051241.GA25340@redhat.com>
 <1284531675.24603.259.camel@localhost.localdomain>
 <20100915101000.GB28016@redhat.com>
 <1284562354.2573.12.camel@localhost.localdomain>
 <1285730669.31343.7.camel@localhost.localdomain>
 <20100929081645.GA21195@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100929081645.GA21195@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2010 at 10:16:45AM +0200, Michael S. Tsirkin wrote:
> On Tue, Sep 28, 2010 at 08:24:29PM -0700, Shirley Ma wrote:
> > Hello Michael,
> > 
> > On Wed, 2010-09-15 at 07:52 -0700, Shirley Ma wrote:
> > > > >  Don't you think once I address vhost_add_used_and_signal update
> > > > > issue, it is a simple and complete patch for macvtap TX zero copy?
> > > > > 
> > > > > Thanks
> > > > > Shirley
> > > > 
> > > > I like the fact that the patch is simple. Unfortunately
> > > > I suspect it'll stop being simple by the time it's complete :) 
> > > 
> > > I can make a try. :)
> > 
> > I compared several approaches for addressing the issue being raised here
> > on how/when to update vhost_add_used_and_signal. The simple approach I
> > have found is:
> > 
> > 1. Adding completion field in struct virtqueue;
> > 2. when it is a zero copy packet, put vhost thread wait for completion
> > to update vhost_add_used_and_signal;
> > 3. passing vq from vhost to macvtap as skb destruct_arg;
> > 4. when skb is freed for the last reference, signal vq completion
> > The test results show same performance as the original patch. How do you
> > think? If it sounds good to you. I will resubmit this reversion patch.
> > The patch still keeps as simple as it was before. :)
> > 
> > Thanks
> > Shirley
> 
> If you look at dev_hard_start_xmit you will see a call
> to skb_orphan_try which often calls the skb destructor.
> So I suspect this is almost equivalent to your original patch,
> and has the same correctness issue.

So you could try doing skb_tx(skb)->prevent_sk_orphan = 1
just to see what will happen. Might be interesting - just
make sure the device doesn't orphan the skb first thing.
I suspect lack of parallelism will result in bad throughput
esp for small messages.

Note this still won't make it correct (this has module unloading
issue, and devices might still orphan skb, clone it, or hang on to
paged data in some other way) but at least closer.

I think you should try testing with guest to external communication,
this will uncover some of these correctness issues for you.
I think netperf also has some flag to check data, might
be a good idea to use it for testing.

> -- 
> MST
