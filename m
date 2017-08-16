From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tap: XDP support
Date: Wed, 16 Aug 2017 06:45:36 +0300
Message-ID: <20170816064314-mutt-send-email-mst@kernel.org>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
 <1502451678-17358-4-git-send-email-jasowang@redhat.com>
 <20170811161223.6808008d@cakuba.netronome.com>
 <8876b3d1-699c-d033-e855-34b24a709c81@redhat.com>
 <20170814185951-mutt-send-email-mst@kernel.org>
 <1f2ad15c-967d-fee1-b483-891f91682d9e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jakub Kicinski <kubakici@wp.pl>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1f2ad15c-967d-fee1-b483-891f91682d9e@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2017 at 01:02:05PM +0800, Jason Wang wrote:
> 
> 
> On 2017年08月15日 00:01, Michael S. Tsirkin wrote:
> > On Sat, Aug 12, 2017 at 10:48:49AM +0800, Jason Wang wrote:
> > > 
> > > On 2017年08月12日 07:12, Jakub Kicinski wrote:
> > > > On Fri, 11 Aug 2017 19:41:18 +0800, Jason Wang wrote:
> > > > > This patch tries to implement XDP for tun. The implementation was
> > > > > split into two parts:
> > > > > 
> > > > > - fast path: small and no gso packet. We try to do XDP at page level
> > > > >     before build_skb(). For XDP_TX, since creating/destroying queues
> > > > >     were completely under control of userspace, it was implemented
> > > > >     through generic XDP helper after skb has been built. This could be
> > > > >     optimized in the future.
> > > > > - slow path: big or gso packet. We try to do it after skb was created
> > > > >     through generic XDP helpers.
> > > > > 
> > > > > Test were done through pktgen with small packets.
> > > > > 
> > > > > xdp1 test shows ~41.1% improvement:
> > > > > 
> > > > > Before: ~1.7Mpps
> > > > > After:  ~2.3Mpps
> > > > > 
> > > > > xdp_redirect to ixgbe shows ~60% improvement:
> > > > > 
> > > > > Before: ~0.8Mpps
> > > > > After:  ~1.38Mpps
> > > > > 
> > > > > Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> > > > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > > Looks OK to me now :)
> > > > 
> > > > Out of curiosity, you say the build_skb() is for "small packets", and it
> > > > seems you are always reserving the 256B regardless of XDP being
> > > > installed.  Does this have no performance impact on non-XDP case?
> > > Have a test, only less than 1% were noticed which I think could be ignored.
> > > 
> > > Thanks
> > What did you test btw?
> 
> Pktgen
> 
> >   The biggest issue would be with something like
> > UDP with short packets.
> > 
> 
> Note that we do this only when sndbuf is INT_MAX. So this is probably not an
> issue.

I'd expect to see the issue for guest to host when the packets are
queued at a UDP socket in host.

> The only thing matter is more stress to page allocator, but according
> to the result of pktgen it was very small that could be ignored.
> 
> Thanks

Besides guest to host, for bridging in host bigger truesize might affect
byte queue counts as well.

-- 
MST
