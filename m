From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Fri, 20 May 2011 02:41:54 +0300
Message-ID: <20110519234154.GA13784@redhat.com>
References: <20110518111734.GO7589@redhat.com>
 <BANLkTi=g_PFfS5653K8ZoQ2Jhp8DhCV1hg@mail.gmail.com>
 <1305729507.32080.6.camel@localhost.localdomain>
 <20110518154746.GA21378@redhat.com>
 <1305734857.32080.53.camel@localhost.localdomain>
 <20110518163633.GB22001@redhat.com>
 <1305737140.32080.59.camel@localhost.localdomain>
 <20110518165138.GD22001@redhat.com>
 <1305738028.32080.66.camel@localhost.localdomain>
 <1305834169.32080.81.camel@localhost.localdomain>
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
In-Reply-To: <1305834169.32080.81.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2011 at 12:42:49PM -0700, Shirley Ma wrote:
> On Wed, 2011-05-18 at 10:00 -0700, Shirley Ma wrote:
> > On Wed, 2011-05-18 at 19:51 +0300, Michael S. Tsirkin wrote:
> > > > > Yes, I agree.  I think for tcpdump, we really need to copy the
> > > data
> > > > > anyway, to avoid guest changing it in between.  So we do that
> > and
> > > then
> > > > > use the copy everywhere, release the old one. Hmm? 
> > > > 
> > > > Yes. Old one use zerocopy, new one use copy data.
> > > > 
> > > > Thanks
> > > > Shirley
> > > 
> > > No, that's wrong, as they might become different with a
> > > malicious guest. As long as we copied already, lets realease
> > > the data and have everyone use the copy. 
> > 
> > Ok, I will patch pskb_expand_head to test it out. 
> 
> I am patching skb_copy, skb_clone, pskb_copy, pskb_expand_head to
> convert a zero-copy skb to a copy skb to avoid this kind of issue.
> 
> This overhead won't impact macvtap/vhost TX zero-copy normally.
> 
> Shirley

OK, that will handle packet socket at least in that it won't crash :)

So the requirements are
- data must be released in a timely fashion (e.g. unlike virtio-net
  tun or bridge)
- no filtering based on data (data is mapped in guest)
- SG support
- HIGHDMA support (on arches where this makes sense)
- on fast path no calls to skb_copy, skb_clone, pskb_copy,
  pskb_expand_head as these are slow

First 2 requirements are a must, all other requirements
are just dependencies to make sure zero copy will be faster
than non zero copy.

Using a new feature bit is probably the simplest approach to
this. macvtap on top of most physical NICs most likely works
correctly so it seems a bit more work than it needs to be,
but it's also the safest one I think ...

-- 
MST
