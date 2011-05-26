From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Thu, 26 May 2011 11:49:16 +0300
Message-ID: <20110526084916.GA17928@redhat.com>
References: <1305729507.32080.6.camel@localhost.localdomain>
 <20110518154746.GA21378@redhat.com>
 <1305734857.32080.53.camel@localhost.localdomain>
 <20110518163633.GB22001@redhat.com>
 <1305737140.32080.59.camel@localhost.localdomain>
 <20110518165138.GD22001@redhat.com>
 <1305738028.32080.66.camel@localhost.localdomain>
 <1305834169.32080.81.camel@localhost.localdomain>
 <20110519234154.GA13784@redhat.com>
 <1306363780.26270.44.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1306363780.26270.44.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 03:49:40PM -0700, Shirley Ma wrote:
> On Fri, 2011-05-20 at 02:41 +0300, Michael S. Tsirkin wrote:
> > So the requirements are
> > - data must be released in a timely fashion (e.g. unlike virtio-net
> >   tun or bridge)
> The current patch doesn't enable tun zero-copy. tun will copy data It's
> not an issue now.
> We can disallow macvtap attach to bridge when
> zero-copy is enabled.

Attach macvtap to a tun device though. Or e.g. veth device ...
So there should be so generic way to disable zerocopy.
It can either be a whitelist or a blacklist.

> 
> > - SG support
> > - HIGHDMA support (on arches where this makes sense)
> 
> This can be checked by device flags.

OK, but pls note that SG can get turned off dynamically.

> > - no filtering based on data (data is mapped in guest)
> 
> > - on fast path no calls to skb_copy, skb_clone, pskb_copy,
> >   pskb_expand_head as these are slow
> 
> Any calls to skb_copy, skb_clone, pskb_copy, pskb_expand_head will do a
> copy. The performance should be the same as none zero-copy case before.

I'm guessing a copy is cheaper than get_user_pages+copy+put_page.
But maybe not by much. Care checking that?

> I have done/tested the patch V6, will send it out for review tomorrow.
> 
> I am looking at where there are some cases, skb remains the same for
> filtering.

To reliably filter on data I think we'll need to copy it first, otherwise
guest can change it. Most filters only look at the header though.

> > First 2 requirements are a must, all other requirements
> > are just dependencies to make sure zero copy will be faster
> > than non zero copy.
> > Using a new feature bit is probably the simplest approach to
> > this. macvtap on top of most physical NICs most likely works
> > correctly so it seems a bit more work than it needs to be,
> > but it's also the safest one I think ... 
> 
> For "macvtap/vhost zero-copy" we can use SG & HIGHDMA to enable it, it
> looks safe to me once patching skb_copy, skb_clone, pskb_copy,
> pskb_expand_head.
> 
> To extend zero-copy in other usages, we can have a new feature bit
> later.
> 
> Is that reasonable?
> 
> Thanks
> Shirley

Is the problem is extra work needed to extend feature bits?

-- 
MST
