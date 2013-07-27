From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sat, 27 Jul 2013 22:30:10 +0100
Message-ID: <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
References: <1374857234-1442-1-git-send-email-nhorman@tuxdriver.com>
	 <1374883371.1666.56.camel@bwh-desktop.uk.level5networks.com>
	 <1374884670.1666.72.camel@bwh-desktop.uk.level5networks.com>
	 <87k3kbdcmy.fsf@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jay Cliburn <jcliburn@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <stable@vger.kernel.org>
To: Luis Henriques <luis.henriques@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87k3kbdcmy.fsf@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-07-27 at 20:30 +0100, Luis Henriques wrote:
> Ben Hutchings <bhutchings@solarflare.com> writes:
> 
> > On Sat, 2013-07-27 at 01:02 +0100, Ben Hutchings wrote:
> >> On Fri, 2013-07-26 at 12:47 -0400, Neil Horman wrote:
> >> > atl1c uses netdev_alloc_skb to refill its rx dma ring, but that call makes no
> >> > guarantees about the suitability of the memory for use in DMA.  As a result
> >> > we've gotten reports of atl1c drivers occasionally hanging and needing to be
> >> > reset:
> >> > https://bugzilla.kernel.org/show_bug.cgi?id=54021
> >> > 
> >> > Fix this by modifying the call to use the internal version __netdev_alloc_skb,
> >> > where you can set the gfp_mask explicitly to include GFP_DMA.
> >> 
> >> This is a really bad idea.  GFP_DMA means allocation from the ISA DMA
> >> region (< 16 MB).  pci_map_single() takes care of allocating a bounce
> >> buffer if necessary.
[...]
> Just to add a little bit more context (and hopefully not noise), I
> started seeing this issue on 3.7.  Bisection resulted on the following
> first bad commit:
> 
> 69b08f6 net: use bigger pages in __netdev_alloc_frag
> 
> Reverting this commit (and e5e6730 "skbuff: Move definition of
> NETDEV_FRAG_PAGE_MAX_SIZE") solved the problem.
> 
> Note also that I'm seeing this issue on a 32 bits system (64 bits
> isn't supported).  This initially made me think the problem could be
> related with this as 69b08f6 log explicitly refers to 32/64 bit
> archs.  But I failed to find any obvious issue with the patch.

Then it seems like this patch works because passing the GFP_DMA flag to
__netdev_alloc_skb() disables the use of __netdev_alloc_frag() and
results in it calling __alloc_skb().  A better workaround would be for
atl1c to call __alloc_skb() directly.

Perhaps the controller doesn't split RX DMA across PCIe page boundaries
(4K), or some other boundaries at smaller intervals than
NETDEV_FRAG_PAGE_MAX_SIZE.

But I think that perhaps the use of __netdev_alloc_frag() should be made
opt-in.  I doubt this is the only driver whose DMA requirements have
been broken.  Since the Linux DMA API lacks any way for devices to
specify boundaries which would then be observed by pci_map_single(), I
don't think this can be considered simply a driver bug.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
